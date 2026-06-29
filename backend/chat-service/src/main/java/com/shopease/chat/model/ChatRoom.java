package com.shopease.chat.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "chat_rooms")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChatRoom {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false)
    private String participant1Id; // buyer

    @Column(nullable = false)
    private String participant2Id; // seller or store

    @Column
    private String lastMessage;

    @Column
    private Instant lastMessageAt;

    @Column(nullable = false)
    private Instant createdAt;
}
