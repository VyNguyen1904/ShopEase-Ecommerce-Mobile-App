package com.shopease.user.service;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Base64;
import java.util.UUID;

@Service
public class TokenService {
    private static final String SECRET = "shopease-local-development-secret";

    public String sign(UUID userId, String role, String type) {
        long ttl = "refresh".equals(type) ? 604800 : 900;
        String payload = userId + ":" + role + ":" + type + ":" + Instant.now().plusSeconds(ttl).getEpochSecond();
        String body = Base64.getUrlEncoder().withoutPadding().encodeToString(payload.getBytes(StandardCharsets.UTF_8));
        return body + "." + hmac(body);
    }

    public UUID requireUserId(String authorization) {
        if (authorization == null || !authorization.startsWith("Bearer ")) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Missing bearer token");
        }
        return validate(authorization.substring(7), "access");
    }

    public UUID validateRefreshToken(String token) {
        return validate(token, "refresh");
    }

    private UUID validate(String token, String expectedType) {
        String[] parts = token.split("\\.");
        if (parts.length != 2 || !hmac(parts[0]).equals(parts[1])) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid token");
        }
        String[] payload = new String(Base64.getUrlDecoder().decode(parts[0]), StandardCharsets.UTF_8).split(":");
        if (payload.length != 4 || !expectedType.equals(payload[2]) || Instant.now().getEpochSecond() > Long.parseLong(payload[3])) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid token");
        }
        return UUID.fromString(payload[0]);
    }

    private String hmac(String value) {
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            mac.init(new SecretKeySpec(SECRET.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
            return Base64.getUrlEncoder().withoutPadding().encodeToString(mac.doFinal(value.getBytes(StandardCharsets.UTF_8)));
        } catch (Exception ex) {
            throw new IllegalStateException(ex);
        }
    }
}
