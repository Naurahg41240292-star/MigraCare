import 'package:flutter/material.dart';
import '../models/obat.dart';

/// MIGRACARE — Halaman Utama Pengingat Obat

class PengingatObatPage extends StatefulWidget {
  const PengingatObatPage({super.key});

  @override
  State<PengingatObatPage> createState() => _PengingatObatPageState();
}

class _PengingatObatPageState extends State<PengingatObatPage> {
  // Warna disamakan dengan AppColors di beranda.dart
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
  Widget build(BuildContext context) {
    final store = PengingatStore.instance;

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
            // ---- Toggle Aktifkan Pengingat ----
            _kartu(Row(
              children: [
                const Expanded(
                  child: Text('Aktifkan Pengingat',
                      style: TextStyle(fontWeight: FontWeight.w700, color: textDark)),
                ),
                Switch(
                  value: pengingatAktif,
                  activeColor: accent,
                  onChanged: (v) => setState(() => pengingatAktif = v),
                ),
              ],
            )),
            const SizedBox(height: 16),

            // ---- Obat Berikutnya ----
            _kartuObatBerikutnya(store),
            const SizedBox(height: 20),

            // ---- Jadwal Hari Ini ----
            const Text('Jadwal Hari Ini',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textDark)),
            const SizedBox(height: 10),
            _daftarJadwal(store),
            const SizedBox(height: 20),

            // ---- Tombol Aksi ----
            Row(
              children: [
                _tombolAksi(Icons.add_circle_rounded, 'Tambah\nObat', _tambahObat),
                const SizedBox(width: 12),
                _tombolAksi(Icons.edit_calendar_rounded, 'Atur\nJadwal', _fiturSegera),
                const SizedBox(width: 12),
                _tombolAksi(Icons.history_rounded, 'Riwayat\nPengingat', _fiturSegera),
              ],
            ),
            const SizedBox(height: 20),

            // ---- Tips Minum Obat ----
            _kartu(Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tips Minum Obat',
                          style: TextStyle(fontWeight: FontWeight.w800, color: textDark)),
                      SizedBox(height: 6),
                      Text(
                        'Minum obat secara teratur sesuai anjuran dokter untuk hasil pengobatan yang optimal.',
                        style: TextStyle(color: textGrey, fontSize: 13, height: 1.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                const Text('🥛', style: TextStyle(fontSize: 34)),
              ],
            )),
            const SizedBox(height: 16),

            // ---- Catatan Penting ----
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
                            style: TextStyle(fontWeight: FontWeight.w800, color: textDark)),
                        SizedBox(height: 4),
                        Text(
                          'MigraCare tidak menentukan dosis obat. Gunakan obat sesuai resep atau anjuran tenaga kesehatan.',
                          style: TextStyle(color: textGrey, fontSize: 12, height: 1.5),
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

  Widget _kartuObatBerikutnya(PengingatStore store) {
    Widget isi;

    if (store.daftarObat.isEmpty) {
      // Belum diisi apa-apa
      isi = const Column(
        children: [
          Icon(Icons.medication_outlined, color: primary, size: 34),
          SizedBox(height: 8),
          Text('Belum ada pengingat obat',
              style: TextStyle(fontWeight: FontWeight.w800, color: textDark)),
          SizedBox(height: 4),
          Text(
            'Tambahkan obat lewat tombol "Tambah Obat" di bawah.',
            textAlign: TextAlign.center,
            style: TextStyle(color: textGrey, fontSize: 13),
          ),
        ],
      );
    } else if (store.obatBerikutnya == null) {
      // Semua sudah diminum
      isi = const Column(
        children: [
          Icon(Icons.check_circle_rounded, color: Color(0xFF3E7C3E), size: 34),
          SizedBox(height: 8),
          Text('Semua obat sudah diminum hari ini 🎉',
              style: TextStyle(fontWeight: FontWeight.w800, color: textDark)),
        ],
      );
    } else {
      final obat = store.obatBerikutnya!;
      isi = Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Obat Berikutnya', style: TextStyle(color: textGrey, fontSize: 13)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.wb_sunny, size: 14, color: accentDark),
                    const SizedBox(width: 4),
                    Text(obat.jam,
                        style: const TextStyle(fontSize: 12, color: textDark)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('${obat.nama} ${obat.dosis}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textDark)),
          const SizedBox(height: 2),
          Text(obat.aturan, style: const TextStyle(color: textGrey, fontSize: 13)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => setState(() => obat.sudahDiminum = true),
              style: ElevatedButton.styleFrom(
                backgroundColor: surface,
                foregroundColor: textDark,
                side: const BorderSide(color: outline),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              icon: const Icon(Icons.check_circle, color: accent),
              label: const Text('Tandai Sudah Diminum',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      );
    }
    return _kartu(isi);
  }

  Widget _daftarJadwal(PengingatStore store) {
    if (store.daftarObat.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: outline),
        ),
        child: const Text('Belum ada jadwal obat hari ini.',
            textAlign: TextAlign.center, style: TextStyle(color: textGrey)),
      );
    }

    return Column(
      children: store.daftarObat.map((obat) {
        final bersih = obat.jam.replaceAll(':', '.').split('.').first;
        final jam = int.tryParse(bersih) ?? 8;
        final pagi = jam < 12;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: outline),
          ),
          child: Row(
            children: [
              Icon(pagi ? Icons.wb_sunny : Icons.nights_stay, color: accent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(obat.jam,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 16, color: textDark)),
                    Text('${obat.nama} ${obat.dosis}',
                        style: const TextStyle(color: textGrey, fontSize: 13)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: obat.sudahDiminum
                      ? const Color(0xFFE4F3E4)
                      : const Color(0xFFFDEEDC),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  obat.sudahDiminum ? 'Sudah diminum' : 'Belum diminum',
                  style: TextStyle(
                    fontSize: 12,
                    color: obat.sudahDiminum
                        ? const Color(0xFF3E7C3E)
                        : const Color(0xFFB07E1F),
                  ),
                ),
              ),
            ],
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
          decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              Icon(icon, color: darkBrown),
              const SizedBox(height: 6),
              Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700, color: darkBrown)),
            ],
          ),
        ),
      ),
    );
  }

  // ============ AKSI ============

  void _fiturSegera() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur ini sedang dikembangkan 🙂')),
    );
  }

  Future<void> _tambahObat() async {
    final namaC = TextEditingController(text: 'Topiramate');
    final dosisC = TextEditingController(text: '50 mg');
    final jamC = TextEditingController(text: '08.00');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Tambah Obat', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: namaC, decoration: const InputDecoration(labelText: 'Nama obat')),
            TextField(controller: dosisC, decoration: const InputDecoration(labelText: 'Dosis (mis. 50 mg)')),
            TextField(
              controller: jamC,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Jam minum (mis. 08.00)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: accent, foregroundColor: darkBrown),
            onPressed: () {
              if (namaC.text.trim().isEmpty) return;
              setState(() {
                PengingatStore.instance.tambahObat(Obat(
                  nama: namaC.text.trim(),
                  dosis: dosisC.text.trim(),
                  jam: jamC.text.trim().isEmpty ? '08.00' : jamC.text.trim(),
                ));
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pengingat obat ditambahkan ✓')),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}