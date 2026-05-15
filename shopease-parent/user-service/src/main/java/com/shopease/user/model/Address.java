package com.shopease.user.model;

import java.util.UUID;

public record Address(UUID id, String recipientName, String phone, String street, String district, String city,
                      boolean defaultAddress) {
    public Address withDefault(boolean value) {
        return new Address(id, recipientName, phone, street, district, city, value);
    }
}
