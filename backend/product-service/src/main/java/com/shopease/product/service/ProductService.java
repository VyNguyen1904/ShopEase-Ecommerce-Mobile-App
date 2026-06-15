package com.shopease.product.service;

import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;

import com.shopease.product.client.InventorySyncClient;
import com.shopease.product.dto.CategoryRequest;
import com.shopease.product.dto.CategoryResponse;
import com.shopease.product.dto.ProductRequest;
import com.shopease.product.dto.ProductResponse;
import com.shopease.product.model.Category;
import com.shopease.product.model.Product;
import com.shopease.product.model.ProductStatus;
import com.shopease.product.repository.CategoryRepository;
import com.shopease.product.repository.ProductRepository;
import lombok.experimental.FieldDefaults;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.Locale;
import java.util.Comparator;

import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional(readOnly = true)
@RequiredArgsConstructor
@FieldDefaults(makeFinal = true, level = AccessLevel.PRIVATE)
public class ProductService {
    ProductRepository products;
    CategoryRepository categories;
    InventorySyncClient inventory;

    public List<CategoryResponse> getAllCategories() {
        return categories.findAll().stream().map(CategoryResponse::from).toList();
    }

    @Transactional
    public CategoryResponse createCategory(CategoryRequest request) {
        String slug = toSlug(request.name());
        Category parent = null;
        if (request.parentId() != null) {
            parent = categories.findById(request.parentId())
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "Parent category not found"));
        }
        Category category = new Category(request.name(), slug, request.description(), request.iconUrl(), parent, request.displayOrder(), request.active());
        return CategoryResponse.from(categories.save(category));
    }

    public List<ProductResponse> listProducts(String keyword, Long categoryId, BigDecimal minPrice, BigDecimal maxPrice, String sortBy, String sortDir) {
        String q = keyword == null ? "" : keyword.toLowerCase(Locale.ROOT);

        Comparator<Product> comparator;
        switch (sortBy != null ? sortBy.toLowerCase() : "") {
            case "price":
                comparator = Comparator.comparing(p -> p.getSalePrice() != null ? p.getSalePrice() : p.getBasePrice());
                break;
            case "createdat":
                comparator = Comparator.comparing(Product::getCreatedAt);
                break;
            case "soldcount":
                comparator = Comparator.comparing(Product::getSoldCount);
                break;
            case "avgrating":
                comparator = Comparator.comparing(Product::getAvgRating);
                break;
            default:
                comparator = Comparator.comparing(Product::getId);
        }

        if ("desc".equalsIgnoreCase(sortDir)) {
            comparator = comparator.reversed();
        }

        return products.findByActiveTrueOrderByIdAsc().stream()
                .filter(product -> q.isBlank() || product.getName().toLowerCase(Locale.ROOT).contains(q)
                        || product.getDescription().toLowerCase(Locale.ROOT).contains(q))
                .filter(product -> categoryId == null || product.getCategory().getId().equals(categoryId))
                .filter(product -> minPrice == null || product.getBasePrice().compareTo(minPrice) >= 0)
                .filter(product -> maxPrice == null || (product.getSalePrice() != null ? product.getSalePrice().compareTo(maxPrice) <= 0 : product.getBasePrice().compareTo(maxPrice) <= 0))
                .sorted(comparator)
                .map(ProductResponse::from).toList();
    }

    public List<String> getProductSuggestions(String q) {
        String keyword = q == null ? "" : q.toLowerCase(Locale.ROOT);
        return products.findByActiveTrueOrderByIdAsc().stream()
                .map(Product::getName)
                .filter(name -> keyword.isBlank() || name.toLowerCase(Locale.ROOT).contains(keyword))
                .limit(10)
                .toList();
    }

    public ProductResponse getProductDetail(Long id) {
        return ProductResponse.from(requireProduct(id));
    }

    @Transactional
    public ProductResponse createProduct(String sellerId, ProductRequest request) {
        ProductResponse response = ProductResponse.from(products.save(toProduct(sellerId, request)));
        inventory.updateStock(response.id(), response.stockQuantity());
        return response;
    }

    @Transactional
    public ProductResponse updateProduct(Long id, String sellerId, String userRole, ProductRequest request) {
        Product existing = requireProduct(id);
        if (!"ADMIN".equalsIgnoreCase(userRole) && !existing.getSellerId().equals(sellerId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only the seller who created this product or an admin can update it");
        }

        Category category = categories.findById(request.categoryId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "Category not found"));
        
        existing.update(
                request.name(),
                toSlug(request.name()),
                request.description(),
                category,
                request.basePrice(),
                request.salePrice(),
                request.stockQuantity(),
                request.weightKg(),
                existing.getSellerId(), // Keep the original seller ID
                request.thumbnailUrl(),
                request.imageUrls() == null ? List.of() : request.imageUrls(),
                request.colors() == null ? List.of() : request.colors(),
                request.sizes() == null ? List.of() : request.sizes(),
                request.material(),
                request.fit(),
                request.careInstructions(),
                request.features() == null ? List.of() : request.features(),
                request.status() != null ? request.status() : existing.getStatus(),
                request.isFeatured()
        );
        
        ProductResponse response = ProductResponse.from(products.save(existing));
        inventory.updateStock(response.id(), response.stockQuantity());
        return response;
    }

    @Transactional
    public void deleteProduct(Long id, String sellerId, String userRole) {
        Product product = requireProduct(id);
        if (!"ADMIN".equalsIgnoreCase(userRole) && !product.getSellerId().equals(sellerId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only the seller who created this product or an admin can delete it");
        }
        product.deactivate();
        products.save(product);
    }

    public List<ProductResponse> getProductsBySeller(String sellerId) {
        return products.findByActiveTrueOrderByIdAsc().stream()
                .filter(product -> product.getSellerId().equals(sellerId)).map(ProductResponse::from).toList();
    }

    private Product requireProduct(Long id) {
        return products.findByIdAndActiveTrue(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Product not found"));
    }

    private Product toProduct(String sellerId, ProductRequest request) {
        Category category = categories.findById(request.categoryId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "Category not found"));
        
        return new Product(
                request.name(),
                toSlug(request.name()),
                request.description(),
                category,
                request.basePrice(),
                request.salePrice(),
                request.stockQuantity(),
                0.0, // avgRating
                0,   // reviewCount
                0,   // soldCount
                request.weightKg(),
                sellerId,
                request.thumbnailUrl(),
                request.imageUrls() == null ? List.of() : request.imageUrls(),
                request.colors() == null ? List.of() : request.colors(),
                request.sizes() == null ? List.of() : request.sizes(),
                request.material(),
                request.fit(),
                request.careInstructions(),
                request.features() == null ? List.of() : request.features(),
                request.status() != null ? request.status() : ProductStatus.DRAFT,
                request.isFeatured(),
                true, // active
                Instant.now()
        );
    }

    private String toSlug(String input) {
        return input.toLowerCase(Locale.ROOT)
                .replaceAll("[^a-z0-9]+", "-")
                .replaceAll("(^-|-$)", "");
    }
}
