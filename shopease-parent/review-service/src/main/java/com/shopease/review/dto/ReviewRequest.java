package com.shopease.review.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.util.List;
import java.util.UUID;

public record ReviewRequest(
        @NotNull Long productId,
        @NotNull UUID orderId,
        @Min(1) @Max(5) int rating,
        @NotBlank @Size(max = 180) String title,
        @NotBlank @Size(max = 4000) String body,
        List<String> imageUrls
) {
}
