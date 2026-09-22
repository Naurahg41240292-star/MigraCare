import 'package:flutter/material.dart';
import '../models/obat.dart';
import 'tambah_obat.dart';
import 'riwayat_pengingat.dart';
import 'atur_jadwal.dart';

/// ==========================================================================
///  MIGRACARE — Halaman Utama Pengingat Obat (v2.3)
///  - Tanpa kartu "Obat Berikutnya" (notif cukup 1: daftar jadwal)
///  - Baris jadwal = toggle dua arah (sudah <-> belum)
///  - Tekan lama baris = hapus obat
///  File: lib/screens/pengingat_obat.dart
/// ==========================================================================

class PengingatObatPage extends StatefulWidget {
  const PengingatObatPage({super.key});

  @override
  State<PengingatObatPage> createState() => _PengingatObatPageState();
}

class _PengingatObatPageState extends State<PengingatObatPage> {
  static const Color background = Color(0xFFFAF4EA);
  static const Color surface = Colors.white;
  static const Color primary = Color(0xFF6B4A2B);
  static const Color darkBrown = Color(0xFF3D2B1A);
  static const Color accent = Color(0xFFF2C230);
  static const Color accentDark = Color(0xFFB07E1F);
  static const Color textDark = Color(0xFF33261A);
  static const Color textGrey = Color(0xFF9C948A);
  static const Color outline = Color(0xFFEDE3D4);

