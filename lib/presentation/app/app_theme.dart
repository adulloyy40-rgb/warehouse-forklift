// ============================================================
// FILE:
// lib/presentation/app/app_theme.dart
// ============================================================
//
// FUNGSI:
// Menyediakan tema visual utama aplikasi Warehouse Forklift.
//
// Semua halaman nantinya menggunakan ThemeData yang sama
// agar tampilan aplikasi konsisten.
//
// Prinsip desain:
// - Profesional
// - Mudah dibaca operator gudang
// - Tombol cukup besar untuk penggunaan operasional
// - Kontras yang jelas
// - Tidak terlalu banyak dekorasi
// ============================================================

import 'package:flutter/material.dart';


// ============================================================
// CLASS: AppTheme
// ============================================================
//
// Menyediakan ThemeData untuk seluruh aplikasi.
// ============================================================

class AppTheme {
  // ==========================================================
  // CONSTRUCTOR PRIVATE
  // ==========================================================
  //
  // Class ini hanya berisi konfigurasi static.
  // Tidak perlu dibuat menjadi object.
  // ==========================================================

  AppTheme._();


  // ==========================================================
  // LIGHT THEME
  // ==========================================================

  static ThemeData get light {
    return ThemeData(
      // --------------------------------------------------------
      // Material 3
      // --------------------------------------------------------

      useMaterial3: true,

      // --------------------------------------------------------
      // Warna dasar aplikasi.
      // --------------------------------------------------------

      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.indigo,
        brightness: Brightness.light,
      ),

      // --------------------------------------------------------
      // Background aplikasi.
      // --------------------------------------------------------

      scaffoldBackgroundColor:
          const Color(0xFFF5F7FA),

      // --------------------------------------------------------
      // AppBar.
      // --------------------------------------------------------

      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
      ),

      // --------------------------------------------------------
      // Card.
      // --------------------------------------------------------

      cardTheme: const CardThemeData(
        elevation: 1,
        margin: EdgeInsets.zero,
      ),

      // --------------------------------------------------------
      // Input field.
      // --------------------------------------------------------

      inputDecorationTheme:
          InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            width: 2,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),

      // --------------------------------------------------------
      // Elevated Button.
      // --------------------------------------------------------

      elevatedButtonTheme:
          ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize:
              const Size(0, 48),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),
        ),
      ),

      // --------------------------------------------------------
      // Filled Button.
      // --------------------------------------------------------

      filledButtonTheme:
          FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize:
              const Size(0, 48),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),
        ),
      ),

      // --------------------------------------------------------
      // Text theme.
      // --------------------------------------------------------

      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
        ),
      ),
    );
  }
}
