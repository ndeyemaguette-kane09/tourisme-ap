package com.example.reservationservice.feign;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@FeignClient(name = "tourism-service")
public interface HotelClient {

    @GetMapping("/hotels/{id}")
    Object getHotelById(@PathVariable Long id);
}