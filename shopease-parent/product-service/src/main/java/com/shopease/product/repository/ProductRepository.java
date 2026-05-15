package com.shopease.product.repository;

<<<<<<< HEAD
import com.shopease.product.model.Product;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ProductRepository extends JpaRepository<Product, Long> {
    List<Product> findByActiveTrueOrderByIdAsc();

    Optional<Product> findByIdAndActiveTrue(Long id);
=======
import com.shopease.product.model.Category;
import com.shopease.product.model.Product;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;

@Repository
public class ProductRepository {
    private final Map<Long, Product> products = new ConcurrentHashMap<>();
    private final AtomicLong ids = new AtomicLong(1000);

    public ProductRepository(CategoryRepository categories) {
        Category electronics = categories.findById(1L).orElseThrow();
        Category fashion = categories.findById(2L).orElseThrow();
        save(new Product(101L, "Wireless Earbuds Pro", "Noise-cancelling earbuds", electronics,
                new BigDecimal("649000"), 42, 4.7, "seller-demo",
                "https://images.unsplash.com/photo-1606220945770-b5b6c2c55bf1",
                List.of("https://images.unsplash.com/photo-1606220945770-b5b6c2c55bf1"), true, Instant.now()));
        save(new Product(102L, "Compact Crossbody Bag", "Water-resistant daily bag", fashion,
                new BigDecimal("279000"), 30, 4.6, "seller-demo",
                "https://images.unsplash.com/photo-1548036328-c9fa89d128fa",
                List.of("https://images.unsplash.com/photo-1548036328-c9fa89d128fa"), true, Instant.now()));
    }

    public Long nextId() {
        return ids.incrementAndGet();
    }

    public Product save(Product product) {
        products.put(product.id(), product);
        return product;
    }

    public Optional<Product> findActiveById(Long id) {
        return Optional.ofNullable(products.get(id)).filter(Product::active);
    }

    public List<Product> findAllActive() {
        return products.values().stream().filter(Product::active).sorted(Comparator.comparing(Product::id)).toList();
    }
>>>>>>> 9f2b30358e4062f0be39eb86dfe53ada7c670722
}
