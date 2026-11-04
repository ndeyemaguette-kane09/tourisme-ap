package com.example.reservationservice.config;

import feign.RequestInterceptor;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

@Configuration
public class FeignAuthConfig {

    // auth-service protège /users/** : on relaie le jeton de l'utilisateur
    @Bean
    public RequestInterceptor forwardAuthorization() {
        return template -> {
            ServletRequestAttributes attrs =
                    (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
            if (attrs == null) {
                return;
            }
            HttpServletRequest request = attrs.getRequest();
            String header = request.getHeader("Authorization");
            if (header != null) {
                template.header("Authorization", header);
            }
        };
    }
}
