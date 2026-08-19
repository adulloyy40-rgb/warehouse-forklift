// ============================================================
// FILE:
// lib/presentation/pages/dashboard/dashboard_page.dart
// ============================================================
//
// FUNGSI:
// Dashboard utama aplikasi Warehouse Forklift.
//
// PADA TAHAP INI:
// Dashboard sudah mulai terhubung dengan:
//
// 1. StorageLocationRepository
//    -> Menyediakan Master Location.
//    -> TOTAL LOCATION = 1.860
//
// 2. StockPalletRepository
//    -> Menyediakan data pallet.
//    -> Menentukan lokasi yang sedang terisi.
//
// ============================================================
//
// RUMUS DASHBOARD:
//
// Total Pallet
// = jumlah seluruh StockPallet
//
// Storage Terisi
// = jumlah lokasi yang ditempati pallet
//
// Location Available
// = Total Location - Storage Terisi
//
// ============================================================

import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/di/app_dependencies.dart';

import '../../../domain/entities/storage_location.dart';
import '../../../domain/entities/stock_pallet.dart';
import '../../../domain/services/stock_pallet_export_service.dart';

import '../storage/storage_page.dart';
import '../import/excel_import_page.dart';
// ============================================================
// DASHBOARD PAGE
// ============================================================
//
// Dashboard dibuat Stateful karena data dashboard berasal
// dari Future repository.
//
// UI akan melakukan load data ketika halaman dibuka.
// ============================================================

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

// ============================================================
// STATE DASHBOARD
// ============================================================

class _DashboardPageState extends State<DashboardPage> {
  int _selectedNavigationIndex = 0;

  // ==========================================================
  // REPOSITORY
  // ==========================================================
  //
  // Storage Location Repository:
  //
  // Bertanggung jawab terhadap Master Location.
  //
  // Layout final:
  //
  // TOTAL LOCATION = 1.860
  // ==========================================================

  // ==========================================================
  // DEPENDENCY
  // ==========================================================
  //
  // Dashboard menggunakan repository dari AppDependencies.
  //
  // Keuntungannya:
  // - tidak membuat AppDatabase baru
  // - tidak membuat repository baru
  // - seluruh halaman menggunakan database yang sama
  // ==========================================================
  final _storageLocationRepository =
      AppDependencies.instance.storageLocationRepository;

  final _stockPalletRepository = AppDependencies.instance.stockPalletRepository;

  // Service untuk membuat file Excel Stock Pallet.
  final _stockPalletExportService = StockPalletExportService();
  // ==========================================================
  // DASHBOARD DATA
  // ==========================================================
  //
  // Data yang ditampilkan:
  //
  // totalPallet
  // storageTerisi
  // locationAvailable
  //
  // Nilai awal dibuat 0.
  // ==========================================================

  int _totalPallet = 0;

  int _storageTerisi = 0;

  int _locationAvailable = 0;

  // ==========================================================
  // LOADING STATE
  // ==========================================================

  bool _isLoading = true;

  // ==========================================================
  // EXPORT STATE
  // ==========================================================

  // Mencegah operator menekan Export berkali-kali
  // ketika proses pembuatan dan penyimpanan Excel sedang berjalan.
  // State ini berubah selama proses export: false → true → false.
  bool _isExporting = false;

  // ==========================================================
  // ERROR STATE
  // ==========================================================

  String? _errorMessage;

  // ==========================================================
  // INIT STATE
  // ==========================================================
  //
  // Ketika Dashboard pertama kali dibuat,
  // kita langsung membaca repository.
  // ==========================================================

  @override
  void initState() {
    super.initState();

    _loadDashboardData();
  }

  // ==========================================================
  // EXPORT STOCK PALLET
  // ==========================================================
  //
  // Alur:
  //
  // SQLite
  //   ↓
  // StockPalletRepository
  //   ↓
  // StockPalletExportService
  //   ↓
  // Excel bytes
  //   ↓
  // FilePicker.saveFile()
  //
  // Database hanya dibaca.
  // Tidak ada data yang diubah atau dihapus.
  // ==========================================================

