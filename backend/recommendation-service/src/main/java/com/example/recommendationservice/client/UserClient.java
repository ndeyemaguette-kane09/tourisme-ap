package com.example.recommendationservice.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import java.util.Map;

@FeignClient(name = "AUTH-SERVICE")
public interface UserClient {

    @GetMapping("/users/{id}")
    Map<String, Object> getUserById(@PathVariable Long id);
}