// ============================================================
// FILE:
// lib/presentation/pages/storage/storage_detail_page.dart
// ============================================================
//
// FUNGSI:
// Menampilkan detail satu lokasi storage.
//
// FITUR:
// 1. Menampilkan Location Code.
// 2. Menampilkan Rack, Bay, Shelving, Position.
// 3. Mengecek apakah lokasi AVAILABLE / OCCUPIED.
// 4. Menampilkan informasi pallet jika lokasi terisi.
// 5. PUT AWAY pallet ke lokasi yang masih AVAILABLE.
// 6. Mencari Master Item berdasarkan PLU.
// 7. Membandingkan Tear dan Stack aktual dengan Master Item.
// 8. Menghitung QTY CTN.
// 9. Menghitung QTY PCS.
// 10. Menyimpan pallet melalui PutAwayStockPallet.
// 11. Mengedit pallet melalui UpdateStockPallet.
//
// ============================================================

import 'package:flutter/material.dart';

import '../../../core/di/app_dependencies.dart';

import '../../../domain/entities/product.dart';
import '../../../domain/entities/stock_pallet.dart';
import '../../../domain/entities/storage_location.dart';

import '../../../domain/repositories/stock_pallet_repository.dart';

import '../../../domain/usecases/product/get_product_by_plu.dart';
import '../../../domain/usecases/stock_pallet/put_away_stock_pallet.dart';
import '../../../domain/usecases/stock_pallet/update_stock_pallet.dart';
import '../../../domain/usecases/stock_pallet/delete_stock_pallet.dart';

// ============================================================
// STORAGE DETAIL PAGE
// ============================================================

class StorageDetailPage extends StatefulWidget {
  const StorageDetailPage({
    super.key,
    required this.location,
    required this.stockPalletRepository,
  });

  // Lokasi storage yang sedang dibuka.
  final StorageLocation location;

  // Repository StockPallet.
  final StockPalletRepository stockPalletRepository;

  @override
  State<StorageDetailPage> createState() => _StorageDetailPageState();
}

// ============================================================
// STORAGE DETAIL STATE
// ============================================================

class _StorageDetailPageState extends State<StorageDetailPage> {
  // ==========================================================
  // DELETE STOCK PALLET
  // ==========================================================
  //
  // Use case untuk mengosongkan pallet dari lokasi storage.
  // Repository tetap menggunakan dependency yang sama.
  // ==========================================================

  DeleteStockPallet get deleteStockPallet =>
      AppDependencies.instance.deleteStockPallet;

  // Pallet yang menempati lokasi.
  //
  // null = lokasi AVAILABLE.
  StockPallet? _pallet;

  // Status loading.
  bool _isLoading = true;

