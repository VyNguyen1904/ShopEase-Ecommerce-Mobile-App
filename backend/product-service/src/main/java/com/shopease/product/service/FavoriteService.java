package com.shopease.product.service;

import com.shopease.product.model.Favorite;
import com.shopease.product.model.Product;
import com.shopease.product.repository.FavoriteRepository;
import com.shopease.product.repository.ProductRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

import com.shopease.product.dto.ProductResponse;

@Service
public class FavoriteService {

    private final FavoriteRepository favoriteRepository;
    private final ProductRepository productRepository;

    public FavoriteService(FavoriteRepository favoriteRepository, ProductRepository productRepository) {
        this.favoriteRepository = favoriteRepository;
        this.productRepository = productRepository;
    }

    public List<ProductResponse> getUserFavorites(String userId) {
        return favoriteRepository.findByUserIdOrderByCreatedAtDesc(userId)
                .stream()
                .map(favorite -> ProductResponse.from(favorite.getProduct()))
                .collect(Collectors.toList());
    }

    @Transactional
    public void addFavorite(String userId, Long productId) {
        if (favoriteRepository.findByUserIdAndProductId(userId, productId).isPresent()) {
            return; // Already favorited
        }

        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new IllegalArgumentException("Product not found"));

        Favorite favorite = new Favorite(userId, product);
        favoriteRepository.save(favorite);
    }

    @Transactional
    public void removeFavorite(String userId, Long productId) {
        favoriteRepository.deleteByUserIdAndProductId(userId, productId);
    }
}
