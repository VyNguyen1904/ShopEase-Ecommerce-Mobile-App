package com.shopease.cart.dto;

import java.math.BigDecimal;
import java.util.List;

public record CartResponse(
        String userId,
        List<CartItemResponse> items,
        BigDecimal subtotal,
        int totalItems
) {
}