  Future<void> _exportStockPallet() async {
    // ==========================================================
    // CEGAH EXPORT GANDA
    // ==========================================================

    if (_isExporting) {
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      // ========================================================
      // 1. AMBIL DATA STOCK PALLET
      // ========================================================

      final pallets = await _stockPalletRepository.getAll();

      if (!mounted) {
        return;
      }

      // ========================================================
      // 2. VALIDASI DATA
      // ========================================================

      if (pallets.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak ada data Stock Pallet untuk diekspor.'),
          ),
        );

        return;
      }

      // ========================================================
      // 3. GENERATE FILE EXCEL
      // ========================================================

      final Uint8List bytes = _stockPalletExportService.export(pallets);

      if (!mounted) {
        return;
      }

      // ========================================================
      // 4. SAVE FILE
      // ========================================================

      final uri = await FilePicker.saveFile(
        fileName: 'stock_pallet_export.xlsx',
        bytes: bytes,
        mimeType:
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        dialogTitle: 'Simpan Export Stock Pallet',
        type: FileType.custom,
        allowedExtensions: const ['xlsx'],
      );

      if (!mounted) {
        return;
      }

      // ========================================================
      // 5. OPERATOR MEMBATALKAN
      // ========================================================

      if (uri == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Export dibatalkan.')));

        return;
      }

      // ========================================================
      // 6. EXPORT BERHASIL
      // ========================================================

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export berhasil: ${pallets.length} pallet.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      // ========================================================
      // 7. ERROR
      // ========================================================

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export gagal: $e'),
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      // ========================================================
      // 8. KEMBALIKAN STATE EXPORT
      // ========================================================

      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  // ==========================================================
  // LOAD DASHBOARD DATA
  // ==========================================================
  //
  // Fungsi ini mengambil:
  //
  // 1. Seluruh Master Location.
  // 2. Seluruh Stock Pallet.
  //
  // Kemudian menghitung:
  //
  // Total Pallet
  // Storage Terisi
  // Location Available
  // ==========================================================

