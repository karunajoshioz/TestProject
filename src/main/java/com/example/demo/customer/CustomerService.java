package com.example.demo.customer;

import com.example.demo.common.ResourceNotFoundException;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional(readOnly = true)
public class CustomerService {
    private final CustomerRepository repository;

    public CustomerService(CustomerRepository repository) {
        this.repository = repository;
    }

    public List<CustomerResponse> findAll() {
        return repository.findAll().stream().map(CustomerResponse::from).toList();
    }

    public CustomerResponse findById(Long id) {
        return CustomerResponse.from(findCustomer(id));
    }

    @Transactional
    public CustomerResponse create(CustomerRequest request) {
        String email = request.email().trim().toLowerCase();
        if (repository.existsByEmailIgnoreCase(email))
            throw new DataIntegrityViolationException("Email already exists");
        return CustomerResponse.from(repository.save(new Customer(request.name().trim(), email)));
    }

    @Transactional
    public CustomerResponse update(Long id, CustomerRequest request) {
        Customer c = findCustomer(id);
        c.changeName(request.name().trim());
        c.changeEmail(request.email().trim().toLowerCase());
        return CustomerResponse.from(repository.save(c));
    }

    @Transactional
    public void delete(Long id) {
        repository.delete(findCustomer(id));
    }

    private Customer findCustomer(Long id) {
        return repository.findById(id).orElseThrow(() -> new ResourceNotFoundException("Customer " + id + " was not found"));
    }
}
