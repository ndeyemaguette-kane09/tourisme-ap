import 'package:flutter/material.dart';

class AppColors {
  static const ink = Color(0xFF15171C);
  static const laterite = Color(0xFFB9502B);
  static const lateriteSoft = Color(0xFFF2D8CB);
  static const muted = Color(0xFF6A6F78);
  static const line = Color(0xFFE6E6E1);
  static const field = Color(0xFFFFFFFF);
  static const chip = Color(0xFFEFEFEA);

  static const primary = ink;
  static const secondary = ink;
  static const accent = laterite;
  static const background = Color(0xFFFAFAF7);
  static const card = Color(0xFFF2F2EE);
  static const textDark = ink;

  static const placeholders = [
    Color(0xFFD9A48F),
    Color(0xFF9DB0A2),
    Color(0xFFD8B985),
    Color(0xFF93AEBB),
    Color(0xFFB7A99B),
  ];

  static Color placeholderFor(Object? seed) {
    final i = (seed?.hashCode ?? 0).abs() % placeholders.length;
    return placeholders[i];
  }
}
