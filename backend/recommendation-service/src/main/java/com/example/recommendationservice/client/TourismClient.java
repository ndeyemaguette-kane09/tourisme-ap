package com.example.recommendationservice.client;


import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;

import com.example.recommendationservice.config.FeignConfig;

import java.util.List;
import java.util.Map;

@FeignClient(name = "TOURISM-SERVICE", configuration = FeignConfig.class)
public interface TourismClient {

    @GetMapping("/hotels")
    List<Map<String, Object>> getAllHotels();
}