package com.example.tourismservice.util;

public final class Values {

    private Values() {
    }

    public static Double toDouble(Object value) {
        if (value == null || value.toString().isBlank()) {
            return null;
        }
        try {
            return Double.parseDouble(value.toString().replace(",", "."));
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
