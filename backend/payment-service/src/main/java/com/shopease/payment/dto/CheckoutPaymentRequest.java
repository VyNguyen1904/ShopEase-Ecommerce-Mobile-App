package com.shopease.payment.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;

public record CheckoutPaymentRequest(
        @NotBlank String orderId,
        @NotNull @DecimalMin("0.0") BigDecimal amount,
        String currency,
        String cardNumber,
        String cardHolder,
        String expiryDate,
        String cvv,
        @NotBlank String paymentMethod
) {
}
