package com.shopease.notification.service;

import com.shopease.notification.dto.NotificationDtos.NotificationRequest;
import com.shopease.notification.model.Notification;
import com.shopease.notification.repository.NotificationRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
public class NotificationService {
    private final NotificationRepository notifications;

    public NotificationService(NotificationRepository notifications) {
        this.notifications = notifications;
    }

    public List<Notification> inbox(String userId) {
        return notifications.findByUserId(userId);
    }

    public Notification create(NotificationRequest request) {
        return notifications.save(new Notification(UUID.randomUUID(), request.userId(), request.title(), request.body(),
                request.type(), request.data() == null ? Map.of() : request.data(), false, request.imageUrl(),
                Instant.now(), null));
    }

    public Notification read(String userId, UUID id) {
        Notification notification = notifications.findByUserIdAndId(userId, id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Notification not found"));
        return notifications.save(notification.readNow());
    }
}
