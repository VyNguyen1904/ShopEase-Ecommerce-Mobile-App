package com.shopease.user.dto;

import com.shopease.user.model.Address;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public record UserResponse(UUID id,
                           String email,
                           String fullName,
                           String phone,
                           String role,
                           List<Address> addresses,
                           Instant createdAt) {
}