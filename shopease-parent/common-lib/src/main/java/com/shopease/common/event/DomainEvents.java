package com.shopease.common.event;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

public final class DomainEvents {
    private DomainEvents() {
    }

    public record UserRegisteredEvent(UUID userId, String email, Instant occurredAt) {
    }

    public record OrderItemEvent(Long productId, String productName, int quantity, BigDecimal unitPrice) {
    }

    public record OrderPlacedEvent(UUID orderId, UUID buyerId, List<OrderItemEvent> items, BigDecimal total,
                                   Instant occurredAt) {
    }

    public record InventoryReservedEvent(UUID orderId, Instant occurredAt) {
    }

    public record InventoryFailedEvent(UUID orderId, Long productId, String reason, Instant occurredAt) {
    }

    public record PaymentCompletedEvent(UUID orderId, UUID transactionId, Instant occurredAt) {
    }

    public record PaymentFailedEvent(UUID orderId, UUID transactionId, String reason, Instant occurredAt) {
    }
}
