package com.shopease.user.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record RegisterRequest(@Email @NotBlank String email,
                              @NotBlank @Size(min = 6, max = 128) String password,
                              @NotBlank @Size(max = 160) String fullName,
                              @Size(max = 40) String phone,
                              @Pattern(regexp = "BUYER|SELLER|ADMIN")
                              String role) {
}