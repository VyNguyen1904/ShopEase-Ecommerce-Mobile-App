package com.shopease.inventory.dto;

import com.shopease.inventory.model.InventoryItem;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

import java.time.Instant;

public final class InventoryDtos {
    private InventoryDtos() {
    }

    public record StockRequest(@Min(0) int availableQty, @Min(0) int reservedQty) {
    }

    public record ReservationRequest(@NotNull Long productId, @Min(1) int quantity) {
    }

    public record InventoryResponse(Long productId, int availableQty, int reservedQty, Instant updatedAt) {
        public static InventoryResponse from(InventoryItem item) {
            return new InventoryResponse(item.getProductId(), item.getAvailableQty(), item.getReservedQty(), item.getUpdatedAt());
        }
    }
}
