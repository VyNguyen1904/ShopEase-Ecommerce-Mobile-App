package com.shopease.inventory.config;

import com.shopease.inventory.model.InventoryItem;
import com.shopease.inventory.repository.InventoryRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.time.Instant;

@Configuration
public class InventoryDataConfig {
    @Bean
    CommandLineRunner seedInventory(InventoryRepository inventory) {
        return args -> {
            if (inventory.count() > 0) {
                return;
            }
            inventory.save(new InventoryItem(101L, 42, 0, Instant.now()));
            inventory.save(new InventoryItem(102L, 30, 0, Instant.now()));
        };
    }
}
