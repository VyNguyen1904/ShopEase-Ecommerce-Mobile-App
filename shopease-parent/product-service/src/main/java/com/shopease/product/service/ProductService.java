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

<<<<<<< HEAD
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
=======
@Service
>>>>>>> 9f2b30358e4062f0be39eb86dfe53ada7c670722
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
<<<<<<< HEAD
        return categories.save(new Category(request.name(), slug, request.description()));
=======
        return categories.create(request.name(), slug, request.description());
>>>>>>> 9f2b30358e4062f0be39eb86dfe53ada7c670722
    }

    public List<Product> products(String keyword, Long categoryId, BigDecimal minPrice, BigDecimal maxPrice) {
        String q = keyword == null ? "" : keyword.toLowerCase(Locale.ROOT);
<<<<<<< HEAD
        return products.findByActiveTrueOrderByIdAsc().stream()
                .filter(product -> q.isBlank() || product.getName().toLowerCase(Locale.ROOT).contains(q)
                        || product.getDescription().toLowerCase(Locale.ROOT).contains(q))
                .filter(product -> categoryId == null || product.getCategory().getId().equals(categoryId))
                .filter(product -> minPrice == null || product.getPrice().compareTo(minPrice) >= 0)
                .filter(product -> maxPrice == null || product.getPrice().compareTo(maxPrice) <= 0)
=======
        return products.findAllActive().stream()
                .filter(product -> q.isBlank() || product.name().toLowerCase(Locale.ROOT).contains(q)
                        || product.description().toLowerCase(Locale.ROOT).contains(q))
                .filter(product -> categoryId == null || product.category().id().equals(categoryId))
                .filter(product -> minPrice == null || product.price().compareTo(minPrice) >= 0)
                .filter(product -> maxPrice == null || product.price().compareTo(maxPrice) <= 0)
>>>>>>> 9f2b30358e4062f0be39eb86dfe53ada7c670722
                .toList();
    }

    public Product product(Long id) {
<<<<<<< HEAD
        return products.findByIdAndActiveTrue(id).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Product not found"));
    }

    public Product create(String sellerId, ProductRequest request) {
        return products.save(toProduct(sellerId, request));
=======
        return products.findActiveById(id).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Product not found"));
    }

    public Product create(String sellerId, ProductRequest request) {
        return products.save(toProduct(products.nextId(), sellerId, request, true));
>>>>>>> 9f2b30358e4062f0be39eb86dfe53ada7c670722
    }

    public Product update(Long id, String sellerId, ProductRequest request) {
        Product existing = product(id);
<<<<<<< HEAD
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
=======
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
>>>>>>> 9f2b30358e4062f0be39eb86dfe53ada7c670722
    }
}
