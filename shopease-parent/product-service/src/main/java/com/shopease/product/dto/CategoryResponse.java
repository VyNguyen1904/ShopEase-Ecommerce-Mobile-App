package com.shopease.product.dto;

import com.shopease.product.model.Category;

public record CategoryResponse(
        Long id,
        String name,
        String slug,
        String description,
        String iconUrl,
        Long parentId,
        int displayOrder,
        boolean active
) {
    public static CategoryResponse from(Category category) {
        if (category == null) {
            return null;
        }
        return new CategoryResponse(
                category.getId(),
                category.getName(),
                category.getSlug(),
                category.getDescription(),
                category.getIconUrl(),
                category.getParent() != null ? category.getParent().getId() : null,
                category.getDisplayOrder(),
                category.isActive()
        );
    }
}
