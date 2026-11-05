import 'package:flutter/material.dart';

/// Centralized color palette for CatQueens app.
/// Colors follow the specification in the implementation plan.
class AppColors {
  // Background / surface
  static const Color background = Color(0xFFF7F1EC); // Cream
  static const Color surface = background;

  // Text colors
  static const Color textPrimary = Color(0xFF8B5E3C);
  static const Color textSecondary = Color(0xFF9A5B5B);

  // Primary accent (orange)
  static const Color primary = Color(0xFFF0932B);

  // Disabled / secondary button color
  static const Color disabled = Color(0xFFB0B0B0);

  // Progress bar colors
  static const Color progressBg = Color(0xFFE0E0E0);
  static const Color progressFill = Color(0xFFF0932B);

  // Icons / logo placeholders
  static const Color icon = Color(0xFF8B5E3C);
  static const Color logo = Color(0xFFF0932B);
  static const Color catHead = Color(0xFFF0932B);

  // Additional palette for region colors (example 9 colors)
  static const List<Color> regionColors = [
    Color(0xFFE5BB43), // yellow
    Color(0xFFF8B4D0), // pink
    Color(0xFF6BBBE8), // blue
    Color(0xFFA9D893), // green
    Color(0xFFB57EDC), // purple
    Color(0xFFFFA726), // orange light
    Color(0xFF90A4AE), // gray blue
    Color(0xFFFFEB3B), // bright yellow
    Color(0xFF81C784), // teal
  ];
}

