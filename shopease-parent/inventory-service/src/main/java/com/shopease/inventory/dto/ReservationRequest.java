package com.shopease.inventory.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

public record ReservationRequest(
        @NotNull Long productId,
        @Min(1) int quantity
) {
}
