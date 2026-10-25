package com.example.demo.customer;
import java.time.Instant;
public record CustomerResponse(Long id,String name,String email,Instant createdAt) {
    public static CustomerResponse from(Customer c){return new CustomerResponse(c.getId(),c.getName(),c.getEmail(),c.getCreatedAt());}
}
