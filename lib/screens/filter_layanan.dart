import 'package:flutter/material.dart';

/// ============================================================
/// FILTER LANJUTAN — Informasi Layanan Kesehatan (MigraCare)
/// ============================================================

// Palet warna — sesuaikan kalau tema halamanmu beda
const Color kCoklat = Color(0xFFA0722A);
const Color kEmas = Color(0xFFF0B93B);
const Color kTeks = Color(0xFF33302B);
const Color kAbu = Color(0xFF8B857C);
const Color kGaris = Color(0xFFECE5D8);

/// Model filter lanjutan. `aktif` dipakai untuk badge di ikon filter.
class FilterLayanan {
  final double ratingMin; // 0 = semua rating
  final double jarakMax; // km; 50 = semua jarak
  final String urutan; // 'terdekat' | 'rating' | 'ulasan' | 'nama'

  const FilterLayanan({
    this.ratingMin = 0,
    this.jarakMax = 50,
    this.urutan = 'terdekat',
  });

  bool get aktif => ratingMin > 0 || jarakMax < 50 || urutan != 'terdekat';
}

/// Deskripsi singkat filter aktif (untuk baris kecil di bawah pencarian).
String deskripsiFilter(FilterLayanan f) {
  final bagian = <String>[];
  if (f.ratingMin > 0) {
    bagian.add('rating ≥ ${f.ratingMin.toStringAsFixed(1)}');
  }
  if (f.jarakMax < 50) bagian.add('jarak ≤ ${f.jarakMax.round()} km');
  if (f.urutan != 'terdekat') {
    const peta = {
      'rating': 'rating tertinggi',
      'ulasan': 'ulasan terbanyak',
      'nama': 'nama A–Z',
    };
    bagian.add('urut: ${peta[f.urutan] ?? f.urutan}');
  }
  return bagian.isEmpty ? 'Tanpa filter' : bagian.join(' · ');
}

/// Buka bottom sheet filter. Return filter baru kalau "Terapkan" ditekan,
/// null kalau sheet ditutup tanpa mengubah apa pun.
Future<FilterLayanan?> showFilterLayananSheet(
    BuildContext context, FilterLayanan saatIni) {
  return showModalBottomSheet<FilterLayanan>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _FilterSheet(saatIni: saatIni),
  );
}

class _FilterSheet extends StatefulWidget {
  final FilterLayanan saatIni;
  const _FilterSheet({required this.saatIni});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late double _ratingMin = widget.saatIni.ratingMin;
  late double _jarakMax = widget.saatIni.jarakMax;
  late String _urutan = widget.saatIni.urutan;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: kGaris,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.tune_rounded, color: kCoklat),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Filter Lanjutan',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: kTeks),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    _ratingMin = 0;
                    _jarakMax = 50;
                    _urutan = 'terdekat';
                  }),
                  child: const Text('Reset',
                      style: TextStyle(
                          color: kCoklat, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _judul('Rating minimum'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chipRating(0, 'Semua'),
                _chipRating(3, '3.0+'),
                _chipRating(4, '4.0+'),
                _chipRating(4.5, '4.5+'),
              ],
            ),
            const SizedBox(height: 16),
            _judul('Jarak maksimum'),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _jarakMax,
                    min: 1,
                    max: 50,
                    divisions: 49,
                    activeColor: kCoklat,
                    label: _jarakMax >= 50
                        ? 'Semua'
                        : '${_jarakMax.round()} km',
                    onChanged: (v) => setState(() => _jarakMax = v),
                  ),
                ),
                SizedBox(
                  width: 84,
                  child: Text(
                    _jarakMax >= 50 ? 'Semua' : '≤ ${_jarakMax.round()} km',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: kAbu),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _judul('Urutkan'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chipUrutan('terdekat', 'Terdekat'),
                _chipUrutan('rating', 'Rating tertinggi'),
                _chipUrutan('ulasan', 'Ulasan terbanyak'),
                _chipUrutan('nama', 'Nama A–Z'),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        Navigator.pop(context, const FilterLayanan()),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kTeks,
                      side: const BorderSide(color: kGaris),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Reset & Tutup'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(
                        context,
                        FilterLayanan(
                          ratingMin: _ratingMin,
                          jarakMax: _jarakMax,
                          urutan: _urutan,
                        )),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kCoklat,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Terapkan',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _judul(String teks) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(teks,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700, color: kTeks)),
      );

  Widget _chipRating(double nilai, String label) {
    final terpilih = _ratingMin == nilai;
    return ChoiceChip(
      label: Text(label),
      selected: terpilih,
      showCheckmark: false,
      onSelected: (_) => setState(() => _ratingMin = nilai),
      selectedColor: kEmas,
      backgroundColor: Colors.white,
      side: BorderSide(color: terpilih ? kEmas : kGaris),
      labelStyle: TextStyle(
        fontSize: 12.5,
        fontWeight: terpilih ? FontWeight.w700 : FontWeight.w400,
        color: terpilih ? kTeks : kAbu,
      ),
    );
  }

  Widget _chipUrutan(String nilai, String label) {
    final terpilih = _urutan == nilai;
    return ChoiceChip(
      label: Text(label),
      selected: terpilih,
      showCheckmark: false,
      onSelected: (_) => setState(() => _urutan = nilai),
      selectedColor: kEmas,
      backgroundColor: Colors.white,
      side: BorderSide(color: terpilih ? kEmas : kGaris),
      labelStyle: TextStyle(
        fontSize: 12.5,
        fontWeight: terpilih ? FontWeight.w700 : FontWeight.w400,
        color: terpilih ? kTeks : kAbu,
      ),
    );
  }
}

