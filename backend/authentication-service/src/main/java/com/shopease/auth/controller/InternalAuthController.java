package com.shopease.auth.controller;

import com.shopease.auth.dto.UserTokenInfo;
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
    public ApiResponse<UserTokenInfo> validate(@RequestParam String token) {
        try {
            UserTokenInfo tokenInfo = tokenValidatorService.validateAndGetTokenInfo(token);
            return ApiResponse.ok(tokenInfo);
        } catch (Exception e) {
            return ApiResponse.error("Unauthorized: " + e.getMessage());
        }
    }
}