import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/di/app_dependencies.dart';
import '../../../domain/entities/stock_pallet.dart';
import '../../../domain/services/pallet_status_calculator.dart';

class SearchStockPalletPage extends StatefulWidget {
  const SearchStockPalletPage({super.key});

  @override
  State<SearchStockPalletPage> createState() => _SearchStockPalletPageState();
}

class _SearchStockPalletPageState extends State<SearchStockPalletPage> {
  final _dependencies = AppDependencies.instance;
  final _searchController = TextEditingController();

  List<StockPallet> _results = [];

  bool _isLoading = false;
  bool _hasSearched = false;
  String? _errorMessage;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();

    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();

    final query = _searchController.text.trim();

    if (query.isEmpty) {
      if (!mounted) {
        return;
      }

      setState(() {
        _results = [];
        _hasSearched = false;
        _errorMessage = null;
        _isLoading = false;
      });

      return;
    }

    _debounce = Timer(
      const Duration(milliseconds: 350),
      () => _search(query),
    );
  }

  Future<void> _search(String query) async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _hasSearched = true;
    });

    try {
      final results =
          await _dependencies.searchStockPallets(query);

      if (!mounted) {
        return;
      }

      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _results = [];
        _isLoading = false;
        _errorMessage = 'Gagal mencari data pallet: $error';
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Stock Pallet'),
      ),
      body: Column(
        children: [
          _buildSearchSection(),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          labelText: 'Cari barang',
          hintText: 'PLU / Barcode / Nama Barang',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Hapus pencarian',
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.clear),
                ),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (!_hasSearched) {
      return _buildInitialState();
    }

    if (_results.isEmpty) {
      return _buildEmptyState();
    }

    return _buildResults();
  }

  Widget _buildInitialState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'Cari Stock Pallet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Masukkan PLU, Barcode, atau nama barang untuk '
              'melihat seluruh lokasi pallet.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'Data tidak ditemukan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tidak ada pallet yang cocok dengan pencarian.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 56,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                final query = _searchController.text.trim();

                if (query.isNotEmpty) {
                  _search(query);
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    final first = _results.first;

    return Column(
      children: [
        _buildSummaryHeader(first),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: _results.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              return _buildPalletCard(_results[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryHeader(StockPallet pallet) {
    final totalCtn = _results.fold<int>(
      0,
      (total, item) => total + item.qtyCtn,
    );

    final totalPcs = _results.fold<int>(
      0,
      (total, item) => total + item.qtyPcs,
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pallet.description,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text('PLU: ${pallet.plu}'),
          Text('Barcode: ${pallet.barcode}'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _summaryItem(
                  'Lokasi',
                  '${_results.length}',
                ),
              ),
              Expanded(
                child: _summaryItem(
                  'Total CTN',
                  '$totalCtn',
                ),
              ),
              Expanded(
                child: _summaryItem(
                  'Total PCS',
                  '$totalPcs',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPalletCard(StockPallet pallet) {
    final status = _calculateStatus(pallet);

    return Card(
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    pallet.description,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusIndicator(status),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'PLU: ${pallet.plu}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Barcode: ${pallet.barcode}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Divider(height: 24),
            _infoRow(
              'Lokasi',
              pallet.locationCode,
            ),
            _infoRow(
              'Qty CTN',
              '${pallet.qtyCtn}',
            ),
            _infoRow(
              'Qty PCS',
              '${pallet.qtyPcs}',
            ),
            _infoRow(
              'Expired',
              _formatDate(pallet.expiredDate),
            ),
            _infoRow(
              'Status',
              _statusLabel(status),
            ),
            _infoRow(
              'Input',
              _formatDateTime(pallet.inputDate),
            ),
            if (!pallet.sesuaiMaster)
              _buildMismatchWarning(pallet),
          ],
        ),
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'expired':
        return 'EXPIRED';
      case 'nearReturn':
      case 'near_return':
        return 'NEAR RETURN';
      default:
        return 'NORMAL';
    }
  }

  Widget _infoRow(
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMismatchWarning(StockPallet pallet) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.orange.withValues(alpha: 0.12),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Tear / Stack tidak sesuai Master Barang.',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _calculateStatus(StockPallet pallet) {
    final result = const PalletStatusCalculator().calculate(
      pallet,
    );

    return result.expiryStatus.name;
  }

  Widget _buildStatusIndicator(String status) {
    switch (status) {
      case 'expired':
        return _statusBadge(
          'EXPIRED',
          Colors.red,
          Icons.error,
        );

      case 'nearReturn':
      case 'near_return':
        return _statusBadge(
          'NEAR RETURN',
          Colors.deepPurple,
          Icons.schedule,
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _statusBadge(
    String text,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/${date.year} $hour:$minute';
  }
}
