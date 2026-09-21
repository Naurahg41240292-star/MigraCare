import 'package:flutter/material.dart';

import '../theme.dart';
import '../services/screening_service.dart';
import 'hasil_analisis.dart';

/// ==========================================================================
///  MIGRACARE — Halaman Skrining (Migraine Monitor)
///  File: lib/screens/skrining.dart
/// ==========================================================================

abstract class _Sk {
  static const Color selected = Color(0xFFDD9438);
  static const Color chipBorder = Color(0xFFD8CDBB);
  static const Color control = Color(0xFFC9822E);
  static const Color skin = Color(0xFFF6DFC8);
  static const Color pain = Color(0xFFE04B37);
}

class _Lokasi {
  const _Lokasi(this.label, this.spots, {this.full = false});
  final String label;
  final List<Alignment> spots;
  final bool full;
}

class SkriningPage extends StatefulWidget {
  const SkriningPage({super.key});

  @override
  State<SkriningPage> createState() => _SkriningPageState();
}

class _SkriningPageState extends State<SkriningPage> {
  // ------------------------------ STATE FORM ------------------------------
  DateTime? _tanggalLahir;
  int? _intensitas;   // 0–3
  int? _durasi;       // 1–3
  int? _frekuensi;    // 1–8
  int? _karakter;     // 0–2
  final Set<int> _lokasi = {};
  final Set<String> _gejala = {};
  final Set<String> _visualAura = {};
  int? _sensory;      // 0–2
  final Set<int> _neuro = {};
  final Set<String> _pemicu = {};
  int? _riwayatKeluarga; // 1 = Ya, 0 = Tidak

  @override
  void initState() {
    super.initState();
    ScreeningService.instance.ensureLoaded();
  }

  // ------------------------------ DATA OPSI -------------------------------
  static const List<String> _frekuensiOpsi = [
    '1 Kali', '2 Kali', '3 Kali', '4 Kali',
    '5 Kali', '6 Kali', '7 Kali', '8 Kali',
  ];

  static const List<String> _karakterOpsi = ['Menusuk', 'Berdenyut', 'Menekan'];

  static const List<String> _gejalaOpsi = [
    'Nausea (Mual)',
    'Vomit (Muntah)',
    'Phonophobia (Sensitif suara)',
    'Photophobia (Sensitif cahaya)',
  ];

  static const List<String> _pemicuOpsi = [
    'Kurang Tidur', 'Stres', 'Makanan', 'Cuaca', 'Menstruasi', 'Lainnya',
  ];

  static const List<String> _visualAuraOpsi = [
    'Kilatan cahaya',
    'Bintik/titik pada penglihatan',
    'Garis/pola zig-zag',
    'Penglihatan menghilang/terganggu',
  ];

  static const List<String> _sensoryOpsi = ['Tidak ada', '1 gejala', '2 gejala'];

  static const List<String> _durasiOpsi = [
    '1–72 jam',
    '> 72 jam',
    'Terus-menerus',
  ];

  static const List<String> _intensitasOpsi = [
    'Tidak ada', 'Ringan', 'Sedang', 'Berat',
  ];

