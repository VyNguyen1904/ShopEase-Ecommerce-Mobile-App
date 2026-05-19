package com.shopease.product.dto;

import com.shopease.product.model.Category;
import com.shopease.product.model.Product;
import com.shopease.product.model.ProductStatus;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;

public final class ProductDTO {
    private ProductDTO() {
    }

    public record CategoryRequest(
            @NotBlank @Size(max = 120) String name,
            @Size(max = 1000) String description,
            String iconUrl,
            Long parentId,
            int displayOrder,
            boolean active
    ) {
    }

    public record ProductRequest(
            @NotBlank @Size(max = 180) String name,
            @NotBlank @Size(max = 4000) String description,
            @NotNull Long categoryId,
            @NotNull @DecimalMin("0.0") BigDecimal basePrice,
            BigDecimal salePrice,
            @Min(0) int stockQuantity,
            BigDecimal weightKg,
            @Size(max = 1000) String thumbnailUrl,
            List<String> imageUrls,
            ProductStatus status,
            boolean isFeatured
    ) {
    }

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

    public record ProductResponse(
            Long id,
            String name,
            String slug,
            String description,
            CategoryResponse category,
            BigDecimal basePrice,
            BigDecimal salePrice,
            int stockQuantity,
            double avgRating,
            int reviewCount,
            int soldCount,
            BigDecimal weightKg,
            String sellerId,
            String thumbnailUrl,
            List<String> imageUrls,
            ProductStatus status,
            boolean isFeatured,
            boolean active,
            Instant createdAt,
            Instant updatedAt
    ) {
        public static ProductResponse from(Product product) {
            return new ProductResponse(
                    product.getId(),
                    product.getName(),
                    product.getSlug(),
                    product.getDescription(),
                    CategoryResponse.from(product.getCategory()),
                    product.getBasePrice(),
                    product.getSalePrice(),
                    product.getStockQuantity(),
                    product.getAvgRating(),
                    product.getReviewCount(),
                    product.getSoldCount(),
                    product.getWeightKg(),
                    product.getSellerId(),
                    product.getThumbnailUrl(),
                    product.getImageUrls(),
                    product.getStatus(),
                    product.isFeatured(),
                    product.isActive(),
                    product.getCreatedAt(),
                    product.getUpdatedAt()
            );
        }
    }
}
