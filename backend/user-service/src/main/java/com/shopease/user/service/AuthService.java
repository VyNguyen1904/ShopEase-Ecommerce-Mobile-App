package com.shopease.user.service;

import com.shopease.user.dto.*;
import com.shopease.user.model.RefreshToken;
import com.shopease.user.model.RefreshTokenFamily;
import com.shopease.user.model.UserAccount;
import com.shopease.user.repository.RefreshTokenFamilyRepository;
import com.shopease.user.repository.RefreshTokenRepository;
import com.shopease.user.repository.UserRepository;
import com.shopease.user.repository.VerificationOtpRepository;
import com.shopease.user.model.VerificationOtp;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
@Transactional
@RequiredArgsConstructor
@FieldDefaults(makeFinal = true, level = AccessLevel.PRIVATE)
public class AuthService {
    UserRepository users;
    UserService userService;
    BCryptPasswordEncoder encoder;
    TokenService tokenService;
    RefreshTokenRepository refreshTokenRepository;
    RefreshTokenFamilyRepository refreshTokenFamilyRepository;
    VerificationOtpRepository verificationOtpRepository;
    MailService mailService;

    public RegisterResponse register(RegisterRequest request) {
        UserAccount user = userService.createUser(request);
        String otp = generateOtp();
        saveOtp(user.getEmail(), otp);
        mailService.sendOtpEmail(user.getEmail(), otp);
        return new RegisterResponse(user.getEmail(), "Please verify your email with the OTP sent to your inbox.");
    }

