package com.shopease.review.dto;

import com.shopease.review.model.Review;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public final class ReviewDtos {
    private ReviewDtos() {
    }

    public record ReviewRequest(@NotNull Long productId, @NotNull UUID orderId, @Min(1) @Max(5) int rating,
                                @NotBlank @Size(max = 180) String title, @NotBlank @Size(max = 4000) String body,
                                List<String> imageUrls) {
    }

    public record ReviewResponse(UUID id, Long productId, UUID orderId, String buyerId, int rating, String title,
                                 String body, List<String> imageUrls, String status, int helpfulCount,
                                 Instant createdAt) {
        public static ReviewResponse from(Review review) {
            return new ReviewResponse(review.getId(), review.getProductId(), review.getOrderId(), review.getBuyerId(),
                    review.getRating(), review.getTitle(), review.getBody(), review.getImageUrls(), review.getStatus(),
                    review.getHelpfulCount(), review.getCreatedAt());
        }
    }
}
