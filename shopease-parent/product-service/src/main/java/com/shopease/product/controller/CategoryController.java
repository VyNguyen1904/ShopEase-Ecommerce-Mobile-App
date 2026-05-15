package com.shopease.product.controller;

import com.shopease.common.dto.ApiResponse;
import com.shopease.product.dto.ProductDtos.CategoryRequest;
import com.shopease.product.model.Category;
import com.shopease.product.service.ProductService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/categories")
public class CategoryController {
    private final ProductService products;

    public CategoryController(ProductService products) {
        this.products = products;
    }

    @GetMapping
    ApiResponse<List<Category>> categories() {
        return ApiResponse.ok(products.categories());
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    ApiResponse<Category> create(@Valid @RequestBody CategoryRequest request) {
        return ApiResponse.created(products.createCategory(request));
    }
}
