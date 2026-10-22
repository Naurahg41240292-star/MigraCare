import 'package:flutter/material.dart';
import '../models/obat.dart';
import '../services/notifikasi_service.dart';

class TambahObatPage extends StatefulWidget {
  const TambahObatPage({super.key});

  @override
  State<TambahObatPage> createState() => _TambahObatPageState();
}

class _TambahObatPageState extends State<TambahObatPage> {
  static const Color background = Color(0xFFFAF4EA);
  static const Color fieldFill = Color(0xFFFBEED8);
  static const Color fieldBorder = Color(0xFFE3BC77);
  static const Color orange = Color(0xFFDE8500);
  static const Color textDark = Color(0xFF33261A);
  static const Color textGrey = Color(0xFF9C948A);
  static const Color surface = Colors.white;
  static const Color outline = Color(0xFFEDE3D4);

  final _namaC = TextEditingController();
  final _dosisC = TextEditingController();
  final _bentukC = TextEditingController(text: 'Tablet');
  final _catatanC = TextEditingController();
  final _catatanMinumC = TextEditingController();

  String _aturanPakai = '2x sehari';
  static const _pilihanAturan = ['1x sehari', '2x sehari', '3x sehari'];

  // ===== LIST JAM CUSTOM (bisa diubah user via TimePicker) =====
  // Default ngikutin aturan pakai, tapi user bisa edit bebas
  List<TimeOfDay> _jamList = [];

  // Label untuk masing-masing slot jam (estetika doang)
  static const _labelJam = ['Pagi', 'Siang', 'Malam'];
  static const _ikonJam = [Icons.wb_sunny, Icons.light_mode, Icons.nights_stay];

  @override
  void initState() {
    super.initState();
    _resetJamDariAturan();
  }

  @override
  void dispose() {
    _namaC.dispose();
    _dosisC.dispose();
    _bentukC.dispose();
    _catatanC.dispose();
    _catatanMinumC.dispose();
    super.dispose();
  }

  /// Reset jam ke default berdasarkan aturan pakai
  void _resetJamDariAturan() {
    switch (_aturanPakai) {
      case '1x sehari':
        _jamList = [const TimeOfDay(hour: 8, minute: 0)];
        break;
      case '2x sehari':
        _jamList = [
          const TimeOfDay(hour: 8, minute: 0),
          const TimeOfDay(hour: 20, minute: 0),
        ];
        break;
      case '3x sehari':
        _jamList = [
          const TimeOfDay(hour: 8, minute: 0),
          const TimeOfDay(hour: 14, minute: 0),
          const TimeOfDay(hour: 20, minute: 0),
        ];
        break;
      default:
        _jamList = [const TimeOfDay(hour: 8, minute: 0)];
    }
  }

  /// Format TimeOfDay → "HH.MM" (format yang dipakai di model Obat)
  String _formatJam(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h.$m';
  }

