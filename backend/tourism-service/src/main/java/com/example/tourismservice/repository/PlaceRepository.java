package com.example.tourismservice.repository;

import com.example.tourismservice.entity.Place;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface PlaceRepository extends JpaRepository<Place, Long> {

    List<Place> findByCategoryId(Long categoryId);

    List<Place> findByCategoryName(String name);

    List<Place> findByCityIgnoreCase(String city);

    List<Place> findBySubTypeIgnoreCase(String subType);
}
