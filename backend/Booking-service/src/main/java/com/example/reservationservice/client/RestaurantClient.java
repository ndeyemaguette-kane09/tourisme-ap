package com.example.reservationservice.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@FeignClient(name = "tourism-service", contextId = "restaurantClient")
public interface RestaurantClient {

    @GetMapping("/restaurants/{id}")
    Object getRestaurantById(@PathVariable Long id);
}