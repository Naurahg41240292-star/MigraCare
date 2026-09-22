import 'package:flutter/material.dart';
import '../models/obat.dart';

/// ==========================================================================
///  MIGRACARE — Halaman Atur Jadwal
///  File: lib/screens/atur_jadwal.dart
/// ==========================================================================

class AturJadwalPage extends StatefulWidget {
  final Obat obat;

  const AturJadwalPage({super.key, required this.obat});

  @override
  State<AturJadwalPage> createState() => _AturJadwalPageState();
}

class _AturJadwalPageState extends State<AturJadwalPage> {
  static const Color background = Color(0xFFFAF4EA);
  static const Color surface = Colors.white;
  static const Color orange = Color(0xFFDE8500);
  static const Color orangeFill = Color(0xFFFBEED8);
  static const Color orangeBorder = Color(0xFFE3BC77);
  static const Color textDark = Color(0xFF33261A);
  static const Color textGrey = Color(0xFF9C948A);
  static const Color outline = Color(0xFFEDE3D4);

  static const List<String> _labelHari = [
    'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min',
  ];
  static const List<String> _namaBulan = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli',
    'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];
  static const List<String> _frekuensi = [
    '1x sehari', '2x sehari', '3x sehari', 'Lainnya',
  ];

  late List<String> _jamList;
  late List<int> _hariList;
  late DateTime _mulaiBerlaku;

  @override
  void initState() {
    super.initState();
    _jamList = List<String>.from(widget.obat.jamList);
    _hariList = List<int>.from(widget.obat.hariList);
    if (_hariList.isEmpty) _hariList = [1, 2, 3, 4, 5, 6, 7];
    _mulaiBerlaku = widget.obat.mulaiBerlaku;
  }

  String get _frekuensiTerpilih {
    if (_jamList.length == 1) return '1x sehari';
    if (_jamList.length == 2) return '2x sehari';
    if (_jamList.length == 3) return '3x sehari';
    return 'Lainnya';
  }

  String _jamTampil(String jam) => jam.replaceAll('.', ':');

  String _labelWaktu(String jam) {
    final h = int.tryParse(jam.split('.').first) ?? 8;
    if (h < 11) return 'Pagi';
    if (h < 15) return 'Siang';
    if (h < 19) return 'Sore';
    return 'Malam';
  }

  IconData _ikonWaktu(String jam) {
    final h = int.tryParse(jam.split('.').first) ?? 8;
    return (h >= 6 && h < 18)
        ? Icons.wb_sunny_rounded
        : Icons.nights_stay_rounded;
  }

  String _formatTanggal(DateTime d) =>
      '${d.day} ${_namaBulan[d.month - 1]} ${d.year}';

