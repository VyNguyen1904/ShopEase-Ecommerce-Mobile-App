package com.shopease.search.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;

public final class SearchDtos {
    private SearchDtos() {
    }

    public record ProductDocumentRequest(@NotNull Long id, @NotBlank String name, @NotBlank String description,
                                         @NotBlank String categoryName, @DecimalMin("0.0") BigDecimal price,
                                         int stockQuantity, double averageRating, String sellerId, boolean active) {
    }
}
