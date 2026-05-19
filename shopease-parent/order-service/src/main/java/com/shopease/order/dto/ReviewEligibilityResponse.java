package com.shopease.order.dto;

import java.util.UUID;

public record ReviewEligibilityResponse(
    UUID orderId,
    String buyerId,
    Long productId,
    boolean eligible,
    String reason
) {}
