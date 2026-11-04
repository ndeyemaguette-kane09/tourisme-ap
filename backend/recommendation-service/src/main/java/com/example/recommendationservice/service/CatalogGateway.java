package com.example.recommendationservice.service;

import com.example.recommendationservice.client.ReservationClient;
import com.example.recommendationservice.client.TourismClient;
import io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker;
import io.github.resilience4j.retry.annotation.Retry;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;

@Component
public class CatalogGateway {

    private static final Logger log = LoggerFactory.getLogger(CatalogGateway.class);

    private final TourismClient tourismClient;
    private final ReservationClient reservationClient;

    private volatile List<Map<String, Object>> lastCatalog = List.of();

    public CatalogGateway(TourismClient tourismClient, ReservationClient reservationClient) {
        this.tourismClient = tourismClient;
        this.reservationClient = reservationClient;
    }

    @CircuitBreaker(name = "tourismService", fallbackMethod = "cachedCatalog")
    public List<Map<String, Object>> catalog() {
        List<Map<String, Object>> catalog = tourismClient.getCatalog();
        lastCatalog = catalog;
        return catalog;
    }

    // tourism-service indisponible : on sert le dernier catalogue reçu
    private List<Map<String, Object>> cachedCatalog(Throwable error) {
        log.warn("Catalogue indisponible, utilisation du cache ({} éléments) : {}", lastCatalog.size(), error.getMessage());
        return lastCatalog;
    }

    @CircuitBreaker(name = "bookingService", fallbackMethod = "noReservations")
    @Retry(name = "bookingService")
    public List<Map<String, Object>> reservations(Long userId) {
        return reservationClient.getReservationsByUser(userId);
    }

    private List<Map<String, Object>> noReservations(Long userId, Throwable error) {
        return List.of();
    }
}
