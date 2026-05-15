package com.shopease.user.controller;

import com.shopease.common.dto.ApiResponse;
import com.shopease.user.dto.UserDtos.*;
import com.shopease.user.service.UserService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {
    private final UserService users;

    public AuthController(UserService users) {
        this.users = users;
    }

    @PostMapping("/register")
    @ResponseStatus(HttpStatus.CREATED)
    ApiResponse<LoginResponse> register(@Valid @RequestBody RegisterRequest request) {
        return ApiResponse.created(users.register(request));
    }

    @PostMapping("/login")
    ApiResponse<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
        return ApiResponse.ok(users.login(request));
    }

    @PostMapping("/refresh")
    ApiResponse<LoginResponse> refresh(@Valid @RequestBody RefreshRequest request) {
        return ApiResponse.ok(users.refresh(request));
    }

    @PostMapping("/logout")
    ApiResponse<Void> logout() {
        return ApiResponse.ok(null);
    }
}
