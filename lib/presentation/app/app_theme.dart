// ============================================================
// FILE:
// lib/presentation/app/app_theme.dart
// ============================================================
//
// FUNGSI:
// Design system utama aplikasi Warehouse Forklift.
//
// Semua halaman menggunakan ThemeData yang sama supaya:
// - warna konsisten
// - typography konsisten
// - tombol konsisten
// - input konsisten
// - Card konsisten
// - mudah dikembangkan ke halaman berikutnya
//
// CATATAN:
// File ini hanya mengatur tampilan.
// Tidak ada database atau business logic di sini.
// ============================================================

import 'package:flutter/material.dart';

// ============================================================
// CLASS: AppTheme
// ============================================================

class AppTheme {
  // Constructor private.
  //
  // AppTheme tidak perlu dibuat menjadi object.
  AppTheme._();

  // ==========================================================
  // DESIGN TOKENS
  // ==========================================================

  // Warna utama aplikasi.
  //
  // Biru digunakan sebagai warna utama karena memberikan
  // kesan profesional dan mudah dibaca pada aplikasi operasional.
  static const Color primaryColor = Color(0xFF3157D5);

  // Background utama aplikasi.
  static const Color backgroundColor = Color(0xFFF5F7FA);

  // Warna surface/card.
  static const Color surfaceColor = Colors.white;

  // Warna teks utama.
  static const Color textPrimaryColor = Color(0xFF172033);

  // Warna teks sekunder.
  static const Color textSecondaryColor = Color(0xFF667085);

  // Warna garis/border.
  static const Color borderColor = Color(0xFFE5E7EB);

  // ==========================================================
  // LIGHT THEME
  // ==========================================================

  static ThemeData get light {
    // --------------------------------------------------------
    // COLOR SCHEME
    // --------------------------------------------------------

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    );

    // --------------------------------------------------------
    // THEME DATA
    // --------------------------------------------------------

    return ThemeData(
      // Material 3 digunakan sebagai dasar UI modern Flutter.
      useMaterial3: true,

      // Color scheme global.
      colorScheme: colorScheme,

      // Background seluruh halaman.
      scaffoldBackgroundColor: backgroundColor,

      // ======================================================
      // APP BAR
      // ======================================================
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimaryColor,
      ),

      // ======================================================
      // CARD
      // ======================================================
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: surfaceColor,
        surfaceTintColor: Colors.transparent,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: borderColor),
        ),
      ),

      // ======================================================
      // INPUT
      // ======================================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderColor),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),

      // ======================================================
      // ELEVATED BUTTON
      // ======================================================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 48),

          elevation: 0,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      // ======================================================
      // FILLED BUTTON
      // ======================================================
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      // ======================================================
      // OUTLINED BUTTON
      // ======================================================
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      // ======================================================
      // ICON BUTTON
      // ======================================================
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size(44, 44)),
      ),

      // ======================================================
      // TEXT THEME
      // ======================================================
      textTheme: const TextTheme(
        // Judul halaman.
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: textPrimaryColor,
          letterSpacing: -0.4,
        ),

        // Judul besar section.
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimaryColor,
        ),

        // Judul card/menu.
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: textPrimaryColor,
        ),

        // Body utama.
        bodyLarge: TextStyle(fontSize: 16, color: textPrimaryColor),

        // Body standar.
        bodyMedium: TextStyle(fontSize: 14, color: textSecondaryColor),

        // Informasi kecil.
        bodySmall: TextStyle(fontSize: 12, color: textSecondaryColor),
      ),

      // ======================================================
      // DIVIDER
      // ======================================================
      dividerTheme: const DividerThemeData(
        space: 1,
        thickness: 1,
        color: borderColor,
      ),
    );
  }
}
