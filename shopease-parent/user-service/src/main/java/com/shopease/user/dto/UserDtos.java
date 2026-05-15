package com.shopease.user.dto;

import com.shopease.user.model.Address;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public final class UserDtos {
    private UserDtos() {
    }

    public record RegisterRequest(@Email @NotBlank String email, @NotBlank @Size(min = 6, max = 128) String password,
                                  @NotBlank @Size(max = 160) String fullName, @Size(max = 40) String phone,
                                  @Pattern(regexp = "BUYER|SELLER|ADMIN") String role) {
    }

    public record LoginRequest(@Email @NotBlank String email, @NotBlank String password) {
    }

    public record RefreshRequest(@NotBlank String refreshToken) {
    }

    public record UpdateProfileRequest(@NotBlank @Size(max = 160) String fullName, @Size(max = 40) String phone,
                                       @Size(max = 1000) String avatarUrl) {
    }

    public record AddressRequest(@NotBlank @Size(max = 160) String recipientName, @NotBlank @Size(max = 40) String phone,
                                 @NotBlank @Size(max = 255) String street, @NotBlank @Size(max = 120) String district,
                                 @NotBlank @Size(max = 120) String city, boolean defaultAddress) {
    }

    public record LoginResponse(String accessToken, String refreshToken, UserResponse user) {
    }

    public record UserResponse(UUID id, String email, String fullName, String phone, String role, String avatarUrl,
                               List<Address> addresses, Instant createdAt) {
    }
}
