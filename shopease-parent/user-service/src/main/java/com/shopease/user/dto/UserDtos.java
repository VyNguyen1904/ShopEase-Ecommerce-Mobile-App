package com.shopease.user.dto;

import com.shopease.user.model.Address;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public final class UserDtos {
    private UserDtos() {
    }

    public record RegisterRequest(@Email @NotBlank String email, @Size(min = 6) String password,
                                  @NotBlank String fullName, String phone, String role) {
    }

    public record LoginRequest(@Email @NotBlank String email, @NotBlank String password) {
    }

    public record RefreshRequest(@NotBlank String refreshToken) {
    }

    public record UpdateProfileRequest(@NotBlank String fullName, String phone, String avatarUrl) {
    }

    public record AddressRequest(@NotBlank String recipientName, @NotBlank String phone, @NotBlank String street,
                                 @NotBlank String district, @NotBlank String city, boolean defaultAddress) {
    }

    public record LoginResponse(String accessToken, String refreshToken, UserResponse user) {
    }

    public record UserResponse(UUID id, String email, String fullName, String phone, String role, String avatarUrl,
                               List<Address> addresses, Instant createdAt) {
    }
}
