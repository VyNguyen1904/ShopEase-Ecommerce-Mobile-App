package com.shopease.search.repository;

import com.shopease.search.model.ProductDocument;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;

@Repository
public class SearchRepository {
    private final Map<Long, ProductDocument> index = new ConcurrentHashMap<>();

    public SearchRepository() {
        save(new ProductDocument(101L, "Wireless Earbuds Pro", "Noise-cancelling earbuds", "Electronics",
                new BigDecimal("649000"), 42, 4.7, "seller-demo", true, Instant.now()));
        save(new ProductDocument(102L, "Compact Crossbody Bag", "Water-resistant daily bag", "Fashion",
                new BigDecimal("279000"), 30, 4.6, "seller-demo", true, Instant.now()));
    }

    public ProductDocument save(ProductDocument document) {
        index.put(document.id(), document);
        return document;
    }

    public Optional<ProductDocument> findById(Long id) {
        return Optional.ofNullable(index.get(id));
    }

    public List<ProductDocument> findAllActive() {
        return index.values().stream().filter(ProductDocument::active).sorted(Comparator.comparing(ProductDocument::id)).toList();
    }
}
