// ============================================================
// FILE:
// lib/presentation/pages/storage/storage_page.dart
// ============================================================
//
// FUNGSI:
// Halaman Master Storage Location.
//
// ALUR:
// Dashboard
//    ↓
// Storage
//    ↓
// Daftar Location
//    ↓
// Klik Location
//    ↓
// Storage Detail Page
//
// STATUS LOCATION:
// AVAILABLE
// OCCUPIED
//
// PERFORMANCE:
// Menggunakan CustomScrollView + SliverList
// agar ribuan lokasi tidak dibangun sekaligus.
// ============================================================

import 'package:flutter/material.dart';

import '../../../core/di/app_dependencies.dart';

import '../../../domain/entities/storage_location.dart';
import '../../../domain/repositories/storage_location_repository.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/stock_pallet.dart';

import '../../../domain/repositories/stock_pallet_repository.dart';
import '../../../domain/repositories/product_repository.dart';

import '../../../domain/services/pallet_status_calculator.dart';

import 'storage_detail_page.dart';

// ============================================================
// STORAGE PAGE
// ============================================================

class StoragePage extends StatefulWidget {
  const StoragePage({super.key});

  @override
  State<StoragePage> createState() => _StoragePageState();
}

// ============================================================
// STORAGE PAGE STATE
// ============================================================

class _StoragePageState extends State<StoragePage> {
  // ==========================================================
  // REPOSITORY
  // ==========================================================

  final StorageLocationRepository _storageRepository =
      AppDependencies.instance.storageLocationRepository;

  final StockPalletRepository _palletRepository =
      AppDependencies.instance.stockPalletRepository;

  final ProductRepository _productRepository =
      AppDependencies.instance.productRepository;

  // ==========================================================
  // DATA
  // ==========================================================

  List<StorageLocation> _locations = [];

  // ==========================================================
  // PALLET CACHE
  // ==========================================================
  //
  // Key   : Location Code
  // Value : StockPallet
  //
  // Tujuan:
  // Menghindari query pallet satu per satu ketika membangun
  // daftar Storage Location.
  // ==========================================================

  final Map<String, StockPallet> _palletByLocation = {};

  // ==========================================================
  // MASTER BARANG CACHE
  // ==========================================================
  //
  // Key   : PLU
  // Value : Product
  // ==========================================================

  final Map<String, Product> _productByPlu = {};

  // ==========================================================
  // OCCUPIED LOCATION CACHE
  // ==========================================================

  // ==========================================================
  // SEARCH
  // ==========================================================

  String _searchQuery = '';

  // ==========================================================
  // RACK FILTER
  // ==========================================================

  int? _selectedRack;

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
  final Set<String> _occupiedLocationCodes = {};

  @override
  void initState() {
    super.initState();

    _loadStorageData();
  }

  // ==========================================================
  // LOAD STORAGE DATA
  // ==========================================================

  Future<void> _loadStorageData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      // ========================================================
      // LOAD SEMUA STORAGE LOCATION
      // ========================================================

      final locations = await _storageRepository.getAllLocations();

      // ========================================================
      // LOAD SEMUA STOCK PALLET
      // ========================================================

      final pallets = await _palletRepository.getAll();

      // ========================================================
      // LOAD MASTER BARANG
      // ========================================================
      //
      // Master Barang dimuat satu kali.
      //
      // Setelah itu digunakan sebagai lookup berdasarkan PLU.
      // ========================================================

      final products = await _productRepository.getAllProducts();

      final productByPlu = <String, Product>{
        for (final product in products) product.plu.trim(): product,
      };

      // ========================================================
      // CACHE PALLET BERDASARKAN LOCATION
      // ========================================================

      final palletByLocation = <String, StockPallet>{
        for (final pallet in pallets)
          if (pallet.locationCode.trim().isNotEmpty)
            pallet.locationCode.trim(): pallet,
      };

      // ========================================================
      // BENTUK SET LOCATION CODE YANG TERISI
      // ========================================================

      final occupiedCodes = palletByLocation.keys.toSet();

      // ========================================================
      // CEK WIDGET MASIH AKTIF
      // ========================================================

