package com.shopease.inventory.model;

import java.time.Instant;

public record InventoryItem(Long productId, int availableQty, int reservedQty, Instant updatedAt) {
}
