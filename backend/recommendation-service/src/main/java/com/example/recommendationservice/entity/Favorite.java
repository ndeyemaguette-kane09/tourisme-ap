package com.example.recommendationservice.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "favorites",
        uniqueConstraints = @UniqueConstraint(columnNames = {"userId", "itemId", "itemType"}))
public class Favorite {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long userId;
    private Long itemId;

    // hotel, restaurant, beach ou place
    private String itemType;

    private String title;
    private String imageUrl;
    private String city;
    private LocalDateTime createdAt;

    public Favorite() {
        this.createdAt = LocalDateTime.now();
    }

    public Long getId() { return id; }
    public Long getUserId() { return userId; }
    public Long getItemId() { return itemId; }
    public String getItemType() { return itemType; }
    public String getTitle() { return title; }
    public String getImageUrl() { return imageUrl; }
    public String getCity() { return city; }
    public LocalDateTime getCreatedAt() { return createdAt; }

    public void setId(Long id) { this.id = id; }
    public void setUserId(Long userId) { this.userId = userId; }
    public void setItemId(Long itemId) { this.itemId = itemId; }
    public void setItemType(String itemType) { this.itemType = itemType; }
    public void setTitle(String title) { this.title = title; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
    public void setCity(String city) { this.city = city; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
