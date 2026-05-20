package com.shopease.product.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record CategoryRequest(
        @NotBlank @Size(max = 120) String name,
        @Size(max = 1000) String description,
        String iconUrl,
        Long parentId,
        int displayOrder,
        boolean active
) {
}
