package com.example.tourismservice.entity;

import java.util.List;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;

@Entity
public class City {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;


    @ManyToOne
@JoinColumn(name = "category_id")
private Category category;

    private String name;

    @OneToMany(mappedBy = "city")
    @JsonIgnore
    private List<Hotel> hotels;


    public City() {}

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public List<Hotel> getHotels() {
        return hotels;
    }

    public void setHotels(List<Hotel> hotels) {
        this.hotels = hotels;
    }


    public Category getCategory() {
    return category;
}

public void setCategory(Category category) {
    this.category = category;
}
}