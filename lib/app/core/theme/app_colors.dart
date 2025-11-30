import 'package:flutter/material.dart';

class AppColors {
  // Base Orange Colors
  static const Color orangePrimary = Color.fromARGB(255, 253, 127, 8);
  static const Color orangeLight = Color.fromARGB(255, 223, 120, 10);
  static const Color orangeDark = Color.fromARGB(255, 182, 92, 2);

  static const Color text = Color(0xFF1B1B1B);
  static const Color white = Colors.white;

  // Primary Colors - Orange Theme
  static const Color primary = orangePrimary;
  static const Color primaryLight = orangeLight;
  static const Color primaryDark = orangeDark;

  // Secondary Colors - Complementary Orange/Accent
  static const Color secondary = Color(0xFFFF9500); // lebih soft orange
  static const Color accent = Color(0xFFFFC107); // gold-ish accent

  // Status Colors
  static const Color success = Color(
    0xFF34C759,
  ); // tetap hijau untuk status sukses
  static const Color error = Color(0xFFFF3B30); // tetap merah
  static const Color warning = Color(0xFFFF9500); // orange untuk warning
  static const Color info = orangePrimary; // info juga pakai orange

  // Neutral Colors
  static const Color background = Color(0xFFFDF6F0);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFFFF2EC);
  static const Color inputFillColor = Color(0xFFFFFAF5);

  // Text Colors
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textTertiary = Color(0xFFC7C7CC);

  // Separator
  static const Color separator = Color(0xFFE5D8CC);
  static const Color separatorLight = Color(0xFFFFEDE3);

  // Card & Container
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFFFE5D1);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [orangePrimary, orangeLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadow
  static const Color shadowColor = Color(0x1A000000);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF1C0F00);
  static const Color darkSurface = Color(0xFF2A1A0D);
  static const Color darkSurfaceVariant = Color(0xFF3A2414);

  // Dark Theme Text Colors
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFBFBFBF);
  static const Color darkTextTertiary = Color(0xFF8C8C8C);

  // Dark Theme Separator
  static const Color darkSeparator = Color(0xFF5A3E2A);
  static const Color darkSeparatorLight = Color(0xFF4A2E1A);

  // Dark Theme Card & Container
  static const Color darkCardBackground = Color(0xFF2A1A0D);
  static const Color darkCardBorder = Color(0xFF5A3E2A);
}
