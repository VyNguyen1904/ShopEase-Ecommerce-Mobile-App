package com.shopease.product.controller;

import lombok.RequiredArgsConstructor;

import com.shopease.common.dto.ApiResponse;
import com.shopease.product.dto.ProductDTO.ProductResponse;
import com.shopease.product.service.ProductService;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;

@RestController
@RequestMapping("/api/search")
@RequiredArgsConstructor
public class SearchController {
    private final ProductService products;

    @GetMapping("/products")
    ApiResponse<List<ProductResponse>> search(@RequestParam(required = false) String q,
                                              @RequestParam(required = false) Long categoryId,
                                              @RequestParam(required = false) BigDecimal minPrice,
                                              @RequestParam(required = false) BigDecimal maxPrice) {
        return ApiResponse.ok(products.products(q, categoryId, minPrice, maxPrice));
    }

    @GetMapping("/suggestions")
    ApiResponse<List<String>> suggestions(@RequestParam(defaultValue = "") String q) {
        return ApiResponse.ok(products.suggestions(q));
    }
}
