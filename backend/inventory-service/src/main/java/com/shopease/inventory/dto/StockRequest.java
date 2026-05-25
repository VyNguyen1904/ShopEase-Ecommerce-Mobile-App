package com.shopease.inventory.dto;

import jakarta.validation.constraints.Min;

public record StockRequest(
        @Min(0) int availableQty,
        @Min(0) int reservedQty
) {
}
