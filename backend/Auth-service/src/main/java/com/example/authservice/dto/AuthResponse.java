package com.example.authservice.dto;

import com.example.authservice.entity.Role;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
public class AuthResponse {
    private String token;
    private Long userId;
    private String name;
    private String role;

    public AuthResponse(String token, Long userId, String name, String role) {
        this.token = token;
        this.userId = userId;
        this.name = name;
        this.role = role;
    }

    // getters
    public String getToken() { return token; }
    public Long getUserId() { return userId; }
    public String getName(){return name;}
    public String getRole(){return role;}
}