      if (!mounted) {
        return;
      }

      // ========================================================
      // UPDATE DATA
      // ========================================================

      setState(() {
        _locations = locations;

        _occupiedLocationCodes
          ..clear()
          ..addAll(occupiedCodes);

        _palletByLocation
          ..clear()
          ..addAll(palletByLocation);

        _productByPlu
          ..clear()
          ..addAll(productByPlu);

        _isLoading = false;
      });
    } catch (error, stackTrace) {
      debugPrint('Storage load error: $error');

      debugPrint(stackTrace.toString());

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat data storage.';
      });
    }
  }

  // ==========================================================
  // TOTAL LOCATION
  // ==========================================================

  int get _totalLocation {
    return _locations.length;
  }

  // ==========================================================
  // OCCUPIED LOCATION
  // ==========================================================

  int get _occupiedLocation {
    return _occupiedLocationCodes.length;
  }

  // ==========================================================
  // AVAILABLE LOCATION
  // ==========================================================

  int get _availableLocation {
    final available = _totalLocation - _occupiedLocation;

    return available.clamp(0, _totalLocation);
  }

  // ==========================================================
  // FILTERED LOCATIONS
  // ==========================================================

  List<StorageLocation> get _filteredLocations {
    final query = _searchQuery.trim().toLowerCase();

    return _locations.where((location) {
      final matchesSearch =
          query.isEmpty || location.code.toLowerCase().contains(query);

      final matchesRack =
          _selectedRack == null || location.rack == _selectedRack;

      return matchesSearch && matchesRack;
    }).toList();
  }

  // ==========================================================
  // RACK LIST
  // ==========================================================

  List<int> get _rackList {
    final racks = _locations.map((location) => location.rack).toSet().toList();

    racks.sort();

    return racks;
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
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Storage Location',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            Text('Master lokasi gudang', style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadStorageData,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: SafeArea(child: _buildBody(theme)),
    );
  }

  // ==========================================================
  // BODY
  // ==========================================================

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    return RefreshIndicator(
      onRefresh: _loadStorageData,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ====================================================
          // HEADER
          // ====================================================
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            sliver: SliverToBoxAdapter(child: _buildHeader(theme)),
          ),

          // ====================================================
          // LOCATION LIST
          // ====================================================
          _buildLocationSliver(theme),

          // ====================================================
          // BOTTOM SPACE
          // ====================================================
          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      ),
    );
  }

  // ==========================================================
  // HEADER
  // ==========================================================

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSummary(theme),

        const SizedBox(height: 24),

        _buildSearchField(theme),

        const SizedBox(height: 12),

        _buildRackFilter(theme),

        const SizedBox(height: 20),

        Text(
          '${_filteredLocations.length} lokasi ditemukan',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),

        const SizedBox(height: 12),
      ],
    );
  }

  // ==========================================================
  // SUMMARY
  // ==========================================================

  Widget _buildSummary(ThemeData theme) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      childAspectRatio: 0.95,
      children: [
        _SummaryCard(
          icon: Icons.location_on_rounded,
          title: 'Total',
          value: _totalLocation.toString(),
        ),
        _SummaryCard(
          icon: Icons.warehouse_rounded,
          title: 'Terisi',
          value: _occupiedLocation.toString(),
        ),
        _SummaryCard(
          icon: Icons.check_circle_rounded,
          title: 'Available',
          value: _availableLocation.toString(),
        ),
      ],
    );
  }

  // ==========================================================
  // SEARCH FIELD
  // ==========================================================

  Widget _buildSearchField(ThemeData theme) {
    return TextField(
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      decoration: InputDecoration(
        hintText: 'Cari Location Code...',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                  });
                },
                icon: const Icon(Icons.clear_rounded),
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  // ==========================================================
  // RACK FILTER
  // ==========================================================

  Widget _buildRackFilter(ThemeData theme) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('Semua Rack'),
              selected: _selectedRack == null,
              onSelected: (_) {
                setState(() {
                  _selectedRack = null;
                });
              },
            ),
          ),

          // ==================================================
          // RACK ITEMS
          // ==================================================
          ..._rackList.map((rack) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text('Rack $rack'),
                selected: _selectedRack == rack,
                onSelected: (_) {
                  setState(() {
                    _selectedRack = rack;
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  // ==========================================================
  // LOCATION SLIVER
  // ==========================================================

  Widget _buildLocationSliver(ThemeData theme) {
    final locations = _filteredLocations;

    // ========================================================
    // EMPTY
    // ========================================================

    if (locations.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverToBoxAdapter(child: _buildEmptyState(theme)),
      );
    }

    // ========================================================
    // LAZY LOCATION LIST
    // ========================================================

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final location = locations[index];

          final isOccupied = _occupiedLocationCodes.contains(location.code);

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _LocationCard(
              location: location,
              isOccupied: isOccupied,
              stockPallet: _palletByLocation[location.code.trim()],
              masterProduct:
                  _productByPlu[_palletByLocation[location.code.trim()]?.plu
                      .trim()],
              stockPalletRepository: _palletRepository,
              palletStatusCalculator: const PalletStatusCalculator(),
            ),
          );
        }, childCount: locations.length),
      ),
    );
  }

  // ==========================================================
  // EMPTY STATE
  // ==========================================================

  Widget _buildEmptyState(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 48,
                color: Colors.grey.shade500,
              ),

              const SizedBox(height: 12),

              Text(
                'Lokasi tidak ditemukan',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'Coba ubah kata pencarian atau filter rack.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // ERROR STATE
  // ==========================================================

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: Colors.red,
            ),

            const SizedBox(height: 16),

            const Text(
              'Gagal memuat Storage',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 8),

            const Text(
              'Terjadi masalah ketika memuat data lokasi.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _loadStorageData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SUMMARY CARD
// ============================================================

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 25, color: theme.colorScheme.primary),

            const SizedBox(height: 6),

            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// MISMATCH BADGE
