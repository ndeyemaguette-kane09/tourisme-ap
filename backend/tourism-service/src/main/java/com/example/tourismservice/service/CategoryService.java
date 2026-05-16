package com.example.tourismservice.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.example.tourismservice.entity.Category;
import com.example.tourismservice.repository.CategoryRepository;

@Service
public class CategoryService {

    private final CategoryRepository categoryRepository;

    public CategoryService(CategoryRepository categoryRepository) {
        this.categoryRepository = categoryRepository;
    }

    public Category createCategory(Category category) {
        return categoryRepository.save(category);
    }

    public List<Category> getAllCategories() {
        return categoryRepository.findAll();
    }

    public Category updateCategory(Long id, Category updatedCategory) {

    Category category = categoryRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Category not found"));

    category.setName(updatedCategory.getName());
    category.setDescription(updatedCategory.getDescription());

    return categoryRepository.save(category);
}

public void deleteCategory(Long id) {

    Category category = categoryRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Category not found"));

    categoryRepository.delete(category);
}

public Category getCategoryById(Long id) {

    return categoryRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Category not found"));
}
}