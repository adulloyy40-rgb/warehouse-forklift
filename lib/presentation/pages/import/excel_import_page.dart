import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/di/app_dependencies.dart';

import '../../../data/datasources/stock_pallet_excel_data_source.dart';
import '../../../domain/usecases/import_stock_pallet.dart';
import '../../../domain/usecases/import_stock_pallet_to_database.dart';
import '../../../domain/validators/stock_pallet_import_validator.dart';

class ExcelImportPage extends StatefulWidget {
  const ExcelImportPage({super.key});

  @override
  State<ExcelImportPage> createState() => _ExcelImportPageState();
}

class _ExcelImportPageState extends State<ExcelImportPage> {
  final StockPalletExcelDataSource _dataSource = StockPalletExcelDataSource();

  final ImportStockPallet _importStockPallet = const ImportStockPallet(
    validator: StockPalletImportValidator(),
  );

  bool _loading = false;
  bool _importingDatabase = false;

  String? _fileName;

  ImportStockPalletResult? _result;

  String? _errorMessage;

  Future<void> _pickExcel() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
      _result = null;
      _fileName = null;
    });

    try {
      final picked = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (picked.isEmpty) {
        if (!mounted) return;

        setState(() {
          _loading = false;
        });

        return;
      }

      final file = picked.single;
      final bytes = await file.readAsBytes();

      if (bytes.isEmpty) {
        throw StateError(
          'File Excel tidak dapat dibaca.',
        );
      }

      final rows = _dataSource.read(bytes);

      final result = _importStockPallet.execute(rows);

      if (!mounted) return;

      setState(() {
        _fileName = file.name;
        _result = result;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _errorMessage = _friendlyErrorMessage(e);
      });
    }
  }

  String _friendlyErrorMessage(Object error) {
    final message = error.toString();

    if (message.contains('tidak memiliki worksheet')) {
      return 'File Excel tidak memiliki worksheet.';
    }

    if (message.contains('Kolom Excel tidak lengkap')) {
      return message.replaceFirst('Bad state: ', '');
    }

    if (message.contains('File Excel tidak dapat dibaca')) {
      return 'File Excel tidak dapat dibaca. Pastikan file tidak rusak.';
    }

    return message.replaceFirst('Bad state: ', '');
  }

  Future<void> _importToDatabase() async {
    final result = _result;

    if (result == null || result.validData.isEmpty) {
      return;
    }

    final operatorNikController = TextEditingController();

    final operatorNik = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Import ke Database'),
          content: TextField(
            controller: operatorNikController,
            autofocus: true,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'NIK Operator',
              hintText: 'Masukkan NIK operator',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                Navigator.of(dialogContext).pop(value.trim());
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                final value = operatorNikController.text.trim();

                if (value.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('NIK Operator wajib diisi.')),
                  );
                  return;
                }

                Navigator.of(dialogContext).pop(value);
              },
              child: const Text('Lanjutkan'),
            ),
          ],
        );
      },
    );

    operatorNikController.dispose();

    if (operatorNik == null || operatorNik.trim().isEmpty) {
      return;
    }

    if (!mounted) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Import'),
          content: Text(
            'Data valid yang akan dimasukkan ke database: '
            '${result.validCount} pallet.\n\n'
            'Data invalid tidak akan dimasukkan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              icon: const Icon(Icons.save_outlined),
              label: const Text('Import'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _importingDatabase = true;
      _errorMessage = null;
    });

    try {
      final dependencies = AppDependencies.instance;

      final importer = ImportStockPalletToDatabase(
        productRepository: dependencies.productRepository,
        stockPalletRepository: dependencies.stockPalletRepository,
      );

      final importResult = await importer.execute(
        rows: result.validData,
        operatorNik: operatorNik.trim(),
      );

      if (!mounted) return;

      setState(() {
        _importingDatabase = false;
      });

      await _showDatabaseImportResult(importResult);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _importingDatabase = false;
        _errorMessage = 'Import ke database gagal: ${e.toString()}';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Import ke database gagal: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showDatabaseImportResult(
    ImportStockPalletToDatabaseResult result,
  ) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                result.failedCount == 0
                    ? Icons.check_circle_outline
                    : Icons.warning_amber_rounded,
              ),
              const SizedBox(width: 10),
              const Expanded(child: Text('Hasil Import Database')),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Berhasil: ${result.successCount} pallet'),
                  const SizedBox(height: 6),
                  Text('Gagal: ${result.failedCount} pallet'),
                  if (result.errors.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Detail error:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...result.errors.map(
                      (error) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text('• $error'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Selesai'),
            ),
          ],
        );
      },
    );
  }

  void _clearImport() {
    setState(() {
      _fileName = null;
      _result = null;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Excel Import'),
        actions: [
          if (_fileName != null)
            IconButton(
              tooltip: 'Reset',
              onPressed: _loading ? null : _clearImport,
              icon: const Icon(Icons.refresh),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _pickExcel,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 16),
                  _buildFileSelector(context),
                  const SizedBox(height: 16),
                  if (result != null && result.validData.isNotEmpty)
                    _buildDatabaseImportButton(context, result),
                  if (_errorMessage != null) _buildErrorCard(context),
                  if (result != null) ...[
                    _buildSummary(context, result),
                    const SizedBox(height: 16),
                    _buildPreview(context, result),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildDatabaseImportButton(
    BuildContext context,
    ImportStockPalletResult result,
  ) {
    final isImporting = _importingDatabase;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.storage_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Import ke Database',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${result.validCount} data valid siap dimasukkan ke database.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: isImporting ? null : _importToDatabase,
              icon: isImporting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_alt_rounded),
              label: Text(
                isImporting
                    ? 'Sedang Mengimport...'
                    : 'Import ${result.validCount} Data ke Database',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.table_view_rounded,
                  size: 30,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Import Stock Pallet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Pilih file Excel Stock Pallet untuk membaca dan '
              'memvalidasi data sebelum dimasukkan ke sistem.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            const Text(
              'Format kolom:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'LOKASI • PLU • DESC • CONV2 • QTY SO • '
              'STACK • TEAR AKTUAL • EXP DATE',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileSelector(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_fileName != null) ...[
              Row(
                children: [
                  const Icon(Icons.description_outlined),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _fileName!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
            ],
            FilledButton.icon(
              onPressed: _pickExcel,
              icon: const Icon(Icons.upload_file_rounded),
              label: Text(
                _fileName == null ? 'Pilih File Excel' : 'Pilih File Lain',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(BuildContext context, ImportStockPalletResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hasil Validasi',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                context,
                title: 'TOTAL',
                value: result.total,
                icon: Icons.dataset_outlined,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _summaryCard(
                context,
                title: 'VALID',
                value: result.validCount,
                icon: Icons.check_circle_outline,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _summaryCard(
                context,
                title: 'INVALID',
                value: result.invalidCount,
                icon: Icons.error_outline,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _summaryCard(
    BuildContext context, {
    required String title,
    required int value,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon),
            const SizedBox(height: 6),
            Text(
              '$value',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(title, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(BuildContext context, ImportStockPalletResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preview Data',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        if (result.validData.isNotEmpty)
          _buildDataSection(
            context,
            title: 'Data Valid',
            icon: Icons.check_circle_outline,
            data: result.validData,
            valid: true,
          ),

        if (result.invalidData.isNotEmpty)
          _buildDataSection(
            context,
            title: 'Data Invalid',
            icon: Icons.warning_amber_rounded,
            data: result.invalidData,
            valid: false,
          ),

        if (result.total == 0)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Center(
                child: Text(
                  'Tidak ada data pallet pada file Excel.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDataSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Map<String, dynamic>> data,
    required bool valid,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text('${data.length} baris'),
        children: [
          const Divider(height: 1),
          ...List.generate(data.length, (index) {
            final row = data[index];

            return _buildRowPreview(context, index + 1, row, valid);
          }),
        ],
      ),
    );
  }

  Widget _buildRowPreview(
    BuildContext context,
    int index,
    Map<String, dynamic> row,
    bool valid,
  ) {
    final location = row['lokasi']?.toString() ?? '-';
    final plu = row['plu']?.toString() ?? '-';
    final description = row['desc']?.toString() ?? '-';
    final tear = row['tear_aktual']?.toString() ?? '-';
    final stack = row['stack']?.toString() ?? '-';
    final expDate = row['exp_date']?.toString() ?? '-';

    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 16,
        child: Text('$index', style: const TextStyle(fontSize: 12)),
      ),
      title: Text(
        '$location  •  PLU $plu',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          '$description\n'
          'Tear: $tear  •  Stack: $stack\n'
          'Exp: $expDate',
        ),
      ),
      isThreeLine: true,
      trailing: Icon(valid ? Icons.check_circle : Icons.error_outline),
    );
  }
}
