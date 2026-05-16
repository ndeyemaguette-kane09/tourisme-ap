package com.example.tourismservice.repository;

import com.example.tourismservice.entity.Beach;
import com.example.tourismservice.entity.Hotel;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

public interface BeachRepository extends JpaRepository<Beach, Long> {
    List<Beach> findByCategoryId(Long categoryId);
    List<Beach> findByCategoryName(String name);
}