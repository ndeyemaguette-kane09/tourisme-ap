package com.example.tourismservice.repository;

import com.example.tourismservice.entity.Hotel;
import com.example.tourismservice.entity.Restaurant;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

public interface RestaurantRepository extends JpaRepository<Restaurant, Long> {
    List<Restaurant> findByCategoryId(Long categoryId);
    List<Restaurant> findByCategoryName(String name);
}