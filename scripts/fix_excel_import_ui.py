from pathlib import Path

path = Path("lib/presentation/pages/import/excel_import_page.dart")
text = path.read_text()

# ------------------------------------------------------------
# 1. Tambahkan mounted guard setelah dialog NIK selesai.
# ------------------------------------------------------------

old = """    operatorNikController.dispose();

    if (operatorNik == null || operatorNik.trim().isEmpty) {
      return;
    }

    final confirmed = await showDialog<bool>(
"""

new = """    operatorNikController.dispose();

    if (operatorNik == null || operatorNik.trim().isEmpty) {
      return;
    }

    if (!mounted) {
      return;
    }

    final confirmed = await showDialog<bool>(
"""

if old in text and new not in text:
    text = text.replace(old, new, 1)

# ------------------------------------------------------------
# 2. Tambahkan method _buildDatabaseImportButton()
#    sebelum _buildHeader().
# ------------------------------------------------------------

marker = """  Widget _buildHeader(BuildContext context) {
"""

method = r'''  Widget _buildDatabaseImportButton(
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
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
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
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
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

'''

if "_buildDatabaseImportButton(" not in text:
    raise SystemExit(
        "ERROR: Pemanggilan _buildDatabaseImportButton tidak ditemukan."
    )

if method.strip() not in text:
    if marker not in text:
        raise SystemExit(
            "ERROR: Posisi _buildHeader tidak ditemukan."
        )

    text = text.replace(marker, method + marker, 1)

path.write_text(text)

print("PATCH BERHASIL")
print(f"File diperbaiki: {path}")
print("- Menambahkan tombol Import ke Database")
print("- Menambahkan loading state pada tombol")
print("- Menambahkan mounted guard")
