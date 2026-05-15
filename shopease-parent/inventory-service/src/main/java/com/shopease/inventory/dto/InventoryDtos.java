package com.shopease.inventory.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

public final class InventoryDtos {
    private InventoryDtos() {
    }

    public record StockRequest(@Min(0) int availableQty, @Min(0) int reservedQty) {
    }

    public record ReservationRequest(@NotNull Long productId, @Min(1) int quantity) {
    }
}
