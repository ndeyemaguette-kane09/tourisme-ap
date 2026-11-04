package com.example.tourismservice.service;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import com.example.tourismservice.entity.Review;
import com.example.tourismservice.repository.BeachRepository;
import com.example.tourismservice.repository.HotelRepository;
import com.example.tourismservice.repository.PlaceRepository;
import com.example.tourismservice.repository.RestaurantRepository;
import com.example.tourismservice.repository.ReviewRepository;

@Service
public class ReviewService {

    private final ReviewRepository repository;
    private final HotelRepository hotelRepository;
    private final RestaurantRepository restaurantRepository;
    private final BeachRepository beachRepository;
    private final PlaceRepository placeRepository;

    public ReviewService(ReviewRepository repository,
                         HotelRepository hotelRepository,
                         RestaurantRepository restaurantRepository,
                         BeachRepository beachRepository,
                         PlaceRepository placeRepository) {
        this.repository = repository;
        this.hotelRepository = hotelRepository;
        this.restaurantRepository = restaurantRepository;
        this.beachRepository = beachRepository;
        this.placeRepository = placeRepository;
    }

    @Transactional
    public Review addReview(Review review) {
        if (review.getEntityId() == null || review.getEntityType() == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Lieu de l'avis manquant");
        }
        if (review.getRating() < 1 || review.getRating() > 5) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "La note doit être entre 1 et 5");
        }

        review.setEntityType(review.getEntityType().toLowerCase());
        review.setCreatedAt(LocalDateTime.now());
        Review saved = repository.save(review);

        refreshRating(saved.getEntityId(), saved.getEntityType());
        return saved;
    }

    public List<Review> getReviews(Long entityId, String entityType) {
        return repository.findByEntityIdAndEntityTypeOrderByCreatedAtDesc(entityId, entityType.toLowerCase());
    }

    private void refreshRating(Long id, String type) {
        double avg = Math.round(repository.averageRating(id, type) * 10) / 10.0;
        int count = (int) repository.countByEntityIdAndEntityType(id, type);

        switch (type) {
            case "hotel" -> hotelRepository.findById(id).ifPresent(h -> {
                h.setRating(avg);
                h.setReviewCount(count);
                hotelRepository.save(h);
            });
            case "restaurant" -> restaurantRepository.findById(id).ifPresent(r -> {
                r.setRating(avg);
                r.setReviewCount(count);
                restaurantRepository.save(r);
            });
            case "beach" -> beachRepository.findById(id).ifPresent(b -> {
                b.setRating(avg);
                b.setReviewCount(count);
                beachRepository.save(b);
            });
            case "place" -> placeRepository.findById(id).ifPresent(p -> {
                p.setRating(avg);
                p.setReviewCount(count);
                placeRepository.save(p);
            });
            default -> throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Type de lieu inconnu : " + type);
        }
    }
}
