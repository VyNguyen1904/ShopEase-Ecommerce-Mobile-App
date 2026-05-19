package com.shopease.user.controller;

import com.shopease.user.dto.AddressRequest;
import com.shopease.user.dto.UpdateProfileRequest;
import com.shopease.user.dto.UserResponse;
import com.shopease.user.service.TokenService;
import lombok.RequiredArgsConstructor;

import com.shopease.common.dto.ApiResponse;
import com.shopease.user.service.UserService;
import jakarta.validation.Valid;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {
    private final UserService users;
    private final TokenService tokens;



    @GetMapping("/me")
    ApiResponse<UserResponse> me(@RequestHeader(HttpHeaders.AUTHORIZATION) String authorization) {
        return ApiResponse.ok(users.profile(tokens.validateAccessToken(authorization)));
    }

    @PutMapping("/me")
    ApiResponse<UserResponse> updateMe(@RequestHeader(HttpHeaders.AUTHORIZATION) String authorization,
                                       @Valid @RequestBody UpdateProfileRequest request) {
        return ApiResponse.ok(users.updateProfile(tokens.validateAccessToken(authorization), request));
    }

    @PostMapping("/me/addresses")
    @ResponseStatus(HttpStatus.CREATED)
    ApiResponse<UserResponse> addAddress(@RequestHeader(HttpHeaders.AUTHORIZATION) String authorization,
                                         @Valid @RequestBody AddressRequest request) {
        return ApiResponse.created(users.addAddress(tokens.validateAccessToken(authorization), request));
    }

    @PutMapping("/me/addresses/{id}")
    ApiResponse<UserResponse> updateAddress(@RequestHeader(HttpHeaders.AUTHORIZATION) String authorization,
                                            @PathVariable UUID id, @Valid @RequestBody AddressRequest request) {
        return ApiResponse.ok(users.updateAddress(tokens.validateAccessToken(authorization), id, request));
    }

    @DeleteMapping("/me/addresses/{id}")
    ApiResponse<UserResponse> deleteAddress(@RequestHeader(HttpHeaders.AUTHORIZATION) String authorization,
                                            @PathVariable UUID id) {
        return ApiResponse.ok(users.deleteAddress(tokens.validateAccessToken(authorization), id));
    }
}
