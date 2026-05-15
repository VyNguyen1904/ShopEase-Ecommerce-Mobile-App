package com.shopease.inventory.repository;

import com.shopease.inventory.model.InventoryItem;
<<<<<<< HEAD
import org.springframework.data.jpa.repository.JpaRepository;

public interface InventoryRepository extends JpaRepository<InventoryItem, Long> {
=======
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;

@Repository
public class InventoryRepository {
    private final Map<Long, InventoryItem> inventory = new ConcurrentHashMap<>();

    public InventoryRepository() {
        save(new InventoryItem(101L, 42, 0, Instant.now()));
        save(new InventoryItem(102L, 30, 0, Instant.now()));
    }

    public InventoryItem save(InventoryItem item) {
        inventory.put(item.productId(), item);
        return item;
    }

    public Optional<InventoryItem> findByProductId(Long productId) {
        return Optional.ofNullable(inventory.get(productId));
    }

    public List<InventoryItem> findAll() {
        return inventory.values().stream().toList();
    }
>>>>>>> 9f2b30358e4062f0be39eb86dfe53ada7c670722
}
