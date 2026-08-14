// File:
// lib/domain/entities/rack_location.dart

// Entity RackLocation mewakili satu posisi pallet
// yang tersedia di gudang.
class RackLocation {
  // Nomor rack.
  // Contoh: 80, 81, 82, sampai 96.
  final int rackNumber;

  // Nomor bay.
  // Contoh: 01 sampai 07.
  final int bayNumber;

  // Nomor shelving/tingkat.
  // Pada layout contoh Rack 80:
  // shelving 1 berada paling bawah sampai shelving 6 paling atas.
  final int shelvingNumber;

  // Nomor urutan pallet pada satu shelving.
  // Posisi 01, 02, atau 03.
  final int palletNumber;

  // Kode lokasi lengkap.
  // Contoh: 8001101.
  final String locationCode;

  // Constructor RackLocation.
  const RackLocation({
    required this.rackNumber,
    required this.bayNumber,
    required this.shelvingNumber,
    required this.palletNumber,
    required this.locationCode,
  });
}
