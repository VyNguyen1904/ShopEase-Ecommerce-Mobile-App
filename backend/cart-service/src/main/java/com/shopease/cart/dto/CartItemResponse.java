package com.shopease.cart.dto;

import java.math.BigDecimal;

public record CartItemResponse(
        Long productId,
        BigDecimal price,
        int quantity,
        BigDecimal subtotal
) {
}
