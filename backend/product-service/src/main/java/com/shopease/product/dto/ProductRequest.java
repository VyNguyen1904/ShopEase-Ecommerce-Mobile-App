package com.shopease.product.dto;

import com.shopease.product.model.ProductStatus;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;
import java.util.List;

public record ProductRequest(
        @NotBlank @Size(max = 180) String name,
        @NotBlank @Size(max = 4000) String description,
        @NotNull Long categoryId,
        @NotNull @DecimalMin("0.0") BigDecimal basePrice,
        BigDecimal salePrice,
        @Min(0) int stockQuantity,
        BigDecimal weightKg,
        @Size(max = 1000) String thumbnailUrl,
        List<String> imageUrls,
        List<String> colors,
        List<String> sizes,
        ProductStatus status,
        boolean isFeatured
) {
}
