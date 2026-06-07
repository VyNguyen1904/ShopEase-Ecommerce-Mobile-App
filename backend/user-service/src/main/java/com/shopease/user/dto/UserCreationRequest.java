package com.shopease.user.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

public record UserCreationRequest(
    @NotBlank String username,
    @Email @NotBlank String email,
    @NotBlank String password,
    @NotBlank String role
) {}
