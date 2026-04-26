package com.example.tourismservice.controller;

import com.example.tourismservice.entity.Restaurant;
import com.example.tourismservice.service.RestaurantService;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/restaurants")
public class RestaurantController {

    private final RestaurantService restaurantService;

    public RestaurantController(RestaurantService restaurantService){
        this.restaurantService = restaurantService;
    }

    @PostMapping
    public Restaurant createRestaurant(@RequestBody java.util.Map<String, Object> data) {

        Restaurant restaurant = new Restaurant();

        restaurant.setName((String) data.get("name"));
        restaurant.setAddress((String) data.get("address"));
        restaurant.setDescription((String) data.get("description"));

        // 🔥 IMAGE FIX (support both image & imageUrl)
        String image = (String) data.get("image");
        if (image == null || image.isEmpty()) {
            image = (String) data.get("imageUrl");
        }
        restaurant.setImageUrl(image);

        // 🔥 RATING FIX
        Object ratingObj = data.get("rating");
        if (ratingObj != null) {
            restaurant.setRating(Double.parseDouble(ratingObj.toString()));
        }

        // 🔥 CITY FIX (simplify city handling)
        String cityName = (String) data.get("city");
        if (cityName != null) {
            restaurant.setCity(cityName);
        }

        return restaurantService.saveRestaurant(restaurant);
    }

    @GetMapping
    public List<Restaurant> getRestaurants(){
        return restaurantService.getAllRestaurants();
    }



   @PutMapping("/{id}")
public Restaurant updateRestaurant(@PathVariable Long id, @RequestBody Map<String, Object> data) {

    // 🔥 IMPORTANT : récupérer l’existant
    Restaurant restaurant = restaurantService.getRestaurantById(id);

    if (restaurant == null) {
        throw new RuntimeException("Restaurant non trouvé");
    }

    // ── UPDATE PROPRE ──
    restaurant.setName((String) data.get("name"));
    restaurant.setDescription((String) data.get("description"));
    restaurant.setAddress((String) data.get("address"));

    // 🔥 IMAGE FIX
    String image = (String) data.get("imageUrl");
    if (image != null) {
        System.out.println("🔥 IMAGE RECUE: " + data.get("imageUrl"));
        restaurant.setImageUrl(image);
    }

    // 🔥 RATING FIX
    Object ratingObj = data.get("rating");
    if (ratingObj != null) {
        restaurant.setRating(Double.parseDouble(ratingObj.toString()));
    }

    // 🔥 CITY FIX
    String cityName = (String) data.get("city");
    if (cityName != null) {
        restaurant.setCity(cityName);
    }

    
    return restaurantService.save(restaurant);
}
}