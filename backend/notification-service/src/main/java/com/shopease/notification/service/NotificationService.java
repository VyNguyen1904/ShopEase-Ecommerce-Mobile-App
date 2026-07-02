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
