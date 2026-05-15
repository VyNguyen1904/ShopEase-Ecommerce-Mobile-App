package com.shopease.review.controller;

import com.shopease.common.dto.ApiResponse;
import com.shopease.review.dto.ReviewDtos.ReviewRequest;
import com.shopease.review.model.Review;
import com.shopease.review.service.ReviewService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/reviews")
public class ReviewController {
    private final ReviewService reviews;

    public ReviewController(ReviewService reviews) {
        this.reviews = reviews;
    }

    @GetMapping("/products/{productId}")
    ApiResponse<List<Review>> byProduct(@PathVariable Long productId) {
        return ApiResponse.ok(reviews.byProduct(productId));
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    ApiResponse<Review> create(@RequestHeader(value = "X-User-Id", defaultValue = "demo-buyer") String buyerId,
                               @Valid @RequestBody ReviewRequest request) {
        return ApiResponse.created(reviews.create(buyerId, request));
    }

    @PostMapping("/{id}/helpful")
    ApiResponse<Review> helpful(@PathVariable UUID id) {
        return ApiResponse.ok(reviews.helpful(id));
    }
}
