package com.shopease.review.model;

import jakarta.persistence.CollectionTable;
import jakarta.persistence.Column;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.Table;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "reviews")
public class Review {
    @Id
    private UUID id;

    @Column(nullable = false)
    private Long productId;

    @Column(nullable = false)
    private UUID orderId;

    @Column(nullable = false)
    private String buyerId;

    @Column(nullable = false)
    private int rating;

    @Column(nullable = false)
    private String title;

    @Column(nullable = false, length = 4000)
    private String body;

    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "review_images", joinColumns = @JoinColumn(name = "review_id"))
    @Column(name = "image_url")
    private List<String> imageUrls = new ArrayList<>();

    @Column(nullable = false)
    private String status;

    @Column(nullable = false)
    private int helpfulCount;

    @Column(nullable = false)
    private Instant createdAt;

    protected Review() {
    }

    public Review(UUID id, Long productId, UUID orderId, String buyerId, int rating, String title, String body,
                  List<String> imageUrls, String status, int helpfulCount, Instant createdAt) {
        this.id = id;
        this.productId = productId;
        this.orderId = orderId;
        this.buyerId = buyerId;
        this.rating = rating;
        this.title = title;
        this.body = body;
        this.imageUrls = new ArrayList<>(imageUrls);
        this.status = status;
        this.helpfulCount = helpfulCount;
        this.createdAt = createdAt;
    }

    public void markHelpful() {
        this.helpfulCount++;
    }

    public UUID getId() {
        return id;
    }

    public Long getProductId() {
        return productId;
    }

    public UUID getOrderId() {
        return orderId;
    }

    public String getBuyerId() {
        return buyerId;
    }

    public int getRating() {
        return rating;
    }

    public String getTitle() {
        return title;
    }

    public String getBody() {
        return body;
    }

    public List<String> getImageUrls() {
        return List.copyOf(imageUrls);
    }

    public String getStatus() {
        return status;
    }

    public int getHelpfulCount() {
        return helpfulCount;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }
}
