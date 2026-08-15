// ============================================================
// FILE:
// test/widget_test.dart
// ============================================================
//
// FUNGSI:
// Widget test dasar untuk aplikasi Warehouse Forklift.
//
// Test ini memastikan:
// 1. Aplikasi dapat dibuat.
// 2. Dashboard berhasil ditampilkan.
// 3. Judul aplikasi tampil.
// ============================================================

import 'package:flutter_test/flutter_test.dart';

import 'package:warehouse_forklift/presentation/app/app.dart';

// ============================================================
// MAIN TEST
// ============================================================

void main() {
  // ==========================================================
  // TEST DASHBOARD
  // ==========================================================

  testWidgets('Warehouse Forklift menampilkan Dashboard', (
    WidgetTester tester,
  ) async {
    // ========================================================
    // JALANKAN APLIKASI
    // ========================================================
    //
    // WarehouseForkliftApp sekarang tidak membutuhkan
    // parameter dependencies.
    // ========================================================

    await tester.pumpWidget(const WarehouseForkliftApp());

    // ========================================================
    // TUNGGU PROSES ASYNC DASHBOARD
    // ========================================================
    //
    // Dashboard mengambil data dari repository.
    // Pump beberapa frame agar proses Future selesai.
    // ========================================================

    await tester.pumpAndSettle();

    // ========================================================
    // VERIFIKASI JUDUL
    // ========================================================

    expect(find.text('Warehouse Forklift'), findsOneWidget);

    // ========================================================
    // VERIFIKASI SUBJUDUL
    // ========================================================

    expect(find.text('Warehouse Operations'), findsOneWidget);

    // ========================================================
    // VERIFIKASI DASHBOARD
    // ========================================================

    expect(find.text('Stock Overview'), findsOneWidget);
  });
}
