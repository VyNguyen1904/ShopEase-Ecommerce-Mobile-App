package com.shopease.cart.model;

import java.math.BigDecimal;
import java.io.Serializable;
import java.time.Instant;

public record CartItem(Long productId, String productName, BigDecimal priceSnapshot, String imageUrl, int quantity,
                       Instant addedAt) implements Serializable {
}
