package com.example.tourismservice.service;

import com.example.tourismservice.entity.Hotel;
import com.example.tourismservice.repository.HotelRepository;
import org.springframework.stereotype.Service;
import com.example.tourismservice.entity.Category;
import com.example.tourismservice.repository.CategoryRepository;

import java.util.List;

@Service
public class HotelService {

    private final HotelRepository hotelRepository;
    private final CategoryRepository categoryRepository;

    public HotelService(HotelRepository hotelRepository,
                    CategoryRepository categoryRepository) {

    this.hotelRepository = hotelRepository;
    this.categoryRepository = categoryRepository;
}

    public Hotel saveHotel(Hotel hotel){

    if (hotel.getCategory() != null &&
        hotel.getCategory().getId() != null) {

        Category category = categoryRepository
                .findById(hotel.getCategory().getId())
                .orElseThrow(() -> new RuntimeException("Category not found"));

        hotel.setCategory(category);
    }

    return hotelRepository.save(hotel);
}

    public List<Hotel> getAllHotels(){
        return hotelRepository.findAll();
    }

    public Hotel getHotelById(Long id){
        return hotelRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Hotel not found"));
    }

    public Hotel updateHotel(Long id, Hotel updatedHotel) {
        Hotel existingHotel = hotelRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Hotel not found"));

        existingHotel.setName(updatedHotel.getName());
        existingHotel.setCity(updatedHotel.getCity());
        existingHotel.setPrice(updatedHotel.getPrice());
        existingHotel.setImageUrl(updatedHotel.getImageUrl());

        return hotelRepository.save(existingHotel);
    }

    public void deleteHotel(Long id){
        hotelRepository.deleteById(id);
    }
    public List<Hotel> getHotelsByCategory(Long categoryId) {
    return hotelRepository.findByCategoryId(categoryId);
}
public List<Hotel> getHotelsByCategoryName(String categoryName) {
    return hotelRepository.findByCategoryName(categoryName);        

}
}