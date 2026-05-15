package com.shopease.order.model;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

public record Order(UUID id, String buyerId, String status, String paymentStatus, List<OrderItem> items,
                    BigDecimal subtotal, BigDecimal shippingFee, BigDecimal discountAmount, BigDecimal totalAmount,
                    String paymentMethod, String shipRecipient, String shipPhone, String shipStreet, String shipDistrict,
                    String shipCity, String note, Instant createdAt) {
    public Order cancelled() {
        return new Order(id, buyerId, "CANCELLED", paymentStatus, items, subtotal, shippingFee, discountAmount,
                totalAmount, paymentMethod, shipRecipient, shipPhone, shipStreet, shipDistrict, shipCity, note, createdAt);
    }
}
