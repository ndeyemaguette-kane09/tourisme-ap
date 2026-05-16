package com.example.authservice.service;

import com.example.authservice.dto.AuthResponse;
import com.example.authservice.dto.LoginRequest;
import com.example.authservice.dto.RegisterRequest;
import com.example.authservice.entity.Role;
import com.example.authservice.entity.User;
import com.example.authservice.repository.RoleRepository;
import com.example.authservice.repository.UserRepository;
import com.example.authservice.service.JwtService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;import org.springframework.security.core.context.SecurityContextHolder;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class AuthService {

    private final UserRepository userRepository;
private final RoleRepository roleRepository;
private final PasswordEncoder passwordEncoder;
private final JwtService jwtService;

    @Autowired
    public AuthService(UserRepository userRepository,
                       RoleRepository roleRepository,
                       PasswordEncoder passwordEncoder,
                       JwtService jwtService) {
        this.userRepository = userRepository;
        this.roleRepository = roleRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
    }

    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    public User getUserById(Long id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found"));
    }

    public void deleteUser(Long id, Authentication authentication) {

    String email = authentication.getName();

    User currentUser = userRepository.findByEmail(email)
            .orElseThrow(() -> new RuntimeException("User not found"));

    if (!currentUser.getId().equals(id) &&
        !currentUser.getRole().getName().equals("ADMIN")) {
        throw new RuntimeException("Forbidden");
    }

    userRepository.deleteById(id);
}

    // 🔥 Update sécurisé (user modifie SON compte ou ADMIN)
    public User updateUser(
            Long id,
            User updatedUser,
            Authentication authentication) {

        String email = authentication.getName();
                System.out.println("AUTH USER = " + authentication.getName());
        User currentUser = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));

        // 🔐 sécurité : user ne modifie que son compte ou admin
        if (!currentUser.getId().equals(id) && 
            !currentUser.getRole().getName().equals("ADMIN")) {
            throw new RuntimeException("Forbidden");
        }

        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found"));

        // 🔥 mise à jour des champs
        if (updatedUser.getName() != null) {
            user.setName(updatedUser.getName());
        }

        if (updatedUser.getPhone() != null) {
            user.setPhone(updatedUser.getPhone());
        }

        if (updatedUser.getEmail() != null) {
            user.setEmail(updatedUser.getEmail());
        }

        // 🔐 password sécurisé
        if (updatedUser.getPassword() != null && !updatedUser.getPassword().isEmpty()) {
            user.setPassword(passwordEncoder.encode(updatedUser.getPassword()));
        }

        User savedUser = userRepository.save(user);

        return savedUser;
    }

    public User register(RegisterRequest request) {

    User user = new User();
    user.setEmail(request.getEmail());
    user.setPassword(passwordEncoder.encode(request.getPassword()));

    // ⚠️ rôle par défaut USER
    Role role = roleRepository.findByName("USER")
            .orElseThrow(() -> new RuntimeException("Role not found"));

    user.setRole(role);

    return userRepository.save(user);
}


public AuthResponse login(LoginRequest request) {

    User user = userRepository.findByEmail(request.getEmail())
            .orElseThrow(() -> new RuntimeException("User not found"));

    if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
        throw new RuntimeException("Invalid credentials");
    }

    //  JWT avec rôle
    Map<String, Object> claims = new HashMap<>();
    claims.put("role", user.getRole().getName());

    String token = jwtService.generateToken(claims, user.getEmail());

    return new AuthResponse(
    token,
    user.getId(),
    user.getName(),
    user.getRole().getName()
);
}

// 🔐 Changement de mot de passe sécurisé
public void changePassword(
        Long userId,
        String oldPassword,
        String newPassword,
        Authentication authentication) {

   
    String email = authentication.getName();

    User currentUser = userRepository.findByEmail(email)
            .orElseThrow(() -> new RuntimeException("User not found"));


    System.out.println("TOKEN USER ID = " + currentUser.getId());
System.out.println("REQUEST USER ID = " + userId);
System.out.println("ROLE = " + currentUser.getRole().getName());
    // 🔒 Vérifier que l'utilisateur modifie SON compte ou est ADMIN
    if (!currentUser.getId().equals(userId) &&
        !currentUser.getRole().getName().equals("ADMIN")) {
        throw new RuntimeException("Forbidden");
    }

    User user = userRepository.findById(userId)
            .orElseThrow(() -> new RuntimeException("User not found"));

    // 🔐 Vérification ancien mot de passe
    if (!passwordEncoder.matches(oldPassword, user.getPassword())) {
        throw new RuntimeException("Incorrect old password");
    }

    // 🔥 Mise à jour sécurisée
    user.setPassword(passwordEncoder.encode(newPassword));

    userRepository.save(user);
}
}