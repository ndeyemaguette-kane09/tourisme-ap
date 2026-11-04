package com.example.reservationservice.controller;

import com.example.reservationservice.entity.Reservation;
import com.example.reservationservice.service.ReservationService;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@RestController
@RequestMapping("/reservations")
public class ReservationController {

    private final ReservationService reservationService;

    public ReservationController(ReservationService reservationService){
        this.reservationService = reservationService;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Reservation createReservation(@RequestBody Reservation reservation){
        return reservationService.createReservation(reservation);
    }

    @GetMapping("/user/{userId}")
    public List<Reservation> getReservationsByUser(@PathVariable Long userId){
        return reservationService.getReservationsByUser(userId);
    }

    @GetMapping
    public List<Reservation> getReservations(Authentication authentication){
        requireAdmin(authentication);
        return reservationService.getAllReservations();
    }

    @PutMapping("/{id}/confirm")
    public Reservation confirm(@PathVariable Long id, Authentication authentication){
        requireAdmin(authentication);
        return reservationService.confirmReservation(id);
    }

    @PutMapping("/{id}/cancel")
    public Reservation cancel(@PathVariable Long id){
        return reservationService.cancelReservation(id);
    }

    private void requireAdmin(Authentication authentication) {
        boolean admin = authentication != null && authentication.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ADMIN"));
        if (!admin) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Réservé aux administrateurs");
        }
    }
}
