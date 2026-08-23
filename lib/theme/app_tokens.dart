import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1B5E20);
  static const Color primaryLight = Color(0xFFE8F5E9);
  static const Color accent = Color(0xFF2E7D32);
  static const Color background = Color(0xFFF9FAF8);
  static const Color surface = Colors.white;
  static const Color surfaceSoft = Color(0xFFF1F5F0);
  static const Color border = Color(0xFFE0E6DE);
  static const Color textPrimary = Color(0xFF1C241D);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color success = Color(0xFF166534);
  static const Color warning = Color(0xFFB45309);
  static const Color error = Color(0xFFDC2626);
}

class AppSpacing {
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}

class AppRadius {
  static const BorderRadius sm = BorderRadius.all(Radius.circular(6.0));
  static const BorderRadius md = BorderRadius.all(Radius.circular(10.0));
  static const BorderRadius lg = BorderRadius.all(Radius.circular(16.0));
  static const BorderRadius full = BorderRadius.all(Radius.circular(999.0));
}