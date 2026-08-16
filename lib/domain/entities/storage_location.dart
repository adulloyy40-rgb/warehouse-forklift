// ============================================================
// FILE:
// lib/domain/entities/storage_location.dart
// ============================================================
//
// FUNGSI:
// Entity untuk menyimpan identitas sebuah lokasi storage.
//
// Entity ini belum bertugas melakukan validasi.
// Validasi akan kita buat terpisah pada:
//
// location_validator.dart
//
// Tujuannya agar struktur data dan aturan bisnis tidak
// bercampur.
// ============================================================

class StorageLocation {
  // ==========================================================
  // rack
  // ==========================================================
  //
  // Nomor rack.
  //
  // Contoh:
  // 80
  // 81
  // ...
  // 96
  // ==========================================================

  final int rack;

  // ==========================================================
  // bay
  // ==========================================================
  //
  // Nomor Bay.
  //
  // Contoh:
  // BAY 01
  // BAY 02
  // ==========================================================

  final int bay;

  // ==========================================================
  // shelving
  // ==========================================================
  //
  // Nomor shelving.
  //
  // Untuk rack tertentu, field ini dapat digunakan untuk
  // membedakan kelompok shelving.
  //
  // Contoh:
  // Shelving 02
  // Shelving 03
  // ==========================================================

  final int? shelving;

  // ==========================================================
  // level
  // ==========================================================
  //
  // Level posisi barang.
  //
  // Contoh:
  // LEVEL 01
  // LEVEL 02
  // ...
  // LEVEL 06
  //
  // Nullable karena tidak semua jenis layout menggunakan
  // istilah Level dengan cara yang sama.
  // ==========================================================

  // ==========================================================
  // position
  // ==========================================================
  //
  // Posisi pallet pada sebuah level/shelving.
  //
  // Contoh:
  // POS 01
  // POS 02
  // POS 03
  // ==========================================================

  final int? position;

  // ==========================================================
  // code
  // ==========================================================
  //
  // Kode lokasi final yang digunakan sistem.
  //
  // Contoh:
  //
  // 8001101
  // 8001102
  // 8001103
  //
  // Untuk sementara kode diterima dari luar.
  // Generator kode akan kita hubungkan pada tahap berikutnya.
  // ==========================================================

  final String code;

  // ==========================================================
  // CONSTRUCTOR
  // ==========================================================

  const StorageLocation({
    required this.rack,
    required this.bay,
    this.shelving,
    this.position,
    required this.code,
  });

  // ==========================================================
  // copyWith()
  // ==========================================================
  //
  // Fungsi:
  // Membuat salinan object dengan perubahan field tertentu.
  //
  // Berguna nanti ketika data storage diperbarui.
  // ==========================================================

  StorageLocation copyWith({
    int? rack,
    int? bay,
    int? shelving,
    int? position,
    String? code,
  }) {
    return StorageLocation(
      rack: rack ?? this.rack,
      bay: bay ?? this.bay,
      shelving: shelving ?? this.shelving,

      position: position ?? this.position,
      code: code ?? this.code,
    );
  }

  // ==========================================================
  // toString()
  // ==========================================================
  //
  // Fungsi:
  // Mempermudah debugging ketika kita melihat object
  // StorageLocation di terminal.
  // ==========================================================

  @override
  String toString() {
    return 'StorageLocation('
        'rack: $rack, '
        'bay: $bay, '
        'shelving: $shelving, '
        'position: $position, '
        'code: $code'
        ')';
  }
}