// ============================================================
//
// Menampilkan peringatan ketika nilai fisik pallet berbeda
// dengan nilai Master Barang.
//
// Contoh:
// - TEAR MISMATCH
// - STACK MISMATCH
//
// Widget ini hanya bertugas sebagai UI.
// Business rule tetap berada di PalletStatusCalculator.
// ============================================================

class _MismatchBadge extends StatelessWidget {
  const _MismatchBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// VALUE MISMATCH DETAIL
// ============================================================
//
// Menampilkan nilai Master dan nilai Aktual.
//
// Contoh:
// TEAR  Master: 4  Aktual: 5
// STACK Master: 3  Aktual: 2
// ============================================================

class _ValueMismatchText extends StatelessWidget {
  const _ValueMismatchText({
    required this.label,
    required this.masterValue,
    required this.actualValue,
  });

  final String label;
  final int masterValue;
  final int actualValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.18),
        ),
      ),
      child: Text(
        '$label  Master: $masterValue  Aktual: $actualValue',
        style: theme.textTheme.bodySmall?.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.error,
        ),
      ),
    );
  }
}

// ============================================================
// EXPIRY STATUS BADGE
// ============================================================
//
// Menampilkan status tanggal pallet:
//
// - EXPIRED
// - NEAR RETURN
//
// Business rule tetap dihitung oleh PalletStatusCalculator.
// Widget ini hanya bertugas menampilkan hasilnya.
// ============================================================

class _ExpiryBadge extends StatelessWidget {
  const _ExpiryBadge({required this.status});

  final PalletExpiryStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isExpired = status == PalletExpiryStatus.expired;

    final color = isExpired ? theme.colorScheme.error : Colors.deepPurple;

    final icon = isExpired ? Icons.error_rounded : Icons.schedule_rounded;

