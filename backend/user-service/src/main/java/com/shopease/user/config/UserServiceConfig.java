package com.shopease.user.config;

import com.shopease.user.model.UserAccount;
import com.shopease.user.repository.UserRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

import java.time.Instant;
import java.util.ArrayList;
import java.util.UUID;

@Configuration
public class UserServiceConfig {
    @Bean
    BCryptPasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder(12);
    }

    @Bean
    CommandLineRunner seedUsers(UserRepository users, BCryptPasswordEncoder encoder) {
        return args -> {
            if (users.count() > 0) {
                return;
            }
            users.save(new UserAccount(UUID.randomUUID(), "buyer@shopease.local", encoder.encode("password123"),
                    "Demo Buyer", "+84900000001", "BUYER", new ArrayList<>(), Instant.now()));
            users.save(new UserAccount(UUID.randomUUID(), "seller@shopease.local", encoder.encode("password123"),
                    "Demo Seller", "+84900000002", "SELLER", new ArrayList<>(), Instant.now()));
        };
    }
}