  void _snack(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan)));
  }

  void _setFrekuensi(String f) {
    setState(() {
      if (f == '1x sehari') {
        _jamList = ['08.00'];
      } else if (f == '2x sehari') {
        _jamList = ['08.00', '20.00'];
      } else if (f == '3x sehari') {
        _jamList = ['08.00', '14.00', '20.00'];
      }
      // 'Lainnya' → atur manual lewat Tambah Waktu
    });
  }

  Future<void> _tambahWaktu() async {
    final pilih = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pilih == null) return;
    final jam =
        '${pilih.hour.toString().padLeft(2, '0')}.${pilih.minute.toString().padLeft(2, '0')}';
    if (_jamList.contains(jam)) {
      _snack('Jam $jam sudah ada di daftar');
      return;
    }
    setState(() {
      _jamList.add(jam);
      _jamList.sort();
    });
  }

  Future<void> _pilihMulaiBerlaku() async {
    final now = DateTime.now();
    final pilih = await showDatePicker(
      context: context,
      initialDate: _mulaiBerlaku,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 5),
    );
    if (pilih == null) return;
    setState(() => _mulaiBerlaku = pilih);
  }

  Future<void> _simpan() async {
    if (_jamList.isEmpty) {
      _snack('Minimal harus ada 1 waktu minum 😊');
      return;
    }
    if (_hariList.isEmpty) {
      _snack('Pilih minimal 1 hari pengulangan 😊');
      return;
    }
    _jamList.sort();
    widget.obat.jamList = List<String>.from(_jamList);
    widget.obat.hariList = List<int>.from(_hariList);
    widget.obat.mulaiBerlaku = _mulaiBerlaku;
    await PengingatStore.instance.simpanPerubahanObat();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Jadwal ${widget.obat.nama} tersimpan ✓')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        iconTheme: const IconThemeData(color: textDark),
        title: Text('Atur Jadwal — ${widget.obat.nama}',
            style: const TextStyle(
                color: textDark,
                fontWeight: FontWeight.w800,
                fontSize: 17)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= WAKTU MINUM =================
            _judul('Waktu Minum'),
            for (final jam in _jamList) _barisWaktu(jam),
            _tombolTambahWaktu(),
            const SizedBox(height: 24),

            // ================= FREKUENSI =================
            _judul('Frekuensi'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _frekuensi.map((f) => _chipPilih(
                    label: f,
                    terpilih: _frekuensiTerpilih == f,
                    onTap: () => _setFrekuensi(f),
                  )).toList(),
            ),
            const SizedBox(height: 24),

            // ================= PENGULANGAN =================
            _judul('Pengulangan'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(7, (i) {
                final weekday = i + 1;
                final terpilih = _hariList.contains(weekday);
                return _chipPilih(
                  label: _labelHari[i],
                  terpilih: terpilih,
                  onTap: () => setState(() {
                    if (terpilih) {
                      if (_hariList.length > 1) _hariList.remove(weekday);
                    } else {
                      _hariList.add(weekday);
                    }
                  }),
                );
              }),
            ),
            const SizedBox(height: 24),

            // ================= MULAI BERLAKU =================
            _judul('Mulai Berlaku'),
            InkWell(
              onTap: _pilihMulaiBerlaku,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: outline),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_rounded, color: orange),
                    const SizedBox(width: 12),
                    Text(_formatTanggal(_mulaiBerlaku),
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: textDark)),
                    const Spacer(),
                    const Icon(Icons.keyboard_arrow_down_rounded,
                        color: textDark),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ================= INFO NOTIFIKASI =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF3DC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications_active_rounded,
                      color: orange),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Anda akan mendapatkan notifikasi sesuai jadwal yang telah diatur',
                      style: TextStyle(
                          fontSize: 12.5, color: textDark, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ================= TOMBOL SIMPAN =================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _simpan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: orange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Simpan Jadwal',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============ WIDGET BANTU ============

  Widget _judul(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: textDark)),
      );

  Widget _barisWaktu(String jam) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: orangeFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: orangeBorder),
      ),
      child: Row(
        children: [
          Icon(_ikonWaktu(jam), color: orange, size: 20),
          const SizedBox(width: 10),
          Text(_jamTampil(jam),
              style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: textDark)),
          const Spacer(),
          Text(_labelWaktu(jam),
              style: const TextStyle(fontSize: 13, color: textGrey)),
          const SizedBox(width: 14),
          InkWell(
            onTap: () => setState(() => _jamList.remove(jam)),
            child: const Icon(Icons.delete_outline_rounded,
                color: orange, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _tombolTambahWaktu() {
    return InkWell(
      onTap: _tambahWaktu,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: orangeBorder),
        ),
        child: const Text('+ Tambah Waktu',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: orange, fontWeight: FontWeight.w700, fontSize: 14)),
      ),
    );
  }

  Widget _chipPilih(
      {required String label,
      required bool terpilih,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: terpilih ? orange : surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: terpilih ? orange : outline),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: terpilih ? Colors.white : textDark,
          ),
        ),
      ),
    );
  }
}