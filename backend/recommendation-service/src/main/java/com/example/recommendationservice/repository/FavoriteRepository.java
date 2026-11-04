package com.example.recommendationservice.repository;

import com.example.recommendationservice.entity.Favorite;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

public interface FavoriteRepository extends JpaRepository<Favorite, Long> {

    List<Favorite> findByUserIdOrderByCreatedAtDesc(Long userId);

    Optional<Favorite> findByUserIdAndItemIdAndItemType(Long userId, Long itemId, String itemType);

    @Transactional
    void deleteByUserIdAndItemIdAndItemType(Long userId, Long itemId, String itemType);
}
