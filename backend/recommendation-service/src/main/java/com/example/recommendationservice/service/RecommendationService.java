package com.example.recommendationservice.service;

import com.example.recommendationservice.client.ReservationClient;
import com.example.recommendationservice.client.TourismClient;
import com.example.recommendationservice.entity.HotelLike;
import com.example.recommendationservice.repository.HotelLikeRepository;

import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;


@Service
public class RecommendationService {

    private final HotelLikeRepository hotelLikeRepository;

    public RecommendationService(HotelLikeRepository hotelLikeRepository) {
        this.hotelLikeRepository = hotelLikeRepository;
    }

    public HotelLike saveLike(HotelLike like) {
        return hotelLikeRepository.save(like);
    }

    public List<HotelLike> getUserLikes(Long userId) {
        return hotelLikeRepository.findByUserId(userId);
    }
}