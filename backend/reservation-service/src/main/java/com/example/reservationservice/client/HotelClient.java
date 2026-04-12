package com.example.reservationservice.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@FeignClient(name = "TOURISM-SERVICE", contextId = "hotelClient")
public interface HotelClient {
    @GetMapping("/hotels/{id}")
    Object getHotelById(@PathVariable Long id);
}