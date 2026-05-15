package com.shopease.cart.model;

import java.math.BigDecimal;

public record ProductSnapshot(Long productId, String name, BigDecimal price, String imageUrl) {
}
