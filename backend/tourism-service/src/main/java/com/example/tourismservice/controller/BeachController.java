package com.example.tourismservice.controller;

import com.example.tourismservice.entity.Beach;
import com.example.tourismservice.entity.Hotel;
import com.example.tourismservice.service.BeachService;
import org.springframework.web.bind.annotation.*;
import com.example.tourismservice.entity.Category;
import com.example.tourismservice.service.CategoryService;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/beaches")
@CrossOrigin(origins = "*")
public class BeachController {
private final BeachService service;
private final CategoryService categoryService;

    public BeachController(BeachService service, CategoryService categoryService) {
    this.service = service;
    this.categoryService = categoryService;
}

    @PostMapping
public Beach createBeach(@RequestBody Map<String, Object> data) {

    Beach beach = new Beach();

    beach.setName((String) data.get("name"));
    beach.setDescription((String) data.get("description"));
    beach.setAddress((String) data.get("address"));
    beach.setImageUrl((String) data.get("imageUrl"));

    Object ratingObj = data.get("rating");
    if (ratingObj != null) {
        beach.setRating(Double.parseDouble(ratingObj.toString()));
    }

    String city = (String) data.get("city");
    if (city != null) {
        beach.setCity(city);
    }

    Object categoryObj = data.get("category");

    if (categoryObj instanceof Map<?, ?> categoryMap) {

        Object categoryIdObj = categoryMap.get("id");

        if (categoryIdObj != null) {

            Long categoryId = Long.parseLong(categoryIdObj.toString());

            Category category = categoryService.getCategoryById(categoryId);

            beach.setCategory(category);
        }
    }

    return service.saveBeach(beach);
}

    @GetMapping
    public List<Beach> getAllBeaches() {
        return service.getAllBeaches();
    }

    @DeleteMapping("/{id}")
    public void deleteBeach(@PathVariable Long id) {
        service.deleteBeach(id);
    }
    @PutMapping("/{id}")
public Beach updateBeach(@PathVariable Long id, @RequestBody Map<String, Object> data) {

    Beach beach = service.getBeachById(id);

    if (beach == null) {
        throw new RuntimeException("Plage non trouvée");
    }

    beach.setName((String) data.get("name"));
    beach.setDescription((String) data.get("description"));

    //  ADDRESS FIX
    String address = (String) data.get("address");
    if (address != null) {
        beach.setAddress(address);
    }

    String image = (String) data.get("imageUrl");
    if (image != null) {
        
        beach.setImageUrl(image);
    }

    String cityName = (String) data.get("city");
    if (cityName != null) {
        beach.setCity(cityName);
    }


    return service.save(beach);

    
}

@GetMapping("/category/{id}")
public List<Beach> getBeachesByCategory(@PathVariable Long id) {
    return service.getBeachesByCategory(id);
}


@GetMapping("/category/name/{name}")
public List<Beach> getBeachesByCategoryName(@PathVariable String name) {
    return service.getBeachesByCategoryName(name);
}

}