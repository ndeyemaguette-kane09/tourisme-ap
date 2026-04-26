package com.example.tourismservice.service;

import com.example.tourismservice.entity.Restaurant;
import com.example.tourismservice.repository.RestaurantRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class RestaurantService {

    private final RestaurantRepository restaurantRepository;

    public RestaurantService(RestaurantRepository restaurantRepository){
        this.restaurantRepository = restaurantRepository;
    }

    public Restaurant saveRestaurant(Restaurant restaurant){
        return restaurantRepository.save(restaurant);
    }

    public List<Restaurant> getAllRestaurants(){
        return restaurantRepository.findAll();
    }

    public Restaurant updateRestaurant(Long id, Restaurant updatedRestaurant) {
    Restaurant existingRestaurant = restaurantRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Restaurant not found"));

    existingRestaurant.setName(updatedRestaurant.getName());
    existingRestaurant.setCity(updatedRestaurant.getCity());
    existingRestaurant.setDescription(updatedRestaurant.getDescription());
    existingRestaurant.setAddress(updatedRestaurant.getAddress());
    existingRestaurant.setImageUrl(updatedRestaurant.getImageUrl());

    return restaurantRepository.save(existingRestaurant);
}
public Restaurant getRestaurantById(Long id) {
    return restaurantRepository.findById(id).orElse(null);
}

public Restaurant save(Restaurant restaurant) {
    return restaurantRepository.save(restaurant);
}
}