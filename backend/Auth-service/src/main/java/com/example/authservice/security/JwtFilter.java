package com.example.authservice.security;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import com.example.authservice.service.JwtService;

@Component
public class JwtFilter extends OncePerRequestFilter {

    @Autowired
    private JwtService jwtService;

    @Autowired
    private UserDetailsService userDetailsService;

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain)
            throws ServletException, IOException {

        String path = request.getServletPath();

        if (path.equals("/auth/login") || path.equals("/auth/register")) {
    filterChain.doFilter(request, response);
    return;
}

        String authHeader = request.getHeader("Authorization");

        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            filterChain.doFilter(request, response);
            return;
        }

        String token = authHeader.substring(7);
        String email = jwtService.extractEmail(token);

        if (email != null && SecurityContextHolder.getContext().getAuthentication() == null) {

            //UserDetails userDetails = userDetailsService.loadUserByUsername(email);
            System.out.println("EMAIL FROM TOKEN = " + email);

UserDetails userDetails;

try {
    userDetails = userDetailsService.loadUserByUsername(email);
    System.out.println("USER FOUND = " + userDetails.getUsername());
} catch (Exception e) {
    System.out.println("USER NOT FOUND");
    e.printStackTrace();
    filterChain.doFilter(request, response);
    return;
}



            System.out.println("TOKEN = " + token);
System.out.println("EMAIL = " + email);
            if (jwtService.isTokenValid(token, userDetails.getUsername())) {
                System.out.println("TOKEN VALID");
                // 🔥 Extract role from token
                String role = jwtService.extractClaim(token, claims -> claims.get("role", String.class));

                // 🔥 Convert role to Spring Security format
               List<SimpleGrantedAuthority> authorities =
        List.of(new SimpleGrantedAuthority(role));

                // 🔥 Create authentication with role
                UsernamePasswordAuthenticationToken authToken =
                        new UsernamePasswordAuthenticationToken(
                                userDetails,
                                null,
                                authorities
                        );

                authToken.setDetails(
                        new WebAuthenticationDetailsSource().buildDetails(request)
                );

                SecurityContextHolder.getContext().setAuthentication(authToken);
                System.out.println("AUTHENTICATION SET");
            }
        }

        filterChain.doFilter(request, response);
    }
}