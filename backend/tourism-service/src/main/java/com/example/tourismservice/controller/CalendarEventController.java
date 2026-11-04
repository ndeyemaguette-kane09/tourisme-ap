package com.example.tourismservice.controller;

import com.example.tourismservice.entity.CalendarEvent;
import com.example.tourismservice.repository.CalendarEventRepository;
import com.example.tourismservice.repository.PlaceRepository;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/events")
public class CalendarEventController {

    private final CalendarEventRepository eventRepository;
    private final PlaceRepository placeRepository;

    public CalendarEventController(CalendarEventRepository eventRepository, PlaceRepository placeRepository) {
        this.eventRepository = eventRepository;
        this.placeRepository = placeRepository;
    }

    @GetMapping
    public List<CalendarEvent> getEvents(@RequestParam(defaultValue = "true") boolean upcoming) {
        if (upcoming) {
            return eventRepository.findByEndDateGreaterThanEqualOrderByStartDateAsc(LocalDate.now());
        }
        return eventRepository.findAllByOrderByStartDateAsc();
    }

    @GetMapping("/{id}")
    public CalendarEvent getEvent(@PathVariable Long id) {
        return eventRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Événement non trouvé"));
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public CalendarEvent createEvent(@RequestBody Map<String, Object> data) {
        CalendarEvent event = new CalendarEvent();
        fill(event, data);
        return eventRepository.save(event);
    }

    @PutMapping("/{id}")
    public CalendarEvent updateEvent(@PathVariable Long id, @RequestBody Map<String, Object> data) {
        CalendarEvent event = getEvent(id);
        fill(event, data);
        return eventRepository.save(event);
    }

    @DeleteMapping("/{id}")
    public void deleteEvent(@PathVariable Long id) {
        eventRepository.deleteById(id);
    }

    private void fill(CalendarEvent event, Map<String, Object> data) {
        if (data.get("name") != null) event.setName(data.get("name").toString().trim());
        if (data.get("community") != null) event.setCommunity(data.get("community").toString().trim());
        if (data.get("description") != null) event.setDescription(data.get("description").toString());
        if (data.get("advice") != null) event.setAdvice(data.get("advice").toString());
        if (data.get("city") != null) event.setCity(data.get("city").toString().trim());
        if (data.get("confirmed") != null) event.setConfirmed(Boolean.parseBoolean(data.get("confirmed").toString()));

        LocalDate start = date(data.get("startDate"));
        LocalDate end = date(data.get("endDate"));
        if (start != null) event.setStartDate(start);
        if (end != null) event.setEndDate(end);
        if (event.getStartDate() == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "La date de début est obligatoire");
        }
        if (event.getEndDate() == null || event.getEndDate().isBefore(event.getStartDate())) {
            event.setEndDate(event.getStartDate());
        }

        if (data.containsKey("placeId")) {
            Object placeId = data.get("placeId");
            event.setPlace(placeId == null ? null : placeRepository.findById(Long.parseLong(placeId.toString()))
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "Lieu inconnu")));
        }
    }

    private LocalDate date(Object value) {
        if (value == null || value.toString().isBlank()) return null;
        try {
            return LocalDate.parse(value.toString().substring(0, 10));
        } catch (DateTimeParseException | StringIndexOutOfBoundsException e) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Date invalide : " + value);
        }
    }
}
