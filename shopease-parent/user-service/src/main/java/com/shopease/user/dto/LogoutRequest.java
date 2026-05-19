package com.shopease.user.dto;

import jakarta.validation.constraints.NotBlank;

public record LogoutRequest(
        @NotBlank String refreshToken
) {
}
