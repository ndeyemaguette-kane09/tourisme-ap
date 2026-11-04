package com.example.tourismservice.controller;

import com.example.tourismservice.entity.Place;
import com.example.tourismservice.repository.PlaceRepository;
import com.example.tourismservice.service.CategoryService;
import com.example.tourismservice.util.Values;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/places")
public class PlaceController {

    private final PlaceRepository placeRepository;
    private final CategoryService categoryService;

    public PlaceController(PlaceRepository placeRepository, CategoryService categoryService) {
        this.placeRepository = placeRepository;
        this.categoryService = categoryService;
    }

    @GetMapping
    public List<Place> getPlaces(@RequestParam(required = false) String city) {
        if (city != null && !city.isBlank()) {
            return placeRepository.findByCityIgnoreCase(city.trim());
        }
        return placeRepository.findAll();
    }

    @GetMapping("/{id}")
    public Place getPlace(@PathVariable Long id) {
        return placeRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Lieu non trouvé"));
    }

    @GetMapping("/category/{id}")
    public List<Place> getPlacesByCategory(@PathVariable Long id) {
        return placeRepository.findByCategoryId(id);
    }

    @GetMapping("/type/{subType}")
    public List<Place> getPlacesBySubType(@PathVariable String subType) {
        return placeRepository.findBySubTypeIgnoreCase(subType);
    }

    @GetMapping("/category/name/{name}")
    public List<Place> getPlacesByCategoryName(@PathVariable String name) {
        return placeRepository.findByCategoryName(name);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Place createPlace(@RequestBody Map<String, Object> data) {
        Place place = new Place();
        fill(place, data);
        return placeRepository.save(place);
    }

    @PutMapping("/{id}")
    public Place updatePlace(@PathVariable Long id, @RequestBody Map<String, Object> data) {
        Place place = getPlace(id);
        fill(place, data);
        return placeRepository.save(place);
    }

    @DeleteMapping("/{id}")
    public void deletePlace(@PathVariable Long id) {
        placeRepository.deleteById(id);
    }

    private void fill(Place place, Map<String, Object> data) {
        if (data.get("name") != null) place.setName((String) data.get("name"));
        if (data.get("subType") != null) place.setSubType(data.get("subType").toString().trim());
        if (data.get("description") != null) place.setDescription((String) data.get("description"));
        if (data.get("city") != null) place.setCity(data.get("city").toString().trim());
        if (data.get("region") != null) place.setRegion((String) data.get("region"));
        if (data.get("address") != null) place.setAddress((String) data.get("address"));
        if (data.get("imageUrl") != null) place.setImageUrl((String) data.get("imageUrl"));
        if (data.get("history") != null) place.setHistory((String) data.get("history"));
        if (data.get("tips") != null) place.setTips((String) data.get("tips"));

        Double lat = Values.toDouble(data.get("latitude"));
        Double lng = Values.toDouble(data.get("longitude"));
        if (lat != null && lng != null) {
            place.setLatitude(lat);
            place.setLongitude(lng);
        }

        Double duration = Values.toDouble(data.get("visitDuration"));
        if (duration != null) place.setVisitDuration(duration);

        Double price = Values.toDouble(data.get("entryPrice"));
        if (price != null) place.setEntryPrice(price);

        if (data.get("category") instanceof Map<?, ?> categoryMap && categoryMap.get("id") != null) {
            Long categoryId = Long.parseLong(categoryMap.get("id").toString());
            place.setCategory(categoryService.getCategoryById(categoryId));
        }
    }
}
