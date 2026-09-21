// =======================================================================
//  MIGRACARE — Helper Format Tanggal & Waktu
//  File: lib/utils/tanggal.dart
// =======================================================================

abstract class Tanggal {
  static const List<String> namaHari = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  static const List<String> namaBulan = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  static const List<String> namaBulanLengkap = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  /// Menghasilkan format tanggal lengkap: "20 September 2026"
  static String lengkap(DateTime d) {
    return '${d.day} ${namaBulanLengkap[d.month - 1]} ${d.year}';
  }

  /// Menghasilkan format jam: "14:30"
  static String jam(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Menghasilkan daftar DateTime untuk N hari ke depan mulai hari ini
  static List<DateTime> hariKeDepan(int jumlah) {
    final now = DateTime.now();
    return List.generate(
      jumlah,
      (i) => DateTime(now.year, now.month, now.day + i),
    );
  }
}