package com.example.userservice.service;

import java.util.List;
import org.springframework.stereotype.Service;

import com.example.userservice.entity.User;
import com.example.userservice.repository.UserRepository;

import org.springframework.beans.factory.annotation.Autowired;

@Service
public class UserService {

    @Autowired
    private UserRepository repository;

    public User createUser(User user) {
        return repository.save(user);
    }

    public User getUser(Long id) {
        return repository.findById(id).orElse(null);
    }

    public List<User> getAllUsers() {
        return repository.findAll();
    }

    
    public void deleteUser(Long id) {
    repository.deleteById(id);
}

public User getUserById(Long id) {
    return repository.findById(id)
        .orElseThrow(() -> new RuntimeException("User not found"));
}

    public User updateUser(Long id, User updatedUser) {
    User user = repository.findById(id)
        .orElseThrow(() -> new RuntimeException("User not found"));

    user.setName(updatedUser.getName());
    user.setEmail(updatedUser.getEmail());
    user.setCity(updatedUser.getCity());
    user.setCountry(updatedUser.getCountry());
    user.setPhoneNumber(updatedUser.getPhoneNumber());
    user.setProfileImage(updatedUser.getProfileImage());

    System.out.println(updatedUser.getCity());
System.out.println(updatedUser.getPhoneNumber());
    return repository.save(user);
}
}