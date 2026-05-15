package com.shopease.user.model;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public record UserAccount(UUID id, String email, String passwordHash, String fullName, String phone, String role,
                          String avatarUrl, List<Address> addresses, Instant createdAt) {
    public UserAccount withProfile(String fullName, String phone, String avatarUrl) {
        return new UserAccount(id, email, passwordHash, fullName, phone, role, avatarUrl, addresses, createdAt);
    }

    public UserAccount withAddresses(List<Address> addresses) {
        return new UserAccount(id, email, passwordHash, fullName, phone, role, avatarUrl, addresses, createdAt);
    }
}
