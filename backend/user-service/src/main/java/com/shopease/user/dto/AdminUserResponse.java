package com.shopease.user.dto;

import java.util.UUID;

public record AdminUserResponse(
    UUID id,
    String username,
    String email,
    String role,
    boolean enabled
) {}
