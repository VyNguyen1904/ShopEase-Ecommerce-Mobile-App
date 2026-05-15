package com.shopease.user.model;

<<<<<<< HEAD
import jakarta.persistence.CollectionTable;
import jakarta.persistence.Column;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.Table;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "users")
public class UserAccount {
    @Id
    @Column(name = "user_id", nullable = false, updatable = false)
    private UUID id;

    @Column(nullable = false, unique = true, length = 255)
    private String email;

    @Column(name = "password_hash", nullable = false)
    private String passwordHash;

    @Column(name = "full_name", nullable = false, length = 100)
    private String fullName;

    @Column(length = 20)
    private String phone;

    @Column(nullable = false, length = 20)
    private String role;

    @Column(name = "avatar_url", length = 512)
    private String avatarUrl;

    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "user_addresses", joinColumns = @JoinColumn(name = "user_id"))
    private List<Address> addresses = new ArrayList<>();

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    protected UserAccount() {
    }

    public UserAccount(UUID id, String email, String passwordHash, String fullName, String phone, String role,
                       String avatarUrl, List<Address> addresses, Instant createdAt) {
        this.id = id;
        this.email = email;
        this.passwordHash = passwordHash;
        this.fullName = fullName;
        this.phone = phone;
        this.role = role;
        this.avatarUrl = avatarUrl;
        this.addresses = new ArrayList<>(addresses);
        this.createdAt = createdAt;
    }

    public UUID getId() { return id; }
    public String getEmail() { return email; }
    public String getPasswordHash() { return passwordHash; }
    public String getFullName() { return fullName; }
    public String getPhone() { return phone; }
    public String getRole() { return role; }
    public String getAvatarUrl() { return avatarUrl; }
    public List<Address> getAddresses() { return addresses; }
    public Instant getCreatedAt() { return createdAt; }

    public void updateProfile(String fullName, String phone, String avatarUrl) {
        this.fullName = fullName;
        this.phone = phone;
        this.avatarUrl = avatarUrl;
    }

    public void replaceAddresses(List<Address> addresses) {
        this.addresses = new ArrayList<>(addresses);
=======
import java.time.Instant;
import java.util.List;
import java.util.UUID;

public record UserAccount(UUID id, String email, String passwordHash, String fullName, String phone, String role,
                          String avatarUrl, List<Address> addresses, Instant createdAt) {
    public UserAccount withProfile(String fullName, String phone, String avatarUrl) {
        return new UserAccount(id, email, passwordHash, fullName, phone, role, avatarUrl, addresses, createdAt);
    }

    public UserAccount withAddresses(List<Address> addresses) {
        return new UserAccount(id, email, passwordHash, fullName, phone, role, avatarUrl, addresses, createdAt);
>>>>>>> 9f2b30358e4062f0be39eb86dfe53ada7c670722
    }
}
