package com.shopease.product.dto;

import com.shopease.product.model.Category;
import com.shopease.product.model.Product;
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

    public record CategoryRequest(@NotBlank @Size(max = 120) String name, @Size(max = 1000) String description) {
    }

    public record ProductRequest(@NotBlank @Size(max = 180) String name, @NotBlank @Size(max = 4000) String description,
                                 @NotNull Long categoryId, @NotNull @DecimalMin("0.0") BigDecimal price,
                                 @Min(0) int stockQuantity, @Size(max = 1000) String thumbnailUrl,
                                 List<String> imageUrls) {
    }

    public record CategoryResponse(Long id, String name, String slug, String description) {
        public static CategoryResponse from(Category category) {
            return new CategoryResponse(category.getId(), category.getName(), category.getSlug(), category.getDescription());
        }
    }

    public record ProductResponse(Long id, String name, String description, CategoryResponse category,
                                  BigDecimal price, int stockQuantity, double averageRating, String sellerId,
                                  String thumbnailUrl, List<String> imageUrls, boolean active, Instant createdAt) {
        public static ProductResponse from(Product product) {
            return new ProductResponse(product.getId(), product.getName(), product.getDescription(),
                    CategoryResponse.from(product.getCategory()), product.getPrice(), product.getStockQuantity(),
                    product.getAverageRating(), product.getSellerId(), product.getThumbnailUrl(),
                    product.getImageUrls(), product.isActive(), product.getCreatedAt());
        }
    }
}
