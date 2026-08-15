// ============================================================
// FILE:
// lib/presentation/pages/storage/storage_page.dart
// ============================================================
//
// FUNGSI:
// Halaman Master Storage Location.
//
// Data lokasi berasal dari:
// StorageLocationRepository
//
// Status lokasi berasal dari:
// StockPalletRepository
//
// STATUS:
// 🟢 AVAILABLE
// 🔴 OCCUPIED
//
// CATATAN:
// Tidak ada data lokasi yang di-hard-code di halaman ini.
// Seluruh lokasi dibaca dari repository.
// ============================================================

import 'package:flutter/material.dart';

import '../../../data/repositories/stock_pallet_repository_impl.dart';
import '../../../data/repositories/storage_location_repository_impl.dart';
import '../../../domain/entities/stock_pallet.dart';
import '../../../domain/entities/storage_location.dart';

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

  final StorageLocationRepositoryImpl _storageRepository =
      const StorageLocationRepositoryImpl();

  final StockPalletRepositoryImpl _palletRepository =
      StockPalletRepositoryImpl();

  // ==========================================================
  // DATA
  // ==========================================================

  List<StorageLocation> _locations = [];

  List<StockPallet> _pallets = [];

  // ==========================================================
  // SEARCH
  // ==========================================================

  String _searchQuery = '';

  // ==========================================================
  // FILTER RACK
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

  @override
  void initState() {
    super.initState();

    _loadStorageData();
  }

  // ==========================================================
  // LOAD STORAGE DATA
  // ==========================================================
  //
  // Mengambil:
  //
  // 1. Seluruh lokasi storage.
  // 2. Seluruh pallet.
  //
  // Kemudian UI menentukan lokasi:
  //
  // AVAILABLE
  // atau
  // OCCUPIED
  // ==========================================================

  Future<void> _loadStorageData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final locations = await _storageRepository.getAllLocations();

      final pallets = await _palletRepository.getAll();

      if (!mounted) {
        return;
      }

      setState(() {
        _locations = locations;
        _pallets = pallets;
        _isLoading = false;
      });
    } catch (error) {
      debugPrint('Storage load error: $error');

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
  // GET OCCUPIED LOCATION CODES
  // ==========================================================
  //
  // Membuat Set kode lokasi yang sedang ditempati pallet.
  //
  // Set digunakan supaya pencarian cepat dan aman terhadap
  // data duplikat.
  // ==========================================================

  Set<String> get _occupiedLocationCodes {
    return _pallets.map((pallet) => pallet.locationCode).toSet();
  }

  // ==========================================================
  // TOTAL LOCATION
  // ==========================================================

  int get _totalLocation {
    return _locations.length;
  }

  // ==========================================================
  // TOTAL OCCUPIED
  // ==========================================================

  int get _occupiedLocation {
    return _occupiedLocationCodes.length;
  }

  // ==========================================================
  // TOTAL AVAILABLE
  // ==========================================================

  int get _availableLocation {
    return (_totalLocation - _occupiedLocation).clamp(0, _totalLocation);
  }

  // ==========================================================
  // FILTERED LOCATIONS
  // ==========================================================
  //
  // Filter berdasarkan:
  //
  // 1. Search code
  // 2. Rack
  // ==========================================================

  List<StorageLocation> get _filteredLocations {
    final query = _searchQuery.trim().toLowerCase();

    return _locations.where((location) {
      // --------------------------------------------------------
      // FILTER SEARCH
      // --------------------------------------------------------

      final matchesSearch =
          query.isEmpty || location.code.toLowerCase().contains(query);

      // --------------------------------------------------------
      // FILTER RACK
      // --------------------------------------------------------

      final matchesRack =
          _selectedRack == null || location.rack == _selectedRack;

      return matchesSearch && matchesRack;
    }).toList();
  }

  // ==========================================================
  // GET RACK LIST
  // ==========================================================
  //
  // Mengambil daftar rack dari data repository.
  //
  // Tidak menggunakan daftar rack hard-code.
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
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? _buildErrorState()
            : RefreshIndicator(
                onRefresh: _loadStorageData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ====================================
                      // SUMMARY
                      // ====================================
                      _buildSummary(theme),

                      const SizedBox(height: 24),

                      // ====================================
                      // SEARCH
                      // ====================================
                      _buildSearchField(theme),

                      const SizedBox(height: 12),

                      // ====================================
                      // RACK FILTER
                      // ====================================
                      _buildRackFilter(theme),

                      const SizedBox(height: 20),

                      // ====================================
                      // RESULT COUNT
                      // ====================================
                      Text(
                        '${_filteredLocations.length} lokasi ditemukan',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ====================================
                      // LOCATION LIST
                      // ====================================
                      _buildLocationList(theme),
                    ],
                  ),
                ),
              ),
      ),
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
          // ----------------------------------------------------
          // ALL RACK
          // ----------------------------------------------------
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

          // ----------------------------------------------------
          // RACK DARI REPOSITORY
          // ----------------------------------------------------
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
  // LOCATION LIST
  // ==========================================================

  Widget _buildLocationList(ThemeData theme) {
    final locations = _filteredLocations;

    if (locations.isEmpty) {
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

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: locations.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final location = locations[index];

        final isOccupied = _occupiedLocationCodes.contains(location.code);

        return _LocationCard(location: location, isOccupied: isOccupied);
      },
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
            Text(_errorMessage ?? '', textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton.icon(
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
// LOCATION CARD
// ============================================================

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.location, required this.isOccupied});

  final StorageLocation location;
  final bool isOccupied;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final statusText = isOccupied ? 'OCCUPIED' : 'AVAILABLE';

    final statusIcon = isOccupied
        ? Icons.inventory_2_rounded
        : Icons.check_circle_rounded;

    final statusColor = isOccupied ? Colors.orange : Colors.green;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          _showLocationDetail(context);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // =================================================
              // LOCATION ICON
              // =================================================
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

              // =================================================
              // LOCATION INFORMATION
              // =================================================
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
                      'Rack ${location.rack} • '
                      'Bay ${location.bay}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),

                    if (location.shelving != null ||
                        location.level != null ||
                        location.position != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        _buildPositionText(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // =================================================
              // STATUS
              // =================================================
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

    if (location.level != null) {
      parts.add('Level ${location.level}');
    }

    if (location.position != null) {
      parts.add('Pos ${location.position}');
    }

    return parts.join(' • ');
  }

  // ==========================================================
  // LOCATION DETAIL
  // ==========================================================

  void _showLocationDetail(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detail Location',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),

                const SizedBox(height: 18),

                _DetailRow(label: 'Location Code', value: location.code),

                _DetailRow(label: 'Rack', value: location.rack.toString()),

                _DetailRow(label: 'Bay', value: location.bay.toString()),

                _DetailRow(
                  label: 'Shelving',
                  value: location.shelving?.toString() ?? '-',
                ),

                _DetailRow(
                  label: 'Level',
                  value: location.level?.toString() ?? '-',
                ),

                _DetailRow(
                  label: 'Position',
                  value: location.position?.toString() ?? '-',
                ),

                _DetailRow(
                  label: 'Status',
                  value: isOccupied ? 'OCCUPIED' : 'AVAILABLE',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
// ============================================================
// DETAIL ROW
// ============================================================

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: TextStyle(color: Colors.grey.shade600)),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
