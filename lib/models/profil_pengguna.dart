/// ==========================================================================
///  MIGRACARE — Model data profil pengguna (singleton)
///  File: lib/models/profil_pengguna.dart
/// ==========================================================================

class ProfilPengguna {
  ProfilPengguna._();
  static final ProfilPengguna instance = ProfilPengguna._();

  String nama = 'Ananda Flors Siregar';
  String email = 'Ananda.Siregar@gmail.com';
  String noTelpon = '+62 812 3456 7890';
  DateTime? tanggalLahirDate = DateTime(2003, 2, 17);
  String jenisKelamin = 'Perempuan';
  String bio = '';
  String? fotoPath; // null = pakai avatar inisial default

  String get tanggalLahir =>
      tanggalLahirDate == null ? '-' : formatTanggal(tanggalLahirDate!);
}

const List<String> _bulan = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
];

String formatTanggal(DateTime d) => '${d.day} ${_bulan[d.month - 1]} ${d.year}';