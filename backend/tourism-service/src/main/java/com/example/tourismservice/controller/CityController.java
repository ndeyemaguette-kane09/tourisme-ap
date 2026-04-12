package com.example.tourismservice.controller;

import com.example.tourismservice.entity.City;
import com.example.tourismservice.service.CityService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/cities")
public class CityController {

    private final CityService cityService;

    public CityController(CityService cityService){
        this.cityService = cityService;
    }

    @PostMapping
    public City createCity(@RequestBody City city){
        return cityService.saveCity(city);
    }

    @GetMapping
    public List<City> getCities(){
        return cityService.getAllCities();
    }
}