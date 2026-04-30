package com.example.reservationservice.service;

import com.example.reservationservice.client.HotelClient;
import com.example.reservationservice.client.NotificationClient;
import com.example.reservationservice.client.UserClient;
import com.example.reservationservice.entity.Reservation;
import com.example.reservationservice.repository.ReservationRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
public class ReservationService {

    private final ReservationRepository reservationRepository;
    private final HotelClient hotelClient;
    private final UserClient userClient;
    private final NotificationClient notificationClient;

    public ReservationService(ReservationRepository reservationRepository,
                              HotelClient hotelClient,
                              UserClient userClient,
                              NotificationClient notificationClient) {
        this.reservationRepository = reservationRepository;
        this.hotelClient = hotelClient;
        this.userClient = userClient;
        this.notificationClient = notificationClient;
    }

    public Reservation createReservation(Reservation reservation) {

        // Vérifier si l'utilisateur existe
        userClient.getUserById(reservation.getUserId());

        // Vérifier si l'hôtel existe
        hotelClient.getHotelById(reservation.getHotelId());

        // Définir le statut
        reservation.setStatus("CREATED");

        // Sauvegarder réservation
        Reservation saved = reservationRepository.save(reservation);

        // Envoyer notification
        Map<String, Object> notifBody = Map.of(
                "userId", reservation.getUserId(),
                "message", "Votre réservation a été confirmée",
                "type", "RESERVATION"
        );
        notificationClient.sendNotification(notifBody);

        return saved;
    }

    public List<Reservation> getAllReservations() {
        return reservationRepository.findAll();
    }

    public List<Reservation> getReservationsByUser(Long userId) {
        return reservationRepository.findByUserId(userId);
    }

    public void cancelReservation(Long id) {
        Reservation reservation = reservationRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Reservation not found"));

        reservation.setStatus("CANCELLED");
        reservationRepository.save(reservation);
    }
    
}