// ============================================================
// FILE:
// lib/presentation/app/app.dart
// ============================================================
//
// FUNGSI:
// Root application Warehouse Forklift.
//
// Tanggung jawab file ini:
// 1. Membuat MaterialApp.
// 2. Memasang theme aplikasi.
// 3. Menentukan halaman awal.
//
// CATATAN:
// Repository saat ini dikelola oleh DashboardPage.
// Dependency Injection penuh akan kita rapikan lagi ketika
// database lokal mulai dipasang.
// ============================================================

import 'package:flutter/material.dart';

import '../pages/dashboard/dashboard_page.dart';
import 'app_theme.dart';

// ============================================================
// ROOT APPLICATION
// ============================================================

class WarehouseForkliftApp extends StatelessWidget {
  const WarehouseForkliftApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ========================================================
      // INFORMASI APLIKASI
      // ========================================================

      title: 'Warehouse Forklift',

      // ========================================================
      // HILANGKAN DEBUG BANNER
      // ========================================================

      debugShowCheckedModeBanner: false,

      // ========================================================
      // THEME
      // ========================================================

      theme: AppTheme.light,

      // ========================================================
      // HALAMAN AWAL
      // ========================================================
      //
      // DashboardPage saat ini membuat repository sendiri.
      // Jadi tidak perlu mengirim parameter repository dari sini.
      // ========================================================

      home: const DashboardPage(),
    );
  }
}
