package com.shopease.search.repository;

import com.shopease.search.model.ProductDocument;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface SearchRepository extends JpaRepository<ProductDocument, Long> {

    List<ProductDocument> findByActiveTrueOrderByIdAsc();
}
