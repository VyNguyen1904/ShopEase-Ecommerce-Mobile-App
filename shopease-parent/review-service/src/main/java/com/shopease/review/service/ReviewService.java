package com.shopease.review.service;

import com.shopease.review.dto.ReviewDtos.ReviewRequest;
import com.shopease.review.model.Review;
import com.shopease.review.repository.ReviewRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
<<<<<<< HEAD
import org.springframework.transaction.annotation.Transactional;
=======
>>>>>>> 9f2b30358e4062f0be39eb86dfe53ada7c670722
import org.springframework.web.server.ResponseStatusException;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
<<<<<<< HEAD
@Transactional
=======
>>>>>>> 9f2b30358e4062f0be39eb86dfe53ada7c670722
public class ReviewService {
    private final ReviewRepository reviews;

    public ReviewService(ReviewRepository reviews) {
        this.reviews = reviews;
    }

    public List<Review> byProduct(Long productId) {
<<<<<<< HEAD
        return reviews.findByProductIdOrderByCreatedAtDesc(productId);
=======
        return reviews.findByProductId(productId);
>>>>>>> 9f2b30358e4062f0be39eb86dfe53ada7c670722
    }

    public Review create(String buyerId, ReviewRequest request) {
        return reviews.save(new Review(UUID.randomUUID(), request.productId(), request.orderId(), buyerId,
                request.rating(), request.title(), request.body(), request.imageUrls() == null ? List.of() : request.imageUrls(),
                "APPROVED", 0, Instant.now()));
    }

    public Review helpful(UUID id) {
<<<<<<< HEAD
        Review review = reviews.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Review not found"));
        review.markHelpful();
        return reviews.save(review);
=======
        return reviews.save(reviews.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Review not found")).helpful());
>>>>>>> 9f2b30358e4062f0be39eb86dfe53ada7c670722
    }
}
