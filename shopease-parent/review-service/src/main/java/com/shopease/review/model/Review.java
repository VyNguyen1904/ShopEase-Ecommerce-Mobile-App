package com.shopease.review.model;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public record Review(UUID id, Long productId, UUID orderId, String buyerId, int rating, String title, String body,
                     List<String> imageUrls, String status, int helpfulCount, Instant createdAt) {
    public Review helpful() {
        return new Review(id, productId, orderId, buyerId, rating, title, body, imageUrls, status,
                helpfulCount + 1, createdAt);
    }
}
