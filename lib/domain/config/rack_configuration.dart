// ============================================================
// FILE:
// lib/domain/config/rack_configuration.dart
// ============================================================
//
// FUNGSI:
// Menyimpan seluruh aturan/layout Rack gudang secara terpusat.
//
// FILE INI:
// - Tidak membaca Excel.
// - Tidak membaca database.
// - Tidak melakukan import data.
// - Tidak melakukan penyimpanan data.
//
// FILE INI HANYA MENYIMPAN ATURAN LAYOUT.
//
// Validator akan menggunakan konfigurasi ini untuk menentukan
// apakah sebuah lokasi diperbolehkan atau tidak.
// ============================================================


// ============================================================
// CLASS: RackConfiguration
// ============================================================
//
// Mewakili konfigurasi satu Rack atau satu kelompok Rack.
// ============================================================

class RackConfiguration {
  // ==========================================================
  // NOMOR RACK
  // ==========================================================

  final int rack;


  // ==========================================================
  // JUMLAH BAY
  // ==========================================================
  //
  // Contoh:
  //
  // Rack 80:
  // Bay 01–07
  //
  // berarti bayCount = 7.
  // ==========================================================

  final int bayCount;


  // ==========================================================
  // SHELVING MINIMUM
  // ==========================================================
  //
  // Nullable karena tidak semua Rack menggunakan Shelving.
  // ==========================================================

  final int? minShelving;


  // ==========================================================
  // SHELVING MAKSIMUM
  // ==========================================================

  final int? maxShelving;


  // ==========================================================
  // JUMLAH POSITION
  // ==========================================================
  //
  // Contoh:
  //
  // Shelving 02
  //   Position 01
  //   Position 02
  //   Position 03
  //
  // berarti positionCount = 3.
  // ==========================================================

  final int? positionCount;


  // ==========================================================
  // CONSTRUCTOR
  // ==========================================================

  const RackConfiguration({
    required this.rack,
    required this.bayCount,
    this.minShelving,
    this.maxShelving,
    this.positionCount,
  });


  // ==========================================================
  // hasShelving
  // ==========================================================
  //
  // Menentukan apakah Rack menggunakan sistem Shelving.
  // ==========================================================

  bool get hasShelving {
    return minShelving != null &&
        maxShelving != null &&
        positionCount != null;
  }


  // ==========================================================
  // isBayValid()
  // ==========================================================
  //
  // Mengecek apakah Bay tersedia pada Rack.
  //
  // Bay selalu dimulai dari 01.
  //
  // Contoh:
  //
  // bayCount = 7
  //
  // valid:
  // 01–07
  //
  // tidak valid:
  // 00
  // 08
  // ==========================================================

  bool isBayValid(int bay) {
    return bay >= 1 && bay <= bayCount;
  }


  // ==========================================================
  // isShelvingValid()
  // ==========================================================
  //
  // Mengecek Shelving.
  //
  // Untuk Rack yang tidak menggunakan Shelving:
  // shelving dianggap tidak diperlukan.
  //
  // Untuk Rack 81–90:
  // Shelving 02–06.
  // ==========================================================

  bool isShelvingValid(int? shelving) {
    // Rack tidak menggunakan Shelving.
    if (!hasShelving) {
      return true;
    }


    // Rack menggunakan Shelving,
    // sehingga Shelving wajib tersedia.
    if (shelving == null) {
      return false;
    }


    return shelving >= minShelving! &&
        shelving <= maxShelving!;
  }


  // ==========================================================
  // isPositionValid()
  // ==========================================================
  //
  // Mengecek Position.
  //
  // Untuk Rack 81–90:
  //
  // Position 01
  // Position 02
  // Position 03
  //
  // setiap Shelving mempunyai 3 Position.
  // ==========================================================

  bool isPositionValid(int? position) {
    // Rack tidak menggunakan Shelving.
    if (!hasShelving) {
      return true;
    }


    // Jika menggunakan Shelving,
    // Position wajib diisi.
    if (position == null) {
      return false;
    }


    return position >= 1 &&
        position <= positionCount!;
  }


  // ==========================================================
  // toString()
  // ==========================================================
  //
  // Membantu debugging.
  // ==========================================================

