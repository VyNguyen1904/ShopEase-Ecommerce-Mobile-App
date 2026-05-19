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
    ApiResponse<List<ProductResponse>> products(@RequestParam(required = false) String keyword,
                                                @RequestParam(required = false) Long categoryId,
                                                @RequestParam(required = false) BigDecimal minPrice,
                                                @RequestParam(required = false) BigDecimal maxPrice) {
        return ApiResponse.ok(products.products(keyword, categoryId, minPrice, maxPrice));
    }

    @GetMapping("/search")
    ApiResponse<List<ProductResponse>> search(@RequestParam(required = false) String q,
                                              @RequestParam(required = false) Long categoryId,
                                              @RequestParam(required = false) BigDecimal minPrice,
                                              @RequestParam(required = false) BigDecimal maxPrice) {
        return ApiResponse.ok(products.products(q, categoryId, minPrice, maxPrice));
    }

    @GetMapping("/{id}")
    ApiResponse<ProductResponse> product(@PathVariable Long id) {
        return ApiResponse.ok(products.product(id));
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    ApiResponse<ProductResponse> create(@RequestHeader(value = "X-User-Id", defaultValue = "seller-demo") String sellerId,
                                        @Valid @RequestBody ProductRequest request) {
        return ApiResponse.created(products.create(sellerId, request));
    }

    @PutMapping("/{id}")
    ApiResponse<ProductResponse> update(@PathVariable Long id,
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
    ApiResponse<List<ProductResponse>> sellerProducts(@PathVariable String sellerId) {
        return ApiResponse.ok(products.bySeller(sellerId));
    }

    @GetMapping("/flash-sale")
    ApiResponse<List<ProductResponse>> flashSale() {
        return ApiResponse.ok(products.flashSale());
    }
}
