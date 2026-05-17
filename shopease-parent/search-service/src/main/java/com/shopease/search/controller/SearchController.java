package com.shopease.search.controller;

import lombok.RequiredArgsConstructor;

import com.shopease.common.dto.ApiResponse;
import com.shopease.search.dto.SearchDtos.ProductDocumentRequest;
import com.shopease.search.model.ProductDocument;
import com.shopease.search.service.SearchService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;

@RestController
@RequestMapping("/api/search")
@RequiredArgsConstructor
public class SearchController {
    private final SearchService search;



    @GetMapping("/products")
    ApiResponse<List<ProductDocument>> products(@RequestParam(required = false) String q,
                                                @RequestParam(required = false) String category,
                                                @RequestParam(required = false) BigDecimal minPrice,
                                                @RequestParam(required = false) BigDecimal maxPrice) {
        return ApiResponse.ok(search.products(q, category, minPrice, maxPrice));
    }

    @GetMapping("/suggestions")
    ApiResponse<List<String>> suggestions(@RequestParam(defaultValue = "") String q) {
        return ApiResponse.ok(search.suggestions(q));
    }

    @PostMapping("/products")
    @ResponseStatus(HttpStatus.CREATED)
    ApiResponse<ProductDocument> upsert(@Valid @RequestBody ProductDocumentRequest request) {
        return ApiResponse.created(search.upsert(request));
    }

    @DeleteMapping("/products/{id}")
    ApiResponse<Void> delete(@PathVariable Long id) {
        search.delete(id);
        return ApiResponse.ok(null);
    }
}
