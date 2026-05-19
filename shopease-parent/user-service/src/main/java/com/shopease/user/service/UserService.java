package com.shopease.user.service;

import com.shopease.user.dto.*;
import com.shopease.user.mapper.UserMapper;
import com.shopease.user.model.Address;
import com.shopease.user.model.UserAccount;
import com.shopease.user.repository.UserRepository;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.UUID;

@Service
@Transactional(readOnly = true)
@RequiredArgsConstructor
@FieldDefaults(makeFinal = true, level = AccessLevel.PRIVATE)
public class UserService {
    UserRepository users;
    UserMapper userMapper;
    BCryptPasswordEncoder encoder;

    @Transactional
    public UserAccount createUser(RegisterRequest request) {
        String email = request.email().toLowerCase(Locale.ROOT);
        if (users.existsByEmailIgnoreCase(email)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Email is already registered");
        }
        String hashedPassword = encoder.encode(request.password());
        UserAccount user =
                new UserAccount(UUID.randomUUID(), email, hashedPassword,
                        request.fullName(), request.phone(),
                        request.role() == null ? "BUYER" : request.role(),
                        new ArrayList<>(),
                        Instant.now());
        return users.save(user);
    }

    public UserResponse profile(UUID userId) {
        return userMapper.toResponse(getUserById(userId));
    }

    @Transactional
    public UserResponse updateProfile(UUID userId, UpdateProfileRequest request) {
        UserAccount user = getUserById(userId);
        user.updateProfile(request.fullName(), request.phone());
        return userMapper.toResponse(users.save(user));
    }

    @Transactional
    public UserResponse addAddress(UUID userId, AddressRequest request) {
        UserAccount user = getUserById(userId);
        List<Address> addresses = new ArrayList<>(user.getAddresses());
        if (request.defaultAddress() || addresses.isEmpty()) {
            addresses.replaceAll(address -> address.withDefault(false));
        }
        addresses.add(userMapper.toAddress(request, request.defaultAddress() || addresses.isEmpty(), UUID.randomUUID()));
        user.replaceAddresses(addresses);
        return userMapper.toResponse(users.save(user));
    }

    @Transactional
    public UserResponse updateAddress(UUID userId, UUID addressId, AddressRequest request) {
        UserAccount user = getUserById(userId);
        List<Address> addresses = user.getAddresses().stream()
                .map(address -> address.getId().equals(addressId)
                        ? userMapper.toAddress(request, request.defaultAddress(), addressId)
                        : (request.defaultAddress() ? address.withDefault(false) : address))
                .toList();
        user.replaceAddresses(addresses);
        return userMapper.toResponse(users.save(user));
    }

    @Transactional
    public UserResponse deleteAddress(UUID userId, UUID addressId) {
        UserAccount user = getUserById(userId);
        user.replaceAddresses(user.getAddresses().stream()
                .filter(address -> !address.getId().equals(addressId)).toList());
        return userMapper.toResponse(users.save(user));
    }

    private UserAccount getUserById(UUID id) {
        return users.findById(id).
                orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));
    }
}
