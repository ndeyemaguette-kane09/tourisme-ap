package com.example.tourismservice.controller;

import com.example.tourismservice.entity.City;
import com.example.tourismservice.entity.Hotel;
import com.example.tourismservice.service.HotelService;
import com.example.tourismservice.service.CityService;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/hotels")
public class HotelController {

    private final HotelService hotelService;
    private final CityService cityService;

    public HotelController(HotelService hotelService, CityService cityService){
        this.hotelService = hotelService;
        this.cityService = cityService;
    }

    @PostMapping
    public Hotel createHotel(@RequestBody Map<String, Object> data){

        System.out.println("🔥 HOTEL RECU: " + data);

        Hotel hotel = new Hotel();

        hotel.setName((String) data.get("name"));
        hotel.setPrice(Double.parseDouble(data.get("price").toString()));
        hotel.setImageUrl((String) data.get("imageUrl"));

        // 🔥 FIX CITY (same logic as update)
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

        return hotelService.saveHotel(hotel);
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

    System.out.println("🔥 PUT HOTEL CALLED");
System.out.println("DATA: " + data);


    Hotel existing = hotelService.getHotelById(id);

    if (data.get("description") != null) {
        existing.setDescription((String) data.get("description"));
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

    return hotelService.saveHotel(existing);
}
    
}