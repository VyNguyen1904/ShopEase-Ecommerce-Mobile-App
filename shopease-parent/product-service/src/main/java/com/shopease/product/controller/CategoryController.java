package com.shopease.product.controller;

import lombok.RequiredArgsConstructor;

import com.shopease.common.dto.ApiResponse;
import com.shopease.product.dto.ProductDTO.CategoryRequest;
import com.shopease.product.dto.ProductDTO.CategoryResponse;
import com.shopease.product.service.ProductService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/categories")
@RequiredArgsConstructor
public class CategoryController {
    private final ProductService products;



    @GetMapping
    ApiResponse<List<CategoryResponse>> categories() {
        return ApiResponse.ok(products.categories());
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    ApiResponse<CategoryResponse> create(@Valid @RequestBody CategoryRequest request) {
        return ApiResponse.created(products.createCategory(request));
    }
}
