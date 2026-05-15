package com.shopease.product.service;

import com.shopease.product.dto.ProductDtos.CategoryRequest;
import com.shopease.product.dto.ProductDtos.ProductRequest;
import com.shopease.product.model.Category;
import com.shopease.product.model.Product;
import com.shopease.product.repository.CategoryRepository;
import com.shopease.product.repository.ProductRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.Locale;

@Service
public class ProductService {
    private final ProductRepository products;
    private final CategoryRepository categories;

    public ProductService(ProductRepository products, CategoryRepository categories) {
        this.products = products;
        this.categories = categories;
    }

    public List<Category> categories() {
        return categories.findAll();
    }

    public Category createCategory(CategoryRequest request) {
        String slug = request.name().toLowerCase(Locale.ROOT).replaceAll("[^a-z0-9]+", "-").replaceAll("(^-|-$)", "");
        return categories.create(request.name(), slug, request.description());
    }

    public List<Product> products(String keyword, Long categoryId, BigDecimal minPrice, BigDecimal maxPrice) {
        String q = keyword == null ? "" : keyword.toLowerCase(Locale.ROOT);
        return products.findAllActive().stream()
                .filter(product -> q.isBlank() || product.name().toLowerCase(Locale.ROOT).contains(q)
                        || product.description().toLowerCase(Locale.ROOT).contains(q))
                .filter(product -> categoryId == null || product.category().id().equals(categoryId))
                .filter(product -> minPrice == null || product.price().compareTo(minPrice) >= 0)
                .filter(product -> maxPrice == null || product.price().compareTo(maxPrice) <= 0)
                .toList();
    }

    public Product product(Long id) {
        return products.findActiveById(id).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Product not found"));
    }

    public Product create(String sellerId, ProductRequest request) {
        return products.save(toProduct(products.nextId(), sellerId, request, true));
    }

    public Product update(Long id, String sellerId, ProductRequest request) {
        Product existing = product(id);
        return products.save(toProduct(id, sellerId, request, existing.active()));
    }

    public void delete(Long id) {
        products.save(product(id).inactive());
    }

    public List<Product> bySeller(String sellerId) {
        return products.findAllActive().stream().filter(product -> product.sellerId().equals(sellerId)).toList();
    }

    public List<Product> flashSale() {
        return products.findAllActive().stream().filter(product -> product.price().compareTo(new BigDecimal("300000")) < 0).toList();
    }

    private Product toProduct(Long id, String sellerId, ProductRequest request, boolean active) {
        Category category = categories.findById(request.categoryId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "Category not found"));
        return new Product(id, request.name(), request.description(), category, request.price(), request.stockQuantity(),
                0, sellerId, request.thumbnailUrl(), request.imageUrls() == null ? List.of() : request.imageUrls(),
                active, Instant.now());
    }
}
