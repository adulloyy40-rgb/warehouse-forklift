// ============================================================
// FILE:
// lib/presentation/app/app.dart
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
      title: 'Warehouse Forklift',

      debugShowCheckedModeBanner: false,

      theme: AppTheme.light,

      home: const DashboardPage(),
    );
  }
}
