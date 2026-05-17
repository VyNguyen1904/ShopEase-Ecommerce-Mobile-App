package com.shopease.user.controller;

import lombok.RequiredArgsConstructor;

import com.shopease.common.dto.ApiResponse;
import com.shopease.user.dto.UserDtos.*;
import com.shopease.user.service.TokenService;
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
        return ApiResponse.ok(users.profile(tokens.requireUserId(authorization)));
    }

    @PutMapping("/me")
    ApiResponse<UserResponse> updateMe(@RequestHeader(HttpHeaders.AUTHORIZATION) String authorization,
                                       @Valid @RequestBody UpdateProfileRequest request) {
        return ApiResponse.ok(users.updateProfile(tokens.requireUserId(authorization), request));
    }

    @PostMapping("/me/addresses")
    @ResponseStatus(HttpStatus.CREATED)
    ApiResponse<UserResponse> addAddress(@RequestHeader(HttpHeaders.AUTHORIZATION) String authorization,
                                         @Valid @RequestBody AddressRequest request) {
        return ApiResponse.created(users.addAddress(tokens.requireUserId(authorization), request));
    }

    @PutMapping("/me/addresses/{id}")
    ApiResponse<UserResponse> updateAddress(@RequestHeader(HttpHeaders.AUTHORIZATION) String authorization,
                                            @PathVariable UUID id, @Valid @RequestBody AddressRequest request) {
        return ApiResponse.ok(users.updateAddress(tokens.requireUserId(authorization), id, request));
    }

    @DeleteMapping("/me/addresses/{id}")
    ApiResponse<UserResponse> deleteAddress(@RequestHeader(HttpHeaders.AUTHORIZATION) String authorization,
                                            @PathVariable UUID id) {
        return ApiResponse.ok(users.deleteAddress(tokens.requireUserId(authorization), id));
    }
}
