package com.shopease.cart.model;

import java.math.BigDecimal;
import java.io.Serializable;
import java.time.Instant;

public record CartItem(Long productId, BigDecimal price, int quantity,
                       String color, String size,
                       Instant addedAt) implements Serializable {
}
