package com.shopease.notification.service;

import com.shopease.notification.dto.NotificationEvent;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class KafkaConsumer {
    private final NotificationService notificationService;

    @KafkaListener(topics = "notification-events", groupId = "notification-group")
    public void consumeNotificationEvent(NotificationEvent event) {
        log.info("Received notification event: {}", event);
        notificationService.processNotification(event);
    }
}
