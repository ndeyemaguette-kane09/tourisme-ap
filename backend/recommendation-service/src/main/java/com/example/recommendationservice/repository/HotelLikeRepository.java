package com.example.recommendationservice.repository;

import com.example.recommendationservice.entity.HotelLike;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface HotelLikeRepository extends JpaRepository<HotelLike, Long> {

    List<HotelLike> findByUserId(Long userId);

    List<HotelLike> findByUserIdAndLikedTrue(Long userId);

}