import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/di/app_dependencies.dart';
import '../../../data/datasources/excel_data_source.dart';
import '../../../domain/usecases/import_master_item_to_database.dart';

class MasterItemImportPage extends StatefulWidget {
  const MasterItemImportPage({super.key});

  @override
  State<MasterItemImportPage> createState() => _MasterItemImportPageState();
}

class _MasterItemImportPageState extends State<MasterItemImportPage> {
  final ExcelDataSource _dataSource = ExcelDataSource();

  bool _loading = false;
  bool _importing = false;

  String? _fileName;
  String? _errorMessage;

  List<Map<String, dynamic>>? _rows;

  Future<void> _pickExcel() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
      _fileName = null;
      _rows = null;
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
        throw StateError('File Excel tidak dapat dibaca.');
      }

      final rows = await _dataSource.readMasterProductBytes(bytes);

      if (!mounted) return;

      setState(() {
        _fileName = file.name;
        _rows = rows;
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

    return message.replaceFirst('Bad state: ', '');
  }

  Future<void> _importToDatabase() async {
    final rows = _rows;

    if (rows == null || rows.isEmpty) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Import Master Barang'),
          content: Text(
            'Sebanyak ${rows.length} item akan dimasukkan ke database SQLite.\n\n'
            'Data Master Barang yang sudah ada tidak akan dihapus otomatis.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Batal'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
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
      _importing = true;
      _errorMessage = null;
    });

    try {
      final dependencies = AppDependencies.instance;

      final importer = dependencies.importMasterItemToDatabase;

      final result = await importer.execute(rows: rows);

      if (!mounted) return;

      setState(() {
        _importing = false;
      });

      await _showImportResult(result);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _importing = false;
        _errorMessage = 'Import Master Barang gagal: $e';
      });
    }
  }

  Future<void> _showImportResult(ImportMasterItemResult result) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                result.isSuccess
                    ? Icons.check_circle_outline
                    : Icons.warning_amber_rounded,
              ),
              const SizedBox(width: 10),
              const Expanded(child: Text('Hasil Import Master Barang')),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Berhasil: ${result.successCount} item'),
                const SizedBox(height: 6),
                Text('Gagal: ${result.failedCount} item'),
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
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
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
      _rows = null;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final rows = _rows;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Master Barang'),
        actions: [
          if (_fileName != null)
            IconButton(
              tooltip: 'Reset',
              onPressed: _importing ? null : _clearImport,
              icon: const Icon(Icons.refresh),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeader(context),
                const SizedBox(height: 16),
                _buildFileSelector(context),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  _buildErrorCard(context),
                ],
                if (rows != null) ...[
                  const SizedBox(height: 16),
                  _buildSummary(context, rows),
                  const SizedBox(height: 16),
                  _buildPreview(context, rows),
                  const SizedBox(height: 16),
                  _buildImportButton(context, rows),
                ],
              ],
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
                  Icons.inventory_2_outlined,
                  size: 30,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Import Master Barang',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Import data Master Barang dari file Excel '
              'ke database SQLite aplikasi.',
            ),
            const SizedBox(height: 12),
            const Text(
              'Format:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'BARCODE • PLU • PRICE • DESC • RETUR HARI • '
              'C2 • TYPE • STACK • TEAR',
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
              onPressed: _importing ? null : _pickExcel,
              icon: const Icon(Icons.upload_file_rounded),
              label: Text(
                _fileName == null
                    ? 'Pilih File Master Barang'
                    : 'Pilih File Lain',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(BuildContext context, List<Map<String, dynamic>> rows) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(
              Icons.dataset_outlined,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Data berhasil dibaca',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('${rows.length} item Master Barang'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(BuildContext context, List<Map<String, dynamic>> rows) {
    final previewRows = rows.take(10).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preview',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...previewRows.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final row = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(child: Text('$index')),
                  title: Text(row['description']?.toString() ?? ''),
                  subtitle: Text(
                    'PLU: ${row['plu']}  •  '
                    'Barcode: ${row['barcode']}',
                  ),
                ),
              );
            }),
            if (rows.length > 10)
              Text(
                'Menampilkan 10 dari ${rows.length} item.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImportButton(
    BuildContext context,
    List<Map<String, dynamic>> rows,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: _importing ? null : _importToDatabase,
          icon: _importing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save_alt_rounded),
          label: Text(
            _importing
                ? 'Mengimport...'
                : 'Import ${rows.length} Item ke Database',
          ),
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
}
