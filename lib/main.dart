// ============================================================
// FILE:
// lib/main.dart
// ============================================================
//
// ENTRY POINT APLIKASI
// ============================================================

import 'package:flutter/material.dart';

import 'presentation/app/app.dart';

// ============================================================
// MAIN
// ============================================================

void main() {
  // Memastikan Flutter binding sudah siap.

  WidgetsFlutterBinding.ensureInitialized();

  // Menjalankan aplikasi Warehouse Forklift.

  runApp(const WarehouseForkliftApp());
}
