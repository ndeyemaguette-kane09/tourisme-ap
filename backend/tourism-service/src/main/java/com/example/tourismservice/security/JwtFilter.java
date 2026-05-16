package com.example.tourismservice.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.filter.OncePerRequestFilter;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.util.Collections;
import io.jsonwebtoken.Claims;
import java.util.List;

@Component
public class JwtFilter extends OncePerRequestFilter {

    private final JwtService jwtService;

    public JwtFilter(JwtService jwtService){
        this.jwtService = jwtService;
    }
    

    @Override
protected void doFilterInternal(HttpServletRequest request,
                                HttpServletResponse response,
                                FilterChain filterChain)
        throws ServletException, IOException {

    String authHeader = request.getHeader("Authorization");

    if (authHeader == null || !authHeader.startsWith("Bearer ")) {
        filterChain.doFilter(request, response);
        return;
    }

    String token = authHeader.substring(7);

    try {
        String username = jwtService.extractEmail(token);

        if (username != null) {
            Claims claims = jwtService.extractAllClaims(token);
            String role = claims.get("role", String.class);

            List<SimpleGrantedAuthority> authorities = List.of(
                new SimpleGrantedAuthority(role)  
            );

            UsernamePasswordAuthenticationToken authToken =
                new UsernamePasswordAuthenticationToken(username, null, authorities);

            SecurityContextHolder.getContext().setAuthentication(authToken);
        }

    } catch (io.jsonwebtoken.ExpiredJwtException e) {
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        response.setContentType("application/json");
        response.getWriter().write("{\"error\": \"Token expired\"}");
        return;
    } catch (io.jsonwebtoken.JwtException e) {
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        response.setContentType("application/json");
        response.getWriter().write("{\"error\": \"Invalid token\"}");
        return;
    }

    filterChain.doFilter(request, response);
}

}