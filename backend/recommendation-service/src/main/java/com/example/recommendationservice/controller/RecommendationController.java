package com.example.recommendationservice.controller;

import com.example.recommendationservice.entity.Favorite;
import com.example.recommendationservice.entity.HotelLike;
import com.example.recommendationservice.service.ItineraryService;
import com.example.recommendationservice.service.RecommendationService;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/recommendations")
public class RecommendationController {

    private final RecommendationService recommendationService;
    private final ItineraryService itineraryService;

    public RecommendationController(RecommendationService recommendationService,
                                    ItineraryService itineraryService) {
        this.recommendationService = recommendationService;
        this.itineraryService = itineraryService;
    }

    @GetMapping("/itinerary")
    public Map<String, Object> itinerary(@RequestParam(defaultValue = "3") int days,
                                         @RequestParam(required = false) List<String> categories,
                                         @RequestParam(required = false) String start) {
        return itineraryService.build(days, categories, start);
    }

    @GetMapping("/user/{userId}")
    public List<Map<String, Object>> recommend(@PathVariable Long userId,
                                               @RequestParam(defaultValue = "10") int limit,
                                               @RequestParam(required = false) List<String> categories) {
        return recommendationService.recommend(userId, limit, categories);
    }

    @PostMapping("/like")
    public HotelLike saveLike(@RequestBody HotelLike like) {
        return recommendationService.saveLike(like);
    }

    @GetMapping("/likes/user/{userId}")
    public List<HotelLike> getUserLikes(@PathVariable Long userId) {
        return recommendationService.getUserLikes(userId);
    }

    @PostMapping("/favorites")
    @ResponseStatus(HttpStatus.CREATED)
    public Favorite addFavorite(@RequestBody Favorite favorite) {
        return recommendationService.addFavorite(favorite);
    }

    @GetMapping("/favorites/user/{userId}")
    public List<Favorite> getFavorites(@PathVariable Long userId) {
        return recommendationService.getFavorites(userId);
    }

    @DeleteMapping("/favorites")
    public void removeFavorite(@RequestParam Long userId,
                               @RequestParam Long itemId,
                               @RequestParam String itemType) {
        recommendationService.removeFavorite(userId, itemId, itemType);
    }
}
