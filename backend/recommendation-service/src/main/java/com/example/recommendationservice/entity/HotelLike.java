package com.example.recommendationservice.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "hotel_likes")
public class HotelLike {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long userId;
    private Long hotelId;
    private Boolean liked;
    private LocalDateTime createdAt;

    public HotelLike() {
        this.createdAt = LocalDateTime.now();
    }

    public HotelLike(Long userId, Long hotelId, Boolean liked) {
        this.userId = userId;
        this.hotelId = hotelId;
        this.liked = liked;
        this.createdAt = LocalDateTime.now();
    }

    public Long getId() { return id; }
    public Long getUserId() { return userId; }
    public Long getHotelId() { return hotelId; }
    public Boolean getLiked() { return liked; }
    public LocalDateTime getCreatedAt() { return createdAt; }

    public void setId(Long id) { this.id = id; }
    public void setUserId(Long userId) { this.userId = userId; }
    public void setHotelId(Long hotelId) { this.hotelId = hotelId; }
    public void setLiked(Boolean liked) { this.liked = liked; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}