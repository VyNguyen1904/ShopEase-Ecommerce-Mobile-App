package com.shopease.cart.dto;

import java.math.BigDecimal;

public record CartItemResponse(
        String itemId,
        Long productId,
        String color,
        String size,
        BigDecimal price,
        int quantity,
        BigDecimal subtotal
) {
}
