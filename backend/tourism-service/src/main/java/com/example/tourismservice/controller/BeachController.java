package com.example.tourismservice.controller;

import com.example.tourismservice.entity.Beach;
import com.example.tourismservice.service.BeachService;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/beaches")
@CrossOrigin(origins = "*")
public class BeachController {

    private final BeachService service;

    public BeachController(BeachService service) {
        this.service = service;
    }

    @PostMapping
    public Beach createBeach(@RequestBody Beach beach) {
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

    // 🔥 ADDRESS FIX
    String address = (String) data.get("address");
    if (address != null) {
        beach.setAddress(address);
    }

    String image = (String) data.get("imageUrl");
    if (image != null) {
        System.out.println("🔥 IMAGE RECUE: " + data.get("imageUrl"));
        beach.setImageUrl(image);
    }

    String cityName = (String) data.get("city");
    if (cityName != null) {
        beach.setCity(cityName);
    }


    return service.save(beach);

    
}
}