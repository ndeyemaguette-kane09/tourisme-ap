package com.example.recommendationservice.client;

import com.example.recommendationservice.config.FeignConfig;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;

import java.util.List;
import java.util.Map;

@FeignClient(name = "TOURISM-SERVICE", configuration = FeignConfig.class)
public interface TourismClient {

    @GetMapping("/hotels")
    List<Map<String, Object>> getAllHotels();

    // catalogue complet : hôtels, restaurants, plages et lieux, au même format
    @GetMapping("/search")
    List<Map<String, Object>> getCatalog();
}
