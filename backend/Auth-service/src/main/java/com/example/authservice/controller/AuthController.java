package com.example.authservice.controller;

import java.util.Map;

import org.springframework.security.core.Authentication;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.authservice.dto.AuthResponse;
import com.example.authservice.dto.LoginRequest;
import com.example.authservice.dto.RegisterRequest;
import com.example.authservice.entity.User;
import com.example.authservice.service.AuthService;

@RestController
@RequestMapping("/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/register")
    public User register(@RequestBody RegisterRequest request){
        return authService.register(request);
    }
    @PostMapping("/login")
public AuthResponse login(@RequestBody LoginRequest request){
    return authService.login(request);
}

@PutMapping("/change-password/{id}")
public ResponseEntity<?> changePassword(
        @PathVariable Long id,
        @RequestBody Map<String, String> request,
        Authentication authentication) {

    String oldPassword = request.get("oldPassword");
    String newPassword = request.get("newPassword");

    authService.changePassword(
            id,
            oldPassword,
            newPassword,
            authentication
    );

    return ResponseEntity.ok("Password updated successfully");
}
}