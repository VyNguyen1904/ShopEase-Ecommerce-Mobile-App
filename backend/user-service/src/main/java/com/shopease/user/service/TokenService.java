package com.shopease.user.service;

import com.shopease.user.config.JWTProperties;
import com.shopease.user.model.UserAccount;
import com.shopease.user.repository.UserRepository;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Date;
import java.time.Instant;
import java.util.HexFormat;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class TokenService {

    private final JWTProperties jwtProperties;
    private final UserRepository userRepository;

    private SecretKey secretKey() {
        return Keys.hmacShaKeyFor(
                Decoders.BASE64.decode(jwtProperties.getSecret())
        );
    }

    public record TokenInfo(String token, Instant expiresAt) {}

    public TokenInfo sign(UUID userId, String role, String tokenType) {
        return sign(userId, role, tokenType, null);
    }

    public TokenInfo sign(UUID userId, String role, String tokenType, Integer tokenVersion) {
        long ttl = "refresh".equals(tokenType)
                ? jwtProperties.getRefreshTokenExpiry()
                : jwtProperties.getAccessTokenExpiry();

        Instant now = Instant.now();
        Instant expiresAt = now.plusSeconds(ttl);

        var builder = Jwts.builder()
                .subject(userId.toString())
                .claim("role", role)
                .claim("type", tokenType)
                .issuedAt(Date.from(now))
                .expiration(Date.from(expiresAt));

        if (tokenVersion != null) {
            builder.claim("token_version", tokenVersion);
        }

        String token = builder
                .signWith(secretKey())
                .compact();

        return new TokenInfo(token, expiresAt);
    }

    /**
     * Used when Authorization header is:
     * Authorization: Bearer <access-token>
     */
    public UUID getUserId(String authorizationHeader) {
        if (authorizationHeader == null || !authorizationHeader.startsWith("Bearer ")) {
            throw new ResponseStatusException(
                    HttpStatus.UNAUTHORIZED,
                    "Missing Bearer Token"
            );
        }

        return validateAccessToken(authorizationHeader.substring(7));
    }

    public UUID validateAccessToken(String rawAccessToken) {
        Claims claims = parseClaims(rawAccessToken);

        String type = claims.get("type", String.class);
        if (!"access".equals(type)) {
            throw new ResponseStatusException(
                    HttpStatus.UNAUTHORIZED,
                    "Wrong token type"
            );
        }

        UUID userId = UUID.fromString(claims.getSubject());
        Integer tokenVersion = claims.get("token_version", Integer.class);

        if (tokenVersion != null) {
            UserAccount user = userRepository.findById(userId)
                    .orElseThrow(() -> new ResponseStatusException(
                            HttpStatus.UNAUTHORIZED,
                            "User not found"
                    ));
            if (user.getTokenVersion() != tokenVersion) {
                throw new ResponseStatusException(
                        HttpStatus.UNAUTHORIZED,
                        "Token has been invalidated (Force logout)"
                );
            }
        }

        return userId;
    }

    public UUID validateRefreshToken(String rawRefreshToken) {
        Claims claims = parseClaims(rawRefreshToken);

        String type = claims.get("type", String.class);
        if (!"refresh".equals(type)) {
            throw new ResponseStatusException(
                    HttpStatus.UNAUTHORIZED,
                    "Wrong token type"
            );
        }

        return UUID.fromString(claims.getSubject());
    }

    public String getRole(String rawToken) {
        Claims claims = parseClaims(rawToken);
        return claims.get("role", String.class);
    }

    public Instant getExpiration(String rawToken) {
        Claims claims = parseClaims(rawToken);
        return claims.getExpiration().toInstant();
    }

    private Claims parseClaims(String token) {
        try {
            return Jwts.parser()
                    .verifyWith(secretKey())
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();

        } catch (ExpiredJwtException e) {
            throw new ResponseStatusException(
                    HttpStatus.UNAUTHORIZED,
                    "Token expired"
            );

        } catch (JwtException e) {
            throw new ResponseStatusException(
                    HttpStatus.UNAUTHORIZED,
                    "Invalid token"
            );
        }
    }

    public String sha256(String rawToken) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(rawToken.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(hash);
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("SHA-256 algorithm not available", e);
        }
    }
}
