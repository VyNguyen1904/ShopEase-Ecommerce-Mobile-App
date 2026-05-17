package com.shopease.notification.controller;

import lombok.RequiredArgsConstructor;

import com.shopease.common.dto.ApiResponse;
import com.shopease.notification.dto.NotificationDtos.NotificationRequest;
import com.shopease.notification.model.Notification;
import com.shopease.notification.service.NotificationService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
public class NotificationController {
    private final NotificationService notifications;



    @GetMapping
    ApiResponse<List<Notification>> inbox(@RequestHeader(value = "X-User-Id", defaultValue = "demo-buyer") String userId) {
        return ApiResponse.ok(notifications.inbox(userId));
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    ApiResponse<Notification> create(@Valid @RequestBody NotificationRequest request) {
        return ApiResponse.created(notifications.create(request));
    }

    @PatchMapping("/{id}/read")
    ApiResponse<Notification> read(@RequestHeader(value = "X-User-Id", defaultValue = "demo-buyer") String userId,
                                   @PathVariable UUID id) {
        return ApiResponse.ok(notifications.read(userId, id));
    }
}
