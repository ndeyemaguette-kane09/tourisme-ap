package com.example.reservationservice.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

import java.util.Map;

@FeignClient(name = "TOURISM-SERVICE", contextId = "hotelClient")
public interface HotelClient {
    @GetMapping("/hotels/{id}")
    Map<String, Object> getHotelById(@PathVariable Long id);
}
