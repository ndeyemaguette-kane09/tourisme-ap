package com.example.reservationservice.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@FeignClient(name = "tourism-service", contextId = "cityClient")
public interface CityClient {
    @GetMapping("/cities/{id}")
    Object getCityById(@PathVariable Long id);
}