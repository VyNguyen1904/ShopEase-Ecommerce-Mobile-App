package com.shopease.review.service;

import lombok.RequiredArgsConstructor;

import com.shopease.review.client.OrderClient;
import com.shopease.review.dto.ReviewDtos.ReviewRequest;
import com.shopease.review.dto.ReviewDtos.ReviewResponse;
import com.shopease.review.model.Review;
import com.shopease.review.repository.ReviewRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
@Transactional(readOnly = true)
@RequiredArgsConstructor
public class ReviewService {
    private final ReviewRepository reviews;
    private final OrderClient orders;



    public List<ReviewResponse> byProduct(Long productId) {
        return reviews.findByProductIdOrderByCreatedAtDesc(productId).stream().map(ReviewResponse::from).toList();
    }

    @Transactional
    public ReviewResponse create(String buyerId, ReviewRequest request) {
        orders.requireReviewEligible(buyerId, request.orderId(), request.productId());
        return ReviewResponse.from(reviews.save(new Review(UUID.randomUUID(), request.productId(), request.orderId(), buyerId,
                request.rating(), request.title(), request.body(), request.imageUrls() == null ? List.of() : request.imageUrls(),
                "APPROVED", 0, Instant.now())));
    }

    @Transactional
    public ReviewResponse helpful(UUID id) {
        Review review = reviews.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Review not found"));
        review.markHelpful();
        return ReviewResponse.from(reviews.save(review));
    }
}
