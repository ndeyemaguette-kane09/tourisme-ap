package com.example.tourismservice.security;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
public class SecurityConfig {

    private final JwtFilter jwtFilter;

    public SecurityConfig(JwtFilter jwtFilter){
        this.jwtFilter = jwtFilter;
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())

    .httpBasic(httpBasic -> httpBasic.disable())

    .formLogin(form -> form.disable())

    .authorizeHttpRequests(auth -> auth

                // ✅ Auth publique
                .requestMatchers("/auth/**").permitAll()

                // ✅ Lecture publique pour tout le monde
                .requestMatchers(HttpMethod.GET,
                    "/hotels/**",
                    "/restaurants/**",
                    "/beaches/**",
                    "/cities/**",
                    "/reviews/**",
                    "/categories",
                    "/categories/**"
                ).permitAll()


                

                // ✅ Avis : tout le monde peut poster un review
                .requestMatchers(HttpMethod.POST, "/reviews/**").permitAll()

                // ✅ Création/modification/suppression : ADMIN uniquement
                .requestMatchers(HttpMethod.POST,
                    "/hotels/**",
                    "/restaurants/**",
                    "/beaches/**",
                    "/cities/**",
                    "/categories",
                    "/categories/**"
                ).hasAuthority("ADMIN")

                .requestMatchers(HttpMethod.PUT, "/**").hasAuthority("ADMIN")
                .requestMatchers(HttpMethod.DELETE, "/**").hasAuthority("ADMIN")

                // ✅ Tout le reste nécessite d'être connecté
                .anyRequest().authenticated()
            )
            .sessionManagement(session -> session
                .sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}