  @override
  String toString() {
    return 'RackConfiguration('
        'rack: $rack, '
        'bayCount: $bayCount, '
        'minShelving: $minShelving, '
        'maxShelving: $maxShelving, '
        'positionCount: $positionCount'
        ')';
  }
}


// ============================================================
// CLASS: RackConfigurations
// ============================================================
//
// SINGLE SOURCE OF TRUTH LAYOUT GUDANG.
//
// Semua aturan Rack utama disimpan di sini.
//
// Layout:
//
// Rack 80
//   7 Bay
//
// Rack 81–90
//   7 Bay
//   Shelving 02–06
//   3 Position / Shelving
//
// Rack 91–94
//   7 Bay
//
// Rack 95–96
//   5 Bay
//
// ============================================================

class RackConfigurations {
  // Constructor private.
//
// Class ini hanya menyediakan konfigurasi statis.
  RackConfigurations._();


  // ==========================================================
  // RACK 80
  // ==========================================================
  //
  // 7 Bay
  // ==========================================================

  static const RackConfiguration rack80 = RackConfiguration(
    rack: 80,
    bayCount: 7,
  );


  // ==========================================================
  // RACK 81–90
  // ==========================================================
  //
  // 7 Bay
  // Shelving 02–06
  // 3 Position per Shelving
  //
  // Jumlah Shelving:
  //
  // 02, 03, 04, 05, 06
  //
  // = 5 Shelving
  //
  // Position:
  //
  // 5 × 3 = 15 pallet / Bay
  //
  // 7 Bay:
  //
  // 7 × 15 = 105 pallet / Rack
  //
  // 10 Rack:
  //
  // 10 × 105 = 1.050 pallet
  // ==========================================================

  static const RackConfiguration rack81To90 = RackConfiguration(
    rack: 81,
    bayCount: 7,
    minShelving: 2,
    maxShelving: 6,
    positionCount: 3,
  );


  // ==========================================================
  // RACK 91–94
  // ==========================================================
  //
  // 7 Bay
  // ==========================================================

  static const RackConfiguration rack91To94 = RackConfiguration(
    rack: 91,
    bayCount: 7,
  );


  // ==========================================================
  // RACK 95–96
  // ==========================================================
  //
  // 5 Bay
  // ==========================================================

  static const RackConfiguration rack95To96 = RackConfiguration(
    rack: 95,
    bayCount: 5,
  );


  // ==========================================================
  // get()
  // ==========================================================
  //
  // Mengambil konfigurasi berdasarkan nomor Rack.
  //
  // Return:
  //
  // RackConfiguration → jika Rack dikenal.
  // null              → jika Rack tidak mempunyai konfigurasi.
  // ==========================================================

  static RackConfiguration? get(int rack) {
    // --------------------------------------------------------
    // Rack 80
    // --------------------------------------------------------

    if (rack == 80) {
      return rack80;
    }


    // --------------------------------------------------------
    // Rack 81–90
    // --------------------------------------------------------
    //
    // Semua Rack pada kelompok ini menggunakan layout yang
    // sama.
    // --------------------------------------------------------

    if (rack >= 81 && rack <= 90) {
      return RackConfiguration(
        rack: rack,
        bayCount: rack81To90.bayCount,
        minShelving: rack81To90.minShelving,
        maxShelving: rack81To90.maxShelving,
        positionCount: rack81To90.positionCount,
      );
    }


    // --------------------------------------------------------
    // Rack 91–94
    // --------------------------------------------------------

    if (rack >= 91 && rack <= 94) {
      return RackConfiguration(
        rack: rack,
        bayCount: rack91To94.bayCount,
      );
    }


    // --------------------------------------------------------
    // Rack 95–96
    // --------------------------------------------------------

    if (rack >= 95 && rack <= 96) {
      return RackConfiguration(
        rack: rack,
        bayCount: rack95To96.bayCount,
      );
    }


    // --------------------------------------------------------
    // Rack tidak dikenal.
    // --------------------------------------------------------

    return null;
  }


  // ==========================================================
  // containsRack()
  // ==========================================================
  //
  // Mengecek apakah Rack mempunyai konfigurasi.
  // ==========================================================

  static bool containsRack(int rack) {
    return get(rack) != null;
  }
}