  static const List<String> _neuroOpsi = [
    'Kesulitan berbicara (Dysphasia)',
    'Gangguan bicara/artikulasi (Dysarthria)',
    'Pusing berputar (Vertigo)',
    'Telinga berdenging (Tinnitus)',
    'Gangguan pendengaran (Hypoacusis)',
    'Penglihatan ganda (Diplopia)',
    'Gangguan lapang penglihatan (Defect)',
    'Gangguan koordinasi (Ataxia)',
    'Gangguan kesadaran (Conscience)',
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

  static const List<int> _lokasiNilai = [2, 1, 1, 2, 1, 1, 1, 1];

  int get _lokasiFinal {
    if (_lokasi.isEmpty) return 0;
    return _lokasi.any((i) => _lokasiNilai[i] == 2) ? 2 : 1;
  }

  // ------------------------------ HELPER ----------------------------------
  int get _umur {
    final now = DateTime.now();
    final tgl = _tanggalLahir!;
    int umur = now.year - tgl.year;
    if (now.month < tgl.month || (now.month == tgl.month && now.day < tgl.day)) {
      umur--;
    }
    return umur;
  }

  String get _labelIntensitas =>
      _intensitas == null ? '-' : _intensitasOpsi[_intensitas!];

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
      initialDate: DateTime(2000),
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

  List<double> buildFeatureVector() => [
        _umur.toDouble(),
        (_durasi! + 1).toDouble(),
        (_frekuensi! + 1).toDouble(),
        _lokasiFinal.toDouble(),
        (_karakter! + 1).toDouble(),
        _intensitas!.toDouble(),
        _gejala.contains('Nausea (Mual)') ? 1 : 0,
        _gejala.contains('Vomit (Muntah)') ? 1 : 0,
        _gejala.contains('Phonophobia (Sensitif suara)') ? 1 : 0,
        _gejala.contains('Photophobia (Sensitif cahaya)') ? 1 : 0,
        _visualAura.length.toDouble(),
        _sensory!.toDouble(),
        for (int i = 0; i < 10; i++) _neuro.contains(i) ? 1 : 0,
        _riwayatKeluarga!.toDouble(),
      ];

  void _selanjutnya() {
    final kurang = <String>[
      if (_tanggalLahir == null) 'Tanggal Lahir',
      if (_durasi == null) 'Durasi',
      if (_frekuensi == null) 'Frequency',
      if (_karakter == null) 'Character',
      if (_intensitas == null) 'Intensitas',
      if (_lokasi.isEmpty) 'Lokasi Nyeri',
      if (_sensory == null) 'Gejala Sensorik',
      if (_riwayatKeluarga == null) 'Riwayat Keluarga',
    ];
    if (kurang.isNotEmpty) {
      _showSnack('Lengkapi dulu: ${kurang.join(', ')}');
      return;
    }

    if (_umur < 15 || _umur > 77) {
      _showSnack('Umur harus di rentang 15–77 tahun sesuai dataset.');
      return;
    }

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
                  _recap('Tanggal Lahir',
                      '${_formatTanggal(_tanggalLahir!)} (${_umur} th)'),
                  _recap('Intensitas', _labelIntensitas),
                  _recap('Durasi', _durasiOpsi[_durasi!]),
                  _recap('Frekuensi', '${_frekuensiOpsi[_frekuensi!]} / minggu'),
                  _recap('Karakter', _karakterOpsi[_karakter!]),
                  _recap('Lokasi Nyeri', lokasiLabel),
                  _recap('Gejala', _gejala.isEmpty ? '-' : _gejala.join(', ')),
                  _recap('Aura Visual',
                      _visualAura.isEmpty ? '-' : _visualAura.join(', ')),
                  _recap('Gejala Sensorik', _sensoryOpsi[_sensory!]),
                  _recap('Pemicu', _pemicu.isEmpty ? '-' : _pemicu.join(', ')),
                  _recap(
                    'Gejala Neurologis',
                    _neuro.isEmpty
                        ? '-'
                        : _neuro.map((i) => _neuroOpsi[i]).join(', '),
                  ),
                  _recap('Riwayat Keluarga',
                      _riwayatKeluarga == 1 ? 'Ya' : 'Tidak'),
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
              onPressed: () async {
                Navigator.of(context).pop();

                try {
                  await ScreeningService.instance.ensureLoaded();

                  final result =
                      ScreeningService.instance.predict(buildFeatureVector());
                  if (!mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HasilAnalisisPage(result: result),
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  _showSnack('ERROR: $e');
                }
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
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(_intensitasOpsi.length, (i) {
                  return _chip(
                    _intensitasOpsi[i],
                    _intensitas == i,
                    () => setState(() => _intensitas = i),
                  );
                }),
              ),
              const SizedBox(height: 20),

              // -------------------- DURASI ---------------------------------
              const _SectionTitle('Durasi'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(_durasiOpsi.length, (i) {
                  return _chip(
                    _durasiOpsi[i],
                    _durasi == i,
                    () => setState(() => _durasi = i),
                  );
                }),
              ),
              const SizedBox(height: 20),

              // -------------------- FREQUENCY ------------------------------
              const _SectionTitle(
                'Frequency',
                subtitle:
                    'Seberapa sering Anda mengalami migrain dalam seminggu?',
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: List.generate(4, (i) {
                        return _radioRow(_frekuensiOpsi[i], i, _frekuensi,
                            (v) => setState(() => _frekuensi = v));
                      }),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: List.generate(4, (i) {
                        final idx = i + 4;
                        return _radioRow(_frekuensiOpsi[idx], idx, _frekuensi,
                            (v) => setState(() => _frekuensi = v));
                      }),
                    ),
                  ),
                ],
              ),
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
                          () => setState(() => _gejala.contains(g)
                              ? _gejala.remove(g)
                              : _gejala.add(g)),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 20),

              // -------------------- AURA VISUAL ----------------------------
              const _SectionTitle(
                'Gangguan Visual (Aura)',
                subtitle: 'Pilih semua gangguan penglihatan yang Anda alami.',
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _visualAuraOpsi
                    .map((v) => _chip(
                          v,
                          _visualAura.contains(v),
                          () => setState(() => _visualAura.contains(v)
                              ? _visualAura.remove(v)
                              : _visualAura.add(v)),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 20),

              // -------------------- SENSORIK -------------------------------
              const _SectionTitle('Gejala Sensorik (Sensory)'),
              const SizedBox(height: 4),
              Row(
                children: List.generate(_sensoryOpsi.length, (i) {
                  return Expanded(
                    child: _radioRow(_sensoryOpsi[i], i, _sensory,
                        (v) => setState(() => _sensory = v)),
                  );
                }),
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
                          () => setState(() => _pemicu.contains(p)
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
                  onChanged: (v) =>
                      setState(() => v! ? _neuro.add(i) : _neuro.remove(i)),
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
                    child: _radioRow('Ya', 1, _riwayatKeluarga,
                        (v) => setState(() => _riwayatKeluarga = v)),
                  ),
                  Expanded(
                    child: _radioRow('Tidak', 0, _riwayatKeluarga,
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
    );
  }

  // -------------------------------------------------------------------------
  //  WIDGET KECIL
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
              _tanggalLahir == null
                  ? 'Pilih tanggal lahir'
                  : _formatTanggal(_tanggalLahir!),
              style: TextStyle(
                fontSize: 13,
                color: _tanggalLahir == null
                    ? AppColors.textGrey
                    : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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