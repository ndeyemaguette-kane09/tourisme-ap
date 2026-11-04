package com.example.tourismservice.repository;

import com.example.tourismservice.entity.Review;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ReviewRepository extends JpaRepository<Review, Long> {

    List<Review> findByEntityIdAndEntityTypeOrderByCreatedAtDesc(Long entityId, String entityType);

    @Query("select coalesce(avg(r.rating), 0) from Review r where r.entityId = :entityId and r.entityType = :entityType")
    double averageRating(@Param("entityId") Long entityId, @Param("entityType") String entityType);

    long countByEntityIdAndEntityType(Long entityId, String entityType);
}
