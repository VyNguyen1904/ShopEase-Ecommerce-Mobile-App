package com.shopease.payment.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;

public record RefundRequest(
        @NotNull @DecimalMin("0.0") BigDecimal amount,
        String reason
) {
}
