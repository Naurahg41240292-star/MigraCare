import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme.dart';
import 'syarat_ketentuan.dart';

/// Halaman "Lengkapi Profil Anda" — muncul setelah daftar akun
class LengkapiProfilPage extends StatefulWidget {
  const LengkapiProfilPage({super.key});

  @override
  State<LengkapiProfilPage> createState() => _LengkapiProfilPageState();
}

class _LengkapiProfilPageState extends State<LengkapiProfilPage> {
  final _namaController = TextEditingController();
  final _teleponController = TextEditingController();
  DateTime? _tanggalLahir;
  String? _jenisKelamin;
  bool _menyimpan = false;

  static const Color kontrol = Color(0xFFC9822E);

  @override
  void dispose() {
    _namaController.dispose();
    _teleponController.dispose();
    super.dispose();
  }

  /// Pastikan ada uid (sementara anonymous — nanti diganti login asli)
  Future<String> _ensureUid() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) return user.uid;
    final cred = await FirebaseAuth.instance.signInAnonymously();
    return cred.user!.uid;
  }

  String _formatTanggal(DateTime d) {
    const bulan = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return '${d.day} ${bulan[d.month - 1]} ${d.year}';
  }

  Future<void> _pilihTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.fromSeed(seedColor: kontrol),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _tanggalLahir = picked);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.darkBrown,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
  }

  /// Simpan profil ke Firestore: users/{uid} (merge — screenings tetap aman)
  Future<void> _simpanDanLanjut() async {
    final nama = _namaController.text.trim();
    final telepon = _teleponController.text.trim();

    final kurang = <String>[
      if (nama.isEmpty) 'Nama Lengkap',
      if (telepon.isEmpty) 'No. Telepon',
      if (_tanggalLahir == null) 'Tanggal Lahir',
      if (_jenisKelamin == null) 'Jenis Kelamin',
    ];
    if (kurang.isNotEmpty) {
      _showSnack('Lengkapi dulu: ${kurang.join(', ')}');
      return;
    }

    setState(() => _menyimpan = true);
    try {
      final uid = await _ensureUid();
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'profile': {
          'namaLengkap': nama,
          'noTelepon': telepon,
          'tanggalLahir': _formatTanggal(_tanggalLahir!),
          'jenisKelamin': _jenisKelamin,
        },
        'profilDiperbaruiPada': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SyaratKetentuanPage()),
      );
    } catch (e) {
      if (mounted) _showSnack('ERROR: $e');
    } finally {
      if (mounted) setState(() => _menyimpan = false);
    }
  }

  void _lewati() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SyaratKetentuanPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
              const SizedBox(height: 16),

              const Text('Lengkapi Profil Anda',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark)),
              const SizedBox(height: 6),
              const Text(
                'Informasi ini membantu kami memberikan pengalaman yang lebih profesional',
                style: TextStyle(fontSize: 12, color: AppColors.textGrey),
              ),
              const SizedBox(height: 20),

              // ---------- AVATAR ----------
              Center(
                child: Stack(
                  children: [
                    // Ganti dengan Image.asset('assets/images/profil.png') kalau ilustrasi Figma sudah diekspor
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6DFC8),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.outline, width: 2),
                      ),
                      child: const Icon(Icons.person_rounded,
                          size: 44, color: Color(0xFFC9822E)),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                            color: kontrol, shape: BoxShape.circle),
                        child: const Icon(Icons.edit_rounded,
                            size: 13, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // ---------- NAMA ----------
              const _Label('Nama Lengkap'),
              const SizedBox(height: 6),
              _inputField(
                controller: _namaController,
                hint: 'Masukkan nama lengkap anda',
              ),
              const SizedBox(height: 14),

              // ---------- TELEPON ----------
              const _Label('No. Telepon'),
              const SizedBox(height: 6),
              _inputField(
                controller: _teleponController,
                hint: 'Masukkan nomor telepon',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 14),

              // ---------- TANGGAL LAHIR ----------
              const _Label('Tanggal Lahir'),
              const SizedBox(height: 6),
              InkWell(
                onTap: _pilihTanggal,
                borderRadius: BorderRadius.circular(10),
                child: _inputContainer(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _tanggalLahir == null
                              ? 'Masukkan tanggal lahir Anda'
                              : _formatTanggal(_tanggalLahir!),
                          style: TextStyle(
                              fontSize: 13,
                              color: _tanggalLahir == null
                                  ? AppColors.textGrey
                                  : AppColors.textDark),
                        ),
                      ),
                      const Icon(Icons.calendar_month_rounded,
                          size: 20, color: AppColors.textGrey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ---------- JENIS KELAMIN ----------
              const _Label('Jenis Kelamin'),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: _dekorasi(),
                child: DropdownButtonFormField<String>(
                  value: _jenisKelamin,
                  hint: const Text('Pilih jenis kelamin',
                      style:
                          TextStyle(fontSize: 13, color: AppColors.textGrey)),
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 14)),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textGrey),
                  items: const ['Laki-laki', 'Perempuan']
                      .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textDark))))
                      .toList(),
                  onChanged: (v) => setState(() => _jenisKelamin = v),
                ),
              ),
              const SizedBox(height: 26),

              // ---------- TOMBOL ----------
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _menyimpan ? null : _simpanDanLanjut,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kontrol,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: kontrol.withValues(alpha: 0.6),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _menyimpan
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Simpan dan Lanjutkan',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: _lewati,
                  child: const Text('Lewati',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: kontrol)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration get _dekorInput => InputDecoration(
        hintText: '',
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        enabledBorder: _border(),
        focusedBorder: _border(warna: kontrol, tebal: 1.4),
      );

  OutlineInputBorder _border({Color warna = AppColors.outline, double tebal = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: warna, width: tebal),
      );

  BoxDecoration _dekorasi() => BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.outline),
      );

  Widget _inputContainer({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: _dekorasi(),
        child: child,
      );

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
  }) =>
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 13, color: AppColors.textDark),
        decoration: _dekorInput.copyWith(hintText: hint),
      );
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark));
  }
}