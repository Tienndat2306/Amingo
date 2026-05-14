import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF775600);
  static const Color secondary = Color(0xFF5C5B5B);
  static const Color tertiary = Color(0xFFAF2046);

  // Surface colors
  static const Color surface = Color(0xFFFFB300);
  static const Color background = Color(0xFFFFF6E3);
  static const Color cardBackground = Color(0xFFFFF0C9);
  static const Color surfaceDark = Color(0xFF3A2D00);

  // Text colors
  static const Color textPrimary = Color(0xFF3A2D00);
  static const Color textSecondary = Color(0xFF6B5A23);
  static const Color textLight = Color(0xFFFFF1DC);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFB02500);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Admin specific colors
  static const Color adminPrimary = Color(0xFF1A237E);
  static const Color adminBackground = Color(0xFFF5F5F5);
  static const Color adminSidebar = Color(0xFF263238);
}

class AppGradients {
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFDBC13), Color(0xFF775600)],
  );

  static const LinearGradient adminGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A237E), Color(0xFF283593)],
  );
}