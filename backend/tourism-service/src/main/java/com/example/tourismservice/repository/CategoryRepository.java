package com.example.tourismservice.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.tourismservice.entity.Category;

public interface CategoryRepository extends JpaRepository<Category, Long> {
}