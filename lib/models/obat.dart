/// MIGRACARE — Model & Penyimpanan Data Pengingat Obat

class Obat {
  String nama;   // contoh: Topiramate
  String dosis;  // contoh: 50 mg
  String aturan; // contoh: 1 tablet. Setelah makan
  String jam;    // contoh: 08.00
  bool sudahDiminum;

  Obat({
    required this.nama,
    required this.dosis,
    required this.jam,
    this.aturan = '1 tablet. Setelah makan',
    this.sudahDiminum = false,
  });
}

/// Singleton supaya data obat bisa diakses
/// dari Beranda maupun halaman Pengingat Obat.
class PengingatStore {
  PengingatStore._();
  static final PengingatStore instance = PengingatStore._();

  bool pengingatAktif = true;
  final List<Obat> daftarObat = []; // mulai KOSONG dulu

  /// Obat yang belum diminum (untuk kartu "Obat Berikutnya")
  Obat? get obatBerikutnya {
    for (final obat in daftarObat) {
      if (!obat.sudahDiminum) return obat;
    }
    return null;
  }

  void tambahObat(Obat obat) => daftarObat.add(obat);
}