  bool pengingatAktif = true;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    await PengingatStore.instance.muatDariDisk();
    PengingatStore.instance.sinkronkanRiwayatHariIni();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textDark),
        title: const Text('Pengingat Obat',
            style: TextStyle(color: textDark, fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _kartu(Row(
              children: [
                const Expanded(
                  child: Text('Aktifkan Pengingat',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, color: textDark)),
                ),
                Switch(
                  value: pengingatAktif,
                  activeColor: accent,
                  onChanged: (v) => setState(() => pengingatAktif = v),
                ),
              ],
            )),
            const SizedBox(height: 20),

            const Text('Jadwal Hari Ini',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: textDark)),
            const SizedBox(height: 4),
            const Text(
              'Ketuk baris untuk ubah status. Tekan lama untuk hapus obat.',
              style: TextStyle(fontSize: 11.5, color: textGrey),
            ),
            const SizedBox(height: 10),
            _daftarJadwal(),
            const SizedBox(height: 20),

            Row(
              children: [
                _tombolAksi(Icons.add_circle_rounded, 'Tambah\nObat',
                    _bukaTambahObat),
                const SizedBox(width: 12),
                _tombolAksi(Icons.edit_calendar_rounded, 'Atur\nJadwal',
                    _bukaAturJadwal),
                const SizedBox(width: 12),
                _tombolAksi(Icons.history_rounded, 'Riwayat\nPengingat',
                    _bukaRiwayat),
              ],
            ),
            const SizedBox(height: 20),

            _kartu(Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tips Minum Obat',
                          style: TextStyle(
                              fontWeight: FontWeight.w800, color: textDark)),
                      SizedBox(height: 6),
                      Text(
                        'Minum obat secara teratur sesuai anjuran dokter untuk hasil pengobatan yang optimal.',
                        style: TextStyle(
                            color: textGrey, fontSize: 13, height: 1.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                const Text('🥛', style: TextStyle(fontSize: 34)),
              ],
            )),
            const SizedBox(height: 16),

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
                  const Icon(Icons.info_outline, color: primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Catatan Penting',
                            style: TextStyle(
                                fontWeight: FontWeight.w800, color: textDark)),
                        SizedBox(height: 4),
                        Text(
                          'MigraCare tidak menentukan dosis obat. Gunakan obat sesuai resep atau anjuran tenaga kesehatan.',
                          style: TextStyle(
                              color: textGrey, fontSize: 12, height: 1.5),
                        ),
                      ],
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

  // ============ WIDGET BANTU ============

  Widget _kartu(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: outline),
      ),
      child: child,
    );
  }

  Widget _daftarJadwal() {
    final store = PengingatStore.instance;
    if (store.daftarObat.isEmpty) {
      return _kartu(const Text('Belum ada jadwal obat hari ini.',
          textAlign: TextAlign.center, style: TextStyle(color: textGrey)));
    }

    final jadwal = store.jadwalHariIni();
    if (jadwal.isEmpty) {
      return _kartu(const Text(
          'Tidak ada jadwal untuk hari ini.\nCek pengulangan hari & mulai berlaku di menu Atur Jadwal.',
          textAlign: TextAlign.center,
          style: TextStyle(color: textGrey, height: 1.5)));
    }

    return Column(
      children: jadwal.map((item) {
        final jamNum = int.tryParse(item.jam.split('.').first) ?? 8;
        final pagi = jamNum < 12;
        return GestureDetector(
          onTap: () => setState(() {
            if (item.sudahDiminum) {
              store.batalkanDiminum(item.obat, item.jam);
            } else {
              store.tandaiDiminum(item.obat, item.jam);
            }
          }),
          onLongPress: () => _konfirmasiHapus(item.obat),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: outline),
            ),
            child: Row(
              children: [
                Icon(pagi ? Icons.wb_sunny : Icons.nights_stay,
                    color: accent),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.jam,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: textDark)),
                      Text(
                          '${item.obat.nama} ${item.obat.dosis} • ${item.obat.bentukSediaan}',
                          style: const TextStyle(
                              color: textGrey, fontSize: 13)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.sudahDiminum
                        ? const Color(0xFFE4F3E4)
                        : const Color(0xFFFDEEDC),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.sudahDiminum ? 'Sudah diminum' : 'Belum diminum',
                        style: TextStyle(
                          fontSize: 12,
                          color: item.sudahDiminum
                              ? const Color(0xFF3E7C3E)
                              : accentDark,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        item.sudahDiminum
                            ? Icons.check_circle
                            : Icons.notifications_active,
                        size: 14,
                        color: item.sudahDiminum
                            ? const Color(0xFF3E7C3E)
                            : accentDark,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _tombolAksi(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration:
              BoxDecoration(color: accent, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              Icon(icon, color: darkBrown),
              const SizedBox(height: 6),
              Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: darkBrown)),
            ],
          ),
        ),
      ),
    );
  }

  // ============ AKSI ============

  Future<void> _konfirmasiHapus(Obat obat) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus obat?',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text(
            'Hapus "${obat.nama}" beserta seluruh jadwalnya? Riwayat yang sudah tercatat tetap tersimpan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC0392B),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (yakin == true) {
      setState(() => PengingatStore.instance.hapusObat(obat.id));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Obat "${obat.nama}" dihapus')),
        );
      }
    }
  }

  Future<void> _bukaTambahObat() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TambahObatPage()),
    );
    setState(() {});
  }

  Future<void> _bukaRiwayat() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RiwayatPengingatPage()),
    );
    setState(() {});
  }

  Future<void> _bukaAturJadwal() async {
    final store = PengingatStore.instance;
    if (store.daftarObat.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Tambahkan obat dulu sebelum mengatur jadwal 😊')),
      );
      return;
    }

    Obat terpilih = store.daftarObat.first;
    if (store.daftarObat.length > 1) {
      terpilih = await showDialog<Obat>(
            context: context,
            builder: (context) => SimpleDialog(
              title: const Text('Atur jadwal obat yang mana?'),
              children: store.daftarObat
                  .map((o) => SimpleDialogOption(
                        onPressed: () => Navigator.pop(context, o),
                        child: Text('${o.nama} ${o.dosis}'),
                      ))
                  .toList(),
            ),
          ) ??
          store.daftarObat.first;
    }

    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AturJadwalPage(obat: terpilih)),
    );
    setState(() {});
  }
}