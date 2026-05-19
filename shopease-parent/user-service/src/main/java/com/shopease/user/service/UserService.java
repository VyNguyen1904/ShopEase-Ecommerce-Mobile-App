package com.shopease.user.service;

import com.shopease.user.config.JWTProperties;
import com.shopease.user.dto.*;
import com.shopease.user.mapper.UserMapper;
import com.shopease.user.model.RefreshToken;
import com.shopease.user.repository.RefreshTokenRepository;
import lombok.RequiredArgsConstructor;

import com.shopease.user.model.Address;
import com.shopease.user.model.UserAccount;
import com.shopease.user.repository.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.UUID;

@Service
@Transactional(readOnly = true)
@RequiredArgsConstructor
public class UserService {
    private final UserRepository users;
    private final BCryptPasswordEncoder encoder;
    private final TokenService tokenService;
    private final UserMapper userMapper;
    private final JWTProperties jwtProperties;
    private final RefreshTokenRepository refreshTokenRepository;

    @Transactional
    public TokenResponse register(RegisterRequest request) {
        String email = request.email().toLowerCase(Locale.ROOT);
        if (users.existsByEmailIgnoreCase(email)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Email is already registered");
        }
        String hashedPassword = encoder.encode(request.password());
        UserAccount user =
                new UserAccount(UUID.randomUUID(), email, hashedPassword,
                        request.fullName(), request.phone(),
                        request.role() == null ? "BUYER" : request.role(),
                        new ArrayList<>(),
                        Instant.now());
        user = users.save(user);
        return returnToken(user);
    }

    public TokenResponse login(LoginRequest request) {
        UserAccount user = users.findByEmailIgnoreCase(request.email())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid email or password"));
        if (!encoder.matches(request.password(), user.getPasswordHash())) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid email or password");
        }
        return returnToken(user);
    }

    /**
     * Refresh rotation:
     * 1. Validate JWT cryptographically
     * 2. Check it is refresh token
     * 3. Look it up in DB
     * 4. Ensure not revoked / not expired
     * 5. Revoke old token
     * 6. Issue new access + refresh token
     */
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

        String newAccessToken = tokenService.sign(userId, role, "access");
        String newRefreshToken = tokenService.sign(userId, role, "refresh");
        String newRefreshTokenHash = tokenService.sha256(newRefreshToken);

        storedToken.setRevokedAt(Instant.now());
        storedToken.setReplacedByTokenHash(newRefreshTokenHash);

        saveRefreshToken(userId, newRefreshToken);

        return new TokenResponse(newAccessToken, newRefreshToken);
    }

    /**
     * Logout:
     * revoke the refresh token if it exists.
     *
     * We make this idempotent:
     * - token found -> revoke
     * - token not found -> do nothing
     */
    public void logout(String rawRefreshToken) {
        String tokenHash = tokenService.sha256(rawRefreshToken);

        refreshTokenRepository.findByTokenHash(tokenHash)
                .ifPresent(token -> {
                    if (!token.isRevoked()) {
                        token.setRevokedAt(Instant.now());
                    }
                });
    }

    private void saveRefreshToken(UUID userId, String rawRefreshToken) {
        String tokenHash = tokenService.sha256(rawRefreshToken);

        Instant expiresAt = Instant.now()
                .plusSeconds(jwtProperties.getRefreshTokenExpiry());

        RefreshToken refreshToken = RefreshToken.builder()
                .id(UUID.randomUUID())
                .userId(userId)
                .tokenHash(tokenHash)
                .expiresAt(expiresAt)
                .createdAt(Instant.now())
                .build();

        refreshTokenRepository.save(refreshToken);
    }

    public UserResponse profile(UUID userId) {
        return userMapper.toResponse(getUserById(userId));
    }

    @Transactional
    public UserResponse updateProfile(UUID userId, UpdateProfileRequest request) {
        UserAccount user = getUserById(userId);
        user.updateProfile(request.fullName(), request.phone());
        return userMapper.toResponse(users.save(user));
    }

    @Transactional
    public UserResponse addAddress(UUID userId, AddressRequest request) {
        UserAccount user = getUserById(userId);
        List<Address> addresses = new ArrayList<>(user.getAddresses());
        if (request.defaultAddress() || addresses.isEmpty()) {
            addresses.replaceAll(address -> address.withDefault(false));
        }
        addresses.add(userMapper.toAddress(request, request.defaultAddress() || addresses.isEmpty(), UUID.randomUUID()));
        user.replaceAddresses(addresses);
        return userMapper.toResponse(users.save(user));
    }

    @Transactional
    public UserResponse updateAddress(UUID userId, UUID addressId, AddressRequest request) {
        UserAccount user = getUserById(userId);
        List<Address> addresses = user.getAddresses().stream()
                .map(address -> address.getId().equals(addressId)
                        ? userMapper.toAddress(request, request.defaultAddress(), addressId)
                        : (request.defaultAddress() ? address.withDefault(false) : address))
                .toList();
        user.replaceAddresses(addresses);
        return userMapper.toResponse(users.save(user));
    }

    @Transactional
    public UserResponse deleteAddress(UUID userId, UUID addressId) {
        UserAccount user = getUserById(userId);
        user.replaceAddresses(user.getAddresses().stream()
                .filter(address -> !address.getId().equals(addressId)).toList());
        return userMapper.toResponse(users.save(user));
    }

    private TokenResponse returnToken(UserAccount user) {
        String accessToken = tokenService.sign(user.getId(), user.getRole(), "access");
        String refreshToken = tokenService.sign(user.getId(), user.getRole(), "refresh");
        return new TokenResponse(accessToken, refreshToken);
    }

    private UserAccount getUserById(UUID id) {
        return users.findById(id).
                orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));
    }
}
