package com.example.tourismservice.repository;

import com.example.tourismservice.entity.Beach;
import org.springframework.data.jpa.repository.JpaRepository;

public interface BeachRepository extends JpaRepository<Beach, Long> {
}