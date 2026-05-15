package com.shopease.notification.dto;

import jakarta.validation.constraints.NotBlank;

import java.util.Map;

public final class NotificationDtos {
    private NotificationDtos() {
    }

    public record NotificationRequest(@NotBlank String userId, @NotBlank String title, @NotBlank String body,
                                      String type, Map<String, String> data, String imageUrl) {
    }
}
