package com.shopease.user.service;

import com.shopease.user.dto.*;
import com.shopease.user.model.RefreshToken;
import com.shopease.user.model.UserAccount;
import com.shopease.user.repository.RefreshTokenRepository;
import com.shopease.user.repository.UserRepository;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.Instant;
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

    public TokenResponse register(RegisterRequest request) {
        UserAccount user = userService.createUser(request);
        return returnToken(user);
    }

    public TokenResponse login(LoginRequest request) {
        UserAccount user = users.findByEmailIgnoreCase(request.email())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid email"));
        if (!encoder.matches(request.password(), user.getPasswordHash())) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid password");
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

        if (storedToken.isRevoked()) {
            throw new ResponseStatusException(
                    HttpStatus.UNAUTHORIZED,
                    "Refresh token already revoked"
            );
        }

        if (storedToken.isExpired()) {
            throw new ResponseStatusException(
                    HttpStatus.UNAUTHORIZED,
                    "Refresh token expired"
            );
        }

        TokenService.TokenInfo newAccess = tokenService.sign(userId, role, "access");
        TokenService.TokenInfo newRefresh = tokenService.sign(userId, role, "refresh");
        String newRefreshTokenHash = tokenService.sha256(newRefresh.token());

        storedToken.setRevokedAt(Instant.now());
        storedToken.setReplacedByTokenHash(newRefreshTokenHash);

        saveRefreshToken(userId, newRefresh);

        return new TokenResponse(newAccess.token(), newRefresh.token());
    }

    public void logout(String rawRefreshToken) {
        String tokenHash = tokenService.sha256(rawRefreshToken);

        refreshTokenRepository.findByTokenHash(tokenHash)
                .ifPresent(token -> {
                    if (!token.isRevoked()) {
                        token.setRevokedAt(Instant.now());
                    }
                });
    }

    private void saveRefreshToken(UUID userId, TokenService.TokenInfo tokenInfo) {
        String tokenHash = tokenService.sha256(tokenInfo.token());

        RefreshToken refreshToken = RefreshToken.builder()
                .id(UUID.randomUUID())
                .userId(userId)
                .tokenHash(tokenHash)
                .expiresAt(tokenInfo.expiresAt())
                .createdAt(Instant.now())
                .build();

        refreshTokenRepository.save(refreshToken);
    }

    private TokenResponse returnToken(UserAccount user) {
        TokenService.TokenInfo access = tokenService.sign(user.getId(), user.getRole(), "access");
        TokenService.TokenInfo refresh = tokenService.sign(user.getId(), user.getRole(), "refresh");

        saveRefreshToken(user.getId(), refresh);

        return new TokenResponse(access.token(), refresh.token());
    }
}
