package com.shopease.order.client;

import com.shopease.order.model.ProductSnapshot;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.util.Map;

@Component
public class ProductCatalogClient {
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
