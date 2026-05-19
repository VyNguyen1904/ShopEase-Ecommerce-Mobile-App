package com.shopease.user.mapper;

import com.shopease.user.dto.AddressRequest;
import com.shopease.user.dto.UserResponse;
import com.shopease.user.model.Address;
import com.shopease.user.model.UserAccount;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingConstants;

import java.util.UUID;

@Mapper(componentModel = MappingConstants.ComponentModel.SPRING)
public interface UserMapper {

    UserResponse toResponse(UserAccount user);

    @Mapping(target = "id", source = "id")
    @Mapping(target = "defaultAddress", source = "defaultAddress")
    Address toAddress(AddressRequest request, boolean defaultAddress, UUID id);
}
