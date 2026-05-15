package com.shopease.product.config;

import com.shopease.product.model.Category;
import com.shopease.product.model.Product;
import com.shopease.product.repository.CategoryRepository;
import com.shopease.product.repository.ProductRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;

@Configuration
public class ProductDataConfig {
    @Bean
    CommandLineRunner seedCatalog(CategoryRepository categories, ProductRepository products) {
        return args -> {
            if (categories.count() > 0 || products.count() > 0) {
                return;
            }
            Category electronics = categories.save(new Category("Electronics", "electronics", "Phones and gadgets"));
            Category fashion = categories.save(new Category("Fashion", "fashion", "Clothes and bags"));

            products.save(new Product("Wireless Earbuds Pro", "Noise-cancelling earbuds", electronics,
                    new BigDecimal("649000"), 42, 4.8, "seller-demo",
                    "https://images.unsplash.com/photo-1606220945770-b5b6c2c55bf1",
                    List.of("https://images.unsplash.com/photo-1606220945770-b5b6c2c55bf1"), true, Instant.now()));
            products.save(new Product("Compact Crossbody Bag", "Water-resistant daily bag", fashion,
                    new BigDecimal("279000"), 30, 4.6, "seller-demo",
                    "https://images.unsplash.com/photo-1548036328-c9fa89d128fa",
                    List.of("https://images.unsplash.com/photo-1548036328-c9fa89d128fa"), true, Instant.now()));
        };
    }
}
