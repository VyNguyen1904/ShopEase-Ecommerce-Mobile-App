package com.shopease.product.model;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;

public record Product(Long id, String name, String description, Category category, BigDecimal price, int stockQuantity,
                      double averageRating, String sellerId, String thumbnailUrl, List<String> imageUrls,
                      boolean active, Instant createdAt) {
    public Product inactive() {
        return new Product(id, name, description, category, price, stockQuantity, averageRating, sellerId, thumbnailUrl,
                imageUrls, false, createdAt);
    }
}
