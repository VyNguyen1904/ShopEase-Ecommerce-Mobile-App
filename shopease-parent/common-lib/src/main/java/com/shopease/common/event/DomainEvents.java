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

    public record OrderItemEvent(Long productId, int quantity) {
    }

    public record OrderPlacedEvent(UUID orderId, String buyerId, List<OrderItemEvent> items, BigDecimal total,
                                   Instant occurredAt) {
    }

    // Commands
    public record ReserveStockCommand(UUID orderId, List<OrderItemEvent> items, Instant occurredAt) {
    }

    public record ProcessPaymentCommand(UUID orderId, String buyerId, BigDecimal amount, String paymentMethod, Instant occurredAt) {
    }

    public record CompensateInventoryCommand(UUID orderId, List<OrderItemEvent> items, Instant occurredAt) {
    }

    // Events
    public record StockReservedEvent(UUID orderId, Instant occurredAt) {
    }

    public record StockReservationFailedEvent(UUID orderId, String reason, Instant occurredAt) {
    }

    public record PaymentProcessedEvent(UUID orderId, UUID transactionId, Instant occurredAt) {
    }

    public record PaymentFailedEvent(UUID orderId, String reason, Instant occurredAt) {
    }

    public record OrderConfirmedEvent(UUID orderId, Instant occurredAt) {
    }

    public record OrderFailedEvent(UUID orderId, String reason, Instant occurredAt) {
    }
}

