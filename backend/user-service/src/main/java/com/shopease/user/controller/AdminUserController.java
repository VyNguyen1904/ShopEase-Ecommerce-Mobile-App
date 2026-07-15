package com.shopease.user.controller;

import com.shopease.common.dto.ApiResponse;
import com.shopease.user.dto.*;
import com.shopease.user.model.Role;
import com.shopease.user.model.UserAccount;
import com.shopease.user.repository.UserRepository;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.UUID;

@RestController
@RequestMapping("/api/admin/users")
@PreAuthorize("hasRole('ADMIN')")
@RequiredArgsConstructor
public class AdminUserController {

    private final UserRepository userRepository;
    private final BCryptPasswordEncoder passwordEncoder;

    @GetMapping
    public ApiResponse<Page<AdminUserResponse>> getAllUsers(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        
        Page<UserAccount> usersPage = userRepository.findAll(PageRequest.of(page, size));
        Page<AdminUserResponse> responsePage = usersPage.map(user -> new AdminUserResponse(
                user.getId(),
                user.getFullName(), // username mapped to fullName
                user.getEmail(),
                user.getRole().name(),
                user.isEnabled()
        ));

        return ApiResponse.ok(responsePage);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<AdminUserResponse> createUser(@Valid @RequestBody UserCreationRequest request) {
        
        if (userRepository.existsByEmailIgnoreCase(request.email())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Email already exists in the database.");
        }

        Role targetRole;
        try {
            targetRole = Role.valueOf(request.role().toUpperCase());
        } catch (IllegalArgumentException e) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid role. Allowed roles are: BUYER, SELLER, ADMIN.");
        }

        UserAccount newUser = new UserAccount(
                UUID.randomUUID(),
                request.email(),
                passwordEncoder.encode(request.password()),
                request.username(), // username maps to fullName
                null, // phone
                targetRole,
                new ArrayList<>(),
                Instant.now()
        );
        newUser.verifyAccount(); // Admin created accounts are pre-verified

        userRepository.save(newUser);

        AdminUserResponse response = new AdminUserResponse(
                newUser.getId(),
                newUser.getFullName(),
                newUser.getEmail(),
                newUser.getRole().name(),
                newUser.isEnabled()
        );

        return ApiResponse.created(response);
    }

    @PutMapping("/{id}/role")
    public ApiResponse<AdminUserResponse> changeUserRole(
            @PathVariable UUID id,
            @Valid @RequestBody RoleUpdateRequest request) {
        
        UserAccount user = userRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found."));

        Role targetRole;
        try {
            targetRole = Role.valueOf(request.role().toUpperCase());
        } catch (IllegalArgumentException e) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid role. Allowed roles are: BUYER, SELLER, ADMIN.");
        }

        user.updateRole(targetRole);
        userRepository.save(user);

        AdminUserResponse response = new AdminUserResponse(
                user.getId(),
                user.getFullName(),
                user.getEmail(),
                user.getRole().name(),
                user.isEnabled()
        );

        return ApiResponse.ok(response);
    }

    @PutMapping("/{id}/status")
    public ApiResponse<AdminUserResponse> blockOrUnblockUser(
            @PathVariable UUID id,
            @RequestParam boolean enabled) {
        
        UserAccount user = userRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found."));

        user.setEnabled(enabled);
        userRepository.save(user);

        AdminUserResponse response = new AdminUserResponse(
                user.getId(),
                user.getFullName(),
                user.getEmail(),
                user.getRole().name(),
                user.isEnabled()
        );

        return ApiResponse.ok(response);
    }

    @PutMapping("/{id}")
    public ApiResponse<AdminUserResponse> updateUser(
            @PathVariable UUID id,
            @Valid @RequestBody UserUpdateRequest request) {
        
        UserAccount user = userRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found."));

        if (!request.email().equalsIgnoreCase(user.getEmail()) && userRepository.existsByEmailIgnoreCase(request.email())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Email already exists.");
        }

        Role targetRole;
        try {
            targetRole = Role.valueOf(request.role().toUpperCase());
        } catch (IllegalArgumentException e) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid role. Allowed roles are: BUYER, SELLER, ADMIN.");
        }

        user.updateAccount(request.username(), request.email(), targetRole);
        userRepository.save(user);

        AdminUserResponse response = new AdminUserResponse(
                user.getId(),
                user.getFullName(),
                user.getEmail(),
                user.getRole().name(),
                user.isEnabled()
        );

        return ApiResponse.ok(response);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public ApiResponse<Void> deleteUser(@PathVariable UUID id) {
        if (!userRepository.existsById(id)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found.");
        }
        userRepository.deleteById(id);
        return ApiResponse.ok(null);
    }

    @GetMapping("/stats")
    public ApiResponse<AdminUserStatsResponse> getUserStats() {
        long totalUsers = userRepository.count();
        long activeUsers = userRepository.countByEnabled(true);

        List<UserAccount> allUsers = userRepository.findAll();
        
        LocalDate today = LocalDate.now();
        Map<String, Long> growthMap = new LinkedHashMap<>();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("MMM", Locale.ENGLISH);

        for (int i = 7; i >= 0; i--) {
            LocalDate d = today.minusMonths(i);
            growthMap.put(d.format(formatter), 0L);
        }

        for (UserAccount user : allUsers) {
            if (user.getCreatedAt() != null) {
                LocalDate regDate = LocalDate.ofInstant(user.getCreatedAt(), ZoneId.systemDefault());
                String monthKey = regDate.format(formatter);
                if (growthMap.containsKey(monthKey)) {
                    growthMap.put(monthKey, growthMap.get(monthKey) + 1);
                }
            }
        }

        List<MonthlyGrowth> userGrowth = new ArrayList<>();
        growthMap.forEach((month, count) -> userGrowth.add(new MonthlyGrowth(month, count)));

        return ApiResponse.ok(new AdminUserStatsResponse(totalUsers, activeUsers, userGrowth));
    }

    public record MonthlyGrowth(String month, long count) {}
    public record AdminUserStatsResponse(long totalUsers, long activeUsers, List<MonthlyGrowth> userGrowth) {}
}
