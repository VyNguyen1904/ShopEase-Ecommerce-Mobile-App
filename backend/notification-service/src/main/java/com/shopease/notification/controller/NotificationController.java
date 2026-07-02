package com.shopease.notification.controller;

import com.shopease.common.dto.ApiResponse;
import com.shopease.notification.model.Notification;
import com.shopease.notification.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
public class NotificationController {
    private final NotificationService notificationService;

    @GetMapping
    public ApiResponse<List<Notification>> getNotifications(@RequestHeader("X-User-Id") String userId) {
        return ApiResponse.ok(notificationService.getUserNotifications(userId));
    }

    @GetMapping("/unread-count")
    public ApiResponse<Map<String, Long>> getUnreadCount(@RequestHeader("X-User-Id") String userId) {
        return ApiResponse.ok(Map.of("count", notificationService.getUnreadCount(userId)));
    }

    @PutMapping("/{id}/read")
    public ApiResponse<Void> markAsRead(
            @PathVariable UUID id,
            @RequestHeader("X-User-Id") String userId) {
        notificationService.markAsRead(id, userId);
        return ApiResponse.ok(null);
    }

    @PutMapping("/read-all")
    public ApiResponse<Void> markAllAsRead(@RequestHeader("X-User-Id") String userId) {
        notificationService.markAllAsRead(userId);
        return ApiResponse.ok(null);
    }
}
