package com.example.reservationservice.service;

import com.example.reservationservice.client.HotelClient;
import com.example.reservationservice.client.UserClient;
import com.example.reservationservice.entity.Reservation;
import com.example.reservationservice.entity.ReservationStatus;
import com.example.reservationservice.repository.ReservationRepository;
import feign.FeignException;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Map;

@Service
public class ReservationService {

    private final ReservationRepository reservationRepository;
    private final HotelClient hotelClient;
    private final UserClient userClient;
    private final NotificationSender notificationSender;

    public ReservationService(ReservationRepository reservationRepository,
                              HotelClient hotelClient,
                              UserClient userClient,
                              NotificationSender notificationSender) {
        this.reservationRepository = reservationRepository;
        this.hotelClient = hotelClient;
        this.userClient = userClient;
        this.notificationSender = notificationSender;
    }

    public Reservation createReservation(Reservation reservation) {
        LocalDate checkIn = reservation.getCheckInDate();
        LocalDate checkOut = reservation.getCheckOutDate();

        if (checkIn == null || checkOut == null || !checkOut.isAfter(checkIn)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Dates de séjour invalides");
        }
        if (checkIn.isBefore(LocalDate.now())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "La date d'arrivée est déjà passée");
        }
        if (reservation.getGuests() < 1) {
            reservation.setGuests(1);
        }

        // Vérifier si l'utilisateur existe
        try {
            userClient.getUserById(reservation.getUserId());
        } catch (FeignException e) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Utilisateur introuvable");
        }

        // Vérifier si l'hôtel existe
        Map<String, Object> hotel;
        try {
            hotel = hotelClient.getHotelById(reservation.getHotelId());
        } catch (FeignException e) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Hôtel introuvable");
        }
        if (hotel == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Hôtel introuvable");
        }

        long nights = ChronoUnit.DAYS.between(checkIn, checkOut);
        double pricePerNight = hotel.get("price") == null ? 0 : Double.parseDouble(hotel.get("price").toString());

        reservation.setId(null);
        reservation.setHotelName((String) hotel.get("name"));
        reservation.setTotalPrice(pricePerNight * nights);
        // Définir le statut
        reservation.setStatus(ReservationStatus.EN_ATTENTE);
        reservation.setCreatedAt(LocalDateTime.now());

        // Sauvegarder réservation
        Reservation saved = reservationRepository.save(reservation);

        // Envoyer notification
        notify(saved, "Votre demande de réservation à " + saved.getHotelName() + " a bien été enregistrée");

        return saved;
    }

    public List<Reservation> getAllReservations() {
        return reservationRepository.findAllByOrderByCreatedAtDesc();
    }

    public List<Reservation> getReservationsByUser(Long userId) {
        return reservationRepository.findByUserIdOrderByCreatedAtDesc(userId);
    }

    public Reservation getReservation(Long id) {
        return reservationRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Réservation introuvable"));
    }

    public Reservation confirmReservation(Long id) {
        Reservation reservation = getReservation(id);
        if (reservation.getStatus() != ReservationStatus.EN_ATTENTE) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Seule une réservation en attente peut être confirmée");
        }
        reservation.setStatus(ReservationStatus.CONFIRMEE);
        Reservation saved = reservationRepository.save(reservation);
        notify(saved, "Votre réservation à " + saved.getHotelName() + " est confirmée");
        return saved;
    }

    public Reservation cancelReservation(Long id) {
        Reservation reservation = getReservation(id);
        if (reservation.getStatus() == ReservationStatus.ANNULEE
                || reservation.getStatus() == ReservationStatus.TERMINEE) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Cette réservation ne peut plus être annulée");
        }
        reservation.setStatus(ReservationStatus.ANNULEE);
        Reservation saved = reservationRepository.save(reservation);
        notify(saved, "Votre réservation à " + saved.getHotelName() + " a été annulée");
        return saved;
    }

    private void notify(Reservation reservation, String message) {
        notificationSender.send(reservation.getUserId(), message);
    }
}
