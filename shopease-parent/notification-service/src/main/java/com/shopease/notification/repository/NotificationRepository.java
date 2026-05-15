package com.shopease.notification.repository;

import com.shopease.notification.model.Notification;
import org.springframework.stereotype.Repository;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Repository
public class NotificationRepository {
    private final Map<String, List<Notification>> notifications = new ConcurrentHashMap<>();

    public Notification save(Notification notification) {
        List<Notification> inbox = notifications.computeIfAbsent(notification.userId(), ignored -> new ArrayList<>());
        inbox.removeIf(existing -> existing.id().equals(notification.id()));
        inbox.add(notification);
        return notification;
    }

    public List<Notification> findByUserId(String userId) {
        return notifications.getOrDefault(userId, List.of()).stream()
                .sorted(Comparator.comparing(Notification::createdAt).reversed()).toList();
    }

    public java.util.Optional<Notification> findByUserIdAndId(String userId, UUID id) {
        return notifications.getOrDefault(userId, List.of()).stream().filter(notification -> notification.id().equals(id)).findFirst();
    }
}
