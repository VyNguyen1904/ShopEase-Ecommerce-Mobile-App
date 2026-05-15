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
        if (users.existsByEmailIgnoreCase(email)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Email is already registered");
        }
        UserAccount user = users.save(new UserAccount(UUID.randomUUID(), email, encoder.encode(request.password()),
                request.fullName(), request.phone(), request.role() == null ? "BUYER" : request.role(),
                null, new ArrayList<>(), Instant.now()));
        return loginResponse(user);
    }

    public LoginResponse login(LoginRequest request) {
        UserAccount user = users.findByEmailIgnoreCase(request.email())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid email or password"));
        if (!encoder.matches(request.password(), user.getPasswordHash())) {
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
        UserAccount user = requireUser(userId);
        user.updateProfile(request.fullName(), request.phone(), request.avatarUrl());
        return toResponse(users.save(user));
    }

    public UserResponse addAddress(UUID userId, AddressRequest request) {
        UserAccount user = requireUser(userId);
        List<Address> addresses = new ArrayList<>(user.getAddresses());
        if (request.defaultAddress() || addresses.isEmpty()) {
            addresses.replaceAll(address -> address.withDefault(false));
        }
        addresses.add(toAddress(request, request.defaultAddress() || addresses.isEmpty(), UUID.randomUUID()));
        user.replaceAddresses(addresses);
        return toResponse(users.save(user));
    }

    public UserResponse updateAddress(UUID userId, UUID addressId, AddressRequest request) {
        UserAccount user = requireUser(userId);
        List<Address> addresses = user.getAddresses().stream()
                .map(address -> address.getId().equals(addressId)
                        ? toAddress(request, request.defaultAddress(), addressId)
                        : (request.defaultAddress() ? address.withDefault(false) : address))
                .toList();
        user.replaceAddresses(addresses);
        return toResponse(users.save(user));
    }

    public UserResponse deleteAddress(UUID userId, UUID addressId) {
        UserAccount user = requireUser(userId);
        user.replaceAddresses(user.getAddresses().stream()
                .filter(address -> !address.getId().equals(addressId)).toList());
        return toResponse(users.save(user));
    }

    private LoginResponse loginResponse(UserAccount user) {
        return new LoginResponse(tokens.sign(user.getId(), user.getRole(), "access"),
                tokens.sign(user.getId(), user.getRole(), "refresh"), toResponse(user));
    }

    private UserAccount requireUser(UUID id) {
        return users.findById(id).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));
    }

    private UserResponse toResponse(UserAccount user) {
        return new UserResponse(user.getId(), user.getEmail(), user.getFullName(), user.getPhone(), user.getRole(), user.getAvatarUrl(),
                user.getAddresses(), user.getCreatedAt());
    }

    private Address toAddress(AddressRequest request, boolean defaultAddress, UUID id) {
        return new Address(id, request.recipientName(), request.phone(), request.street(), request.district(),
                request.city(), defaultAddress);
    }
}
