package com.shopease.user.service;

import com.shopease.user.dto.UserDtos.*;
import com.shopease.user.model.Address;
import com.shopease.user.model.UserAccount;
import com.shopease.user.repository.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.UUID;

@Service
public class UserService {
    private final UserRepository users;
    private final BCryptPasswordEncoder encoder;
    private final TokenService tokens;

    public UserService(UserRepository users, BCryptPasswordEncoder encoder, TokenService tokens) {
        this.users = users;
        this.encoder = encoder;
        this.tokens = tokens;
    }

    public LoginResponse register(RegisterRequest request) {
        String email = request.email().toLowerCase(Locale.ROOT);
        if (users.existsByEmail(email)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Email is already registered");
        }
        UserAccount user = users.save(new UserAccount(UUID.randomUUID(), email, encoder.encode(request.password()),
                request.fullName(), request.phone(), request.role() == null ? "BUYER" : request.role(),
                null, new ArrayList<>(), Instant.now()));
        return loginResponse(user);
    }

    public LoginResponse login(LoginRequest request) {
        UserAccount user = users.findByEmail(request.email())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid email or password"));
        if (!encoder.matches(request.password(), user.passwordHash())) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid email or password");
        }
        return loginResponse(user);
    }

    public LoginResponse refresh(RefreshRequest request) {
        return loginResponse(requireUser(tokens.validateRefreshToken(request.refreshToken())));
    }

    public UserResponse profile(UUID userId) {
        return toResponse(requireUser(userId));
    }

    public UserResponse updateProfile(UUID userId, UpdateProfileRequest request) {
        return toResponse(users.save(requireUser(userId).withProfile(request.fullName(), request.phone(), request.avatarUrl())));
    }

    public UserResponse addAddress(UUID userId, AddressRequest request) {
        UserAccount user = requireUser(userId);
        List<Address> addresses = new ArrayList<>(user.addresses());
        if (request.defaultAddress() || addresses.isEmpty()) {
            addresses.replaceAll(address -> address.withDefault(false));
        }
        addresses.add(toAddress(request, request.defaultAddress() || addresses.isEmpty(), UUID.randomUUID()));
        return toResponse(users.save(user.withAddresses(addresses)));
    }

    public UserResponse updateAddress(UUID userId, UUID addressId, AddressRequest request) {
        UserAccount user = requireUser(userId);
        List<Address> addresses = user.addresses().stream()
                .map(address -> address.id().equals(addressId)
                        ? toAddress(request, request.defaultAddress(), addressId)
                        : (request.defaultAddress() ? address.withDefault(false) : address))
                .toList();
        return toResponse(users.save(user.withAddresses(addresses)));
    }

    public UserResponse deleteAddress(UUID userId, UUID addressId) {
        UserAccount user = requireUser(userId);
        return toResponse(users.save(user.withAddresses(user.addresses().stream()
                .filter(address -> !address.id().equals(addressId)).toList())));
    }

    private LoginResponse loginResponse(UserAccount user) {
        return new LoginResponse(tokens.sign(user.id(), user.role(), "access"),
                tokens.sign(user.id(), user.role(), "refresh"), toResponse(user));
    }

    private UserAccount requireUser(UUID id) {
        return users.findById(id).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));
    }

    private UserResponse toResponse(UserAccount user) {
        return new UserResponse(user.id(), user.email(), user.fullName(), user.phone(), user.role(), user.avatarUrl(),
                user.addresses(), user.createdAt());
    }

    private Address toAddress(AddressRequest request, boolean defaultAddress, UUID id) {
        return new Address(id, request.recipientName(), request.phone(), request.street(), request.district(),
                request.city(), defaultAddress);
    }
}
