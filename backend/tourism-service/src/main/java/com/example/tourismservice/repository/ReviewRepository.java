package com.example.tourismservice.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.tourismservice.entity.Review;

public interface ReviewRepository extends JpaRepository<Review, Long> {

    List<Review> findByEntityIdAndEntityType(Long entityId, String entityType);
}