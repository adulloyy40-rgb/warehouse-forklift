import 'package:flutter/material.dart';

import '../../../core/di/app_dependencies.dart';
import '../../../domain/entities/product.dart';

class MasterItemEditPage extends StatefulWidget {
  final Product product;

  const MasterItemEditPage({super.key, required this.product});

  @override
  State<MasterItemEditPage> createState() => _MasterItemEditPageState();
}

class _MasterItemEditPageState extends State<MasterItemEditPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _barcodeController;
  late final TextEditingController _pluController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _returHariController;
  late final TextEditingController _conv2Controller;
  late final TextEditingController _typeController;
  late final TextEditingController _masterTearController;
  late final TextEditingController _masterStackController;

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    final product = widget.product;

    _barcodeController = TextEditingController(text: product.barcode);
    _pluController = TextEditingController(text: product.plu);
    _descriptionController = TextEditingController(text: product.description);
    _priceController = TextEditingController(text: product.price.toString());
    _returHariController = TextEditingController(
      text: product.returHari.toString(),
    );
    _conv2Controller = TextEditingController(text: product.conv2.toString());
    _typeController = TextEditingController(text: product.type);
    _masterTearController = TextEditingController(
      text: product.masterTear.toString(),
    );
    _masterStackController = TextEditingController(
      text: product.masterStack.toString(),
    );
  }

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

  Future<void> _save() async {
    if (_saving) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final product = Product(
      id: widget.product.id,
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
      await AppDependencies.instance.updateProduct(product);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Master Item berhasil diperbarui.')),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui Master Item: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
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

    if (decimal && number < 0) {
      return '$field tidak boleh negatif.';
    }

    if (!decimal && number < 0) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Master Item'),
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
                label: Text(_saving ? 'Menyimpan...' : 'Simpan Perubahan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final product = widget.product;
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
                Icons.edit_note_rounded,
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
                    'Edit Master Item',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'ID Database: ${product.id ?? '-'}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Perubahan akan disimpan ke SQLite.',
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

  Widget _buildIdentitySection() {
    return _buildSectionCard(
      title: 'Identitas Item',
      icon: Icons.badge_outlined,
      children: [
        TextFormField(
          controller: _barcodeController,
          keyboardType: TextInputType.number,
          decoration: _decoration(
            'Barcode',
            hint: 'Masukkan barcode',
            icon: Icons.qr_code_rounded,
          ),
          validator: (value) => _requiredText(value, 'Barcode'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _pluController,
          keyboardType: TextInputType.number,
          decoration: _decoration(
            'PLU',
            hint: 'Masukkan PLU',
            icon: Icons.tag_rounded,
          ),
          validator: (value) => _requiredText(value, 'PLU'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _descriptionController,
          textCapitalization: TextCapitalization.words,
          maxLines: 2,
          decoration: _decoration(
            'Description',
            hint: 'Nama/deskripsi barang',
            icon: Icons.inventory_2_outlined,
          ),
          validator: (value) => _requiredText(value, 'Description'),
        ),
      ],
    );
  }

  Widget _buildOperationalSection() {
    return _buildSectionCard(
      title: 'Data Operasional',
      icon: Icons.settings_outlined,
      children: [
        TextFormField(
          controller: _priceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: _decoration(
            'Price',
            hint: 'Contoh: 4216.94',
            icon: Icons.payments_outlined,
          ),
          validator: (value) => _requiredNumber(value, 'Price', decimal: true),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _returHariController,
          keyboardType: TextInputType.number,
          decoration: _decoration(
            'Retur Hari',
            hint: 'Jumlah hari retur',
            icon: Icons.event_available_outlined,
          ),
          validator: (value) => _requiredNumber(value, 'Retur Hari'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _conv2Controller,
          keyboardType: TextInputType.number,
          decoration: _decoration(
            'CONV2',
            hint: 'PCS per CTN',
            icon: Icons.swap_horiz_rounded,
          ),
          validator: (value) => _requiredNumber(value, 'CONV2'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _typeController,
          textCapitalization: TextCapitalization.characters,
          decoration: _decoration(
            'Type',
            hint: 'Contoh: FG / CTN / PCS',
            icon: Icons.category_outlined,
          ),
          validator: (value) => _requiredText(value, 'Type'),
        ),
      ],
    );
  }

  Widget _buildMasterSection() {
    return _buildSectionCard(
      title: 'Master Tear & Stack',
      icon: Icons.layers_outlined,
      children: [
        TextFormField(
          controller: _masterTearController,
          keyboardType: TextInputType.number,
          decoration: _decoration(
            'Master Tear',
            hint: 'Standar tear',
            icon: Icons.view_stream_outlined,
          ),
          validator: (value) => _requiredNumber(value, 'Master Tear'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _masterStackController,
          keyboardType: TextInputType.number,
          decoration: _decoration(
            'Master Stack',
            hint: 'Standar stack',
            icon: Icons.view_agenda_outlined,
          ),
          validator: (value) => _requiredNumber(value, 'Master Stack'),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
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
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}
