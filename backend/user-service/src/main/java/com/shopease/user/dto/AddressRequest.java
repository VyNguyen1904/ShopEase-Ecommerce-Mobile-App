package com.shopease.user.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record AddressRequest(@NotBlank @Size(max = 160) String recipientName,
                             @NotBlank @Size(max = 40) String phone,
                             @NotBlank @Size(max = 255) String street,
                             @NotBlank @Size(max = 120) String district,
                             @NotBlank @Size(max = 120) String city,
                             boolean defaultAddress,
                             Double latitude,
                             Double longitude) {
}
