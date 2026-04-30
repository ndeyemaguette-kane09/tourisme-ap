package com.example.reservationservice.controller;

import com.example.reservationservice.entity.Reservation;
import com.example.reservationservice.service.ReservationService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/reservations")
public class ReservationController {

    private final ReservationService reservationService;

    public ReservationController(ReservationService reservationService){
        this.reservationService = reservationService;
    }

    @PostMapping
    public Reservation createReservation(@RequestBody Reservation reservation){
                return reservationService.createReservation(reservation);
    }

    @GetMapping("/user/{userId}")
public List<Reservation> getReservationsByUser(@PathVariable Long userId){
    return reservationService.getReservationsByUser(userId);
}

    @GetMapping
    public List<Reservation> getReservations(){
        return reservationService.getAllReservations();
    }
}