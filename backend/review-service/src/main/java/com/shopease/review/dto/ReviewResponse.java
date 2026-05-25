package com.shopease.review.dto;

import com.shopease.review.model.Review;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public record ReviewResponse(
        UUID id,
        Long productId,
        UUID orderId,
        String buyerId,
        int rating,
        String title,
        String body,
        List<String> imageUrls,
        String status,
        int helpfulCount,
        Instant createdAt
) {
    public static ReviewResponse from(Review review) {
        if (review == null) {
            return null;
        }
        return new ReviewResponse(
                review.getId(),
                review.getProductId(),
                review.getOrderId(),
                review.getBuyerId(),
                review.getRating(),
                review.getTitle(),
                review.getBody(),
                review.getImageUrls(),
                review.getStatus(),
                review.getHelpfulCount(),
                review.getCreatedAt()
        );
    }
}
