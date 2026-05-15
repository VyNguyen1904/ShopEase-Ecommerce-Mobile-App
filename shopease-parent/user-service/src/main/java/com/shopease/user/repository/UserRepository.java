package com.shopease.user.repository;

import com.shopease.user.model.UserAccount;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.ArrayList;
import java.util.Locale;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Repository
public class UserRepository {
    private final Map<UUID, UserAccount> users = new ConcurrentHashMap<>();
    private final Map<String, UUID> idsByEmail = new ConcurrentHashMap<>();

    public UserRepository(BCryptPasswordEncoder encoder) {
        save(new UserAccount(UUID.randomUUID(), "buyer@shopease.local", encoder.encode("password123"),
                "Demo Buyer", "0900000001", "BUYER", null, new ArrayList<>(), Instant.now()));
        save(new UserAccount(UUID.randomUUID(), "seller@shopease.local", encoder.encode("password123"),
                "Demo Seller", "0900000002", "SELLER", null, new ArrayList<>(), Instant.now()));
        save(new UserAccount(UUID.randomUUID(), "admin@shopease.local", encoder.encode("password123"),
                "Demo Admin", "0900000003", "ADMIN", null, new ArrayList<>(), Instant.now()));
    }

    public UserAccount save(UserAccount user) {
        users.put(user.id(), user);
        idsByEmail.put(user.email().toLowerCase(Locale.ROOT), user.id());
        return user;
    }

    public Optional<UserAccount> findById(UUID id) {
        return Optional.ofNullable(users.get(id));
    }

    public Optional<UserAccount> findByEmail(String email) {
        return Optional.ofNullable(idsByEmail.get(email.toLowerCase(Locale.ROOT))).flatMap(this::findById);
    }

    public boolean existsByEmail(String email) {
        return idsByEmail.containsKey(email.toLowerCase(Locale.ROOT));
    }
}
