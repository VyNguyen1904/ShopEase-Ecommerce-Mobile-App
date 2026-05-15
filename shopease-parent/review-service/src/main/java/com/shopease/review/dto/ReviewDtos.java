package com.shopease.review.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.util.List;
import java.util.UUID;

public final class ReviewDtos {
    private ReviewDtos() {
    }

    public record ReviewRequest(@NotNull Long productId, @NotNull UUID orderId, @Min(1) @Max(5) int rating,
                                String title, @NotBlank String body, List<String> imageUrls) {
    }
}
