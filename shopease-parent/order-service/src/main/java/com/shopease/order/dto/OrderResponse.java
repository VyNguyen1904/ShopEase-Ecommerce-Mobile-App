package com.shopease.order.dto;

import com.shopease.common.domain.OrderStatus;
import com.shopease.common.domain.PaymentStatus;
import com.shopease.order.model.Order;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

public record OrderResponse(
    UUID id,
    String buyerId,
    OrderStatus status,
    PaymentStatus paymentStatus,
    List<OrderItemResponse> items,
    BigDecimal subtotal,
    BigDecimal shippingFee,
    BigDecimal discountAmount,
    BigDecimal totalAmount,
    String paymentMethod,
    String shipRecipient,
    String shipPhone,
    String shipStreet,
    String shipDistrict,
    String shipCity,
    String note,
    Instant createdAt
) {
    public static OrderResponse from(Order order) {
        return new OrderResponse(
            order.getId(),
            order.getBuyerId(),
            order.getStatus(),
            order.getPaymentStatus(),
            order.getItems().stream().map(OrderItemResponse::from).toList(),
            order.getSubtotal(),
            order.getShippingFee(),
            order.getDiscountAmount(),
            order.getTotalAmount(),
            order.getPaymentMethod(),
            order.getShipRecipient(),
            order.getShipPhone(),
            order.getShipStreet(),
            order.getShipDistrict(),
            order.getShipCity(),
            order.getNote(),
            order.getCreatedAt()
        );
    }
}
