package com.shopease.product.controller;

import lombok.RequiredArgsConstructor;

import com.shopease.common.dto.ApiResponse;
import com.shopease.product.dto.ProductDTO.ProductRequest;
import com.shopease.product.dto.ProductDTO.ProductResponse;
import com.shopease.product.service.ProductService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;

@RestController
@RequestMapping("/api/products")
@RequiredArgsConstructor
public class ProductController {
    private final ProductService products;



    @GetMapping
    ApiResponse<List<ProductResponse>> listProducts(@RequestParam(required = false) String keyword,
                                                    @RequestParam(required = false) Long categoryId,
                                                    @RequestParam(required = false) BigDecimal minPrice,
                                                    @RequestParam(required = false) BigDecimal maxPrice) {
        return ApiResponse.ok(products.listProducts(keyword, categoryId, minPrice, maxPrice));
    }

    @GetMapping("/search")
    ApiResponse<List<ProductResponse>> search(@RequestParam(required = false) String q,
                                              @RequestParam(required = false) Long categoryId,
                                              @RequestParam(required = false) BigDecimal minPrice,
                                              @RequestParam(required = false) BigDecimal maxPrice) {
        return ApiResponse.ok(products.listProducts(q, categoryId, minPrice, maxPrice));
    }

    @GetMapping("/suggestions")
    ApiResponse<List<String>> getProductSuggestions(@RequestParam(defaultValue = "") String q) {
        return ApiResponse.ok(products.getProductSuggestions(q));
    }

    @GetMapping("/{id}")
    ApiResponse<ProductResponse> getProductDetail(@PathVariable Long id) {
        return ApiResponse.ok(products.getProductDetail(id));
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    ApiResponse<ProductResponse> createProduct(@RequestHeader(value = "X-User-Id", defaultValue = "seller-demo") String sellerId,
                                               @Valid @RequestBody ProductRequest request) {
        return ApiResponse.created(products.createProduct(sellerId, request));
    }

    @PutMapping("/{id}")
    ApiResponse<ProductResponse> updateProduct(@PathVariable Long id,
                                               @RequestHeader(value = "X-User-Id", defaultValue = "seller-demo") String sellerId,
                                               @Valid @RequestBody ProductRequest request) {
        return ApiResponse.ok(products.updateProduct(id, sellerId, request));
    }

    @DeleteMapping("/{id}")
    ApiResponse<Void> deleteProduct(@PathVariable Long id) {
        products.deleteProduct(id);
        return ApiResponse.ok(null);
    }

    @GetMapping("/seller/{sellerId}")
    ApiResponse<List<ProductResponse>> getProductsBySeller(@PathVariable String sellerId) {
        return ApiResponse.ok(products.getProductsBySeller(sellerId));
    }
}
