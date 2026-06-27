import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFE91E63); // Pink
  static const Color primaryLight = Color(0xFFFF6090);
  static const Color primaryDark = Color(0xFFB0003A);
  static const Color secondary = Color(0xFF6A1B9A); // Violet
  static const Color secondaryLight = Color(0xFF9C4DCC);
  static const Color secondaryDark = Color(0xFF38006B);

  static const Color destructive = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);

  static const Color background = Color(0xFFFDF2F8); // Soft pink background
  static const Color foreground = Color(0xFF1A1A2E);
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardForeground = Color(0xFF1A1A2E);
  static const Color muted = Color(0xFFF3E8F0);
  static const Color mutedForeground = Color(0xFF78716C);
  static const Color border = Color(0xFFEDE0E8);
  static const Color inputBorder = Color(0xFFE8D5E0);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glowGradient = LinearGradient(
    colors: [primaryLight, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient destructiveGradient = LinearGradient(
    colors: [destructive, Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}