package com.shopease.cart.repository;

import com.shopease.cart.model.ProductSnapshot;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.Map;

@Repository
public class ProductSnapshotRepository {
    private final Map<Long, ProductSnapshot> products = Map.of(
            101L, new ProductSnapshot(101L, "Wireless Earbuds Pro", new BigDecimal("649000"),
                    "https://images.unsplash.com/photo-1606220945770-b5b6c2c55bf1"),
            102L, new ProductSnapshot(102L, "Compact Crossbody Bag", new BigDecimal("279000"),
                    "https://images.unsplash.com/photo-1548036328-c9fa89d128fa")
    );

    public ProductSnapshot find(Long productId) {
        return products.getOrDefault(productId, new ProductSnapshot(productId, "Product " + productId, BigDecimal.ZERO, null));
    }
}
