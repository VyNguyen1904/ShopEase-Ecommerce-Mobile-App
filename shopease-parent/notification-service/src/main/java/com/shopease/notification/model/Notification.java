package com.shopease.notification.model;

import java.time.Instant;
import java.util.Map;
import java.util.UUID;

public record Notification(UUID id, String userId, String title, String body, String type, Map<String, String> data,
                           boolean read, String imageUrl, Instant createdAt, Instant readAt) {
    public Notification readNow() {
        return new Notification(id, userId, title, body, type, data, true, imageUrl, createdAt, Instant.now());
    }
}
