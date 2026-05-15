package com.shopease.product.controller;

import com.shopease.common.dto.ApiResponse;
import com.shopease.product.dto.ProductDtos.ProductRequest;
import com.shopease.product.model.Product;
import com.shopease.product.service.ProductService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;

@RestController
@RequestMapping("/api/products")
public class ProductController {
    private final ProductService products;

    public ProductController(ProductService products) {
        this.products = products;
    }

    @GetMapping
    ApiResponse<List<Product>> products(@RequestParam(required = false) String keyword,
                                        @RequestParam(required = false) Long categoryId,
                                        @RequestParam(required = false) BigDecimal minPrice,
                                        @RequestParam(required = false) BigDecimal maxPrice) {
        return ApiResponse.ok(products.products(keyword, categoryId, minPrice, maxPrice));
    }

    @GetMapping("/search")
    ApiResponse<List<Product>> search(@RequestParam(required = false) String q,
                                      @RequestParam(required = false) Long categoryId,
                                      @RequestParam(required = false) BigDecimal minPrice,
                                      @RequestParam(required = false) BigDecimal maxPrice) {
        return ApiResponse.ok(products.products(q, categoryId, minPrice, maxPrice));
    }

    @GetMapping("/{id}")
    ApiResponse<Product> product(@PathVariable Long id) {
        return ApiResponse.ok(products.product(id));
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    ApiResponse<Product> create(@RequestHeader(value = "X-User-Id", defaultValue = "seller-demo") String sellerId,
                                @Valid @RequestBody ProductRequest request) {
        return ApiResponse.created(products.create(sellerId, request));
    }

    @PutMapping("/{id}")
    ApiResponse<Product> update(@PathVariable Long id,
                                @RequestHeader(value = "X-User-Id", defaultValue = "seller-demo") String sellerId,
                                @Valid @RequestBody ProductRequest request) {
        return ApiResponse.ok(products.update(id, sellerId, request));
    }

    @DeleteMapping("/{id}")
    ApiResponse<Void> delete(@PathVariable Long id) {
        products.delete(id);
        return ApiResponse.ok(null);
    }

    @GetMapping("/seller/{sellerId}")
    ApiResponse<List<Product>> sellerProducts(@PathVariable String sellerId) {
        return ApiResponse.ok(products.bySeller(sellerId));
    }

    @GetMapping("/flash-sale")
    ApiResponse<List<Product>> flashSale() {
        return ApiResponse.ok(products.flashSale());
    }
}
