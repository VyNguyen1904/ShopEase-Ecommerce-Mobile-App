package com.shopease.payment.repository;

import com.shopease.payment.model.Refund;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface RefundRepository extends JpaRepository<Refund, UUID> {
}
