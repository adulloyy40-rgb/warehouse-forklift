import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    if (normalizedBarcode.isEmpty || _hasScanned || _isSearching) {
      return;
    }

    setState(() {
      _hasScanned = true;
      _isSearching = true;
      _product = null;
      _errorMessage = null;
      _scannedBarcode = normalizedBarcode;
    });

    await _controller.stop();

    await HapticFeedback.mediumImpact();

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
          _errorMessage =
              'Barcode berhasil terbaca, tetapi tidak ditemukan di Master Item.';
        }
      });

      if (product != null) {
        await HapticFeedback.heavyImpact();
      } else {
        await HapticFeedback.vibrate();
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSearching = false;
        _errorMessage = 'Gagal mencari barcode di Master Item.';
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
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: _controller,
            builder: (context, state, child) {
              return IconButton(
                tooltip: state.torchState == TorchState.on
                    ? 'Matikan flashlight'
                    : 'Nyalakan flashlight',
                onPressed: () => _controller.toggleTorch(),
                icon: Icon(
                  state.torchState == TorchState.on
                      ? Icons.flash_on_rounded
                      : Icons.flash_off_rounded,
                ),
              );
            },
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

              const SizedBox(height: 14),

              _ScannerStatus(
                hasScanned: _hasScanned,
                isSearching: _isSearching,
              ),

              const SizedBox(height: 18),

              if (_scannedBarcode != null)
                _ScannedBarcodeCard(barcode: _scannedBarcode!),

              if (_isSearching) ...[
                const SizedBox(height: 12),
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
                          child: Text(
                            'Mencari informasi Master Item...',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              if (_errorMessage != null && !_isSearching) ...[
                const SizedBox(height: 12),
                _ResultErrorCard(
                  barcode: _scannedBarcode,
                  message: _errorMessage!,
                  onScanAgain: _scanAgain,
                ),
              ],

              if (_product != null && !_isSearching) ...[
                const SizedBox(height: 12),
                _ProductResultCard(
                  product: _product!,
                  scannedBarcode: _scannedBarcode ?? _product!.barcode,
                  onScanAgain: _scanAgain,
                ),
              ],

              if (!_hasScanned && !_isSearching) ...[
                const SizedBox(height: 12),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Icon(Icons.qr_code_scanner_rounded, size: 28),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Arahkan kamera ke barcode barang. '
                            'Pastikan barcode terlihat jelas dan fokus.',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
        height: 320,
        child: Stack(
          fit: StackFit.expand,
          children: [
            MobileScanner(
              controller: controller,
              fit: BoxFit.cover,
              onDetect: onDetect,
            ),
            const _ScannerOverlay(),
          ],
        ),
      ),
    );
  }
}

class _ScannerOverlay extends StatelessWidget {
  const _ScannerOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.18),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 280,
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 18,
            child: Text(
              'Posisikan barcode di dalam kotak',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                shadows: [Shadow(blurRadius: 4, offset: Offset(0, 1))],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerStatus extends StatelessWidget {
  const _ScannerStatus({required this.hasScanned, required this.isSearching});

  final bool hasScanned;
  final bool isSearching;

  @override
  Widget build(BuildContext context) {
    if (isSearching) {
      return const _StatusCard(
        icon: Icons.search_rounded,
        text: 'Barcode terbaca. Sedang mencari Master Item...',
      );
    }

    if (hasScanned) {
      return const _StatusCard(
        icon: Icons.check_circle_outline_rounded,
        text: 'Scan berhasil. Kamera dihentikan sementara.',
      );
    }

    return const _StatusCard(
      icon: Icons.center_focus_strong_rounded,
      text: 'Siap scan barcode',
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScannedBarcodeCard extends StatelessWidget {
  const _ScannedBarcodeCard({required this.barcode});

  final String barcode;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Barcode Terbaca',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            SelectableText(
              barcode,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
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
              SelectableText('Barcode: $barcode'),
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
