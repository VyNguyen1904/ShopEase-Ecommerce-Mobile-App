package com.shopease.user;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class UserServiceApplication {
    public static void main(String[] args) {
        System.out.println(java.util.TimeZone.getDefault().getID());
        SpringApplication.run(UserServiceApplication.class, args);
    }
}
