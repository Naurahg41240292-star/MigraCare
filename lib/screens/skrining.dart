import 'package:flutter/material.dart';

import '../theme.dart';

/// ==========================================================================
///  MIGRACARE — Halaman Skrining (Migraine Monitor)
///  File: lib/screens/skrining.dart
/// ==========================================================================

/// Warna tambahan khusus halaman skrining
abstract class _Sk {
  static const Color selected = Color(0xFFDD9438); // chip/kartu terpilih
  static const Color chipBorder = Color(0xFFD8CDBB);
  static const Color control = Color(0xFFC9822E); // slider, radio, checkbox, tombol
  static const Color sliderInactive = Color(0xFFE7DFD2);
  static const Color skin = Color(0xFFF6DFC8); // warna kulit ilustrasi
  static const Color pain = Color(0xFFE04B37); // area nyeri
}

/// Satu pilihan lokasi nyeri (posisi titik nyeri pada ilustrasi kepala)
class _Lokasi {
  const _Lokasi(this.label, this.spots, {this.full = false});
  final String label;
  final List<Alignment> spots;
  final bool full; // true = seluruh kepala
}

class SkriningPage extends StatefulWidget {
  const SkriningPage({super.key});

  @override
  State<SkriningPage> createState() => _SkriningPageState();
}

class _SkriningPageState extends State<SkriningPage> {
  // ------------------------------ STATE FORM ------------------------------
  DateTime _tanggalLahir = DateTime(2001, 5, 28);
  double _intensitas = 6;
  final TextEditingController _durasiController =
      TextEditingController(text: '4');
  int? _frekuensi;
  int? _karakter;
  final Set<int> _lokasi = {6}; // sesuai desain: Belakang Kepala terpilih
  final Set<String> _gejala = {'Photophobia (Sensitif cahaya)'};
  final Set<String> _pemicu = {'Kurang Tidur', 'Cuaca'};
  final Set<int> _neuro = {};
  int? _riwayatKeluarga; // 0 = Ya, 1 = Tidak

  // ------------------------------ DATA OPSI -------------------------------
  static const List<String> _frekuensiOpsi = [
    '1 Kali',
    '2–3 kali',
    '4–5 kali',
    '> 5 kali',
  ];
  static const List<String> _karakterOpsi = ['Menusuk', 'Berdenyut', 'Menekan'];
  static const List<String> _gejalaOpsi = [
    'Nausea (Mual)',
    'Vomit (Muntah)',
    'Photophobia (Sensitif cahaya)',
    'Visual (Gangguan penglihatan)',
    'Phonophobia (Sensitif suara)',
  ];
  static const List<String> _pemicuOpsi = [
    'Kurang Tidur',
    'Stres',
    'Makanan',
    'Cuaca',
    'Menstruasi',
    'Lainnya',
  ];
  static const List<String> _neuroOpsi = [
    'Gangguan Sensorik (Sensory)',
    'Kesulitan berbicara (Dysphasia)',
    'Gangguan koordinasi (Ataxia)',
    'Penglihatan ganda (Diplopia)',
    'Telinga berdenging (Tinnitus)',
    'Gangguan pendengaran (Hypoacusis)',
    'Mati rasa / Kesemutan (Paresthesia)',
  ];
  static const List<_Lokasi> _lokasiOpsi = [
    _Lokasi('Sakit Kepala', [], full: true),
    _Lokasi('Satu Sisi Kepala', [Alignment(0.45, -0.1)]),
    _Lokasi('Samping Kepala', [Alignment(0.55, -0.35)]),
    _Lokasi('Dahi (Frontal)', [Alignment(0, -0.62)]),
    _Lokasi('Belakang Mata', [Alignment(-0.3, 0.1), Alignment(0.3, 0.1)]),
    _Lokasi('Sekitar Mata', [Alignment(-0.32, 0.05), Alignment(0.32, 0.05)]),
    _Lokasi('Belakang Kepala', [Alignment(0, 0.75)]),
    _Lokasi('Lainnya', [Alignment(0.6, 0.3)]),
  ];

