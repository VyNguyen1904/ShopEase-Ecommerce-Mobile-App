package com.shopease.search.model;

import java.math.BigDecimal;
import java.time.Instant;

public record ProductDocument(Long id, String name, String description, String categoryName, BigDecimal price,
                              int stockQuantity, double averageRating, String sellerId, boolean active,
                              Instant updatedAt) {
    public ProductDocument inactive() {
        return new ProductDocument(id, name, description, categoryName, price, stockQuantity, averageRating, sellerId,
                false, Instant.now());
    }
}
