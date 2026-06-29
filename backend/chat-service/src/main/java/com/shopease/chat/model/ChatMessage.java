package com.shopease.chat.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "chat_messages")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChatMessage {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false)
    private UUID roomId;

    @Column(nullable = false)
    private String senderId;

    @Column(nullable = false, length = 1000)
    private String messageText;

    @Column(nullable = false)
    private Instant sentAt;

    @Column(nullable = false)
    private boolean isRead = false;
}
