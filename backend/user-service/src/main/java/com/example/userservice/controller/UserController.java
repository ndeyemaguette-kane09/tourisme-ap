package com.example.userservice.controller;

import java.util.List;
import org.springframework.web.bind.annotation.*;

import com.example.userservice.entity.User;
import com.example.userservice.service.UserService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;

@RestController
@RequestMapping("/users")
@CrossOrigin("*")
public class UserController {

    @Autowired
    private UserService service;

    @PostMapping
    public User create(@RequestBody User user) {
        return service.createUser(user);
    }

    

    @GetMapping
    public List<User> all() {
        return service.getAllUsers();
    }

    @PutMapping("/{id}")
public ResponseEntity<User> updateUser(
        @PathVariable Long id,
        @RequestBody User user) {

    return ResponseEntity.ok(service.updateUser(id, user));
}
    @DeleteMapping("/{id}")
public ResponseEntity<String> deleteUser(@PathVariable Long id) {
    service.deleteUser(id);
    return ResponseEntity.ok("User deleted successfully");
}

@GetMapping("/{id}")
public ResponseEntity<User> getUserById(@PathVariable Long id) {
    return ResponseEntity.ok(service.getUserById(id));
}
}