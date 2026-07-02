package com.shopease.order.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import java.util.List;

public record CreateOrderRequest(
    @NotEmpty List<@Valid OrderItemRequest> items,
    @NotBlank String shipRecipient,
    @NotBlank String shipPhone,
    @NotBlank String shipStreet,
    @NotBlank String shipDistrict,
    @NotBlank String shipCity,
    Double shipLatitude,
    Double shipLongitude,
    @Pattern(regexp = "COD|CARD|MOMO|VNPAY", flags = Pattern.Flag.CASE_INSENSITIVE) String paymentMethod,
    @Size(max = 1000) String note
) {}
