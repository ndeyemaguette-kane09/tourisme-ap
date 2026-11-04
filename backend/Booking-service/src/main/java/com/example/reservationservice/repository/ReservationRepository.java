package com.example.reservationservice.repository;

import com.example.reservationservice.entity.Reservation;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface ReservationRepository extends JpaRepository<Reservation, Long> {

    List<Reservation> findByUserIdOrderByCreatedAtDesc(Long userId);

    List<Reservation> findByHotelId(Long hotelId);

    List<Reservation> findAllByOrderByCreatedAtDesc();
}
