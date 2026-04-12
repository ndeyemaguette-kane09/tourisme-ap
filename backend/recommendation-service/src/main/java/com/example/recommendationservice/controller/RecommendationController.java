package com.example.recommendationservice.controller;

import com.example.recommendationservice.entity.HotelLike;
import com.example.recommendationservice.service.RecommendationService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/recommendations")
public class RecommendationController {

    private final RecommendationService recommendationService;

    public RecommendationController(RecommendationService recommendationService) {
        this.recommendationService = recommendationService;
    }

    @PostMapping("/like")
    public HotelLike saveLike(@RequestBody HotelLike like) {
        return recommendationService.saveLike(like);
    }

    @GetMapping("/user/{userId}")
    public List<HotelLike> getUserLikes(@PathVariable Long userId) {
        return recommendationService.getUserLikes(userId);
    }
}