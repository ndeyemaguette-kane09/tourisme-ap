package com.example.tourismservice.service;

import com.example.tourismservice.entity.City;
import com.example.tourismservice.repository.CityRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CityService {

    private final CityRepository cityRepository;

    public CityService(CityRepository cityRepository){
        this.cityRepository = cityRepository;
    }

    public City saveCity(City city){
        return cityRepository.save(city);
    }

    public List<City> getAllCities(){
        return cityRepository.findAll();
    }
    
    public City findByName(String name) {
    return cityRepository.findByNameIgnoreCase(name.trim())
        .orElseThrow(() -> new RuntimeException("City not found: " + name));
}
}