package com.shopease.user.dto;

import java.util.Map;

public record UserStatsResponse(
    long totalUsers,
    Map<String, Long> usersByRole,
    long newUsersToday
) {}
