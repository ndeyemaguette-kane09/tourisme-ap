package com.example.tourismservice.controller;

import com.example.tourismservice.entity.City;
import com.example.tourismservice.entity.Hotel;
import com.example.tourismservice.service.HotelService;
import com.example.tourismservice.service.CityService;
import org.springframework.web.bind.annotation.*;
import com.example.tourismservice.entity.Category;
import com.example.tourismservice.service.CategoryService;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/hotels")
public class HotelController {

    private final HotelService hotelService;
    private final CityService cityService;
    private final CategoryService categoryService;

    public HotelController(HotelService hotelService,
                       CityService cityService,
                       CategoryService categoryService){

    this.hotelService = hotelService;
    this.cityService = cityService;
    this.categoryService = categoryService;
}

    @PostMapping
    public Hotel createHotel(@RequestBody Map<String, Object> data){

        

        Hotel hotel = new Hotel();

        hotel.setName((String) data.get("name"));
        hotel.setPrice(Double.parseDouble(data.get("price").toString()));
        hotel.setImageUrl((String) data.get("imageUrl"));


        hotel.setDescription((String) data.get("description"));
hotel.setAddress((String) data.get("address"));

Object ratingObj = data.get("rating");
if (ratingObj != null) {
    hotel.setRating(Double.parseDouble(ratingObj.toString()));
}
Object categoryObj = data.get("category");

if (categoryObj instanceof Map<?, ?> categoryMap) {

    Object categoryIdObj = categoryMap.get("id");

    if (categoryIdObj != null) {

        Long categoryId = Long.parseLong(categoryIdObj.toString());

        Category category = categoryService.getCategoryById(categoryId);

        hotel.setCategory(category);
    }
}

        //  FIX CITY (same logic as update)
        Object cityObj = data.get("city");
        if (cityObj == null) {
            cityObj = data.get("cityName");
        }

        if (cityObj != null) {
            String cityName = cityObj.toString().trim();

            hotel.setCityName(cityName);

            try {
                City city = cityService.findByName(cityName);
                hotel.setCity(city);
            } catch (Exception e) {
                System.out.println("⚠️ City not found: " + cityName);
            }
        }

       
        System.out.println("NAME = " + hotel.getName());
        System.out.println("ADDRESS = " + hotel.getAddress());
        System.out.println("DESCRIPTION = " + hotel.getDescription());
        System.out.println("PRICE = " + hotel.getPrice());
        System.out.println("RATING = " + hotel.getRating());
        System.out.println("IMAGE = " + hotel.getImageUrl());
        System.out.println("CITY NAME = " + hotel.getCityName());
        System.out.println("CATEGORY = " + hotel.getCategory());

        Hotel savedHotel = hotelService.saveHotel(hotel);

        
        System.out.println(savedHotel);

        return savedHotel;
    }

    @GetMapping
    public List<Hotel> getHotels(){
        return hotelService.getAllHotels();
    }

    @GetMapping("/{id}")
    public Hotel getHotel(@PathVariable Long id){
        return hotelService.getHotelById(id);
    }

    @DeleteMapping("/{id}")
    public void deleteHotel(@PathVariable Long id){
        hotelService.deleteHotel(id);
    }


    @PutMapping("/{id}")
public Hotel updateHotel(@PathVariable Long id, @RequestBody Map<String, Object> data) {

    


    Hotel existing = hotelService.getHotelById(id);

    if (data.get("description") != null) {
        existing.setDescription((String) data.get("description"));
    }
    if (data.get("address") != null) {
    existing.setAddress((String) data.get("address"));
}

    existing.setName((String) data.get("name"));
    existing.setPrice(Double.parseDouble(data.get("price").toString()));
    existing.setImageUrl((String) data.get("imageUrl"));

    // 🔥 FIX RATING
    Object ratingObj = data.get("rating");
    if (ratingObj != null) {
        existing.setRating(Double.parseDouble(ratingObj.toString()));
    }

    // 🔥 FIX CITY (handle both city and cityName)
    Object cityObj = data.get("city");
    if (cityObj == null) {
        cityObj = data.get("cityName");
    }

    if (cityObj != null) {
        String cityName = cityObj.toString().trim();

        // 🔥 update visible field
        existing.setCityName(cityName);

        try {
            // 🔥 update relation safely
            City city = cityService.findByName(cityName);
            existing.setCity(city);
        } catch (Exception e) {
            System.out.println("⚠️ City not found: " + cityName);
        }
    }
    Object categoryObj = data.get("category");

if (categoryObj instanceof Map<?, ?> categoryMap) {

    Object categoryIdObj = categoryMap.get("id");

    if (categoryIdObj != null) {

        Long categoryId = Long.parseLong(categoryIdObj.toString());

        Category category = categoryService.getCategoryById(categoryId);

        existing.setCategory(category);
    }
}

    return hotelService.saveHotel(existing);
}
    

@GetMapping("/category/{id}")
public List<Hotel> getHotelsByCategory(@PathVariable Long id) {
    return hotelService.getHotelsByCategory(id);
}

@GetMapping("/category/name/{name}")
public List<Hotel> getHotelsByCategoryName(@PathVariable String name) {
    return hotelService.getHotelsByCategoryName(name);
}
}