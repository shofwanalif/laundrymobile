import 'package:flutter/material.dart';

class AppColors {
  // Base Blue Colors - Memberikan kesan air dan kebersihan
  static const Color bluePrimary = Color(0xFF0077B6); // Biru Ocean yang solid
  static const Color blueLight = Color(0xFF90E0EF);   // Biru muda transparan seperti air jernih
  static const Color blueDark = Color(0xFF03045E);    // Biru Navy untuk kontras tinggi

  static const Color text = Color(0xFF1B1B1B);
  static const Color white = Colors.white;

  // Primary Colors - Blue Theme
  static const Color primary = bluePrimary;
  static const Color primaryLight = blueLight;
  static const Color primaryDark = blueDark;

  // Secondary Colors - Menggunakan warna Cyan/Teal agar tetap senada dengan air
  static const Color secondary = Color(0xFF00B4D8); 
  static const Color accent = Color(0xFFCAF0F8); // Sangat muda, hampir seperti kristal air

  // Status Colors
  static const Color success = Color(0xFF2D6A4F); // Hijau botol (cocok dengan biru)
  static const Color error = Color(0xFFE63946);   // Merah lembut
  static const Color warning = Color(0xFFFFB703); // Kuning cerah
  static const Color info = bluePrimary;

  // Neutral Colors - Background dengan tint biru tipis agar terasa "dingin"
  static const Color background = Color(0xFFF0F8FF); // Alice Blue
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFE1F5FE);
  static const Color inputFillColor = Color(0xFFF8FDFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF023E8A); // Teks utama biru sangat tua (lebih modern dari hitam)
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);

  // Separator
  static const Color separator = Color(0xFFD1E9F6);
  static const Color separatorLight = Color(0xFFE3F2FD);

  // Card & Container
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFBEE3F8);

  // Gradient Colors - Efek gradasi air yang segar
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [bluePrimary, Color(0xFF00B4D8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF48CAE4), Color(0xFFADE8F4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadow
  static const Color shadowColor = Color(0x1A023E8A); // Shadow dengan tint biru

  // Dark Theme Colors - Deep Sea Theme
  static const Color darkBackground = Color(0xFF021024);
  static const Color darkSurface = Color(0xFF05264E);
  static const Color darkSurfaceVariant = Color(0xFF08335E);

  // Dark Theme Text Colors
  static const Color darkTextPrimary = Color(0xFFE0FBFF);
  static const Color darkTextSecondary = Color(0xFFB0C4DE);
  static const Color darkTextTertiary = Color(0xFF778899);

  // Dark Theme Separator
  static const Color darkSeparator = Color(0xFF1E3A5F);
  static const Color darkSeparatorLight = Color(0xFF2C5282);

  // Dark Theme Card & Container
  static const Color darkCardBackground = Color(0xFF05264E);
  static const Color darkCardBorder = Color(0xFF1E3A5F);
}