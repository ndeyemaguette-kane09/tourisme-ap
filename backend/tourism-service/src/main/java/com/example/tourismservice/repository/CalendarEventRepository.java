package com.example.tourismservice.repository;

import com.example.tourismservice.entity.CalendarEvent;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;

public interface CalendarEventRepository extends JpaRepository<CalendarEvent, Long> {

    List<CalendarEvent> findByEndDateGreaterThanEqualOrderByStartDateAsc(LocalDate date);

    List<CalendarEvent> findAllByOrderByStartDateAsc();
}
