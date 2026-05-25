package com.shopease.user.model;

import jakarta.persistence.CollectionTable;
import jakarta.persistence.Column;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.Table;
import lombok.Getter;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Getter
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

    @jakarta.persistence.Enumerated(jakarta.persistence.EnumType.STRING)
    @Column(nullable = false, length = 20)
    private Role role;


    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "user_addresses", joinColumns = @JoinColumn(name = "user_id"))
    private List<Address> addresses = new ArrayList<>();

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    protected UserAccount() {
    }

    public UserAccount(UUID id,
                       String email,
                       String passwordHash,
                       String fullName,
                       String phone,
                       Role role,
                       List<Address> addresses,
                       Instant createdAt) {
        this.id = id;
        this.email = email;
        this.passwordHash = passwordHash;
        this.fullName = fullName;
        this.phone = phone;
        this.role = role;
        this.addresses = addresses != null ? new ArrayList<>(addresses) : new ArrayList<>();
        this.createdAt = createdAt;
    }

    public void updateProfile(String fullName, String phone) {
        this.fullName = fullName;
        this.phone = phone;
    }

    public void replaceAddresses(List<Address> addresses) {
        this.addresses = new ArrayList<>(addresses);
    }

    public void updateRole(Role role) {
        this.role = role;
    }
}
