package com.shopease.product.config;

import com.shopease.product.model.Category;
import com.shopease.product.model.Product;
import com.shopease.product.model.ProductStatus;
import com.shopease.product.repository.CategoryRepository;
import com.shopease.product.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Configuration;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;

@Configuration
@RequiredArgsConstructor
public class DataLoader implements CommandLineRunner {

    private final CategoryRepository categoryRepository;
    private final ProductRepository productRepository;

    @Override
    @Transactional
    public void run(String... args) throws Exception {
        if (categoryRepository.count() > 0) {
            return;
        }

        // Categories
        Category electronics = categoryRepository.save(new Category("Electronics", "electronics", "Latest gadgets and electronics", "https://example.com/icons/electronics.png", null, 1, true));
        Category fashion = categoryRepository.save(new Category("Fashion", "fashion", "Trendy clothes and accessories", "https://example.com/icons/fashion.png", null, 2, true));
        Category home = categoryRepository.save(new Category("Home & Garden", "home-garden", "Everything for your home", "https://example.com/icons/home.png", null, 3, true));

        // Subcategories
        Category smartphones = categoryRepository.save(new Category("Smartphones", "smartphones", "Latest smartphones", "https://example.com/icons/smartphones.png", electronics, 1, true));
        Category laptops = categoryRepository.save(new Category("Laptops", "laptops", "Powerful laptops", "https://example.com/icons/laptops.png", electronics, 2, true));

        // Products
        productRepository.save(new Product(
                "iPhone 15 Pro",
                "iphone-15-pro",
                "The latest iPhone with titanium design.",
                smartphones,
                new BigDecimal("999.00"),
                new BigDecimal("899.00"),
                50,
                4.8,
                120,
                45,
                new BigDecimal("0.187"),
                "seller-apple",
                "https://example.com/images/iphone15pro.png",
                List.of("https://example.com/images/iphone15pro-side.png", "https://example.com/images/iphone15pro-back.png"),
                ProductStatus.ACTIVE,
                true,
                true,
                Instant.now()
        ));

        productRepository.save(new Product(
                "MacBook Pro 14",
                "macbook-pro-14",
                "MacBook Pro with M3 chip.",
                laptops,
                new BigDecimal("1599.00"),
                null,
                30,
                4.9,
                85,
                20,
                new BigDecimal("1.6"),
                "seller-apple",
                "https://example.com/images/macbookpro14.png",
                List.of("https://example.com/images/macbookpro14-open.png"),
                ProductStatus.ACTIVE,
                true,
                true,
                Instant.now()
        ));

        productRepository.save(new Product(
                "Samsung Galaxy S24",
                "samsung-galaxy-s24",
                "New Galaxy with AI features.",
                smartphones,
                new BigDecimal("799.00"),
                new BigDecimal("749.00"),
                60,
                4.7,
                95,
                35,
                new BigDecimal("0.167"),
                "seller-samsung",
                "https://example.com/images/s24.png",
                List.of("https://example.com/images/s24-front.png"),
                ProductStatus.ACTIVE,
                false,
                true,
                Instant.now()
        ));

        productRepository.save(new Product(
                "Cotton T-Shirt",
                "cotton-t-shirt",
                "Comfortable 100% cotton t-shirt.",
                fashion,
                new BigDecimal("19.99"),
                null,
                200,
                4.5,
                250,
                150,
                new BigDecimal("0.2"),
                "seller-fashion",
                "https://example.com/images/tshirt.png",
                List.of("https://example.com/images/tshirt-blue.png", "https://example.com/images/tshirt-red.png"),
                ProductStatus.ACTIVE,
                false,
                true,
                Instant.now()
        ));

        productRepository.save(new Product(
                "Leather Jacket",
                "leather-jacket",
                "Stylish black leather jacket.",
                fashion,
                new BigDecimal("120.00"),
                new BigDecimal("99.00"),
                40,
                4.6,
                60,
                15,
                new BigDecimal("1.2"),
                "seller-fashion",
                "https://example.com/images/jacket.png",
                List.of("https://example.com/images/jacket-wear.png"),
                ProductStatus.ACTIVE,
                true,
                true,
                Instant.now()
        ));

        productRepository.save(new Product(
                "Coffee Maker",
                "coffee-maker",
                "Drip coffee maker with programmable timer.",
                home,
                new BigDecimal("45.00"),
                null,
                80,
                4.3,
                110,
                40,
                new BigDecimal("2.5"),
                "seller-home",
                "https://example.com/images/coffeemaker.png",
                List.of("https://example.com/images/coffeemaker-pot.png"),
                ProductStatus.ACTIVE,
                false,
                true,
                Instant.now()
        ));
    }
}
