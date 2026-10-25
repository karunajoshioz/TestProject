/*
package com.example.demo.customer;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;
import java.time.Instant;
import java.util.List;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;


@WebMvcTest(CustomerController.class)

class CustomerControllerTest {
 @Autowired
 MockMvc mockMvc;
 @MockitoBean
 CustomerService customerService;

 @Test
 void shouldReturnCustomers() throws Exception {
  when(customerService.findAll()).thenReturn(List.of(new CustomerResponse(1L, "Karuna", "karuna@example.com",
          Instant.parse("2026-01-01T00:00:00Z"))));
  mockMvc.perform(get("/api/v1/customers"))
          .andExpect(status().isOk()).andExpect(jsonPath("$[0].id").value(1))
          .andExpect(jsonPath("$[0].name").value("Karuna"));
 }
}
*/
