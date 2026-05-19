package com.shopease.user.controller;

import com.shopease.user.dto.*;
import lombok.RequiredArgsConstructor;

import com.shopease.common.dto.ApiResponse;
import com.shopease.user.service.UserService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {
    private final UserService userService;

    @PostMapping("/register")
    @ResponseStatus(HttpStatus.CREATED)
    ApiResponse<TokenResponse> register(@Valid @RequestBody RegisterRequest request) {
        return ApiResponse.created(userService.register(request));
    }

    @PostMapping("/login")
    ApiResponse<TokenResponse> login(@Valid @RequestBody LoginRequest request) {
        return ApiResponse.ok(userService.login(request));
    }

    @PostMapping("/refresh")
    ApiResponse<TokenResponse> refresh(@Valid @RequestBody RefreshTokenRequest request) {
        TokenResponse response = userService.refresh(request);
        return ApiResponse.ok(response);
    }

    @PostMapping("/logout")
    ApiResponse<Void> logout(@Valid @RequestBody LogoutRequest request) {
        userService.logout(request.refreshToken());
        return ApiResponse.ok(null);
    }
}
