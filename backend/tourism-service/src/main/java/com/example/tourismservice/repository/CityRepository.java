package com.example.tourismservice.repository;

import com.example.tourismservice.entity.City;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface CityRepository extends JpaRepository<City, Long> {

    Optional<City> findByName(String name);
    Optional<City> findByNameIgnoreCase(String name);

}