package com.example.demo.common;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.*;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.util.*;

@RestControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(ResourceNotFoundException.class)
    ResponseEntity<ApiError> nf(ResourceNotFoundException e, HttpServletRequest r) {
        return response(HttpStatus.NOT_FOUND, e.getMessage(), r.getRequestURI(), Map.of());
    }

    @ExceptionHandler(DataIntegrityViolationException.class)
    ResponseEntity<ApiError> conflict(DataIntegrityViolationException e, HttpServletRequest r) {
        return response(HttpStatus.CONFLICT, "The supplied data conflicts with an existing record", r.getRequestURI(), Map.of());
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    ResponseEntity<ApiError> validation(MethodArgumentNotValidException e, HttpServletRequest r) {
        Map<String, String> errors = new LinkedHashMap<>();
        e.getBindingResult().getFieldErrors().forEach(x -> errors.putIfAbsent(x.getField(), x.getDefaultMessage()));
        return response(HttpStatus.BAD_REQUEST, "Request validation failed", r.getRequestURI(), errors);
    }

    private ResponseEntity<ApiError> response(HttpStatus s, String m, String p, Map<String, String> v) {
        return ResponseEntity.status(s).body(new ApiError(Instant.now(), s.value(), s.getReasonPhrase(), m, p, v));
    }
}
