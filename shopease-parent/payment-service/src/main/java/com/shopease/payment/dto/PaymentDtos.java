package com.shopease.payment.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;
import java.util.UUID;

public final class PaymentDtos {
    private PaymentDtos() {
    }

    public record CreatePaymentRequest(@NotNull UUID orderId, @NotBlank String buyerId,
                                       @DecimalMin("0.0") BigDecimal amount, @NotBlank String method) {
    }

    public record RefundRequest(@DecimalMin("0.0") BigDecimal amount, String reason) {
    }
}