  /// Format TimeOfDay → "HH:MM" (untuk tampilan UI)
  String _formatJamUI(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Buka TimePicker saat user tap card jam
  Future<void> _bukaTimePicker(int index) async {
    final terpilih = await showTimePicker(
      context: context,
      initialTime: _jamList[index],
      helpText: 'Pilih jam minum obat',
      cancelText: 'Batal',
      confirmText: 'Pilih',
      hourLabelText: 'Jam',
      minuteLabelText: 'Menit',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: orange,
                ),
            timePickerTheme: const TimePickerThemeData(
              hourMinuteColor: fieldFill,
              dialHandColor: orange,
            ),
          ),
          child: child!,
        );
      },
    );

    if (terpilih != null) {
      setState(() {
        _jamList[index] = terpilih;
      });
    }
  }

  // ============ _simpan() DENGAN JAM CUSTOM ============
  Future<void> _simpan() async {
    final nama = _namaC.text.trim();
    if (nama.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama obat wajib diisi ya 😊')),
      );
      return;
    }

    // Validasi: pastikan semua jam sudah diisi
    if (_jamList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jam minum obat belum diatur')),
      );
      return;
    }

    // Konversi List<TimeOfDay> → List<String> "HH.MM"
    final jamListString = _jamList.map(_formatJam).toList();

    final obatBaru = Obat(
      id: PengingatStore.buatId(),
      nama: nama,
      dosis: _dosisC.text.trim(),
      bentukSediaan:
          _bentukC.text.trim().isEmpty ? 'Tablet' : _bentukC.text.trim(),
      catatan: _catatanC.text.trim(),
      aturanPakai: _aturanPakai,
      jamList: jamListString,
      catatanMinum: _catatanMinumC.text.trim(),
    );

    // 1. Simpan ke store lokal
    PengingatStore.instance.tambahObat(obatBaru);

    // 2. Jadwalkan notifikasi untuk semua jam
    try {
      await NotificationService.instance.jadwalkanObat(obatBaru);
    } catch (e) {
      debugPrint('Gagal jadwalkan notifikasi: $e');
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Obat "$nama" berhasil ditambahkan ✓')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        iconTheme: const IconThemeData(color: textDark),
        title: const Text('Tambah Obat',
            style: TextStyle(color: textDark, fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Nama Obat'),
            _textField(_namaC, hint: 'Contoh: Topiramate'),
            const SizedBox(height: 16),

            _label('Dosis'),
            _textField(_dosisC, hint: 'Contoh: 50 mg'),
            const Text('*Masukkan dosis sesuai pada resep',
                style: TextStyle(fontSize: 11, color: textGrey)),
            const SizedBox(height: 16),

            _label('Bentuk Sediaan'),
            _textField(_bentukC, hint: 'Tablet / Kapsul / Sirup'),
            const SizedBox(height: 16),

            _label('Catatan (Opsional)'),
            _textField(_catatanC,
                hint: 'Contoh: Jangan diminum bersama kopi', maxLines: 3),
            const SizedBox(height: 16),

            // ===== ATURAN PAKAI (sekaligus tentukan jumlah slot jam) =====
            _label('Aturan Pakai'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: fieldFill,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: fieldBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _aturanPakai,
                  isExpanded: true,
                  items: _pilihanAturan
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() {
                      _aturanPakai = v;
                      _resetJamDariAturan();
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ===== JAM MINUM (CUSTOM — pakai TimePicker) =====
            Row(
              children: [
                const Expanded(
                  child: Text('Jam Minum',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: textDark)),
                ),
                TextButton.icon(
                  onPressed: () => setState(_resetJamDariAturan),
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Reset',
                      style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(foregroundColor: orange),
                ),
              ],
            ),
            const Text(
              'Ketuk kartu jam untuk mengubah waktunya sesuai keinginanmu.',
              style: TextStyle(fontSize: 11.5, color: textGrey),
            ),
            const SizedBox(height: 8),
            _buildJamList(),
            const SizedBox(height: 16),

            _label('Catatan Minum (Opsional)'),
            _textField(_catatanMinumC, hint: 'Contoh: Diminum setelah makan'),
            const SizedBox(height: 32),

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
                child: const Text('Simpan Obat',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== WIDGET: LIST JAM (CUSTOM TIMEPICKER) =====
  Widget _buildJamList() {
    return Column(
      children: List.generate(_jamList.length, (i) {
        final jam = _jamList[i];
        final label = i < _labelJam.length ? _labelJam[i] : 'Jam ${i + 1}';
        final ikon = i < _ikonJam.length ? _ikonJam[i] : Icons.schedule;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: () => _bukaTimePicker(i),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: outline),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: fieldFill,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(ikon, color: orange, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label,
                            style: const TextStyle(
                                fontSize: 11, color: textGrey)),
                        const SizedBox(height: 2),
                        Text(_formatJamUI(jam),
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: textDark,
                            )),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: fieldFill,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.edit_rounded, size: 14, color: orange),
                        SizedBox(width: 4),
                        Text('Ubah',
                            style: TextStyle(
                                fontSize: 11,
                                color: orange,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 14, color: textDark)),
      );

  Widget _textField(TextEditingController controller,
      {String? hint, int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: fieldFill,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: fieldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: orange, width: 1.5),
        ),
      ),
    );
  }
}