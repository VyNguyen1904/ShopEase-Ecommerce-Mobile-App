package com.shopease.notification.dto;

public record NotificationEvent(
    String userId,
    String title,
    String message,
    String type
) {}
