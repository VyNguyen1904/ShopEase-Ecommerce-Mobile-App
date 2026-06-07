package com.shopease.user.dto;

import jakarta.validation.constraints.NotBlank;

public record RoleUpdateRequest(
    @NotBlank String role
) {}
