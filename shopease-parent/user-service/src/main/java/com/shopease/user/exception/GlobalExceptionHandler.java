package com.shopease.user.exception;

import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.server.ResponseStatusException;

import java.time.Instant;

@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    public record ErrorResponse(int status, String message, Instant timestamp) {
    }

    @ExceptionHandler(ResponseStatusException.class)
    public ResponseEntity<ErrorResponse> handleResponseStatusException(RuntimeException e) {
        log.error("Runtime error: {}", e.getMessage());
        HttpStatus status = HttpStatus.BAD_REQUEST;
        return ResponseEntity.status(status)
                .body(new ErrorResponse(status.value(), e.getMessage(), Instant.now()));
    }
}
