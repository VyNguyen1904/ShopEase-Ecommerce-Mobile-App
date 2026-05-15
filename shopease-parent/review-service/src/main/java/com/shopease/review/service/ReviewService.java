package com.shopease.review.service;

import com.shopease.review.dto.ReviewDtos.ReviewRequest;
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
@Transactional
public class ReviewService {
    private final ReviewRepository reviews;

    public ReviewService(ReviewRepository reviews) {
        this.reviews = reviews;
    }

    public List<Review> byProduct(Long productId) {
        return reviews.findByProductIdOrderByCreatedAtDesc(productId);
    }

    public Review create(String buyerId, ReviewRequest request) {
        return reviews.save(new Review(UUID.randomUUID(), request.productId(), request.orderId(), buyerId,
                request.rating(), request.title(), request.body(), request.imageUrls() == null ? List.of() : request.imageUrls(),
                "APPROVED", 0, Instant.now()));
    }

    public Review helpful(UUID id) {
        Review review = reviews.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Review not found"));
        review.markHelpful();
        return reviews.save(review);
    }
}
