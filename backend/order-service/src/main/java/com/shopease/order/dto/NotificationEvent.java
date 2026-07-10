package com.shopease.order.dto;

public record NotificationEvent(
    String userId,
    String title,
    String message,
    String type
) {}
