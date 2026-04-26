package com.example.tourismservice.service;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.tourismservice.entity.Review;
import com.example.tourismservice.repository.ReviewRepository;

@Service
public class ReviewService {

    @Autowired
    private ReviewRepository repository;

    public Review addReview(Review review) {
        review.setCreatedAt(LocalDateTime.now());
        return repository.save(review);
    }

    public List<Review> getReviews(Long entityId, String entityType) {
        return repository.findByEntityIdAndEntityType(entityId, entityType);
    }
}
