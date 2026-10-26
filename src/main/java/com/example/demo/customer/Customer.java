package com.example.demo.customer;
import jakarta.persistence.*;
import java.time.Instant;
@Entity
@Table(schema = "customers", name = "customers",
        uniqueConstraints = @UniqueConstraint(name = "uk_customers_email", columnNames = "email"))
public class Customer {
    @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
    @Column(nullable=false, length=100) private String name;
    @Column(nullable=false, length=255) private String email;
    @Column(name="created_at", nullable=false, updatable=false) private Instant createdAt;
    protected Customer() {}
    public Customer(String name, String email) { this.name=name; this.email=email; }
    @PrePersist void prePersist() { createdAt=Instant.now(); }
    public Long getId(){return id;} public String getName(){return name;} public String getEmail(){return email;} public Instant getCreatedAt(){return createdAt;}
    public void changeName(String name){this.name=name;} public void changeEmail(String email){this.email=email;}
}
