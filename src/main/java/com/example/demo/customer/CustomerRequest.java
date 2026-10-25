package com.example.demo.customer;
import jakarta.validation.constraints.*;
public record CustomerRequest(
    @NotBlank @Size(max=100) String name,
    @NotBlank @Email @Size(max=255) String email
) {}
