package com.example.tourismservice.repository;

import com.example.tourismservice.entity.Hotel;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

public interface HotelRepository extends JpaRepository<Hotel, Long> {
    List<Hotel> findByCategoryId(Long categoryId);
    List<Hotel> findByCategoryName(String name);
}