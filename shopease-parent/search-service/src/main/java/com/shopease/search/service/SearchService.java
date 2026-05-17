package com.shopease.search.service;

import lombok.RequiredArgsConstructor;

import com.shopease.search.dto.SearchDtos.ProductDocumentRequest;
import com.shopease.search.model.ProductDocument;
import com.shopease.search.repository.SearchRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.Locale;

@Service
@RequiredArgsConstructor
public class SearchService {
    private final SearchRepository search;



    public List<ProductDocument> products(String q, String category, BigDecimal minPrice, BigDecimal maxPrice) {
        String keyword = q == null ? "" : q.toLowerCase(Locale.ROOT);
        return search.findByActiveTrueOrderByIdAsc().stream()
                .filter(product -> keyword.isBlank() || product.getName().toLowerCase(Locale.ROOT).contains(keyword)
                        || product.getDescription().toLowerCase(Locale.ROOT).contains(keyword))
                .filter(product -> category == null || product.getCategoryName().equalsIgnoreCase(category))
                .filter(product -> minPrice == null || product.getPrice().compareTo(minPrice) >= 0)
                .filter(product -> maxPrice == null || product.getPrice().compareTo(maxPrice) <= 0)
                .toList();
    }

    public List<String> suggestions(String q) {
        String keyword = q == null ? "" : q.toLowerCase(Locale.ROOT);
        return search.findByActiveTrueOrderByIdAsc().stream().map(ProductDocument::getName)
                .filter(name -> keyword.isBlank() || name.toLowerCase(Locale.ROOT).contains(keyword)).limit(10).toList();
    }

    public ProductDocument upsert(ProductDocumentRequest request) {
        return search.save(new ProductDocument(request.id(), request.name(), request.description(), request.categoryName(),
                request.price(), request.stockQuantity(), request.averageRating(), request.sellerId(), request.active(),
                Instant.now()));
    }

    public void delete(Long id) {
        ProductDocument document = search.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Product document not found"));
        search.save(document.inactive());
    }
}
