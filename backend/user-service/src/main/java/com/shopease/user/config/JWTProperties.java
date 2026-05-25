package com.shopease.user.config;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Getter
@Setter
@Component
// TODO: Figure out the mechanism of this during runtime, why we need setter to set values into fields
@ConfigurationProperties(prefix = "app.jwt")
public class JWTProperties {
    String secret;
    long accessTokenExpiry;
    long refreshTokenExpiry;
}
