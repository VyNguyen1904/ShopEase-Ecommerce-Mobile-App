package com.shopease.order.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;

import java.util.List;

public final class OrderDtos {
    private OrderDtos() {
    }

    public record CreateOrderRequest(@NotEmpty List<@Valid OrderItemRequest> items, @NotBlank String shipRecipient,
                                     @NotBlank String shipPhone, @NotBlank String shipStreet,
                                     @NotBlank String shipDistrict, @NotBlank String shipCity, String paymentMethod,
                                     String note) {
    }

    public record OrderItemRequest(@NotNull Long productId, @Min(1) int quantity) {
    }
}
