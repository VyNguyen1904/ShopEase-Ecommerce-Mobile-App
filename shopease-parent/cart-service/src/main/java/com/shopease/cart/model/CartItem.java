package com.shopease.cart.model;

import java.math.BigDecimal;
import java.time.Instant;

public record CartItem(Long productId, String productName, BigDecimal priceSnapshot, String imageUrl, int quantity,
                       Instant addedAt) {
}
