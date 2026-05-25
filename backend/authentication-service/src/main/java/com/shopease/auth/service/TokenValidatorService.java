package com.shopease.auth.service;

import com.shopease.auth.dto.UserTokenInfo;
import com.shopease.auth.config.JWTProperties;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class TokenValidatorService {

    private final JWTProperties jwtProperties;

    private SecretKey secretKey() {
        return Keys.hmacShaKeyFor(Decoders.BASE64.decode(jwtProperties.getSecret()));
    }

    public UserTokenInfo validateAndGetTokenInfo(String token) {
        Claims claims = Jwts.parser()
                .verifyWith(secretKey())
                .build()
                .parseSignedClaims(token)
                .getPayload();

        String type = claims.get("type", String.class);
        if (!"access".equals(type)) {
            throw new RuntimeException("Invalid token type");
        }

        String userId = claims.getSubject();
        String role = claims.get("role", String.class);
        return new UserTokenInfo(userId, role);
    }
}
