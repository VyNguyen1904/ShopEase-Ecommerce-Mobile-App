package com.shopease.user.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class StoreInfoResponse {
    private String storeName;
    private String phone;
    private String street;
    private String district;
    private String city;
    private Double latitude;
    private Double longitude;
}
