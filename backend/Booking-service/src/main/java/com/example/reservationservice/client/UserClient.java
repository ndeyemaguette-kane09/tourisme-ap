package com.example.reservationservice.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

import java.util.Map;

@FeignClient(name = "AUTH-SERVICE", contextId = "userClient")
public interface UserClient {
    @GetMapping("/users/{id}")
    Map<String, Object> getUserById(@PathVariable Long id);
}
