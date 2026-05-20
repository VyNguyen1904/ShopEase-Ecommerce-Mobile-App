package com.shopease.product.config;

import com.shopease.product.model.Category;
import com.shopease.product.model.Product;
import com.shopease.product.model.ProductStatus;
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
            Category electronics = categories.save(new Category("Electronics", "electronics", "Phones and gadgets", null, null, 0, true));
            Category fashion = categories.save(new Category("Fashion", "fashion", "Clothes and bags", null, null, 0, true));

            products.save(new Product(
                    "Wireless Earbuds Pro",
                    "wireless-earbuds-pro",
                    "Noise-cancelling earbuds",
                    electronics,
                    new BigDecimal("649000"),
                    null, // salePrice
                    42, // stockQuantity
                    4.8, // avgRating
                    0, // reviewCount
                    0, // soldCount
                    null, // weightKg
                    "seller-demo",
                    "https://images.unsplash.com/photo-1606220945770-b5b6c2c55bf1",
                    List.of("https://images.unsplash.com/photo-1606220945770-b5b6c2c55bf1"),
                    ProductStatus.ACTIVE,
                    true, // isFeatured
                    true, // active
                    Instant.now()
            ));
            products.save(new Product(
                    "Compact Crossbody Bag",
                    "compact-crossbody-bag",
                    "Water-resistant daily bag",
                    fashion,
                    new BigDecimal("279000"),
                    null, // salePrice
                    30, // stockQuantity
                    4.6, // avgRating
                    0, // reviewCount
                    0, // soldCount
                    null, // weightKg
                    "seller-demo",
                    "https://images.unsplash.com/photo-1548036328-c9fa89d128fa",
                    List.of("https://images.unsplash.com/photo-1548036328-c9fa89d128fa"),
                    ProductStatus.ACTIVE,
                    true, // isFeatured
                    true, // active
                    Instant.now()
            ));
        };
    }
}
