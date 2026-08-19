import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/di/app_dependencies.dart';
import '../../../domain/entities/product.dart';

class ScanBarcodePage extends StatefulWidget {
  const ScanBarcodePage({super.key});

  @override
  State<ScanBarcodePage> createState() => _ScanBarcodePageState();
}

class _ScanBarcodePageState extends State<ScanBarcodePage> {
  final MobileScannerController _controller = MobileScannerController();

  final _productRepository = AppDependencies.instance.productRepository;

  Product? _product;
  String? _scannedBarcode;
  String? _errorMessage;
  bool _isSearching = false;
  bool _hasScanned = false;

  Future<void> _handleBarcode(String barcode) async {
    final normalizedBarcode = barcode.trim();

    if (normalizedBarcode.isEmpty || _isSearching || _hasScanned) {
      return;
    }

    setState(() {
      _hasScanned = true;
      _isSearching = true;
      _errorMessage = null;
      _product = null;
      _scannedBarcode = normalizedBarcode;
    });

    await _controller.stop();

    try {
      final product = await _productRepository.getProductByBarcode(
        normalizedBarcode,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _product = product;
        _isSearching = false;

        if (product == null) {
          _errorMessage = 'Barcode tidak ditemukan di Master Barang.';
        }
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSearching = false;
        _errorMessage = 'Gagal mencari barcode: $e';
      });
    }
  }

  Future<void> _scanAgain() async {
    setState(() {
      _product = null;
      _errorMessage = null;
      _scannedBarcode = null;
      _hasScanned = false;
      _isSearching = false;
    });

    await _controller.start();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Scan Barcode',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Flash',
            onPressed: () => _controller.toggleTorch(),
            icon: const Icon(Icons.flash_on_rounded),
          ),
          IconButton(
            tooltip: 'Ganti kamera',
            onPressed: () => _controller.switchCamera(),
            icon: const Icon(Icons.cameraswitch_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ScannerPreview(
                controller: _controller,
                onDetect: (capture) {
                  for (final barcode in capture.barcodes) {
                    final value = barcode.rawValue;

                    if (value != null && value.trim().isNotEmpty) {
                      _handleBarcode(value);
                      break;
                    }
                  }
                },
              ),

              const SizedBox(height: 18),

              if (_isSearching)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                        SizedBox(width: 14),
                        Expanded(
                          child: Text('Mencari informasi Master Barang...'),
                        ),
                      ],
                    ),
                  ),
                ),

              if (_errorMessage != null && !_isSearching)
                _ResultErrorCard(
                  barcode: _scannedBarcode,
                  message: _errorMessage!,
                  onScanAgain: _scanAgain,
                ),

              if (_product != null && !_isSearching)
                _ProductResultCard(
                  product: _product!,
                  scannedBarcode: _scannedBarcode ?? _product!.barcode,
                  onScanAgain: _scanAgain,
                ),

              if (!_hasScanned && !_isSearching)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Icon(Icons.qr_code_scanner_rounded),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text('Arahkan kamera ke barcode produk.'),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScannerPreview extends StatelessWidget {
  const _ScannerPreview({required this.controller, required this.onDetect});

  final MobileScannerController controller;
  final void Function(BarcodeCapture capture) onDetect;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 300,
        child: Stack(
          fit: StackFit.expand,
          children: [
            MobileScanner(controller: controller, onDetect: onDetect),
            IgnorePointer(
              child: Center(
                child: Container(
                  width: 260,
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 3),
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductResultCard extends StatelessWidget {
  const _ProductResultCard({
    required this.product,
    required this.scannedBarcode,
    required this.onScanAgain,
  });

  final Product product;
  final String scannedBarcode;
  final VoidCallback onScanAgain;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withValues(
                    alpha: 0.12,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Produk ditemukan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            _InfoRow(label: 'Barcode', value: scannedBarcode),
            _InfoRow(label: 'PLU', value: product.plu),
            _InfoRow(label: 'Nama Barang', value: product.description),
            _InfoRow(
              label: 'Harga',
              value: 'Rp ${product.price.toStringAsFixed(0)}',
            ),
            _InfoRow(label: 'Retur Hari', value: '${product.returHari} hari'),
            _InfoRow(label: 'CONV2', value: product.conv2.toString()),
            _InfoRow(label: 'Type', value: product.type),
            _InfoRow(
              label: 'Master Tear',
              value: product.masterTear.toString(),
            ),
            _InfoRow(
              label: 'Master Stack',
              value: product.masterStack.toString(),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onScanAgain,
                icon: const Icon(Icons.qr_code_scanner_rounded),
                label: const Text('Scan Lagi'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultErrorCard extends StatelessWidget {
  const _ResultErrorCard({
    required this.barcode,
    required this.message,
    required this.onScanAgain,
  });

  final String? barcode;
  final String message;
  final VoidCallback onScanAgain;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 34),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            if (barcode != null) ...[
              const SizedBox(height: 8),
              Text('Barcode: $barcode'),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onScanAgain,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Scan Lagi'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(value.isEmpty ? '-' : value)),
        ],
      ),
    );
  }
}
