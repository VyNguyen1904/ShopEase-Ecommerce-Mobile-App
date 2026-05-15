package com.shopease.order.model;

import java.math.BigDecimal;

public record OrderItem(Long productId, String productName, String productImage, BigDecimal unitPrice, int quantity,
                        BigDecimal subtotal) {
}
