package com.example.tourismservice.controller;

import com.example.tourismservice.entity.Category;
import com.example.tourismservice.repository.BeachRepository;
import com.example.tourismservice.repository.HotelRepository;
import com.example.tourismservice.repository.PlaceRepository;
import com.example.tourismservice.repository.RestaurantRepository;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.text.Normalizer;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/search")
public class SearchController {

    private final HotelRepository hotelRepository;
    private final RestaurantRepository restaurantRepository;
    private final BeachRepository beachRepository;
    private final PlaceRepository placeRepository;

    public SearchController(HotelRepository hotelRepository,
                            RestaurantRepository restaurantRepository,
                            BeachRepository beachRepository,
                            PlaceRepository placeRepository) {
        this.hotelRepository = hotelRepository;
        this.restaurantRepository = restaurantRepository;
        this.beachRepository = beachRepository;
        this.placeRepository = placeRepository;
    }

    @GetMapping
    public List<Map<String, Object>> search(@RequestParam(required = false) String q,
                                            @RequestParam(required = false) String type,
                                            @RequestParam(required = false) String city,
                                            @RequestParam(required = false) String category,
                                            @RequestParam(required = false) String subType,
                                            @RequestParam(required = false) Double minRating,
                                            @RequestParam(required = false) Double maxPrice) {
        List<Map<String, Object>> items = catalog();

        return items.stream()
                .filter(i -> type == null || type.isBlank() || type.equalsIgnoreCase((String) i.get("type")))
                .filter(i -> city == null || city.isBlank() || normalize(city).equals(normalize((String) i.get("city"))))
                .filter(i -> category == null || category.isBlank() || category.equalsIgnoreCase((String) i.get("category")))
                .filter(i -> subType == null || subType.isBlank() || normalize(subType).equals(normalize((String) i.get("subType"))))
                .filter(i -> minRating == null || (double) i.get("rating") >= minRating)
                .filter(i -> maxPrice == null || i.get("price") == null || (double) i.get("price") <= maxPrice)
                .filter(i -> matches(i, q))
                .sorted(Comparator.comparingDouble((Map<String, Object> i) -> (double) i.get("rating")).reversed())
                .toList();
    }

    public List<Map<String, Object>> catalog() {
        List<Map<String, Object>> items = new ArrayList<>();
        hotelRepository.findAll().forEach(h -> items.add(item(h.getId(), "hotel", h.getName(), h.getDescription(),
                h.getCityForJson(), h.getImageUrl(), h.getRating(), h.getCategory(), h.getLatitude(), h.getLongitude(), h.getPrice())));
        restaurantRepository.findAll().forEach(r -> items.add(item(r.getId(), "restaurant", r.getName(), r.getDescription(),
                r.getCity(), r.getImageUrl(), r.getRating(), r.getCategory(), r.getLatitude(), r.getLongitude(), null)));
        beachRepository.findAll().forEach(b -> items.add(item(b.getId(), "beach", b.getName(), b.getDescription(),
                b.getCity(), b.getImageUrl(), b.getRating(), b.getCategory(), b.getLatitude(), b.getLongitude(), null)));
        placeRepository.findAll().forEach(p -> {
            Map<String, Object> item = item(p.getId(), "place", p.getName(), p.getDescription(),
                    p.getCity(), p.getImageUrl(), p.getRating(), p.getCategory(), p.getLatitude(), p.getLongitude(), p.getEntryPrice());
            item.put("visitDuration", p.getVisitDuration());
            item.put("region", p.getRegion());
            item.put("subType", p.getSubType());
            items.add(item);
        });
        return items;
    }

    private Map<String, Object> item(Long id, String type, String name, String description, String city, String imageUrl,
                                     double rating, Category category, Double lat, Double lng, Double price) {
        Map<String, Object> item = new HashMap<>();
        item.put("id", id);
        item.put("type", type);
        item.put("name", name);
        item.put("description", description);
        item.put("city", city == null ? "" : city.trim());
        item.put("imageUrl", imageUrl);
        item.put("rating", rating);
        item.put("category", category == null ? null : category.getName());
        item.put("latitude", lat);
        item.put("longitude", lng);
        item.put("price", price);
        return item;
    }

    private boolean matches(Map<String, Object> item, String q) {
        if (q == null || q.isBlank()) {
            return true;
        }
        String haystack = normalize(item.get("name") + " " + item.get("city") + " "
                + item.get("category") + " " + item.get("subType") + " " + item.get("description"));
        for (String word : normalize(q).split("\\s+")) {
            if (!haystack.contains(word)) {
                return false;
            }
        }
        return true;
    }

    // "Gorée" et "goree" doivent donner le même résultat
    private String normalize(String s) {
        if (s == null) {
            return "";
        }
        return Normalizer.normalize(s, Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "")
                .toLowerCase()
                .trim();
    }
}
