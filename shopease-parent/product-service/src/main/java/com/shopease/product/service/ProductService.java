package com.shopease.product.service;

import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;

import com.shopease.product.client.InventorySyncClient;
import com.shopease.product.client.SearchIndexClient;
import com.shopease.product.dto.ProductDTO.CategoryRequest;
import com.shopease.product.dto.ProductDTO.CategoryResponse;
import com.shopease.product.dto.ProductDTO.ProductRequest;
import com.shopease.product.dto.ProductDTO.ProductResponse;
import com.shopease.product.model.Category;
import com.shopease.product.model.Product;
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

import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional(readOnly = true)
@RequiredArgsConstructor
@FieldDefaults(makeFinal = true, level = AccessLevel.PRIVATE)
public class ProductService {
     ProductRepository products;
     CategoryRepository categories;
     SearchIndexClient searchIndex;
     InventorySyncClient inventory;


    public List<CategoryResponse> categories() {
        return categories.findAll().stream().map(CategoryResponse::from).toList();
    }

    @Transactional
    public CategoryResponse createCategory(CategoryRequest request) {
        String slug = request.name().toLowerCase(Locale.ROOT).replaceAll("[^a-z0-9]+", "-").replaceAll("(^-|-$)", "");
        return CategoryResponse.from(categories.save(new Category(request.name(), slug, request.description())));
    }

    public List<ProductResponse> products(String keyword, Long categoryId, BigDecimal minPrice, BigDecimal maxPrice) {
        String q = keyword == null ? "" : keyword.toLowerCase(Locale.ROOT);
        return products.findByActiveTrueOrderByIdAsc().stream()
                .filter(product -> q.isBlank() || product.getName().toLowerCase(Locale.ROOT).contains(q)
                        || product.getDescription().toLowerCase(Locale.ROOT).contains(q))
                .filter(product -> categoryId == null || product.getCategory().getId().equals(categoryId))
                .filter(product -> minPrice == null || product.getPrice().compareTo(minPrice) >= 0)
                .filter(product -> maxPrice == null || product.getPrice().compareTo(maxPrice) <= 0)
                .map(ProductResponse::from).toList();
    }

    public ProductResponse product(Long id) {
        return ProductResponse.from(requireProduct(id));
    }

    @Transactional
    public ProductResponse create(String sellerId, ProductRequest request) {
        ProductResponse response = ProductResponse.from(products.save(toProduct(sellerId, request)));
        inventory.upsert(response.id(), response.stockQuantity());
        searchIndex.upsert(response);
        return response;
    }

    @Transactional
    public ProductResponse update(Long id, String sellerId, ProductRequest request) {
        Product existing = requireProduct(id);
        Category category = categories.findById(request.categoryId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "Category not found"));
        existing.update(request.name(), request.description(), category, request.price(), request.stockQuantity(), sellerId,
                request.thumbnailUrl(), request.imageUrls() == null ? List.of() : request.imageUrls());
        ProductResponse response = ProductResponse.from(products.save(existing));
        inventory.upsert(response.id(), response.stockQuantity());
        searchIndex.upsert(response);
        return response;
    }

    @Transactional
    public void delete(Long id) {
        Product product = requireProduct(id);
        product.deactivate();
        products.save(product);
        searchIndex.delete(id);
    }

    public List<ProductResponse> bySeller(String sellerId) {
        return products.findByActiveTrueOrderByIdAsc().stream()
                .filter(product -> product.getSellerId().equals(sellerId)).map(ProductResponse::from).toList();
    }

    public List<ProductResponse> flashSale() {
        return products.findByActiveTrueOrderByIdAsc().stream()
                .filter(product -> product.getPrice().compareTo(new BigDecimal("300000")) < 0)
                .map(ProductResponse::from).toList();
    }

    private Product requireProduct(Long id) {
        return products.findByIdAndActiveTrue(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Product not found"));
    }

    private Product toProduct(String sellerId, ProductRequest request) {
        Category category = categories.findById(request.categoryId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "Category not found"));
        return new Product(request.name(), request.description(), category, request.price(), request.stockQuantity(),
                0, sellerId, request.thumbnailUrl(), request.imageUrls() == null ? List.of() : request.imageUrls(),
                true, Instant.now());
    }
}
