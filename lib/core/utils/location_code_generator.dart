// File:
// lib/core/utils/location_code_generator.dart

// Class ini bertugas membuat kode lokasi pallet
// berdasarkan aturan lokasi gudang yang sudah kita sepakati.
class LocationCodeGenerator {
  // Constructor dibuat private agar class ini digunakan
  // sebagai utility dan tidak perlu dibuat menggunakan LocationCodeGenerator().
  LocationCodeGenerator._();

  // Menghasilkan satu kode lokasi lengkap.
  //
  // Contoh:
  // rack    = 80
  // bay     = 1
  // shelving = 1
  // position = 1
  //
  // Hasil:
  // 8001101
  static String generateCode({
    required int rack,
    required int bay,
    required int shelving,
    required int position,
  }) {
    // Rack selalu menggunakan dua digit.
    // Contoh 80 tetap menjadi "80".
    final String rackCode = rack.toString().padLeft(2, '0');

    // Bay menggunakan dua digit.
    // Contoh 1 menjadi "01".
    final String bayCode = bay.toString().padLeft(2, '0');

    // Shelving menggunakan satu digit.
    // Contoh 1 menjadi "1".
    final String shelvingCode = shelving.toString();

    // Posisi pallet menggunakan dua digit.
    // Contoh 1 menjadi "01".
    final String positionCode = position.toString().padLeft(2, '0');

    // Menggabungkan seluruh bagian menjadi kode lokasi.
    //
    // Contoh:
    // 80 + 01 + 1 + 01
    // = 8001101
    return '$rackCode$bayCode$shelvingCode$positionCode';
  }

  // Menentukan jumlah bay berdasarkan nomor rack.
  static int getBayCount(int rack) {
    // Rack 80 memiliki Bay 01 sampai Bay 07.
    if (rack == 80) {
      return 7;
    }

    // Rack 91 sampai 94 memiliki Bay 01 sampai Bay 07.
    if (rack >= 91 && rack <= 94) {
      return 7;
    }

    // Rack 95 dan 96 hanya memiliki Bay 01 sampai Bay 05.
    if (rack == 95 || rack == 96) {
      return 5;
    }

    // Rack 81 sampai 90 menggunakan aturan bay lapangan.
    //
    // Untuk sementara jumlah bay diset 5 sesuai aturan
    // yang sudah kita bahas untuk kelompok Rack 81-90.
    //
    // Nanti bagian ini bisa kita ubah jika data lapangan
    // memberikan jumlah bay yang berbeda.
    if (rack >= 81 && rack <= 90) {
      return 7;
    }

    // Jika nomor rack tidak termasuk aturan gudang,
    // kita kembalikan 0 agar tidak menghasilkan lokasi palsu.
    return 0;
  }

  // Menentukan shelving paling awal berdasarkan nomor rack.
  static int getFirstShelving(int rack) {
    // Rack 81 sampai 90 dimulai dari shelving 02.
    //
    // Contoh:
    // 8101201
    // 8101202
    // 8101203
    if (rack >= 81 && rack <= 90) {
      return 2;
    }

    // Rack lainnya dimulai dari shelving 01.
    return 1;
  }

  // Menentukan shelving terakhir berdasarkan nomor rack.
  static int getLastShelving(int rack) {
    // Semua rack menggunakan shelving sampai 06.
    return 6;
  }

  // Menghasilkan seluruh kode lokasi untuk satu rack.
  static List<String> generateRackLocations(int rack) {
    // Menyediakan list kosong untuk menampung seluruh kode lokasi.
    final List<String> locations = [];

    // Mendapatkan jumlah bay sesuai aturan rack.
    final int bayCount = getBayCount(rack);

    // Mendapatkan shelving awal.
    final int firstShelving = getFirstShelving(rack);

    // Mendapatkan shelving terakhir.
    final int lastShelving = getLastShelving(rack);

    // Jika rack tidak memiliki aturan,
    // jangan menghasilkan data lokasi.
    if (bayCount == 0) {
      return locations;
    }

    // Melakukan perulangan untuk setiap bay.
    for (int bay = 1; bay <= bayCount; bay++) {
      // Melakukan perulangan dari shelving paling bawah
      // sampai shelving paling atas.
      for (int shelving = firstShelving; shelving <= lastShelving; shelving++) {
        // Setiap shelving mempunyai 3 posisi pallet.
        for (int position = 1; position <= 3; position++) {
          // Membuat kode lokasi berdasarkan
          // rack, bay, shelving, dan posisi.
          final String code = generateCode(
            rack: rack,
            bay: bay,
            shelving: shelving,
            position: position,
          );

          // Memasukkan kode lokasi ke dalam list.
          locations.add(code);
        }
      }
    }

    // Mengembalikan seluruh lokasi rack.
    return locations;
  }
}