  // Pesan error.
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _loadLocationData();
  }

  // ==========================================================
  // LOAD LOCATION DATA
  // ==========================================================

  Future<void> _loadLocationData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

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

      debugPrint('StorageDetailPage load error: $error');

      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat data lokasi.';
      });
    }
  }

  // ==========================================================
  // OPEN PUT AWAY
  // ==========================================================

  Future<void> _openPutAwayForm() async {
    // Lokasi OCCUPIED tidak boleh PUT AWAY.
    if (_pallet != null) {
      return;
    }

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

    // Jika berhasil simpan,
    // reload lokasi.
    if (result == true) {
      await _loadLocationData();
    }
  }

  // ==========================================================
  // OPEN EDIT PALLET
  // ==========================================================
  //
  // EDIT hanya tersedia jika lokasi sedang OCCUPIED.
  // Location Code tetap terkunci; operator hanya mengubah
  // data pallet yang memang boleh dikoreksi di lapangan.
  // ==========================================================

  // ==========================================================
  // CONFIRM DELETE / KOSONGKAN PALLET
  // ==========================================================
  //
  // Digunakan untuk mengosongkan lokasi yang sedang OCCUPIED.
  //
  // ALUR:
  //
  // Operator
  //    ↓
  // KOSONGKAN PALLET
  //    ↓
  // Dialog konfirmasi
  //    ↓
  // DeleteStockPallet
  //    ↓
  // SQLite
  //    ↓
  // Reload Storage Detail
  //    ↓
  // AVAILABLE
  //
  // Location Code tidak dapat dipilih oleh operator.
  // Sistem menggunakan location yang sedang dibuka.
  // ==========================================================

  Future<void> _confirmDeletePallet() async {
    final pallet = _pallet;

    // --------------------------------------------------------
    // Safety check:
    // Jika tidak ada pallet, tidak ada yang boleh dihapus.
    // --------------------------------------------------------

    if (pallet == null) {
      return;
    }

    // --------------------------------------------------------
    // Dialog konfirmasi.
    // --------------------------------------------------------

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Kosongkan Pallet?'),
          content: Text(
            'Pallet dengan PLU ${pallet.plu} '
            'akan dihapus dari lokasi ${widget.location.code}. '
            'Tindakan ini tidak dapat dibatalkan.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('BATAL'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('KOSONGKAN'),
            ),
          ],
        );
      },
    );

    // Operator membatalkan proses.
    if (confirmed != true) {
      return;
    }

    // --------------------------------------------------------
    // Jalankan proses delete.
    // --------------------------------------------------------

    try {
      await deleteStockPallet(widget.location.code);

      if (!mounted) {
        return;
      }

      // ------------------------------------------------------
      // Reload agar status berubah:
      //
      // OCCUPIED → AVAILABLE
      // ------------------------------------------------------

      await _loadLocationData();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pallet berhasil dikosongkan.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      debugPrint('StorageDetailPage delete pallet error: $error');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengosongkan pallet.')),
      );
    }
  }

  Future<void> _openEditPalletForm() async {
    final pallet = _pallet;

    if (pallet == null) {
      return;
    }

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return _EditPalletForm(
          location: widget.location,
          pallet: pallet,
          stockPalletRepository: widget.stockPalletRepository,
        );
      },
    );

    if (result == true) {
      await _loadLocationData();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('EDIT PALLET berhasil disimpan.')),
      );
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isOccupied = _pallet != null;

    return Scaffold(
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
                else if (isOccupied) ...[
                  _PalletInformationCard(pallet: _pallet!),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      // ==================================================
                      // EDIT PALLET
                      // ==================================================
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _openEditPalletForm,
                          icon: const Icon(Icons.edit_note_rounded),
                          label: const Text(
                            'EDIT PALLET',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // ==================================================
                      // KOSONGKAN PALLET
                      // ==================================================
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _confirmDeletePallet,
                          icon: const Icon(Icons.delete_outline_rounded),
                          label: const Text(
                            'KOSONGKAN',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
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

class _LocationHeader extends StatelessWidget {
  const _LocationHeader({required this.location, required this.isOccupied});

  final StorageLocation location;
  final bool isOccupied;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final statusColor = isOccupied ? Colors.orange : Colors.green;

    final statusText = isOccupied ? 'OCCUPIED' : 'AVAILABLE';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
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

  String _displayNullable(int? value) {
    return value?.toString() ?? '-';
  }
}

// ============================================================
// PALLET INFORMATION CARD
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
            _InformationRow(
              icon: Icons.location_on_outlined,
              title: 'Location Code',
              value: pallet.locationCode,
            ),

            const Divider(height: 24),

            _InformationRow(
              icon: Icons.qr_code_rounded,
              title: 'Barcode',
              value: pallet.barcode,
            ),

            const Divider(height: 24),

            _InformationRow(
              icon: Icons.tag_rounded,
              title: 'PLU',
              value: pallet.plu,
            ),

            const Divider(height: 24),

            _InformationRow(
              icon: Icons.inventory_2_outlined,
              title: 'Description',
              value: pallet.description,
            ),

            const Divider(height: 24),

            _InformationRow(
              icon: Icons.layers_outlined,
              title: 'Tear',
              value: pallet.tear.toString(),
            ),

            const Divider(height: 24),

            _InformationRow(
              icon: Icons.view_module_outlined,
              title: 'Stack',
              value: pallet.stack.toString(),
            ),

            const Divider(height: 24),

            _InformationRow(
              icon: Icons.inventory_rounded,
              title: 'QTY CTN',
              value: pallet.qtyCtn.toString(),
            ),

            const Divider(height: 24),

            _InformationRow(
              icon: Icons.numbers_rounded,
              title: 'QTY PCS',
              value: pallet.qtyPcs.toString(),
            ),

            const Divider(height: 24),

            _InformationRow(
              icon: Icons.calendar_today_outlined,
              title: 'Expired',
              value: _formatDate(pallet.expiredDate),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');

    final month = date.month.toString().padLeft(2, '0');

    final year = date.year.toString();

    return '$day/$month/$year';
  }
}

// ============================================================
// AVAILABLE CARD
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
    final description = isOccupied
        ? 'Lokasi ini sedang ditempati pallet.'
        : 'Lokasi ini siap digunakan untuk penyimpanan pallet.';

    final statusColor = isOccupied ? Colors.orange : Colors.green;

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
          ],
        ),
      ),
    );
  }
}

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
        Icon(icon, size: 22, color: theme.colorScheme.primary),

        const SizedBox(width: 14),

        Expanded(
          child: Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

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
// EDIT PALLET FORM
// ============================================================
//
// FUNGSI:
// Form khusus untuk mengedit pallet yang sudah menempati lokasi.
//
// ATURAN:
// - Location Code tidak dapat diubah.
// - PLU dapat diganti dan harus valid di Master Item.
// - Barcode, Description, Price, Conv2, dan Type mengikuti Master.
// - Tear dan Stack dapat dikoreksi sesuai kondisi lapangan.
// - Qty CTN dan Qty PCS dihitung otomatis.
// - Expired Date dapat dikoreksi.
// - Update menggunakan UpdateStockPallet.
// ============================================================

class _EditPalletForm extends StatefulWidget {
  const _EditPalletForm({
    required this.location,
    required this.pallet,
    required this.stockPalletRepository,
  });

  final StorageLocation location;
  final StockPallet pallet;
  final StockPalletRepository stockPalletRepository;

  @override
  State<_EditPalletForm> createState() => _EditPalletFormState();
}

class _EditPalletFormState extends State<_EditPalletForm> {
  final TextEditingController _pluController = TextEditingController();

  final TextEditingController _tearController = TextEditingController();

  final TextEditingController _stackController = TextEditingController();

  final TextEditingController _expiredDateController = TextEditingController();

  Product? _product;

  bool _isSearching = false;
  bool _isSaving = false;
  String? _errorMessage;

  GetProductByPlu get getProductByPlu =>
      AppDependencies.instance.getProductByPlu;

  UpdateStockPallet get updateStockPallet =>
      AppDependencies.instance.updateStockPallet;

  @override
  void initState() {
    super.initState();

    _pluController.text = widget.pallet.plu;
    _tearController.text = widget.pallet.tear.toString();
    _stackController.text = widget.pallet.stack.toString();
    _expiredDateController.text = _formatDate(widget.pallet.expiredDate);

    _tearController.addListener(_refresh);
    _stackController.addListener(_refresh);

    _loadInitialProduct();
  }

  Future<void> _loadInitialProduct() async {
    try {
      final product = await getProductByPlu(widget.pallet.plu);

      if (!mounted) {
        return;
      }

      setState(() {
        _product = product;

        if (product == null) {
          _errorMessage =
              'Master Item untuk PLU ${widget.pallet.plu} tidak ditemukan.';
        }
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      debugPrint('Edit pallet initial product error: $error');

      setState(() {
        _errorMessage = 'Gagal memuat Master Item.';
      });
    }
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  int _parseInt(String value) {
    return int.tryParse(value.trim()) ?? 0;
  }

  int get _tear => _parseInt(_tearController.text);

  int get _stack => _parseInt(_stackController.text);

  // ==========================================================
  // QTY CTN EDIT
  // ==========================================================
  //
  // Aturan:
  //
  // 1. Qty CTN hasil import adalah Qty fisik/lapangan.
  // 2. Jika Tear dan Stack belum diubah, pertahankan Qty CTN
  //    yang sudah tersimpan di database.
  // 3. Jika Tear atau Stack diubah, hitung ulang Qty CTN
  //    berdasarkan Tear × Stack baru.
  //
  // Contoh:
  //
  // Database:
  //   Qty CTN = 140
  //   Tear    = 12
  //   Stack   = 6
  //
  // Edit tanggal saja:
  //   Qty CTN tetap 140.
  //
  // Edit Tear/Stack:
  //   Tear dan Stack berubah sesuai kondisi aktual.
  //   Qty CTN tetap mengikuti quantity fisik pallet.
  //   Status kesesuaian Master dihitung ulang.
  // ==========================================================

  int get _qtyCtn {
    // Qty CTN adalah jumlah fisik aktual pallet.
    //
    // Tear dan Stack hanya digunakan untuk validasi
    // kesesuaian dengan Master Item.
    //
    // Mengubah Tear/Stack tidak otomatis mengubah
    // Qty CTN aktual.
    return widget.pallet.qtyCtn;
  }

  int get _qtyPcs {
    if (_product == null) {
      return 0;
    }

    return _qtyCtn * _product!.conv2;
  }

  bool get _sesuaiMaster {
    if (_product == null) {
      return false;
    }

    return _tear == _product!.masterTear && _stack == _product!.masterStack;
  }

  Future<void> _searchProduct() async {
    final plu = _pluController.text.trim();

    if (plu.isEmpty) {
      setState(() {
        _product = null;
        _errorMessage = 'PLU wajib diisi.';
      });
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    try {
      final product = await getProductByPlu(plu);

      if (!mounted) {
        return;
      }

      setState(() {
        _isSearching = false;
        _product = product;
        _errorMessage = product == null
            ? 'Barang dengan PLU $plu tidak ditemukan.'
            : null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      debugPrint('Edit pallet product search error: $error');

      setState(() {
        _isSearching = false;
        _product = null;
        _errorMessage = 'Gagal mencari Master Item.';
      });
    }
  }

  Future<void> _selectExpiredDate() async {
    final current = _getExpiredDate() ?? DateTime.now();

    final selected = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(current.year - 10),
      lastDate: DateTime(current.year + 20),
    );

    if (selected == null || !mounted) {
      return;
    }

    _expiredDateController.text = _formatDate(selected);

    setState(() {});
  }

  DateTime? _getExpiredDate() {
    final value = _expiredDateController.text.trim();

    if (value.isEmpty) {
      return null;
    }

    final parts = value.split('/');

    if (parts.length != 3) {
      return null;
    }

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) {
      return null;
    }

    final date = DateTime(year, month, day);

    // Mencegah tanggal seperti 31/02/2026
    // berubah diam-diam menjadi tanggal lain.
    if (date.year != year || date.month != month || date.day != day) {
      return null;
    }

    return date;
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  Future<void> _saveEdit() async {
    if (_product == null) {
      setState(() {
        _errorMessage = 'Master Item belum valid. Cari PLU terlebih dahulu.';
      });
      return;
    }

    if (_tear <= 0) {
      setState(() {
        _errorMessage = 'Tear harus lebih besar dari 0.';
      });
      return;
    }

    if (_stack <= 0) {
      setState(() {
        _errorMessage = 'Stack harus lebih besar dari 0.';
      });
      return;
    }

    final expiredDate = _getExpiredDate();

    if (expiredDate == null) {
      setState(() {
        _errorMessage = 'Tanggal expired tidak valid.';
      });
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final updatedPallet = StockPallet(
        locationCode: widget.pallet.locationCode,
        plu: _product!.plu,
        barcode: _product!.barcode,
        description: _product!.description,
        price: _product!.price,
        returHari: _product!.returHari,
        conv2: _product!.conv2,
        type: _product!.type,
        tear: _tear,
        stack: _stack,
        qtyCtn: _qtyCtn,
        qtyPcs: _qtyPcs,
        expiredDate: expiredDate,
        inputDate: widget.pallet.inputDate,
        operatorNik: widget.pallet.operatorNik,
        sesuaiMaster: _sesuaiMaster,
      );

      await updateStockPallet(updatedPallet);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      debugPrint('Edit pallet save error: $error');

      setState(() {
        _isSaving = false;
        _errorMessage = error is StateError
            ? error.message
            : error is ArgumentError
            ? error.message?.toString()
            : 'Gagal menyimpan perubahan pallet.';
      });
    }
  }

  @override
  void dispose() {
    _pluController.dispose();
    _tearController.dispose();
    _stackController.dispose();
    _expiredDateController.dispose();

    super.dispose();
  }

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
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Edit Pallet',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Tutup',
                  onPressed: _isSaving
                      ? null
                      : () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),

            Text(
              'Lokasi: ${widget.location.code}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 20),

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
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.search,
                    enabled: !_isSaving,
                    onSubmitted: (_) => _searchProduct(),
                    decoration: const InputDecoration(
                      labelText: 'PLU',
                      prefixIcon: Icon(Icons.tag_rounded),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 56,
                  child: FilledButton(
                    onPressed: _isSearching || _isSaving
                        ? null
                        : _searchProduct,
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

            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
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
            ],

            if (_product != null) ...[
              const SizedBox(height: 16),

              _PutAwayProductCard(product: _product!),

              const SizedBox(height: 16),

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
                enabled: !_isSaving,
                decoration: const InputDecoration(
                  labelText: 'Tear',
                  prefixIcon: Icon(Icons.layers_rounded),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

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
                enabled: !_isSaving,
                decoration: const InputDecoration(
                  labelText: 'Stack',
                  prefixIcon: Icon(Icons.view_module_rounded),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Tanggal Expired',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: _expiredDateController,
                readOnly: true,
                enabled: !_isSaving,
                onTap: _selectExpiredDate,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Expired',
                  prefixIcon: Icon(Icons.calendar_today_rounded),
                  suffixIcon: Icon(Icons.arrow_drop_down_rounded),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              _PutAwayQuantityCard(
                qtyCtn: _qtyCtn,
                qtyPcs: _qtyPcs,
                conv2: _product!.conv2,
              ),

              const SizedBox(height: 16),

              _PutAwayMasterStatusCard(
                sesuaiMaster: _sesuaiMaster,
                masterTear: _product!.masterTear,
                masterStack: _product!.masterStack,
                actualTear: _tear,
                actualStack: _stack,
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _saveEdit,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(
                    _isSaving ? 'MENYIMPAN...' : 'SIMPAN PERUBAHAN',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PUT AWAY FORM
// ============================================================

class _PutAwayForm extends StatefulWidget {
  const _PutAwayForm({
    required this.location,
    required this.stockPalletRepository,
  });

  final StorageLocation location;
  final StockPalletRepository stockPalletRepository;

  @override
  State<_PutAwayForm> createState() => _PutAwayFormState();
}
// ============================================================
// PUT AWAY FORM STATE
// ============================================================

class _PutAwayFormState extends State<_PutAwayForm> {
  // ==========================================================
  // CONTROLLERS
  // ==========================================================

  final TextEditingController _pluController = TextEditingController();

  final TextEditingController _tearController = TextEditingController();

  final TextEditingController _stackController = TextEditingController();

  final TextEditingController _expiredDateController = TextEditingController();

  // ==========================================================
  // PRODUCT
  // ==========================================================

  Product? _product;

  // ==========================================================
  // SEARCH STATUS
  // ==========================================================

  bool _isSearching = false;

  // ==========================================================
  // SAVE STATUS
  // ==========================================================

  bool _isSaving = false;

  // ==========================================================
  // ERROR
  // ==========================================================

  String? _errorMessage;

  // ==========================================================
  // GET PRODUCT USE CASE
  // ==========================================================

  GetProductByPlu get getProductByPlu {
    return AppDependencies.instance.getProductByPlu;
  }

  // ==========================================================
  // PUT AWAY USE CASE
  // ==========================================================

  PutAwayStockPallet get putAwayStockPallet {
    return AppDependencies.instance.putAwayStockPallet;
  }

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();

    // Listener untuk menghitung quantity secara realtime.
    _tearController.addListener(_refreshQuantity);

    _stackController.addListener(_refreshQuantity);
  }

  // ==========================================================
  // REFRESH QUANTITY
  // ==========================================================
  void _refreshQuantity() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    _pluController.dispose();
    _tearController.dispose();
    _stackController.dispose();
    _expiredDateController.dispose();

    super.dispose();
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

  int get _qtyCtn {
    return _tear * _stack;
  }
  // ==========================================================
  // QTY PCS
  // ==========================================================

  int get _qtyPcs {
    if (_product == null) {
      return 0;
    }

    return _qtyCtn * _product!.conv2;
  }

  // ==========================================================
  // MASTER MATCH
  // ==========================================================

  bool get _sesuaiMaster {
    if (_product == null) {
      return false;
    }

    return _tear == _product!.masterTear && _stack == _product!.masterStack;
  }

  // ==========================================================
  // SEARCH PRODUCT
  // ==========================================================

  Future<void> _searchProduct() async {
    final plu = _pluController.text.trim();

    if (plu.isEmpty) {
      setState(() {
        _product = null;
        _errorMessage = 'PLU wajib diisi.';
      });

      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isSearching = true;
      _product = null;
      _errorMessage = null;
    });

    try {
      final product = await getProductByPlu(plu);

      if (!mounted) {
        return;
      }

      setState(() {
        _isSearching = false;
        _product = product;

        if (product == null) {
          _errorMessage = 'Barang dengan PLU $plu tidak ditemukan.';
        }
      });

      // Isi Tear dan Stack menggunakan
      // nilai Master sebagai nilai awal.
      if (product != null) {
        _tearController.text = product.masterTear.toString();

        _stackController.text = product.masterStack.toString();
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      debugPrint('Search product error: $error');

      setState(() {
        _isSearching = false;
        _product = null;
        _errorMessage = 'Gagal mencari Master Item.';
      });
    }
  }

  // ==========================================================
  // SELECT EXPIRED DATE
  // ==========================================================
  Future<void> _selectExpiredDate() async {
    final now = DateTime.now();

    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 20),
      initialDate: now,
    );

    if (selected == null || !mounted) {
      return;
    }

    final day = selected.day.toString().padLeft(2, '0');

    final month = selected.month.toString().padLeft(2, '0');

    final year = selected.year.toString();

    _expiredDateController.text = '$day/$month/$year';

    setState(() {});
  }

  // ==========================================================
  // BUILD EXPIRED DATE
  // ==========================================================

  DateTime? _getExpiredDate() {
    final value = _expiredDateController.text.trim();

    if (value.isEmpty) {
      return null;
    }

    final parts = value.split('/');

    if (parts.length != 3) {
      return null;
    }

    final day = int.tryParse(parts[0]);

    final month = int.tryParse(parts[1]);

    final year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) {
      return null;
    }

    return DateTime(year, month, day);
  }

  // ==========================================================
  // SAVE PUT AWAY
  // ==========================================================

  Future<void> _savePutAway() async {
    // ----------------------------------------------------------
    // PRODUCT
    // ----------------------------------------------------------
    if (_product == null) {
      setState(() {
        _errorMessage = 'Cari barang berdasarkan PLU terlebih dahulu.';
      });

      return;
    }

    // ----------------------------------------------------------
    // VALIDATE TEAR
    // ----------------------------------------------------------

    if (_tear <= 0) {
      setState(() {
        _errorMessage = 'Tear harus lebih besar dari 0.';
      });

      return;
    }

    // ----------------------------------------------------------
    // VALIDATE STACK
    // ----------------------------------------------------------

    if (_stack <= 0) {
      setState(() {
        _errorMessage = 'Stack harus lebih besar dari 0.';
      });

      return;
    }

    // ----------------------------------------------------------
    // VALIDATE EXPIRED DATE
    // ----------------------------------------------------------

    final expiredDate = _getExpiredDate();

    if (expiredDate == null) {
      setState(() {
        _errorMessage = 'Tanggal expired wajib diisi.';
      });

      return;
    }

    // ----------------------------------------------------------
    // START SAVE
    // ----------------------------------------------------------

    FocusScope.of(context).unfocus();

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });
    try {
      // --------------------------------------------------------
      // BUAT STOCK PALLET DOMAIN ENTITY
      // --------------------------------------------------------

      final pallet = StockPallet(
        locationCode: widget.location.code,

        plu: _product!.plu,

        barcode: _product!.barcode,

        description: _product!.description,

        price: _product!.price,

        returHari: _product!.returHari,

        conv2: _product!.conv2,

        type: _product!.type,

        tear: _tear,

        stack: _stack,

        qtyCtn: _qtyCtn,

        qtyPcs: _qtyPcs,

        expiredDate: expiredDate,

        inputDate: DateTime.now(),

        // Operator NIK belum mempunyai
        // sistem login pada tahap ini.
        operatorNik: '',

        sesuaiMaster: _sesuaiMaster,
      );

      // --------------------------------------------------------
      // SIMPAN MELALUI USE CASE
      // --------------------------------------------------------

      await putAwayStockPallet(pallet);

      if (!mounted) {
        return;
      }

      // --------------------------------------------------------
      // TUTUP FORM DAN KIRIM STATUS BERHASIL
      // --------------------------------------------------------

      Navigator.of(context).pop(true);

      // --------------------------------------------------------
      // NOTIFICATION
      // --------------------------------------------------------

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PUT AWAY berhasil disimpan.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      debugPrint('Put Away save error: $error');

      setState(() {
        _isSaving = false;

        if (error is StateError) {
          _errorMessage = error.message;
        } else {
          _errorMessage = 'Gagal menyimpan PUT AWAY.';
        }
      });
    }
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
                  onPressed: _isSaving
                      ? null
                      : () {
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
                    enabled: !_isSaving,
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
                    onPressed: _isSearching || _isSaving
                        ? null
                        : _searchProduct,
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

            // ==================================================
            // ERROR
            // ==================================================
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),

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
            ],

            // ==================================================
            // PRODUCT
            // ==================================================
            if (_product != null) ...[
              const SizedBox(height: 20),

              Text(
                'Master Item',
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
                enabled: !_isSaving,
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
                enabled: !_isSaving,
                decoration: InputDecoration(
                  labelText: 'Stack',
                  hintText: 'Master: ${_product!.masterStack}',
                  prefixIcon: const Icon(Icons.view_module_rounded),
                  border: const OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              // =================================================
              // EXPIRED DATE
              // =================================================
              Text(
                'Tanggal Expired',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: _expiredDateController,
                readOnly: true,
                enabled: !_isSaving,
                onTap: _selectExpiredDate,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Expired',
                  hintText: 'DD/MM/YYYY',
                  prefixIcon: Icon(Icons.calendar_today_rounded),
                  suffixIcon: Icon(Icons.arrow_drop_down_rounded),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              // =================================================
              // QUANTITY
              // =================================================
              _PutAwayQuantityCard(
                qtyCtn: _qtyCtn,
                qtyPcs: _qtyPcs,
                conv2: _product!.conv2,
              ),

              const SizedBox(height: 16),

              // =================================================
              // MASTER STATUS
              // =================================================
              _PutAwayMasterStatusCard(
                sesuaiMaster: _sesuaiMaster,
                masterTear: _product!.masterTear,
                masterStack: _product!.masterStack,
                actualTear: _tear,
                actualStack: _stack,
              ),

              const SizedBox(height: 20),

              // =================================================
              // SAVE BUTTON
              // =================================================
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _savePutAway,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(
                    _isSaving ? 'MENYIMPAN...' : 'SIMPAN PUT AWAY',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PUT AWAY PRODUCT CARD
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
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Perhitungan Quantity',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
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
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
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
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
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
    final color = sesuaiMaster ? Colors.green : Colors.orange;

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
