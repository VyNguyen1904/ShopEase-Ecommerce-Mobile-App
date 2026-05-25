package com.shopease.order.dto;

import com.shopease.order.model.OrderItem;
import java.math.BigDecimal;

public record OrderItemResponse(
    Long id,
    Long productId,
    String productName,
    String productImage,
    BigDecimal unitPrice,
    int quantity,
    BigDecimal subtotal
) {
    public static OrderItemResponse from(OrderItem item) {
        return new OrderItemResponse(
            item.getId(),
            item.getProductId(),
            item.getProductName(),
            item.getProductImage(),
            item.getUnitPrice(),
            item.getQuantity(),
            item.getSubtotal()
        );
    }
}
