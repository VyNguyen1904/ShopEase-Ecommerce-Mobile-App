package com.shopease.user.model;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;

import java.util.UUID;

@Embeddable
public class Address {

    @Column(name = "address_id", nullable = false)
    private UUID id;

    @Column(name = "recipient_name", nullable = false, length = 100)
    private String recipientName;

    @Column(nullable = false, length = 20)
    private String phone;

    @Column(nullable = false)
    private String street;

    @Column(nullable = false, length = 100)
    private String district;

    @Column(nullable = false, length = 100)
    private String city;

    @Column(name = "default_address", nullable = false)
    private boolean defaultAddress;

    protected Address() {
    }

    public Address(UUID id, String recipientName, String phone, String street, String district, String city,
                   boolean defaultAddress) {
        this.id = id;
        this.recipientName = recipientName;
        this.phone = phone;
        this.street = street;
        this.district = district;
        this.city = city;
        this.defaultAddress = defaultAddress;
    }

    public UUID getId() { return id; }
    public String getRecipientName() { return recipientName; }
    public String getPhone() { return phone; }
    public String getStreet() { return street; }
    public String getDistrict() { return district; }
    public String getCity() { return city; }
    public boolean isDefaultAddress() { return defaultAddress; }

    public Address withDefault(boolean value) {
        return new Address(id, recipientName, phone, street, district, city, value);
    }
}
