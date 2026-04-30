package com.example.reservationservice.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@FeignClient(name = "AUTH-SERVICE")
public interface UserClient {
    @GetMapping("/users/{id}")
    Object getUserById(@PathVariable Long id);
}