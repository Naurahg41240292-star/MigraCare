import 'package:flutter/material.dart';
import '../models/obat.dart';

/// ==========================================================================
///  MIGRACARE — Halaman Tambah Obat
///  File: lib/screens/tambah_obat.dart
/// ==========================================================================

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

  final _namaC = TextEditingController();
  final _dosisC = TextEditingController();
  final _bentukC = TextEditingController(text: 'Tablet');
  final _catatanC = TextEditingController();
  final _catatanMinumC = TextEditingController();

  String _aturanPakai = '2x sehari';
  static const _pilihanAturan = ['1x sehari', '2x sehari', '3x sehari', 'Lainnya'];

  @override
  void dispose() {
    _namaC.dispose();
    _dosisC.dispose();
    _bentukC.dispose();
    _catatanC.dispose();
    _catatanMinumC.dispose();
    super.dispose();
  }

  /// Jam minum otomatis mengikuti aturan pakai
  List<String> _jamDariAturan(String aturan) {
    switch (aturan) {
      case '1x sehari':
        return ['08.00'];
      case '2x sehari':
        return ['08.00', '20.00'];
      case '3x sehari':
        return ['08.00', '14.00', '20.00'];
      default:
        return ['08.00'];
    }
  }

  void _simpan() {
    final nama = _namaC.text.trim();
    if (nama.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama obat wajib diisi ya 😊')),
      );
      return;
    }

    PengingatStore.instance.tambahObat(Obat(
      id: PengingatStore.buatId(),
      nama: nama,
      dosis: _dosisC.text.trim(),
      bentukSediaan:
          _bentukC.text.trim().isEmpty ? 'Tablet' : _bentukC.text.trim(),
      catatan: _catatanC.text.trim(),
      aturanPakai: _aturanPakai,
      jamList: _jamDariAturan(_aturanPakai),
      catatanMinum: _catatanMinumC.text.trim(),
    ));

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
                  onChanged: (v) =>
                      setState(() => _aturanPakai = v ?? _aturanPakai),
                ),
              ),
            ),
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