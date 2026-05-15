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

import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
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
        return categories.save(new Category(request.name(), slug, request.description()));
    }

    public List<Product> products(String keyword, Long categoryId, BigDecimal minPrice, BigDecimal maxPrice) {
        String q = keyword == null ? "" : keyword.toLowerCase(Locale.ROOT);
        return products.findByActiveTrueOrderByIdAsc().stream()
                .filter(product -> q.isBlank() || product.getName().toLowerCase(Locale.ROOT).contains(q)
                        || product.getDescription().toLowerCase(Locale.ROOT).contains(q))
                .filter(product -> categoryId == null || product.getCategory().getId().equals(categoryId))
                .filter(product -> minPrice == null || product.getPrice().compareTo(minPrice) >= 0)
                .filter(product -> maxPrice == null || product.getPrice().compareTo(maxPrice) <= 0)
                .toList();
    }

    public Product product(Long id) {
        return products.findByIdAndActiveTrue(id).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Product not found"));
    }

    public Product create(String sellerId, ProductRequest request) {
        return products.save(toProduct(sellerId, request));
    }

    public Product update(Long id, String sellerId, ProductRequest request) {
        Product existing = product(id);
        Category category = categories.findById(request.categoryId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "Category not found"));
        existing.update(request.name(), request.description(), category, request.price(), request.stockQuantity(), sellerId,
                request.thumbnailUrl(), request.imageUrls() == null ? List.of() : request.imageUrls());
        return products.save(existing);
    }

    public void delete(Long id) {
        Product product = product(id);
        product.deactivate();
        products.save(product);
    }

    public List<Product> bySeller(String sellerId) {
        return products.findByActiveTrueOrderByIdAsc().stream().filter(product -> product.getSellerId().equals(sellerId)).toList();
    }

    public List<Product> flashSale() {
        return products.findByActiveTrueOrderByIdAsc().stream().filter(product -> product.getPrice().compareTo(new BigDecimal("300000")) < 0).toList();
    }

    private Product toProduct(String sellerId, ProductRequest request) {
        Category category = categories.findById(request.categoryId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "Category not found"));
        return new Product(request.name(), request.description(), category, request.price(), request.stockQuantity(),
                0, sellerId, request.thumbnailUrl(), request.imageUrls() == null ? List.of() : request.imageUrls(),
                true, Instant.now());
    }
}
