import 'package:flutter/material.dart';

class AppColors {
  static const ink = Color(0xFF15171C);
  static const coral = Color(0xFFFF6B4A);
  static const coralSoft = Color(0xFFFF8A6B);
  static const muted = Color(0xFF6A6F78);
  static const line = Color(0xFFE6E6E1);
  static const field = Color(0xFFFFFFFF);
  static const chip = Color(0xFFEFEFEA);

  static const primary = ink;
  static const secondary = ink;
  static const accent = coral;
  static const background = Color(0xFFFAFAF7);
  static const card = Color(0xFFF2F2EE);
  static const textDark = ink;

  static const placeholders = [
    Color(0xFFFF8A6B),
    Color(0xFF5FB3A1),
    Color(0xFFF4B860),
    Color(0xFF7FC8D9),
    Color(0xFFC9A7E8),
  ];

  static Color placeholderFor(Object? seed) {
    final i = (seed?.hashCode ?? 0).abs() % placeholders.length;
    return placeholders[i];
  }
}
