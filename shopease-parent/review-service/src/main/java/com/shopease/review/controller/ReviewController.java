package com.shopease.review.controller;

import lombok.RequiredArgsConstructor;

import com.shopease.common.dto.ApiResponse;
import com.shopease.review.dto.ReviewDtos.ReviewRequest;
import com.shopease.review.dto.ReviewDtos.ReviewResponse;
import com.shopease.review.service.ReviewService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/reviews")
@RequiredArgsConstructor
public class ReviewController {
    private final ReviewService reviews;



    @GetMapping("/products/{productId}")
    ApiResponse<List<ReviewResponse>> getReviewsByProduct(@PathVariable Long productId) {
        return ApiResponse.ok(reviews.getReviewsByProduct(productId));
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    ApiResponse<ReviewResponse> createReview(@RequestHeader(value = "X-User-Id", defaultValue = "demo-buyer") String buyerId,
                                             @Valid @RequestBody ReviewRequest request) {
        return ApiResponse.created(reviews.createReview(buyerId, request));
    }

    @PostMapping("/{id}/helpful")
    ApiResponse<ReviewResponse> markReviewAsHelpful(@PathVariable UUID id) {
        return ApiResponse.ok(reviews.markReviewAsHelpful(id));
    }
}