  @override
  void dispose() {
    _durasiController.dispose();
    super.dispose();
  }

  // ------------------------------ HELPER ----------------------------------
  String get _labelIntensitas {
    if (_intensitas <= 3) return 'Ringan';
    if (_intensitas <= 7) return 'Sedang';
    return 'Berat';
  }

  String _formatTanggal(DateTime d) {
    const bulan = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return '${d.day} ${bulan[d.month - 1]} ${d.year}';
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.darkBrown,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }

  Future<void> _pilihTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalLahir,
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.accentDark),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _tanggalLahir = picked);
  }

  void _selanjutnya() {
    // Validasi field wajib
    final kurang = <String>[
      if (_frekuensi == null) 'Frequency',
      if (_karakter == null) 'Character',
      if (_lokasi.isEmpty) 'Lokasi Nyeri',
      if (_riwayatKeluarga == null) 'Riwayat Keluarga',
    ];
    if (kurang.isNotEmpty) {
      _showSnack('Lengkapi dulu: ${kurang.join(', ')}');
      return;
    }

    final durasi = _durasiController.text.trim();
    final lokasiLabel = _lokasi.map((i) => _lokasiOpsi[i].label).join(', ');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Ringkasan Skrining',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _recap('Tanggal Lahir', _formatTanggal(_tanggalLahir)),
                  _recap('Intensitas',
                      '$_labelIntensitas (${_intensitas.toInt()}/10)'),
                  _recap('Durasi', durasi.isEmpty ? '-' : '$durasi jam'),
                  _recap('Frekuensi', _frekuensiOpsi[_frekuensi!]),
                  _recap('Karakter', _karakterOpsi[_karakter!]),
                  _recap('Lokasi Nyeri', lokasiLabel),
                  _recap('Gejala', _gejala.isEmpty ? '-' : _gejala.join(', ')),
                  _recap('Pemicu', _pemicu.isEmpty ? '-' : _pemicu.join(', ')),
                  _recap(
                    'Gejala Neurologis',
                    _neuro.isEmpty
                        ? '-'
                        : _neuro.map((i) => _neuroOpsi[i]).join(', '),
                  ),
                  _recap(
                      'Riwayat Keluarga', _riwayatKeluarga == 0 ? 'Ya' : 'Tidak'),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Perbaiki',
                style: TextStyle(color: AppColors.textGrey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showSnack('✓ Data skrining tersimpan. Analisis AI segera hadir!');
                // TODO: nanti di sini Navigator.push ke halaman hasil analisis
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _Sk.control,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Lanjutkan',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _recap(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10.5,
              color: AppColors.textGrey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------ BUILD -----------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Migraine Monitor',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Catat episode migrain Anda hari ini.',
                style: TextStyle(fontSize: 12.5, color: AppColors.textGrey),
              ),
              const SizedBox(height: 20),

              // -------------------- TANGGAL LAHIR --------------------------
              const _SectionTitle('Tanggal Lahir'),
              const SizedBox(height: 8),
              _tanggalField(),
              const SizedBox(height: 20),

              // -------------------- INTENSITAS NYERI -----------------------
              const _SectionTitle('Intensitas Nyeri'),
              const SizedBox(height: 8),
              _intensitasCard(),
              const SizedBox(height: 20),

              // -------------------- DURASI ---------------------------------
              const _SectionTitle('Durasi'),
              const SizedBox(height: 8),
              _durasiField(),
              const SizedBox(height: 20),

              // -------------------- FREQUENCY ------------------------------
              const _SectionTitle(
                'Frequency',
                subtitle:
                    'Seberapa sering Anda mengalami migrain dalam seminggu?',
              ),
              const SizedBox(height: 4),
              ...List.generate(_frekuensiOpsi.length, (i) {
                return _radioRow(
                  _frekuensiOpsi[i],
                  i,
                  _frekuensi,
                  (v) => setState(() => _frekuensi = v),
                );
              }),
              const SizedBox(height: 20),

              // -------------------- CHARACTER ------------------------------
              const _SectionTitle(
                'Character',
                subtitle: 'Bagaimana karakter nyeri yang Anda rasakan?',
              ),
              const SizedBox(height: 4),
              Row(
                children: List.generate(_karakterOpsi.length, (i) {
                  return Expanded(
                    child: _radioRow(
                      _karakterOpsi[i],
                      i,
                      _karakter,
                      (v) => setState(() => _karakter = v),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),

              // -------------------- LOKASI NYERI ---------------------------
              const _SectionTitle('Lokasi Nyeri'),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.72,
                children:
                    List.generate(_lokasiOpsi.length, (i) => _lokasiCard(i)),
              ),
              const SizedBox(height: 20),

              // -------------------- GEJALA ---------------------------------
              const _SectionTitle(
                'Gejala Yang Dirasakan',
                subtitle: 'Pilih gejala yang Anda alami.',
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _gejalaOpsi
                    .map((g) => _chip(
                          g,
                          _gejala.contains(g),
                          () => setState(() =>
                              _gejala.contains(g)
                                  ? _gejala.remove(g)
                                  : _gejala.add(g)),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 20),

              // -------------------- PEMICU ---------------------------------
              const _SectionTitle(
                'Pemicu (Trigger)',
                subtitle: 'Apa yang mungkin memicu migrain anda?',
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _pemicuOpsi
                    .map((p) => _chip(
                          p,
                          _pemicu.contains(p),
                          () => setState(() =>
                              _pemicu.contains(p)
                                  ? _pemicu.remove(p)
                                  : _pemicu.add(p)),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 20),

              // -------------------- GEJALA NEUROLOGIS ----------------------
              const _SectionTitle('Gejala Neurologis'),
              const SizedBox(height: 4),
              ...List.generate(_neuroOpsi.length, (i) {
                return CheckboxListTile(
                  value: _neuro.contains(i),
                  onChanged: (v) => setState(
                      () => v! ? _neuro.add(i) : _neuro.remove(i)),
                  title: Text(
                    _neuroOpsi[i],
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textDark,
                    ),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  contentPadding: EdgeInsets.zero,
                  activeColor: _Sk.control,
                  checkboxShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
              const SizedBox(height: 12),

              // -------------------- RIWAYAT KELUARGA -----------------------
              const _SectionTitle('Riwayat Keluarga Migrain ?'),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: _radioRow('Ya', 0, _riwayatKeluarga,
                        (v) => setState(() => _riwayatKeluarga = v)),
                  ),
                  Expanded(
                    child: _radioRow('Tidak', 1, _riwayatKeluarga,
                        (v) => setState(() => _riwayatKeluarga = v)),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // -------------------- TOMBOL SELANJUTNYA ---------------------
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selanjutnya,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _Sk.control,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Selanjutnya',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // CATATAN: bottom nav TIDAK ADA di sini — nav dipasang di HalamanUtama.
    );
  }

  // -------------------------------------------------------------------------
  //  WIDGET KECIL (field, kartu, chip, radio, kartu lokasi)
  // -------------------------------------------------------------------------

  Widget _tanggalField() {
    return InkWell(
      onTap: _pilihTanggal,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.outline),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_rounded,
                size: 20, color: AppColors.textGrey),
            const SizedBox(width: 10),
            Text(
              _formatTanggal(_tanggalLahir),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _intensitasCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$_labelIntensitas (${_intensitas.toInt()}/10)',
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 5,
              activeTrackColor: _Sk.control,
              inactiveTrackColor: _Sk.sliderInactive,
              thumbColor: const Color(0xFFA96817),
              overlayColor: const Color(0xFFC9822E).withValues(alpha: 0.15),
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: _intensitas,
              min: 0,
              max: 10,
              divisions: 10,
              label: '${_intensitas.toInt()}',
              onChanged: (v) => setState(() => _intensitas = v),
            ),
          ),
          const Row(
            children: [
              _SkalaLabel('0'),
              _SkalaLabel('2'),
              _SkalaLabel('4'),
              _SkalaLabel('6'),
              _SkalaLabel('8'),
              _SkalaLabel('10'),
            ],
          ),
          const SizedBox(height: 2),
          const Row(
            children: [
              Expanded(
                child: Text('Ringan',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textGrey)),
              ),
              Expanded(
                child: Text('Sedang',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark)),
              ),
              Expanded(
                child: Text('Berat',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textGrey)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _durasiField() {
    return TextField(
      controller: _durasiController,
      keyboardType: TextInputType.number,
      style: const TextStyle(fontSize: 13, color: AppColors.textDark),
      decoration: InputDecoration(
        hintText: 'Contoh: 4',
        hintStyle: const TextStyle(fontSize: 13, color: AppColors.textGrey),
        prefixIcon: const Icon(Icons.schedule_rounded,
            size: 20, color: AppColors.textGrey),
        suffixText: 'Jam',
        suffixStyle:
            const TextStyle(fontSize: 12.5, color: AppColors.textGrey),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _Sk.control, width: 1.4),
        ),
      ),
    );
  }

  /// Baris radio custom (lingkaran amber, sesuai desain)
  Widget _radioRow(
      String label, int value, int? group, ValueChanged<int?> onChanged) {
    final selected = group == value;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? _Sk.control : Colors.transparent,
                border: Border.all(
                  color: selected ? _Sk.control : const Color(0xFFC9BFB0),
                  width: 1.8,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 13, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.w400,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Chip pilihan (Gejala & Pemicu)
  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _Sk.selected : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? _Sk.selected : _Sk.chipBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : AppColors.textDark,
          ),
        ),
      ),
    );
  }

  /// Kartu lokasi nyeri (ilustrasi kepala + titik nyeri)
  Widget _lokasiCard(int index) {
    final item = _lokasiOpsi[index];
    final selected = _lokasi.contains(index);
    return GestureDetector(
      onTap: () => setState(
          () => selected ? _lokasi.remove(index) : _lokasi.add(index)),
      child: Container(
        padding: const EdgeInsets.fromLTRB(6, 8, 6, 8),
        decoration: BoxDecoration(
          color: selected ? _Sk.selected : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? _Sk.selected : AppColors.outline,
          ),
        ),
        child: Column(
          children: [
            Expanded(child: _PainFace(lokasi: item)),
            const SizedBox(height: 6),
            Text(
              item.label,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 8.5,
                height: 1.2,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
//  WIDGET PENDUKUNG
// ===========================================================================

/// Judul section + subjudul opsional
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 3),
          Text(
            subtitle!,
            style: const TextStyle(
              fontSize: 11.5,
              color: AppColors.textGrey,
            ),
          ),
        ],
      ],
    );
  }
}

/// Angka skala di bawah slider
class _SkalaLabel extends StatelessWidget {
  const _SkalaLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 10, color: AppColors.textGrey),
      ),
    );
  }
}

/// Ilustrasi kepala dengan titik nyeri (digambar programatik — tanpa aset)
class _PainFace extends StatelessWidget {
  const _PainFace({required this.lokasi});

  final _Lokasi lokasi;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 38,
        height: 48,
        decoration: BoxDecoration(
          color: _Sk.skin,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: const Color(0xFFE8D0B4)),
        ),
        child: Stack(
          children: [
            if (lokasi.full)
              // Nyeri di seluruh kepala → gradasi merah menyeluruh
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(19),
                    gradient: RadialGradient(
                      radius: 1.1,
                      colors: [
                        _Sk.pain.withValues(alpha: 0.85),
                        _Sk.pain.withValues(alpha: 0.25),
                      ],
                    ),
                  ),
                ),
              )
            else
              // Titik nyeri pada posisi tertentu
              for (final spot in lokasi.spots)
                Align(
                  alignment: spot,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _Sk.pain.withValues(alpha: 0.9),
                          _Sk.pain.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}