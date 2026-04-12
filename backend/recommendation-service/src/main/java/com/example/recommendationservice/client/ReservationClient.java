package com.example.recommendationservice.client;

import com.example.recommendationservice.config.FeignConfig;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

import java.util.List;
import java.util.Map;

@FeignClient(name = "RESERVATION-SERVICE", configuration = FeignConfig.class)
public interface ReservationClient {

    @GetMapping("/reservations/user/{userId}")
    List<Map<String, Object>> getReservationsByUser(@PathVariable Long userId);
}