    public TokenResponse verifyEmail(VerifyEmailRequest request) {
        VerificationOtp storedOtp = verificationOtpRepository.findByEmailIgnoreCase(request.email())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "OTP not found"));

        if (!storedOtp.getOtp().equals(request.otp())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid OTP");
        }

        if (storedOtp.getExpiresAt().isBefore(Instant.now())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "OTP expired");
        }

        UserAccount user = users.findByEmailIgnoreCase(request.email())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));

        userService.verifyUser(user.getId());
        verificationOtpRepository.delete(storedOtp);

        return returnToken(user);
    }

    public void resendOtp(ResendOtpRequest request) {
        UserAccount user = users.findByEmailIgnoreCase(request.email())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));

        if (user.isVerified()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "User is already verified");
        }

        verificationOtpRepository.findByEmailIgnoreCase(request.email())
                .ifPresent(verificationOtpRepository::delete);

        String newOtp = generateOtp();
        saveOtp(user.getEmail(), newOtp);
        mailService.sendOtpEmail(user.getEmail(), newOtp);
    }

    private String generateOtp() {
        return String.format("%06d", new java.util.Random().nextInt(999999));
    }

    private void saveOtp(String email, String otp) {
        VerificationOtp verificationOtp = verificationOtpRepository.findByEmailIgnoreCase(email)
                .orElse(VerificationOtp.builder()
                        .id(UUID.randomUUID())
                        .email(email)
                        .build());
        
        verificationOtp.setOtp(otp);
        verificationOtp.setExpiresAt(Instant.now().plus(5, java.time.temporal.ChronoUnit.MINUTES));
        verificationOtp.setCreatedAt(Instant.now());
        
        verificationOtpRepository.save(verificationOtp);
    }

    public TokenResponse login(LoginRequest request) {
        UserAccount user = users.findByEmailIgnoreCase(request.email())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid email"));
        if (!encoder.matches(request.password(), user.getPasswordHash())) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid password");
        }
        if (!user.isVerified()) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "User account is not verified");
        }
        if (!user.isEnabled()) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "User account is blocked");
        }
        return returnToken(user);
    }

    public TokenResponse refresh(RefreshTokenRequest request) {
        UUID userId = tokenService.validateRefreshToken(request.refreshToken());
        String role = tokenService.getRole(request.refreshToken());

        String currentTokenHash = tokenService.sha256(request.refreshToken());

        RefreshToken storedToken = refreshTokenRepository
                .findByTokenHash(currentTokenHash)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.UNAUTHORIZED,
                        "Refresh token not recognized"
                ));

        // Case F4: Reuse Detection (RT is revoked)
        if (storedToken.isRevoked()) {
            // Revoke entire family
            UUID familyId = storedToken.getFamilyId();
            refreshTokenFamilyRepository.findById(familyId).ifPresent(family -> {
                family.setRevokedAt(Instant.now());
                family.setRevokedReason("COMPROMISED");
                refreshTokenFamilyRepository.save(family);
            });

            // Revoke all tokens in family
            List<RefreshToken> familyTokens = refreshTokenRepository.findAllByFamilyId(familyId);
            for (RefreshToken token : familyTokens) {
                if (!token.isRevoked()) {
                    token.setRevokedAt(Instant.now());
                    token.setRevokedReason("FAMILY_COMPROMISED");
                }
            }
            refreshTokenRepository.saveAll(familyTokens);

            // Increment token_version of user
            UserAccount user = users.findById(userId).orElseThrow();
            user.incrementTokenVersion();
            users.save(user);

            throw new ResponseStatusException(
                    HttpStatus.UNAUTHORIZED,
                    "Refresh token already revoked (Compromised session). Force login."
            );
        }

        if (storedToken.isExpired()) {
            throw new ResponseStatusException(
                    HttpStatus.UNAUTHORIZED,
                    "Refresh token expired"
            );
        }

        // Case F5: Happy Path Rotation
        UserAccount user = users.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "User not found"));
        if (!user.isEnabled()) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "User account is blocked");
        }

        TokenService.TokenInfo newAccess = tokenService.sign(userId, role, "access", user.getTokenVersion());
        TokenService.TokenInfo newRefresh = tokenService.sign(userId, role, "refresh", user.getTokenVersion());
        String newRefreshTokenHash = tokenService.sha256(newRefresh.token());

        storedToken.setRevokedAt(Instant.now());
        storedToken.setRevokedReason("ROTATED");
        storedToken.setReplacedByTokenHash(newRefreshTokenHash);
        refreshTokenRepository.save(storedToken);

        saveRefreshToken(userId, newRefresh, storedToken.getFamilyId());

        refreshTokenFamilyRepository.findById(storedToken.getFamilyId()).ifPresent(family -> {
            family.setLastUsedAt(Instant.now());
            family.setUpdatedAt(Instant.now());
            refreshTokenFamilyRepository.save(family);
        });

        return new TokenResponse(newAccess.token(), newRefresh.token());
    }

    public void logout(String rawRefreshToken) {
        String tokenHash = tokenService.sha256(rawRefreshToken);

        refreshTokenRepository.findByTokenHash(tokenHash)
                .ifPresent(token -> {
                    UUID familyId = token.getFamilyId();
                    // Revoke family
                    refreshTokenFamilyRepository.findById(familyId).ifPresent(family -> {
                        family.setRevokedAt(Instant.now());
                        family.setRevokedReason("USER_LOGOUT");
                        refreshTokenFamilyRepository.save(family);
                    });
                    // Revoke tokens in family
                    List<RefreshToken> familyTokens = refreshTokenRepository.findAllByFamilyId(familyId);
                    for (RefreshToken t : familyTokens) {
                        if (!t.isRevoked()) {
                            t.setRevokedAt(Instant.now());
                            t.setRevokedReason("USER_LOGOUT");
                        }
                    }
                    refreshTokenRepository.saveAll(familyTokens);
                });
    }

    public void logoutAll(UUID userId) {
        List<RefreshTokenFamily> activeFamilies = refreshTokenFamilyRepository.findAllByUserIdAndRevokedAtIsNull(userId);
        for (RefreshTokenFamily family : activeFamilies) {
            family.setRevokedAt(Instant.now());
            family.setRevokedReason("LOGOUT_ALL");
            refreshTokenFamilyRepository.save(family);

            List<RefreshToken> tokens = refreshTokenRepository.findAllByFamilyId(family.getId());
            for (RefreshToken t : tokens) {
                if (!t.isRevoked()) {
                    t.setRevokedAt(Instant.now());
                    t.setRevokedReason("LOGOUT_ALL");
                }
            }
            refreshTokenRepository.saveAll(tokens);
        }

        users.findById(userId).ifPresent(user -> {
            user.incrementTokenVersion();
            users.save(user);
        });
    }

    private void saveRefreshToken(UUID userId, TokenService.TokenInfo tokenInfo, UUID familyId) {
        String tokenHash = tokenService.sha256(tokenInfo.token());

        RefreshToken refreshToken = RefreshToken.builder()
                .id(UUID.randomUUID())
                .userId(userId)
                .familyId(familyId)
                .tokenHash(tokenHash)
                .expiresAt(tokenInfo.expiresAt())
                .createdAt(Instant.now())
                .build();

        refreshTokenRepository.save(refreshToken);
    }

    private TokenResponse returnToken(UserAccount user) {
        // Create new Refresh Token Family
        UUID familyId = UUID.randomUUID();
        RefreshTokenFamily family = RefreshTokenFamily.builder()
                .id(familyId)
                .userId(user.getId())
                .createdAt(Instant.now())
                .updatedAt(Instant.now())
                .lastUsedAt(Instant.now())
                .build();
        refreshTokenFamilyRepository.save(family);

        TokenService.TokenInfo access = tokenService.sign(user.getId(), user.getRole().name(), "access", user.getTokenVersion());
        TokenService.TokenInfo refresh = tokenService.sign(user.getId(), user.getRole().name(), "refresh", user.getTokenVersion());

        saveRefreshToken(user.getId(), refresh, familyId);

        return new TokenResponse(access.token(), refresh.token());
    }
}
