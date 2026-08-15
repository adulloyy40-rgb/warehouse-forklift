// ============================================================
// FILE:
// lib/presentation/pages/storage/storage_detail_page.dart
// ============================================================
//
// FUNGSI:
// Menampilkan detail satu lokasi storage.
//
// HALAMAN INI MENAMPILKAN:
//
// 1. Location Code
// 2. Rack
// 3. Bay
// 4. Shelving
// 5. Level
// 6. Position
// 7. Status lokasi
// 8. Informasi pallet jika lokasi terisi
//
// STATUS:
//
// AVAILABLE
// = lokasi belum ditempati pallet.
//
// OCCUPIED
// = lokasi sedang ditempati pallet.
//
// ============================================================

import 'package:flutter/material.dart';

import '../../../domain/entities/storage_location.dart';
import '../../../domain/entities/stock_pallet.dart';
import '../../../domain/repositories/stock_pallet_repository.dart';

// ============================================================
// STORAGE DETAIL PAGE
// ============================================================
//
// Halaman menerima:
//
// - StorageLocation
// - StockPalletRepository
//
// Repository diberikan dari AppDependencies sehingga kita
// tidak membuat repository baru di dalam halaman.
//
// ============================================================

class StorageDetailPage extends StatefulWidget {
  const StorageDetailPage({
    super.key,
    required this.location,
    required this.stockPalletRepository,
  });

  // ==========================================================
  // LOCATION
  // ==========================================================
  //
  // Lokasi yang sedang dilihat operator.
  // ==========================================================

  final StorageLocation location;

  // ==========================================================
  // STOCK PALLET REPOSITORY
  // ==========================================================
  //
  // Repository digunakan untuk mencari pallet berdasarkan
  // Location Code.
  // ==========================================================

  final StockPalletRepository stockPalletRepository;

  @override
  State<StorageDetailPage> createState() => _StorageDetailPageState();
}

// ============================================================
// STATE
// ============================================================

class _StorageDetailPageState extends State<StorageDetailPage> {
  // ==========================================================
  // PALLET
  // ==========================================================
  //
  // Jika null berarti lokasi AVAILABLE.
  // Jika ada data berarti lokasi OCCUPIED.
  // ==========================================================

  StockPallet? _pallet;

  // ==========================================================
  // LOADING
  // ==========================================================

  bool _isLoading = true;

  // ==========================================================
  // ERROR
  // ==========================================================

  String? _errorMessage;

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();

    _loadLocationData();
  }

  // ==========================================================
  // LOAD LOCATION DATA
  // ==========================================================
  //
  // Mencari pallet berdasarkan Location Code.
  //
  // Contoh:
  //
  // 8001101
  //
  // Jika ditemukan:
  //
  // OCCUPIED
  //
  // Jika tidak:
  //
  // AVAILABLE
  // ==========================================================

  Future<void> _loadLocationData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final pallet = await widget.stockPalletRepository.findByLocationCode(
        widget.location.code,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _pallet = pallet;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat data lokasi.';
      });

      debugPrint('Storage detail error: $error');
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bool isOccupied = _pallet != null;

    return Scaffold(
      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        title: const Text(
          'Storage Detail',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),

        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadLocationData,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadLocationData,

          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),

            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // ==================================================
                // LOCATION HEADER
                // ==================================================
                _LocationHeader(
                  location: widget.location,
                  isOccupied: isOccupied,
                ),

                const SizedBox(height: 20),

                // ==================================================
                // ERROR
                // ==================================================
                if (_errorMessage != null)
                  _ErrorCard(
                    message: _errorMessage!,
                    onRetry: _loadLocationData,
                  ),

                // ==================================================
                // LOCATION INFORMATION
                // ==================================================
                Text(
                  'Informasi Lokasi',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 12),

                _LocationInformationCard(location: widget.location),

                const SizedBox(height: 24),

                // ==================================================
                // PALLET INFORMATION
                // ==================================================
                Text(
                  'Informasi Pallet',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 12),

                if (_isLoading)
                  const _LoadingCard()
                else if (isOccupied)
                  _PalletInformationCard(pallet: _pallet!)
                else
                  const _AvailableCard(),

                const SizedBox(height: 24),

                // ==================================================
                // SYSTEM INFORMATION
                // ==================================================
                _SystemInformationCard(isOccupied: isOccupied),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// LOCATION HEADER
// ============================================================
//
// Bagian atas halaman.
//
// Menampilkan Location Code dan status lokasi.
// ============================================================

class _LocationHeader extends StatelessWidget {
  const _LocationHeader({required this.location, required this.isOccupied});

  final StorageLocation location;

  final bool isOccupied;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Color statusColor = isOccupied ? Colors.orange : Colors.green;

    final String statusText = isOccupied ? 'OCCUPIED' : 'AVAILABLE';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Row(
          children: [
            // ==================================================
            // LOCATION ICON
            // ==================================================
            Container(
              width: 56,
              height: 56,

              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.10),

                borderRadius: BorderRadius.circular(16),
              ),

              child: Icon(
                Icons.location_on_rounded,
                size: 30,
                color: theme.colorScheme.primary,
              ),
            ),

