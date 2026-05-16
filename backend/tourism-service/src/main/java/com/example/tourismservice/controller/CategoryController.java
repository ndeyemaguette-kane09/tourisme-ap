package com.example.tourismservice.controller;

import java.util.List;

import org.springframework.web.bind.annotation.*;

import com.example.tourismservice.entity.Category;
import com.example.tourismservice.service.CategoryService;

@RestController
@RequestMapping("/categories")
public class CategoryController {

    private final CategoryService categoryService;

    public CategoryController(CategoryService categoryService) {
        this.categoryService = categoryService;
    }

    @PostMapping
    public Category createCategory(@RequestBody Category category) {
        return categoryService.createCategory(category);
    }

    @GetMapping
    public List<Category> getAllCategories() {
        return categoryService.getAllCategories();
    }

    @PutMapping("/{id}")
public Category updateCategory(@PathVariable Long id,
                               @RequestBody Category category) {
    return categoryService.updateCategory(id, category);
}

@DeleteMapping("/{id}")
public void deleteCategory(@PathVariable Long id) {
    categoryService.deleteCategory(id);
}
}