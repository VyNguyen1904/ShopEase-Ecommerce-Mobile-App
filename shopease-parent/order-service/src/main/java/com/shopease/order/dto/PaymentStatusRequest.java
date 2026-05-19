package com.shopease.order.dto;

import jakarta.validation.constraints.NotNull;

public record PaymentStatusRequest(
    @NotNull Boolean paid
) {}
