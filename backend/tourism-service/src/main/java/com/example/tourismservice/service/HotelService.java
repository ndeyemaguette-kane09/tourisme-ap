package com.example.tourismservice.service;

import com.example.tourismservice.entity.Hotel;
import com.example.tourismservice.repository.HotelRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class HotelService {

    private final HotelRepository hotelRepository;

    public HotelService(HotelRepository hotelRepository){
        this.hotelRepository = hotelRepository;
    }

    public Hotel saveHotel(Hotel hotel){
        return hotelRepository.save(hotel);
    }

    public List<Hotel> getAllHotels(){
        return hotelRepository.findAll();
    }

    public Hotel getHotelById(Long id){
        return hotelRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Hotel not found"));
    }

    public void deleteHotel(Long id){
        hotelRepository.deleteById(id);
    }
}