    final label = isExpired ? 'EXPIRED' : 'NEAR RETURN';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// LOCATION CARD
// ============================================================

class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.location,
    required this.isOccupied,
    required this.stockPallet,
    required this.masterProduct,
    required this.stockPalletRepository,
    required this.palletStatusCalculator,
  });

  final StorageLocation location;

  final bool isOccupied;

  final StockPallet? stockPallet;

  final Product? masterProduct;

  final StockPalletRepository stockPalletRepository;

  final PalletStatusCalculator palletStatusCalculator;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // ==========================================================
    // HITUNG STATUS TEAR / STACK
    // ==========================================================
    //
    // TEAR AKTUAL  dibandingkan dengan TEAR MASTER
    // STACK AKTUAL dibandingkan dengan STACK MASTER
    //
    // Jika pallet kosong, tidak ada kalkulasi.
    // ==========================================================

    final palletStatus = stockPallet == null
        ? null
        : palletStatusCalculator.calculate(
            stockPallet!,
            masterTear: masterProduct?.masterTear,
            masterStack: masterProduct?.masterStack,
          );

    final statusText = isOccupied ? 'OCCUPIED' : 'AVAILABLE';

    final statusIcon = isOccupied
        ? Icons.inventory_2_rounded
        : Icons.check_circle_rounded;

    final statusColor = isOccupied ? Colors.orange : Colors.green;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StorageDetailPage(
                location: location,
                stockPalletRepository: stockPalletRepository,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // ==================================================
              // STATUS ICON
              // ==================================================
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(statusIcon, color: statusColor),
              ),

              const SizedBox(width: 14),

              // ==================================================
              // LOCATION INFORMATION
              // ==================================================
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.code,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'Rack ${location.rack} • Bay ${location.bay}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),

                    if (location.shelving != null ||
                        location.position != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        _buildPositionText(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],

                    // ==================================================
                    // PALLET ITEM DETAIL
                    // ==================================================
                    //
                    // Data berasal langsung dari StockPallet.
                    //
                    // description → Nama Barang
                    // qtyCtn     → Qty CTN
                    // qtyPcs     → Qty PCS
                    //
                    // Tidak ada query database tambahan di sini.
                    // ==================================================
                    if (stockPallet != null) ...[
                      const SizedBox(height: 8),

                      Text(
                        stockPallet!.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        'Qty CTN = ${stockPallet!.qtyCtn} • '
                        'Qty PCS = ${stockPallet!.qtyPcs}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],

                    // ==================================================
                    // EXPIRY STATUS
                    // ==================================================
                    //
                    // Hanya ditampilkan jika pallet memang ada.
                    //
                    // NORMAL      -> tidak menampilkan badge.
                    // NEAR RETURN -> tampilkan badge.
                    // EXPIRED     -> tampilkan badge.
                    // ==================================================
                    if (palletStatus != null &&
                        palletStatus.expiryStatus !=
                            PalletExpiryStatus.normal) ...[
                      const SizedBox(height: 8),

                      _ExpiryBadge(status: palletStatus.expiryStatus),
                    ],

                    // ==================================================
                    // TEAR / STACK MISMATCH
                    // ==================================================
                    //
                    // Hanya ditampilkan jika pallet memang ada.
                    // ==================================================
                    if (palletStatus != null &&
                        palletStatus.hasTearOrStackMismatch) ...[
                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          if (palletStatus.tearMismatch)
                            _MismatchBadge(
                              icon: Icons.warning_amber_rounded,
                              label: 'TEAR MISMATCH',
                            ),

                          if (palletStatus.stackMismatch)
                            _MismatchBadge(
                              icon: Icons.layers_clear_rounded,
                              label: 'STACK MISMATCH',
                            ),
                        ],
                      ),

                      if (masterProduct != null) ...[
                        const SizedBox(height: 6),

                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            if (palletStatus.tearMismatch)
                              _ValueMismatchText(
                                label: 'TEAR',
                                masterValue: masterProduct!.masterTear,
                                actualValue: stockPallet!.tear,
                              ),

                            if (palletStatus.stackMismatch)
                              _ValueMismatchText(
                                label: 'STACK',
                                masterValue: masterProduct!.masterStack,
                                actualValue: stockPallet!.stack,
                              ),
                          ],
                        ),
                      ],
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // ==================================================
              // STATUS BADGE
              // ==================================================
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // POSITION TEXT
  // ==========================================================

  String _buildPositionText() {
    final parts = <String>[];

    if (location.shelving != null) {
      parts.add('Shelving ${location.shelving}');
    }

    if (location.position != null) {
      parts.add('Pos ${location.position}');
    }

    return parts.join(' • ');
  }
}
