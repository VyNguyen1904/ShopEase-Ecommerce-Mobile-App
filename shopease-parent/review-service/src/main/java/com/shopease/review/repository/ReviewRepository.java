package com.shopease.review.repository;

import com.shopease.review.model.Review;
<<<<<<< HEAD
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface ReviewRepository extends JpaRepository<Review, UUID> {
    List<Review> findByProductIdOrderByCreatedAtDesc(Long productId);
=======
import org.springframework.stereotype.Repository;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Repository
public class ReviewRepository {
    private final Map<Long, List<Review>> reviewsByProduct = new ConcurrentHashMap<>();

    public Review save(Review review) {
        List<Review> reviews = reviewsByProduct.computeIfAbsent(review.productId(), ignored -> new ArrayList<>());
        reviews.removeIf(existing -> existing.id().equals(review.id()));
        reviews.add(review);
        return review;
    }

    public List<Review> findByProductId(Long productId) {
        return reviewsByProduct.getOrDefault(productId, List.of()).stream()
                .sorted(Comparator.comparing(Review::createdAt).reversed()).toList();
    }

    public Optional<Review> findById(UUID id) {
        return reviewsByProduct.values().stream().flatMap(List::stream).filter(review -> review.id().equals(id)).findFirst();
    }
>>>>>>> 9f2b30358e4062f0be39eb86dfe53ada7c670722
}
