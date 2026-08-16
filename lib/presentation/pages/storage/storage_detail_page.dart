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

import '../../../core/di/app_dependencies.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/usecases/product/get_product_by_plu.dart';

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

  // ============================================================
  // OPEN PUT AWAY FORM
  // ============================================================

  Future<void> _openPutAwayForm() async {
    // ----------------------------------------------------------
    // Jangan membuka PUT AWAY jika lokasi sudah terisi.
    // ----------------------------------------------------------

    if (_pallet != null) {
      return;
    }

    // ----------------------------------------------------------
    // Buka form PUT AWAY.
    // ----------------------------------------------------------

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return _PutAwayForm(
          location: widget.location,
          stockPalletRepository: widget.stockPalletRepository,
        );
      },
    );

    // ----------------------------------------------------------
    // Jika PUT AWAY berhasil,
    // reload data lokasi.
    // ----------------------------------------------------------

    if (result == true) {
      await _loadLocationData();
    }
  }

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
                else ...[
                  const _AvailableCard(),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: _openPutAwayForm,
                      icon: const Icon(Icons.move_to_inbox_rounded),
                      label: const Text(
                        'PUT AWAY',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],

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

// ============================================================
// PUT AWAY FORM
// ============================================================
//
// FUNGSI:
// Form untuk memasukkan pallet ke lokasi storage.
//
// ALUR:
//
// PLU
//   ↓
// GetProductByPlu
//   ↓
// Master Barang
//   ↓
// Input Tear & Stack
//   ↓
// Hitung Qty CTN
//   ↓
// Hitung Qty PCS
//   ↓
// Bandingkan dengan Master
//
// ============================================================

class _PutAwayForm extends StatefulWidget {
  const _PutAwayForm({
    required this.location,
    required this.stockPalletRepository,
  });

  // Lokasi tujuan pallet.
  final StorageLocation location;

  // Repository StockPallet.
  final StockPalletRepository stockPalletRepository;

  @override
  State<_PutAwayForm> createState() => _PutAwayFormState();
}

// ============================================================
// PUT AWAY FORM STATE
// ============================================================
//
// State untuk form PUT AWAY.
//
// Tahap pertama:
//
// 1. Menyiapkan controller input.
// 2. Menyimpan Product hasil pencarian PLU.
// 3. Menyimpan status loading pencarian.
// 4. Menyimpan pesan error.
//
// UI form akan kita buat setelah struktur State ini
// berhasil dianalisis Flutter.
// ============================================================

class _PutAwayFormState extends State<_PutAwayForm> {
  // ==========================================================
  // PLU CONTROLLER
  // ==========================================================
  //
  // Digunakan operator untuk memasukkan PLU barang.
  // ==========================================================

  final TextEditingController _pluController = TextEditingController();

  // ==========================================================
  // QTY CTN CONTROLLER
  // ==========================================================
  //
  // Jumlah CTN aktual yang dimasukkan operator.
  //
  // Catatan:
  // Untuk sementara controller ini kita siapkan terlebih dahulu.
  // Perhitungan final akan kita tentukan pada tahap berikutnya.
  // ==========================================================

  final TextEditingController _qtyCtnController = TextEditingController();

  // ==========================================================
  // TEAR CONTROLLER
  // ==========================================================
  //
  // Tear aktual pallet.
  // ==========================================================

  final TextEditingController _tearController = TextEditingController();

  // ==========================================================
  // STACK CONTROLLER
  // ==========================================================
  //
  // Stack aktual pallet.
  // ==========================================================

  final TextEditingController _stackController = TextEditingController();

  // ==========================================================
  // EXPIRED DATE CONTROLLER
  // ==========================================================
  //
  // Menampilkan tanggal expired barang.
  // ==========================================================

  final TextEditingController _expiredDateController = TextEditingController();

  // ==========================================================
  // PRODUCT
  // ==========================================================
  //
  // Product hasil pencarian Master Barang berdasarkan PLU.
  //
  // null:
  // Belum ada barang yang ditemukan.
  // ==========================================================

  Product? _product;

  // ==========================================================
  // LOADING PRODUCT
  // ==========================================================
  //
  // true ketika aplikasi sedang mencari PLU
  // pada Master Barang.
  // ==========================================================

  bool _isSearching = false;
  // ==========================================================
  // ERROR MESSAGE
  // ==========================================================
  //
  // Menyimpan pesan error form.
  // ==========================================================

  String? _errorMessage;

  // ==========================================================
  // GET PRODUCT BY PLU
  // ==========================================================

  GetProductByPlu get getProductByPlu {
    return AppDependencies.instance.getProductByPlu;
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    _pluController.dispose();
    _qtyCtnController.dispose();
    _tearController.dispose();
    _stackController.dispose();
    _expiredDateController.dispose();

    super.dispose();
  }

  // ==========================================================
  // QUANTITY CHANGED
  // ==========================================================

  void _onQuantityChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  // ==========================================================
  // SEARCH PRODUCT
  // ==========================================================

  Future<void> _searchProduct() async {
    final plu = _pluController.text.trim();

    if (plu.isEmpty) {
      setState(() {
        _errorMessage = 'PLU wajib diisi.';
        _product = null;
      });

      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isSearching = true;
      _errorMessage = null;
      _product = null;
    });

    try {
      final product = await getProductByPlu(plu);

      if (!mounted) {
        return;
      }

      setState(() {
        _product = product;
        _isSearching = false;

        if (product == null) {
          _errorMessage = 'Barang dengan PLU $plu tidak ditemukan.';
        }
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSearching = false;
        _product = null;
        _errorMessage = 'Gagal mencari Master Barang.';
      });

      debugPrint('Put Away product search error: $error');
    }
  }

  // ==========================================================
  // INTEGER PARSER
  // ==========================================================

  int _parseInt(String value) {
    return int.tryParse(value.trim()) ?? 0;
  }

  // ==========================================================
  // TEAR
  // ==========================================================

  int get _tear {
    return _parseInt(_tearController.text);
  }

  // ==========================================================
  // STACK
  // ==========================================================

  int get _stack {
    return _parseInt(_stackController.text);
  }

  // ==========================================================
  // QTY CTN
  // ==========================================================
  //
  // Rumus:
  //
  // Tear × Stack
  //
  // Contoh:
  //
  // Tear  = 10
  // Stack = 5
  //
  // CTN = 10 × 5
  //     = 50
  // ==========================================================

  int get _qtyCtn {
    return _tear * _stack;
  }

  // ==========================================================
  // QTY PCS
  // ==========================================================
  //
  // Rumus:
  //
  // Qty CTN × Conv2
  // ==========================================================

  int get _qtyPcs {
    final product = _product;

    if (product == null) {
      return 0;
    }

    return _qtyCtn * product.conv2;
  }

  // ==========================================================
  // SESUAI MASTER
  // ==========================================================
  //
  // True:
  // Tear dan Stack sama dengan Master.
  //
  // False:
  // Salah satu berbeda.
  // ==========================================================

  bool get _sesuaiMaster {
    final product = _product;

    if (product == null) {
      return false;
    }

    return _tear == product.masterTear && _stack == product.masterStack;
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================================================
            // HEADER
            // ==================================================
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Put Away Pallet',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),

                IconButton(
                  tooltip: 'Tutup',
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),

            const SizedBox(height: 4),

            Text(
              'Lokasi tujuan: ${widget.location.code}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 24),

            // ==================================================
            // PLU
            // ==================================================
            Text(
              'PLU Barang',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _pluController,
                    textInputAction: TextInputAction.search,
                    keyboardType: TextInputType.number,
                    onSubmitted: (_) {
                      _searchProduct();
                    },
                    decoration: const InputDecoration(
                      labelText: 'Masukkan PLU',
                      hintText: 'Contoh: 5867',
                      prefixIcon: Icon(Icons.qr_code_2_rounded),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                SizedBox(
                  height: 56,
                  child: FilledButton(
                    onPressed: _isSearching ? null : _searchProduct,
                    child: _isSearching
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search_rounded),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ==================================================
            // ERROR
            // ==================================================
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.20)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.red),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // ==================================================
            // PRODUCT INFORMATION
            // ==================================================
            if (_product != null) ...[
              const SizedBox(height: 20),

              Text(
                'Master Barang',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 10),

              _PutAwayProductCard(product: _product!),

              const SizedBox(height: 20),

              // =================================================
              // TEAR
              // =================================================
              Text(
                'Tear Aktual',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: _tearController,
                keyboardType: TextInputType.number,
                onChanged: (_) {
                  _onQuantityChanged();
                },
                decoration: InputDecoration(
                  labelText: 'Tear',
                  hintText: 'Master: ${_product!.masterTear}',
                  prefixIcon: const Icon(Icons.layers_rounded),
                  border: const OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              // =================================================
              // STACK
              // =================================================
              Text(
                'Stack Aktual',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: _stackController,
                keyboardType: TextInputType.number,
                onChanged: (_) {
                  _onQuantityChanged();
                },

                decoration: InputDecoration(
                  labelText: 'Stack',
                  hintText: 'Master: ${_product!.masterStack}',
                  prefixIcon: const Icon(Icons.view_module_rounded),
                  border: const OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              // =================================================
              // QUANTITY RESULT
              // =================================================
              _PutAwayQuantityCard(
                qtyCtn: _qtyCtn,
                qtyPcs: _qtyPcs,
                conv2: _product!.conv2,
              ),

              const SizedBox(height: 16),

              // =================================================
              // MASTER COMPARISON
              // =================================================
              _PutAwayMasterStatusCard(
                sesuaiMaster: _sesuaiMaster,
                masterTear: _product!.masterTear,
                masterStack: _product!.masterStack,
                actualTear: _tear,
                actualStack: _stack,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PRODUCT CARD
// ============================================================

class _PutAwayProductCard extends StatelessWidget {
  const _PutAwayProductCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _InformationRow(
              icon: Icons.qr_code_rounded,
              title: 'Barcode',
              value: product.barcode,
            ),

            const Divider(height: 24),

            _InformationRow(
              icon: Icons.tag_rounded,
              title: 'PLU',
              value: product.plu,
            ),

            const Divider(height: 24),

            _InformationRow(
              icon: Icons.inventory_2_rounded,
              title: 'Description',
              value: product.description,
            ),

            const Divider(height: 24),

            _InformationRow(
              icon: Icons.swap_horiz_rounded,
              title: 'Conv2',
              value: product.conv2.toString(),
            ),

            const Divider(height: 24),

            _InformationRow(
              icon: Icons.layers_rounded,
              title: 'Master Tear',
              value: product.masterTear.toString(),
            ),

            const Divider(height: 24),

            _InformationRow(
              icon: Icons.view_module_rounded,
              title: 'Master Stack',
              value: product.masterStack.toString(),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// QUANTITY CARD
// ============================================================

class _PutAwayQuantityCard extends StatelessWidget {
  const _PutAwayQuantityCard({
    required this.qtyCtn,
    required this.qtyPcs,
    required this.conv2,
  });

  final int qtyCtn;
  final int qtyPcs;
  final int conv2;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Perhitungan Quantity',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _QuantityItem(
                    title: 'QTY CTN',
                    value: qtyCtn.toString(),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _QuantityItem(
                    title: 'QTY PCS',
                    value: qtyPcs.toString(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              'PCS = CTN × Conv2 ($conv2)',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// QUANTITY ITEM
// ============================================================

class _QuantityItem extends StatelessWidget {
  const _QuantityItem({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MASTER STATUS CARD
// ============================================================

class _PutAwayMasterStatusCard extends StatelessWidget {
  const _PutAwayMasterStatusCard({
    required this.sesuaiMaster,
    required this.masterTear,
    required this.masterStack,
    required this.actualTear,
    required this.actualStack,
  });

  final bool sesuaiMaster;
  final int masterTear;
  final int masterStack;
  final int actualTear;
  final int actualStack;

  @override
  Widget build(BuildContext context) {
    final Color color = sesuaiMaster ? Colors.green : Colors.orange;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(
              sesuaiMaster ? Icons.check_circle_rounded : Icons.warning_rounded,
              color: color,
              size: 32,
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sesuaiMaster ? 'Sesuai Master' : 'Berbeda dari Master',
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    'Master: Tear $masterTear × Stack $masterStack',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),

                  Text(
                    'Aktual: Tear $actualTear × Stack $actualStack',
                    style: Theme.of(context).textTheme.bodySmall,
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
