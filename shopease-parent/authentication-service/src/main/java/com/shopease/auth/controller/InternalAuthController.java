package com.shopease.auth.controller;

import com.shopease.auth.service.TokenValidatorService;
import com.shopease.common.dto.ApiResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/internal/auth")
@RequiredArgsConstructor
public class InternalAuthController {

    private final TokenValidatorService tokenValidatorService;

    @GetMapping("/validate")
    public ApiResponse<String> validate(@RequestParam String token) {
        try {
            String userId = tokenValidatorService.validateAndGetUserId(token);
            return ApiResponse.ok(userId);
        } catch (Exception e) {
            return ApiResponse.error(401, "Unauthorized: " + e.getMessage());
        }
    }
}
