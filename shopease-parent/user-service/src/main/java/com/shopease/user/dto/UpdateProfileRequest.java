package com.shopease.user.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record UpdateProfileRequest(@NotBlank @Size(max = 160) String fullName,
                                   @Size(max = 40) String phone,
                                   @Size(max = 1000) String avatarUrl) {
}
