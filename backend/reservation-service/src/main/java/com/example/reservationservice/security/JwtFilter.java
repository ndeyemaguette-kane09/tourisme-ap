package com.example.reservationservice.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.ArrayList;

@Component
public class JwtFilter extends OncePerRequestFilter {

    private final JwtService jwtService;

    public JwtFilter(JwtService jwtService) {
        this.jwtService = jwtService;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain)
            throws ServletException, IOException {

        final String authHeader = request.getHeader("Authorization");
        String jwt = null;
String path = request.getServletPath();

// Autoriser les appels internes entre microservices
if (path.startsWith("/hotels") ||
    path.startsWith("/cities") ||
    path.startsWith("/restaurants") ||
    path.startsWith("/notifications") ||
    path.startsWith("/users")) {
    filterChain.doFilter(request, response);
    return;
}
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            jwt = authHeader.substring(7);
        }

        if (jwt != null && jwtService.isTokenValid(jwt)) {
    UsernamePasswordAuthenticationToken authToken =
            new UsernamePasswordAuthenticationToken(
                    jwtService.extractEmail(jwt),
                    null,
                    new ArrayList<>()
            );

    SecurityContextHolder.getContext().setAuthentication(authToken);
}

        filterChain.doFilter(request, response);
    }
}