package com.example.reservationservice.service;

import com.example.reservationservice.client.NotificationClient;
import io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker;
import io.github.resilience4j.retry.annotation.Retry;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import java.util.Map;

@Component
public class NotificationSender {

    private static final Logger log = LoggerFactory.getLogger(NotificationSender.class);

    private final NotificationClient notificationClient;

    public NotificationSender(NotificationClient notificationClient) {
        this.notificationClient = notificationClient;
    }

    @CircuitBreaker(name = "notificationService", fallbackMethod = "skip")
    @Retry(name = "notificationService")
    public void send(Long userId, String message) {
        notificationClient.sendNotification(Map.of(
                "userId", userId,
                "message", message,
                "type", "RESERVATION"
        ));
    }

    private void skip(Long userId, String message, Throwable error) {
        log.warn("Notification non envoyée à l'utilisateur {} : {}", userId, error.getMessage());
    }
}