  Future<void> _loadDashboardData() async {
    // Aktifkan loading.

    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      // ========================================================
      // AMBIL MASTER LOCATION
      // ========================================================
      //
      // Master Location berasal dari generator.
      //
      // Layout final menghasilkan:
      //
      // 1.860 lokasi.
      // ========================================================

      final List<StorageLocation> locations = await _storageLocationRepository
          .getAllLocations();

      // ========================================================
      // AMBIL SELURUH STOCK PALLET
      // ========================================================
      //
      // Repository mengembalikan seluruh pallet aktif.
      // ========================================================

      final List<StockPallet> pallets = await _stockPalletRepository.getAll();

      // ========================================================
      // TOTAL LOCATION
      // ========================================================
      //
      // Jumlah lokasi berasal dari Master Location.
      //
      // Tidak menggunakan angka hard-code 1.860.
      //
      // Jadi jika layout berubah di masa depan,
      // Dashboard otomatis mengikuti generator.
      // ========================================================

      final int totalLocation = locations.length;

      // ========================================================
      // HITUNG LOKASI TERISI
      // ========================================================
      //
      // Setiap StockPallet memiliki Location Code.
      //
      // Karena repository StockPallet sudah melarang
      // dua pallet aktif menggunakan lokasi yang sama,
      // maka setiap locationCode mewakili satu lokasi terisi.
      //
      // Kita tetap menggunakan Set agar aman terhadap
      // kemungkinan data duplikat.
      // ========================================================

      final Set<String> occupiedLocationCodes = pallets
          .map((StockPallet pallet) => pallet.locationCode)
          .toSet();

      // ========================================================
      // STORAGE TERISI
      // ========================================================

      final int storageTerisi = occupiedLocationCodes.length;

      // ========================================================
      // LOCATION AVAILABLE
      // ========================================================
      //
      // Rumus:
      //
      // Available =
      // Total Location - Storage Terisi
      //
      // Gunakan max(0, ...) supaya nilai tidak pernah negatif
      // apabila suatu saat data pallet bermasalah.
      // ========================================================

      final int locationAvailable = (totalLocation - storageTerisi).clamp(
        0,
        totalLocation,
      );

      // ========================================================
      // UPDATE UI
      // ========================================================

      if (!mounted) {
        return;
      }

      setState(() {
        _totalPallet = pallets.length;

        _storageTerisi = storageTerisi;

        _locationAvailable = locationAvailable;

        _isLoading = false;
      });
    } catch (error) {
      // ========================================================
      // ERROR HANDLING
      // ========================================================

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;

        _errorMessage = 'Gagal memuat data dashboard.';
      });

      debugPrint('Dashboard load error: $error');
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        titleSpacing: 20,

        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              'Warehouse Forklift',

              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),

            Text('Warehouse Operations', style: TextStyle(fontSize: 12)),
          ],
        ),

        actions: [
          IconButton(
            tooltip: 'Notifikasi',

            onPressed: () {},

            icon: const Icon(Icons.notifications_none_rounded),
          ),

          const Padding(
            padding: EdgeInsets.only(right: 16),

            child: CircleAvatar(
              radius: 18,

              child: Icon(Icons.person_outline_rounded),
            ),
          ),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboardData,

          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),

            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // ==================================================
                // GREETING
                // ==================================================
                const SizedBox(height: 12),

                Text(
                  'Selamat datang, Operator 👋',

                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Kelola aktivitas gudang dengan cepat dan aman.',

                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 24),

                // ==================================================
                // QUICK ACTION
                // ==================================================
                Text(
                  'Operasional',

                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 14),

                GridView.count(
                  crossAxisCount: 2,

                  shrinkWrap: true,

                  physics: const NeverScrollableScrollPhysics(),

                  crossAxisSpacing: 12,

                  mainAxisSpacing: 12,

                  childAspectRatio: 1.35,

                  children: [
                    // ==================================================
                    // MASTER BARANG
                    // ==================================================
                    _MenuCard(
                      icon: Icons.inventory_2_rounded,
                      title: 'Master Barang',
                      subtitle: 'Data produk',
                      onTap: () {
                        // Belum dihubungkan.
                      },
                    ),

                    // ==================================================
                    // STORAGE
                    // ==================================================
                    _MenuCard(
                      icon: Icons.location_on_rounded,
                      title: 'Storage',
                      subtitle: 'Lokasi rak',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const StoragePage(),
                          ),
                        );
                      },
                    ),

                    // ==================================================
                    // EXCEL IMPORT
                    // ==================================================
                    _MenuCard(
                      icon: Icons.file_upload_rounded,
                      title: 'Excel Import',
                      subtitle: 'Import data pallet',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ExcelImportPage(),
                          ),
                        );
                      },
                    ),

                    // ==================================================
                    // EXPORT STOCK PALLET
                    // ==================================================
                    _MenuCard(
                      icon: _isExporting
                          ? Icons.hourglass_top_rounded
                          : Icons.file_download_rounded,
                      title: _isExporting
                          ? 'Exporting...'
                          : 'Export Stock Pallet',
                      subtitle: _isExporting
                          ? 'Menyiapkan file Excel'
                          : 'Export data pallet',
                      onTap: _isExporting ? null : _exportStockPallet,
                      enabled: !_isExporting,
                    ),

                    // ==================================================
                    // PUTAWAY
                    // ==================================================
                    _MenuCard(
                      icon: Icons.precision_manufacturing_rounded,
                      title: 'Putaway',
                      subtitle: 'Simpan pallet',
                      onTap: () {
                        // Belum dihubungkan.
                      },
                    ),

                    // ==================================================
                    // PICKING
                    // ==================================================
                    _MenuCard(
                      icon: Icons.local_shipping_rounded,
                      title: 'Picking',
                      subtitle: 'Ambil barang',
                      onTap: () {
                        // Belum dihubungkan.
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ==================================================
                // STOCK OVERVIEW
                // ==================================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Text(
                      'Stock Overview',

                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    TextButton(
                      onPressed: () {},

                      child: const Text('Lihat Semua'),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // ==================================================
                // ERROR MESSAGE
                // ==================================================
                if (_errorMessage != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),

                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),

                          const SizedBox(width: 12),

                          Expanded(child: Text(_errorMessage!)),

                          IconButton(
                            onPressed: _loadDashboardData,

                            icon: const Icon(Icons.refresh),
                          ),
                        ],
                      ),
                    ),
                  ),

                // ==================================================
                // STOCK CARD
                // ==================================================
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),

                    child: Column(
                      children: [
                        // ------------------------------------------
                        // TOTAL PALLET
                        // ------------------------------------------
                        _StockRow(
                          icon: Icons.inventory_2_outlined,

                          title: 'Total Pallet',

                          value: _isLoading ? '...' : _totalPallet.toString(),
                        ),

                        const Divider(height: 24),

                        // ------------------------------------------
                        // STORAGE TERISI
                        // ------------------------------------------
                        _StockRow(
                          icon: Icons.warehouse_outlined,

                          title: 'Storage Terisi',

                          value: _isLoading ? '...' : _storageTerisi.toString(),
                        ),

                        const Divider(height: 24),

                        // ------------------------------------------
                        // LOCATION AVAILABLE
                        // ------------------------------------------
                        _StockRow(
                          icon: Icons.check_circle_outline_rounded,

                          title: 'Location Available',

                          value: _isLoading
                              ? '...'
                              : _locationAvailable.toString(),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ==================================================
                // SYSTEM STATUS
                // ==================================================
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),

                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,

                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.12),

                            shape: BoxShape.circle,
                          ),

                          child: const Icon(
                            Icons.cloud_done_rounded,

                            color: Colors.green,
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text(
                                'System Ready',

                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              const SizedBox(height: 3),

                              Text(
                                'Warehouse system siap digunakan.',

                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Icon(
                          Icons.check_circle_rounded,

                          color: Colors.green,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // ========================================================
      // BOTTOM NAVIGATION
      // ========================================================
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedNavigationIndex,

        onDestinationSelected: (index) {
          setState(() {
            _selectedNavigationIndex = index;
          });

          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StoragePage()),
            ).then((_) {
              if (!mounted) {
                return;
              }

              setState(() {
                _selectedNavigationIndex = 0;
              });
            });
          }
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Home',
          ),

          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2_rounded),
            label: 'Stock',
          ),

          NavigationDestination(
            icon: Icon(Icons.local_shipping_outlined),
            selectedIcon: Icon(Icons.local_shipping_rounded),
            label: 'Operation',
          ),

          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'More',
          ),
        ],
      ),
    );
  }
}
// ============================================================
// MENU CARD
// ============================================================

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;

  final String title;

  final String subtitle;

  final VoidCallback? onTap;

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final primaryColor = theme.colorScheme.primary;

    final iconColor = enabled
        ? primaryColor
        : theme.colorScheme.onSurface.withValues(alpha: 0.38);

    final titleColor = enabled
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurface.withValues(alpha: 0.38);

    final subtitleColor = enabled
        ? theme.colorScheme.onSurfaceVariant
        : theme.colorScheme.onSurface.withValues(alpha: 0.30);

    return Card(
      clipBehavior: Clip.antiAlias,

      child: InkWell(
        onTap: enabled ? onTap : null,

        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              if (enabled)
                Icon(icon, size: 30, color: iconColor)
              else
                SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: primaryColor,
                  ),
                ),

              const SizedBox(height: 10),

              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: subtitleColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// STOCK ROW
// ============================================================

class _StockRow extends StatelessWidget {
  const _StockRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;

  final String title;

  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary),

        const SizedBox(width: 14),

        Expanded(
          child: Text(
            title,

            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        Text(
          value,

          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
