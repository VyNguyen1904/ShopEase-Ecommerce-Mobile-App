package com.shopease.product.dto;

import com.shopease.product.model.Product;
import com.shopease.product.model.ProductStatus;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;

public record ProductResponse(
        Long id,
        String name,
        String slug,
        String description,
        CategoryResponse category,
        BigDecimal basePrice,
        BigDecimal salePrice,
        int stockQuantity,
        double avgRating,
        int reviewCount,
        int soldCount,
        BigDecimal weightKg,
        String sellerId,
        String thumbnailUrl,
        List<String> imageUrls,
        List<String> colors,
        List<String> sizes,
        ProductStatus status,
        boolean isFeatured,
        boolean active,
        Instant createdAt,
        Instant updatedAt
) {
    public static ProductResponse from(Product product) {
        if (product == null) {
            return null;
        }
        return new ProductResponse(
                product.getId(),
                product.getName(),
                product.getSlug(),
                product.getDescription(),
                CategoryResponse.from(product.getCategory()),
                product.getBasePrice(),
                product.getSalePrice(),
                product.getStockQuantity(),
                product.getAvgRating(),
                product.getReviewCount(),
                product.getSoldCount(),
                product.getWeightKg(),
                product.getSellerId(),
                product.getThumbnailUrl(),
                product.getImageUrls(),
                product.getColors(),
                product.getSizes(),
                product.getStatus(),
                product.isFeatured(),
                product.isActive(),
                product.getCreatedAt(),
                product.getUpdatedAt()
        );
    }
}
