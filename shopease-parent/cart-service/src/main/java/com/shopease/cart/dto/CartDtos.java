package com.shopease.cart.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;
import java.util.List;

public final class CartDtos {
    private CartDtos() {
    }

    public record CartItemRequest(@NotNull Long productId, @Min(1) int quantity) {
    }

    public record CartItemResponse(Long productId, String productName, BigDecimal priceSnapshot, String imageUrl,
                                   int quantity, BigDecimal subtotal) {
    }

    public record CartResponse(String userId, List<CartItemResponse> items, BigDecimal subtotal, int totalItems) {
    }
}
