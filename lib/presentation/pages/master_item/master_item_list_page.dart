import 'package:flutter/material.dart';

import '../../../core/di/app_dependencies.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/repositories/product_repository.dart';
import '../import/master_item_import_page.dart';
import 'master_item_create_page.dart';
import 'master_item_detail_page.dart';

class MasterItemListPage extends StatefulWidget {
  const MasterItemListPage({super.key});

  @override
  State<MasterItemListPage> createState() => _MasterItemListPageState();
}

class _MasterItemListPageState extends State<MasterItemListPage> {
  late final ProductRepository _repository;

  final TextEditingController _searchController = TextEditingController();

  List<Product> _items = [];

  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _repository = AppDependencies.instance.productRepository;

    _loadItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final items = await _repository.getAllProducts();

      if (!mounted) return;

      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _errorMessage = 'Gagal memuat Master Item: $e';
      });
    }
  }

  Future<void> _searchItems(String query) async {
    try {
      final items = await _repository.searchProducts(query);

      if (!mounted) return;

      setState(() {
        _items = items;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Gagal mencari Master Item: $e';
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _loadItems();
  }

  Future<void> _openCreateMasterItem() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const MasterItemCreatePage()),
    );

    if (!mounted) return;

    if (created == true) {
      await _loadItems();
    }
  }

  Future<void> _openImportMasterItem() async {
    final imported = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const MasterItemImportPage()),
    );

    if (!mounted) return;

    if (imported == true) {
      await _loadItems();
    }
  }

  Future<void> _openDetail(Product item) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => MasterItemDetailPage(productId: item.id!),
      ),
    );

    if (!mounted) return;

    if (changed == true) {
      await _loadItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Master Item'),
        actions: [
          IconButton(
            tooltip: 'Tambah Master Item',
            onPressed: _loading ? null : _openCreateMasterItem,
            icon: const Icon(Icons.add_box_rounded),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _loadItems,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchSection(context),
          Expanded(child: _buildContent(context, theme)),
        ],
      ),
    );
  }

  Widget _buildSearchSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onSubmitted: _searchItems,
        decoration: InputDecoration(
          labelText: 'Cari Master Item',
          hintText: 'PLU, barcode, atau nama item',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _searchController.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Hapus pencarian',
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.clear_rounded),
                ),
          border: const OutlineInputBorder(),
        ),
        onChanged: (_) {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, ThemeData theme) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildErrorState(context);
    }

    if (_items.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: _loadItems,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: _items.length + 1,
        separatorBuilder: (_, index) {
          if (index == 0) {
            return const SizedBox(height: 8);
          }

          return const SizedBox(height: 8);
        },
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildSummaryCard(context);
          }

          final item = _items[index - 1];

          return _buildItemCard(context, item);
        },
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.inventory_2_rounded,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Master Item',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_items.length} item tersedia',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, Product item) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openDetail(item),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.inventory_2_outlined,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 12),
              _buildInfoRow(context, label: 'PLU', value: item.plu),
              const SizedBox(height: 6),
              _buildInfoRow(context, label: 'Barcode', value: item.barcode),
              const SizedBox(height: 6),
              _buildInfoRow(
                context,
                label: 'Type',
                value: item.type.isEmpty ? '-' : item.type,
              ),
              const SizedBox(height: 6),
              _buildInfoRow(
                context,
                label: 'CONV2',
                value: '${item.conv2} PCS / CTN',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        const Text(':  '),
        Expanded(
          child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final query = _searchController.text.trim();
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              query.isEmpty
                  ? Icons.inventory_2_outlined
                  : Icons.search_off_rounded,
              size: 64,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              query.isEmpty
                  ? 'Belum ada Master Item'
                  : 'Master Item tidak ditemukan',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              query.isEmpty
                  ? 'Silakan import data Master Item terlebih dahulu.'
                  : 'Coba gunakan PLU, barcode, atau nama item yang lain.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (query.isEmpty)
              FilledButton.icon(
                onPressed: _loading ? null : _openImportMasterItem,
                icon: const Icon(Icons.upload_file_rounded),
                label: const Text('Import Master Item'),
              )
            else
              OutlinedButton.icon(
                onPressed: _clearSearch,
                icon: const Icon(Icons.clear_rounded),
                label: const Text('Hapus Pencarian'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal Memuat Master Item',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loadItems,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
