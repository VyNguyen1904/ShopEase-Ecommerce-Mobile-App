package com.shopease.notification.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.Instant;
import java.util.Map;
import java.util.UUID;

@Entity
@Table(name = "notifications")
public class Notification {

    @Id
    @Column(nullable = false, updatable = false)
    private UUID id;

    @Column(nullable = false)
    private String userId;

    @Column(nullable = false)
    private String title;

    @Column(nullable = false, length = 2000)
    private String body;

    @Column(nullable = false, length = 50)
    private String type;

    @org.hibernate.annotations.JdbcTypeCode(org.hibernate.type.SqlTypes.JSON)
    @Column(columnDefinition = "jsonb")
    private Map<String, String> data;

    @Column(nullable = false)
    private boolean read;

    @Column(length = 512)
    private String imageUrl;

    @Column(nullable = false, updatable = false)
    private Instant createdAt;

    private Instant readAt;

    protected Notification() {
    }

    public Notification(UUID id, String userId, String title, String body, String type,
                        Map<String, String> data, boolean read, String imageUrl,
                        Instant createdAt, Instant readAt) {
        this.id = id;
        this.userId = userId;
        this.title = title;
        this.body = body;
        this.type = type;
        this.data = data;
        this.read = read;
        this.imageUrl = imageUrl;
        this.createdAt = createdAt;
        this.readAt = readAt;
    }

    public Notification readNow() {
        return new Notification(id, userId, title, body, type, data, true, imageUrl, createdAt, Instant.now());
    }

    public UUID getId() { return id; }
    public String getUserId() { return userId; }
    public String getTitle() { return title; }
    public String getBody() { return body; }
    public String getType() { return type; }
    public Map<String, String> getData() { return data; }
    public boolean isRead() { return read; }
    public String getImageUrl() { return imageUrl; }
    public Instant getCreatedAt() { return createdAt; }
    public Instant getReadAt() { return readAt; }
}
