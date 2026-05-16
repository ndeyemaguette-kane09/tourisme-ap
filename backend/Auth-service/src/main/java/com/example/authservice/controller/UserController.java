package com.example.authservice.controller;

import com.example.authservice.entity.User;
import com.example.authservice.repository.UserRepository;

import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/users")
public class UserController {

    private final UserRepository userRepository;

    public UserController(UserRepository userRepository){
        this.userRepository = userRepository;
    }

    @GetMapping("/{id}")
    public User getUser(@PathVariable Long id){
        return userRepository.findById(id).orElse(null);
    }
    // utilisateur supprime SON COMPTE
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteUser(@PathVariable Long id, Authentication authentication) {

        String email = authentication.getName(); // récupéré du JWT

        User user = userRepository.findByEmail(email).orElse(null);

        if (user == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("User not found");
        }

        // 🔐 vérification
        if (!user.getId().equals(id) && !user.getRole().getName().equals("ADMIN")) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body("You can only delete your own account");
        }

        userRepository.deleteById(id);

        return ResponseEntity.ok("User deleted successfully");
    }
}