package com.example.tourismservice.service;


import com.example.tourismservice.entity.Beach;
import com.example.tourismservice.repository.BeachRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class BeachService {

    private final BeachRepository repository;

    public BeachService(BeachRepository repository) {
        this.repository = repository;
    }

    public Beach saveBeach(Beach beach) {
        return repository.save(beach);
    }

    public List<Beach> getAllBeaches() {
        return repository.findAll();
    }

    public void deleteBeach(Long id) {
        repository.deleteById(id);
    }
    public Beach updateBeach(Long id, Beach updatedBeach) {
    Beach existingBeach = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Beach not found"));

    existingBeach.setName(updatedBeach.getName());
    existingBeach.setCity(updatedBeach.getCity());
    existingBeach.setDescription(updatedBeach.getDescription());
    existingBeach.setAddress(updatedBeach.getAddress());
    existingBeach.setImageUrl(updatedBeach.getImageUrl());

    return repository.save(existingBeach);
}
public Beach getBeachById(Long id) {
    return repository.findById(id).orElse(null);
}

public Beach save(Beach beach) {
    return repository.save(beach);
}
}