// ==================== SARING + URUTKAN ====================

/// Saring & urutkan daftar layanan berdasarkan filter.
/// items = List<Map<String, dynamic>> — misal dari
/// db.collection('layanan').get() lalu docs.map((d) => d.data()).
/// Nama field dicari dari beberapa kandidat supaya cocok dengan
/// struktur data Firestore apa pun. Item tanpa data rating/jarak
/// TETAP ditampilkan (hanya tidak ikut tersaring/terurut dari itu).
List<Map<String, dynamic>> saringLayanan(
    List<Map<String, dynamic>> items, FilterLayanan f) {
  dynamic ambil(Map<String, dynamic> m, List<String> kunci) {
    for (final k in kunci) {
      final v = m[k];
      if (v != null && v.toString().trim().isNotEmpty) return v;
    }
    return null;
  }

  double? keAngka(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.replaceAll(',', '.'));
    return null;
  }

  double? ratingOf(Map<String, dynamic> m) => keAngka(
      ambil(m, ['rating', 'ratingRata', 'rating_rata', 'nilaiRating']));
  double? jarakOf(Map<String, dynamic> m) =>
      keAngka(ambil(m, ['jarak', 'jarakKm', 'jarak_km', 'distance']));
  int? ulasanOf(Map<String, dynamic> m) => keAngka(
          ambil(m, ['jumlahUlasan', 'jumlah_ulasan', 'ulasan', 'reviews']))
      ?.toInt();
  String namaOf(Map<String, dynamic> m) =>
      (ambil(m, ['nama', 'name', 'namaLayanan', 'namaFaskes']) ?? '')
          .toString();

  // --- saring ---
  final hasil = items.where((m) {
    if (f.ratingMin > 0) {
      final r = ratingOf(m);
      if (r != null && r < f.ratingMin) return false;
    }
    if (f.jarakMax < 50) {
      final j = jarakOf(m);
      if (j != null && j > f.jarakMax) return false;
    }
    return true;
  }).toList();

  // --- urutkan ---
  if (f.urutan == 'rating') {
    hasil.sort((a, b) => (ratingOf(b) ?? -1).compareTo(ratingOf(a) ?? -1));
  } else if (f.urutan == 'ulasan') {
    hasil.sort((a, b) => (ulasanOf(b) ?? -1).compareTo(ulasanOf(a) ?? -1));
  } else if (f.urutan == 'nama') {
    hasil.sort((a, b) =>
        namaOf(a).toLowerCase().compareTo(namaOf(b).toLowerCase()));
  } else {
    // terdekat
    hasil.sort((a, b) => (jarakOf(a) ?? 1e9).compareTo(jarakOf(b) ?? 1e9));
  }
  return hasil;
}