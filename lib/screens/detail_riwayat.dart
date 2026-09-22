import 'package:flutter/material.dart';
import '../models/obat.dart';

/// ==========================================================================
///  MIGRACARE — Halaman Detail Riwayat
///  File: lib/screens/detail_riwayat.dart
/// ==========================================================================

class DetailRiwayatPage extends StatelessWidget {
  final DateTime tanggal;

  const DetailRiwayatPage({super.key, required this.tanggal});

  static const Color background = Color(0xFFFAF4EA);
  static const Color surface = Colors.white;
  static const Color orange = Color(0xFFDE8500);
  static const Color textDark = Color(0xFF33261A);
  static const Color textGrey = Color(0xFF9C948A);
  static const Color outline = Color(0xFFEDE3D4);
  static const Color green = Color(0xFF3E7C3E);
  static const Color greenBg = Color(0xFFE4F3E4);
  static const Color orangeBg = Color(0xFFFDEEDC);

  static const List<String> _namaHari = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
  ];
  static const List<String> _namaBulan = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli',
    'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  String get _tanggalTampil =>
      '${_namaHari[tanggal.weekday - 1]}, ${tanggal.day} ${_namaBulan[tanggal.month - 1]} ${tanggal.year}';

  String _jamTampil(String jam) => jam.replaceAll('.', ':');

  @override
  Widget build(BuildContext context) {
    final store = PengingatStore.instance;
    final entri = store.daftarRiwayat
        .where((r) =>
            r.tanggal.year == tanggal.year &&
            r.tanggal.month == tanggal.month &&
            r.tanggal.day == tanggal.day)
        .toList()
      ..sort((a, b) => a.jam.compareTo(b.jam));

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        iconTheme: const IconThemeData(color: textDark),
        title: const Text('Detail Riwayat',
            style: TextStyle(color: textDark, fontWeight: FontWeight.w800)),
      ),
      body: entri.isEmpty
          ? const Center(
              child: Text('Tidak ada riwayat pada tanggal ini.',
                  style: TextStyle(color: textGrey)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---- Kartu tanggal ----
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: outline),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month_rounded,
                            color: orange),
                        const SizedBox(width: 12),
                        Text(_tanggalTampil,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: textDark)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ---- Kartu tiap entri ----
                  for (final r in entri) ...[
                    _kartuEntri(r, store),
                    const SizedBox(height: 14),
                  ],

                  const SizedBox(height: 8),

                  // ---- Catatan kaki ----
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF3DC),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, color: orange),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Riwayat ini berdasarkan pengingat yang telah anda atur di MigraCare',
                            style: TextStyle(
                                fontSize: 12.5,
                                color: textDark,
                                height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _kartuEntri(RiwayatObat r, PengingatStore store) {
    final jamNum = int.tryParse(r.jam.split('.').first) ?? 8;
    final pagi = jamNum < 12;

    Obat? obat;
    for (final o in store.daftarObat) {
      if (o.id == r.idObat) {
        obat = o;
        break;
      }
    }
    final bentuk = obat?.bentukSediaan ?? '';
    final catatan =
        (r.catatan != null && r.catatan!.isNotEmpty) ? r.catatan! : '-';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(pagi ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded,
                  color: orange, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_jamTampil(r.jam),
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: textDark)),
                    Text('${r.namaObat} ${r.dosisObat}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: textDark)),
                    if (bentuk.isNotEmpty)
                      Text('1 $bentuk',
                          style: const TextStyle(
                              fontSize: 12, color: textGrey)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: r.sudahDiminum ? greenBg : orangeBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      r.sudahDiminum ? 'Sudah diminum' : 'Belum diminum',
                      style: TextStyle(
                          fontSize: 11,
                          color: r.sudahDiminum ? green : orange),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      r.sudahDiminum
                          ? Icons.check_circle
                          : Icons.notifications_active,
                      size: 14,
                      color: r.sudahDiminum ? green : orange,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 22, color: outline),
          _barisInfo(
            Icons.access_time_rounded,
            r.sudahDiminum ? 'Waktu diminum' : 'Waktu dijadwalkan',
            _jamTampil(r.sudahDiminum ? (r.waktuDiminum ?? r.jam) : r.jam),
          ),
          const SizedBox(height: 10),
          _barisInfo(Icons.notes_rounded, 'Catatan', catatan),
        ],
      ),
    );
  }

  Widget _barisInfo(IconData icon, String label, String nilai) {
    return Row(
      children: [
        Icon(icon, size: 18, color: textGrey),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label,
              style: const TextStyle(fontSize: 13, color: textGrey)),
        ),
        Text(nilai,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textDark)),
      ],
    );
  }
}