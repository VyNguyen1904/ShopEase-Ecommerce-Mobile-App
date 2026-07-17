package com.shopease.notification.service;

import com.shopease.notification.dto.NotificationEvent;
import com.shopease.notification.model.Notification;
import com.shopease.notification.repository.NotificationRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class NotificationService {
    private final NotificationRepository notificationRepository;
    private final SimpMessagingTemplate messagingTemplate;
    private final com.shopease.notification.repository.DeviceTokenRepository deviceTokenRepository;

    @Transactional
    public void registerDeviceToken(String userId, String token) {
        deviceTokenRepository.deleteByToken(token);
        com.shopease.notification.model.DeviceToken deviceToken = new com.shopease.notification.model.DeviceToken();
        deviceToken.setUserId(userId);
        deviceToken.setToken(token);
        deviceTokenRepository.save(deviceToken);
    }

    @Transactional
    public void processNotification(NotificationEvent event) {
        // Here we could check user preferences before creating
        // (For now, we create for everyone)
        Notification notification = Notification.builder()
                .userId(event.userId())
                .title(event.title())
                .message(event.message())
                .type(event.type())
                .isRead(false)
                .createdAt(Instant.now())
                .build();
        
        Notification saved = notificationRepository.save(notification);
        
        // Push to user via WebSocket
        messagingTemplate.convertAndSend("/topic/notifications/" + event.userId(), saved);

        // Push via Firebase Cloud Messaging
        List<com.shopease.notification.model.DeviceToken> tokens = deviceTokenRepository.findByUserId(event.userId());
        for (com.shopease.notification.model.DeviceToken dt : tokens) {
            try {
                com.google.firebase.messaging.Message fcmMessage = com.google.firebase.messaging.Message.builder()
                        .setToken(dt.getToken())
                        .setNotification(com.google.firebase.messaging.Notification.builder()
                                .setTitle(event.title())
                                .setBody(event.message())
                                .build())
                        .putData("type", event.type())
                        .build();
                com.google.firebase.messaging.FirebaseMessaging.getInstance().send(fcmMessage);
                log.info("Sent FCM push notification to token {}", dt.getToken());
            } catch (Exception e) {
                log.error("Failed to send FCM message to token " + dt.getToken(), e);
            }
        }
    }

    public List<Notification> getUserNotifications(String userId) {
        return notificationRepository.findByUserIdOrderByCreatedAtDesc(userId);
    }

    public long getUnreadCount(String userId) {
        return notificationRepository.countByUserIdAndIsReadFalse(userId);
    }

    @Transactional
    public void markAsRead(UUID notificationId, String userId) {
        notificationRepository.findById(notificationId).ifPresent(notification -> {
            if (notification.getUserId().equals(userId)) {
                notification.setRead(true);
                notificationRepository.save(notification);
            }
        });
    }

    @Transactional
    public void markAllAsRead(String userId) {
        List<Notification> unread = notificationRepository.findByUserIdOrderByCreatedAtDesc(userId)
                .stream().filter(n -> !n.isRead()).toList();
        unread.forEach(n -> n.setRead(true));
        notificationRepository.saveAll(unread);
    }
}
