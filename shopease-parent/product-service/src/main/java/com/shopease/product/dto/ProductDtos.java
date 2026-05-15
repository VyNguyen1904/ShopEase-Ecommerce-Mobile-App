package com.shopease.product.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;
import java.util.List;

public final class ProductDtos {
    private ProductDtos() {
    }

    public record CategoryRequest(@NotBlank String name, String description) {
    }

    public record ProductRequest(@NotBlank String name, @NotBlank String description, @NotNull Long categoryId,
                                 @DecimalMin("0.0") BigDecimal price, @Min(0) int stockQuantity, String thumbnailUrl,
                                 List<String> imageUrls) {
    }
}
