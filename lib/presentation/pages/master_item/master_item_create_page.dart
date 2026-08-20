import 'package:flutter/material.dart';

import '../../../core/di/app_dependencies.dart';
import '../../../domain/entities/product.dart';

class MasterItemCreatePage extends StatefulWidget {
  const MasterItemCreatePage({super.key});

  @override
  State<MasterItemCreatePage> createState() => _MasterItemCreatePageState();
}

class _MasterItemCreatePageState extends State<MasterItemCreatePage> {
  final _formKey = GlobalKey<FormState>();

  final _barcodeController = TextEditingController();
  final _pluController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController(text: '0');
  final _returHariController = TextEditingController(text: '0');
  final _conv2Controller = TextEditingController(text: '0');
  final _typeController = TextEditingController();
  final _masterTearController = TextEditingController(text: '0');
  final _masterStackController = TextEditingController(text: '0');

  bool _saving = false;

  @override
  void dispose() {
    _barcodeController.dispose();
    _pluController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _returHariController.dispose();
    _conv2Controller.dispose();
    _typeController.dispose();
    _masterTearController.dispose();
    _masterStackController.dispose();
    super.dispose();
  }

  String? _requiredText(String? value, String field) {
    if (value == null || value.trim().isEmpty) {
      return '$field wajib diisi.';
    }

    return null;
  }

  String? _requiredNumber(String? value, String field, {bool decimal = false}) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return '$field wajib diisi.';
    }

    final number = decimal ? double.tryParse(text) : int.tryParse(text);

    if (number == null) {
      return '$field harus berupa angka yang valid.';
    }

    if (number < 0) {
      return '$field tidak boleh negatif.';
    }

    return null;
  }

  InputDecoration _decoration(String label, {String? hint, IconData? icon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon == null ? null : Icon(icon),
      border: const OutlineInputBorder(),
    );
  }

  Future<void> _save() async {
    if (_saving) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final product = Product(
      barcode: _barcodeController.text.trim(),
      plu: _pluController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      returHari: int.parse(_returHariController.text.trim()),
      conv2: int.parse(_conv2Controller.text.trim()),
      type: _typeController.text.trim(),
      masterTear: int.parse(_masterTearController.text.trim()),
      masterStack: int.parse(_masterStackController.text.trim()),
    );

    setState(() {
      _saving = true;
    });

    try {
      await AppDependencies.instance.createProduct(product);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Master Item berhasil ditambahkan.')),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan Master Item: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Master Item'),
        actions: [
          IconButton(
            tooltip: 'Simpan',
            onPressed: _saving ? null : _save,
            icon: const Icon(Icons.save_rounded),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildIdentitySection(),
            const SizedBox(height: 12),
            _buildOperationalSection(),
            const SizedBox(height: 12),
            _buildMasterSection(),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(_saving ? 'Menyimpan...' : 'Simpan Master Item'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
                Icons.add_box_rounded,
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
                    'Tambah Master Item',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Masukkan data barang baru secara manual.',
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

  Widget _buildIdentitySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Identitas Barang',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _barcodeController,
              decoration: _decoration('Barcode', icon: Icons.qr_code_2_rounded),
              validator: (value) => _requiredText(value, 'Barcode'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _pluController,
              decoration: _decoration('PLU', icon: Icons.tag_rounded),
              validator: (value) => _requiredText(value, 'PLU'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: _decoration(
                'Deskripsi / Nama Barang',
                icon: Icons.inventory_2_outlined,
              ),
              validator: (value) =>
                  _requiredText(value, 'Deskripsi / Nama Barang'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationalSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data Operasional',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: _decoration('Harga', icon: Icons.payments_outlined),
              validator: (value) =>
                  _requiredNumber(value, 'Harga', decimal: true),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _returHariController,
              keyboardType: TextInputType.number,
              decoration: _decoration(
                'Retur Hari',
                icon: Icons.event_repeat_outlined,
              ),
              validator: (value) => _requiredNumber(value, 'Retur Hari'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _conv2Controller,
              keyboardType: TextInputType.number,
              decoration: _decoration(
                'CONV2',
                hint: 'Jumlah PCS dalam 1 CTN',
                icon: Icons.swap_horiz_rounded,
              ),
              validator: (value) => _requiredNumber(value, 'CONV2'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _typeController,
              decoration: _decoration('Type', icon: Icons.category_outlined),
              validator: (value) => _requiredText(value, 'Type'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMasterSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Master Tear & Stack',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _masterTearController,
              keyboardType: TextInputType.number,
              decoration: _decoration(
                'Master Tear',
                icon: Icons.layers_outlined,
              ),
              validator: (value) => _requiredNumber(value, 'Master Tear'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _masterStackController,
              keyboardType: TextInputType.number,
              decoration: _decoration(
                'Master Stack',
                icon: Icons.view_agenda_outlined,
              ),
              validator: (value) => _requiredNumber(value, 'Master Stack'),
            ),
          ],
        ),
      ),
    );
  }
}
