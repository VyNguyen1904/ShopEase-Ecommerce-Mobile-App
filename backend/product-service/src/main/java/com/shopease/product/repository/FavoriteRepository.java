package com.shopease.product.repository;

import com.shopease.product.model.Favorite;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface FavoriteRepository extends JpaRepository<Favorite, Long> {
    List<Favorite> findByUserIdOrderByCreatedAtDesc(String userId);
    Optional<Favorite> findByUserIdAndProductId(String userId, Long productId);
    void deleteByUserIdAndProductId(String userId, Long productId);
}
