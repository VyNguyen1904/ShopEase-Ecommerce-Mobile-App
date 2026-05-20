package com.shopease.inventory.dto;

import com.shopease.inventory.model.InventoryItem;

import java.time.Instant;

public record InventoryResponse(
        Long productId,
        int availableQty,
        int reservedQty,
        Instant updatedAt
) {
    public static InventoryResponse from(InventoryItem item) {
        if (item == null) {
            return null;
        }
        return new InventoryResponse(
                item.getProductId(),
                item.getAvailableQty(),
                item.getReservedQty(),
                item.getUpdatedAt()
        );
    }
}
