import 'package:flutter/material.dart';

import '../../../core/di/app_dependencies.dart';
import '../../../domain/entities/product.dart';
import 'master_item_edit_page.dart';

class MasterItemDetailPage extends StatefulWidget {
  final int productId;

  const MasterItemDetailPage({super.key, required this.productId});

  @override
  State<MasterItemDetailPage> createState() => _MasterItemDetailPageState();
}

class _MasterItemDetailPageState extends State<MasterItemDetailPage> {
  Product? _product;

  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final product = await AppDependencies.instance.getProductById(
        widget.productId,
      );

      if (!mounted) return;

      setState(() {
        _product = product;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _product = null;
        _loading = false;
        _errorMessage = 'Gagal memuat Master Item: $e';
      });
    }
  }

  Future<void> _refreshProduct() async {
    await _loadProduct();
  }

  Future<void> _editProduct() async {
    final product = _product;

    if (product == null) {
      return;
    }

    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => MasterItemEditPage(product: product)),
    );

    if (!mounted || updated != true) {
      return;
    }

    await _loadProduct();
  }

  Future<void> _deleteProduct() async {
    if (_product == null) return;

    final product = _product!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Master Item?'),
          content: Text(
            'Master Item "${product.description}" akan dihapus dari database.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    try {
      final deleted = await AppDependencies.instance.deleteProduct(product.id!);

      if (!mounted) return;

      if (!deleted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Master Item gagal dihapus atau sudah tidak tersedia.',
            ),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Master Item berhasil dihapus.')),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus Master Item: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Master Item'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _refreshProduct,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildErrorState(context);
    }

    final product = _product;

    if (product == null) {
      return _buildNotFoundState(context);
    }

    return RefreshIndicator(
      onRefresh: _refreshProduct,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _buildHeaderCard(context, product),
          const SizedBox(height: 12),
          _buildIdentityCard(context, product),
          const SizedBox(height: 12),
          _buildOperationalCard(context, product),
          const SizedBox(height: 12),
          _buildMasterReferenceCard(context, product),
          const SizedBox(height: 20),
          _buildActionButtons(context, product),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, Product product) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.inventory_2_rounded,
                size: 30,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.description.isEmpty
                        ? 'Tanpa Deskripsi'
                        : product.description,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'PLU ${product.plu.isEmpty ? '-' : product.plu}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.type.isEmpty ? 'Type tidak tersedia' : product.type,
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

  Widget _buildIdentityCard(BuildContext context, Product product) {
    return _buildSectionCard(
      context,
      title: 'Identitas Item',
      icon: Icons.badge_outlined,
      children: [
        _buildDetailRow(
          context,
          label: 'ID Database',
          value: product.id?.toString() ?? '-',
        ),
        _buildDetailRow(
          context,
          label: 'Barcode',
          value: product.barcode.isEmpty ? '-' : product.barcode,
        ),
        _buildDetailRow(
          context,
          label: 'PLU',
          value: product.plu.isEmpty ? '-' : product.plu,
        ),
        _buildDetailRow(
          context,
          label: 'Description',
          value: product.description.isEmpty ? '-' : product.description,
        ),
      ],
    );
  }

  Widget _buildOperationalCard(BuildContext context, Product product) {
    return _buildSectionCard(
      context,
      title: 'Informasi Operasional',
      icon: Icons.settings_outlined,
      children: [
        _buildDetailRow(
          context,
          label: 'Price',
          value: _formatPrice(product.price),
        ),
        _buildDetailRow(
          context,
          label: 'Retur Hari',
          value: '${product.returHari} hari',
        ),
        _buildDetailRow(
          context,
          label: 'CONV2',
          value: '${product.conv2} PCS / CTN',
        ),
        _buildDetailRow(
          context,
          label: 'Type',
          value: product.type.isEmpty ? '-' : product.type,
        ),
      ],
    );
  }

  Widget _buildMasterReferenceCard(BuildContext context, Product product) {
    return _buildSectionCard(
      context,
      title: 'Standar Master',
      icon: Icons.fact_check_outlined,
      children: [
        _buildDetailRow(
          context,
          label: 'Master Tear',
          value: product.masterTear.toString(),
        ),
        _buildDetailRow(
          context,
          label: 'Master Stack',
          value: product.masterStack.toString(),
        ),
      ],
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 4),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 12),
          const Text(':'),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: _editProduct,
          icon: const Icon(Icons.edit_rounded),
          label: const Text('Edit Master Item'),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: _deleteProduct,
          icon: const Icon(Icons.delete_outline_rounded),
          label: const Text('Hapus Master Item'),
        ),
      ],
    );
  }

  Widget _buildNotFoundState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Master Item Tidak Ditemukan',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Data dengan ID ${widget.productId} tidak tersedia di database.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loadProduct,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
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
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loadProduct,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double value) {
    final fixed = value.toStringAsFixed(2);
    final parts = fixed.split('.');

    final integerPart = parts[0];
    final decimalPart = parts[1];

    final buffer = StringBuffer();

    for (var i = 0; i < integerPart.length; i++) {
      final positionFromEnd = integerPart.length - i;

      buffer.write(integerPart[i]);

      if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
        buffer.write('.');
      }
    }

    return 'Rp ${buffer.toString()},$decimalPart';
  }
}