            const SizedBox(width: 16),

            // ==================================================
            // LOCATION CODE
            // ==================================================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    'Location Code',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    location.code,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ==================================================
                  // STATUS BADGE
                  // ==================================================
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),

                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),

                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// LOCATION INFORMATION CARD
// ============================================================

class _LocationInformationCard extends StatelessWidget {
  const _LocationInformationCard({required this.location});

  final StorageLocation location;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          children: [
            _InformationRow(
              icon: Icons.view_module_rounded,
              title: 'Rack',
              value: location.rack.toString(),
            ),

            const Divider(height: 24),

            _InformationRow(
              icon: Icons.grid_view_rounded,
              title: 'Bay',
              value: location.bay.toString(),
            ),

            const Divider(height: 24),

            _InformationRow(
              icon: Icons.layers_outlined,
              title: 'Shelving',
              value: _displayNullable(location.shelving),
            ),

            const Divider(height: 24),

            _InformationRow(
              icon: Icons.stairs_rounded,
              title: 'Level',
              value: _displayNullable(location.level),
            ),

            const Divider(height: 24),

            _InformationRow(
              icon: Icons.space_dashboard_outlined,
              title: 'Position',
              value: _displayNullable(location.position),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // NULLABLE VALUE
  // ==========================================================

  String _displayNullable(int? value) {
    if (value == null) {
      return '-';
    }

    return value.toString();
  }
}

// ============================================================
// PALLET INFORMATION CARD
// ============================================================
//
// Ditampilkan ketika lokasi sedang ditempati pallet.
// ============================================================

class _PalletInformationCard extends StatelessWidget {
  const _PalletInformationCard({required this.pallet});

  final StockPallet pallet;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          children: [
            // ==================================================
            // LOCATION CODE
            // ==================================================
            _InformationRow(
              icon: Icons.location_on_outlined,
              title: 'Location Code',
              value: pallet.locationCode,
            ),

            const Divider(height: 24),

            // ==================================================
            // PRODUCT
            // ==================================================
            _InformationRow(
              icon: Icons.inventory_2_outlined,
              title: 'Product',
              value: _readProduct(pallet),
            ),

            const Divider(height: 24),

            // ==================================================
            // QUANTITY
            // ==================================================
            _InformationRow(
              icon: Icons.numbers_rounded,
              title: 'Quantity',
              value: _readQuantity(pallet),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // PRODUCT
  // ==========================================================
  //
  // Kita menggunakan helper terpisah supaya halaman ini tidak
  // bergantung pada struktur field tertentu secara berlebihan.
  //
  // Jika entity StockPallet nantinya mempunyai field productCode,
  // fungsi ini dapat disesuaikan.
  // ==========================================================

  String _readProduct(StockPallet pallet) {
    // Untuk tahap awal, tampilkan representasi object.
    //
    // Nanti ketika ProductRepository sudah dihubungkan,
    // bagian ini akan menampilkan:
    //
    // Product Code
    // Product Name
    // Batch
    // Expired Date
    //
    return pallet.toString();
  }

  // ==========================================================
  // QUANTITY
  // ==========================================================

  String _readQuantity(StockPallet pallet) {
    return pallet.toString();
  }
}

// ============================================================
// AVAILABLE CARD
// ============================================================
//
// Ditampilkan ketika lokasi belum memiliki pallet.
// ============================================================

class _AvailableCard extends StatelessWidget {
  const _AvailableCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,

              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.12),

                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.check_circle_rounded,
                size: 40,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 14),

            const Text(
              'Location Available',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 6),

            Text(
              'Lokasi ini belum ditempati pallet.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// LOADING CARD
// ============================================================

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(24),

        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

// ============================================================
// ERROR CARD
// ============================================================

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String message;

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.red),

            const SizedBox(width: 12),

            Expanded(child: Text(message)),

            IconButton(
              tooltip: 'Coba lagi',
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SYSTEM INFORMATION CARD
// ============================================================

class _SystemInformationCard extends StatelessWidget {
  const _SystemInformationCard({required this.isOccupied});

  final bool isOccupied;

  @override
  Widget build(BuildContext context) {
    final String description = isOccupied
        ? 'Lokasi ini sedang ditempati pallet.'
        : 'Lokasi ini siap digunakan untuk penyimpanan pallet.';

    final Color statusColor = isOccupied ? Colors.orange : Colors.green;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isOccupied
                    ? Icons.inventory_2_rounded
                    : Icons.check_circle_rounded,
                color: statusColor,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isOccupied ? 'Storage Occupied' : 'Storage Available',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade500),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// INFORMATION ROW
// ============================================================

// ============================================================
// INFORMATION ROW
// ============================================================

class _InformationRow extends StatelessWidget {
  const _InformationRow({
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
        // ======================================================
        // ICON
        // ======================================================
        Icon(icon, size: 22, color: theme.colorScheme.primary),

        const SizedBox(width: 14),

        // ======================================================
        // TITLE
        // ======================================================
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // ======================================================
        // VALUE
        // ======================================================
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
