package com.shopease.product.repository;

import com.shopease.product.model.Category;
import org.springframework.stereotype.Repository;

import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;

@Repository
public class CategoryRepository {
    private final Map<Long, Category> categories = new ConcurrentHashMap<>();
    private final AtomicLong ids = new AtomicLong(10);

    public CategoryRepository() {
        save(new Category(1L, "Electronics", "electronics", "Phones and gadgets"));
        save(new Category(2L, "Fashion", "fashion", "Clothes and bags"));
    }

    public Category save(Category category) {
        categories.put(category.id(), category);
        return category;
    }

    public Category create(String name, String slug, String description) {
        return save(new Category(ids.incrementAndGet(), name, slug, description));
    }

    public Optional<Category> findById(Long id) {
        return Optional.ofNullable(categories.get(id));
    }

    public List<Category> findAll() {
        return categories.values().stream().sorted(Comparator.comparing(Category::id)).toList();
    }
}
