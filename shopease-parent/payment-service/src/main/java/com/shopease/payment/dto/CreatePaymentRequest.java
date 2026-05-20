package com.shopease.payment.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;
import java.util.UUID;

public record CreatePaymentRequest(
        @NotNull UUID orderId,
        @NotBlank String buyerId,
        @NotNull @DecimalMin("0.0") BigDecimal amount,
        @NotBlank String method
) {
}
