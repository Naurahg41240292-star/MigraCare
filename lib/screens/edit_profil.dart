import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../models/profil_pengguna.dart';
import 'profil.dart' show AppColors, AvatarPengguna;

/// ==========================================================================
///  MIGRACARE — Halaman Edit Profil
///  File: lib/screens/edit_profil.dart
///  - Muat data dari Firestore (users/{uid}/profile)
///  - Simpan perubahan ke Firestore (merge)
///  - Telepon maksimal 13 digit
/// ==========================================================================

class EditProfilPage extends StatefulWidget {
  const EditProfilPage({super.key});

  @override
  State<EditProfilPage> createState() => _EditProfilPageState();
}

class _EditProfilPageState extends State<EditProfilPage> {
  final _namaC = TextEditingController();
  final _teleponC = TextEditingController();
  final _bioC = TextEditingController();

  String _email = '';
  String _tanggalTeks = '';
  DateTime? _tanggal;
  String? _jenisKelamin;
  String? _fotoPath;

  bool _loading = true;
  bool _menyimpan = false;

  final _picker = ImagePicker();

  static const List<String> _bulan = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  @override
  void initState() {
    super.initState();
    _muatProfil();
  }

  @override
  void dispose() {
    _namaC.dispose();
    _teleponC.dispose();
    _bioC.dispose();
    super.dispose();
  }

  // ============================ MUAT DATA ============================
  Future<void> _muatProfil() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      String email = user?.email ?? '';
      String nama = '';
      String telepon = '';
      String tanggal = '';
      String? jenisKelamin;
      String bio = '';

      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          final data = doc.data()!;
          final profile =
              (data['profile'] as Map<String, dynamic>?) ?? {};
          nama = (profile['namaLengkap'] ??
                  data['akun']?['namaLengkap'] ??
                  '') as String;
          telepon = (profile['noTelepon'] ?? '') as String;
          tanggal = (profile['tanggalLahir'] ?? '') as String;
          final jk = (profile['jenisKelamin'] ?? '') as String;
          jenisKelamin = jk.isEmpty ? null : jk;
          bio = (profile['bio'] ?? '') as String;
        }
      }

      if (!mounted) return;
      setState(() {
        _namaC.text = nama;
        _teleponC.text = telepon;
        _tanggalTeks = tanggal;
        _tanggal = _parseTanggal(tanggal);
        _jenisKelamin = jenisKelamin;
        _bioC.text = bio;
        _email = email;
        _fotoPath = ProfilPengguna.instance.fotoPath;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  /// Parse "17 Februari 2003" → DateTime (null kalau gagal)
  DateTime? _parseTanggal(String s) {
    final parts = s.trim().split(' ');
    if (parts.length != 3) return null;
    final i = _bulan.indexOf(parts[1]);
    final d = int.tryParse(parts[0]);
    final y = int.tryParse(parts[2]);
    if (i < 0 || d == null || y == null) return null;
    return DateTime(y, i + 1, d);
  }

  String _formatTanggal(DateTime d) => '${d.day} ${_bulan[d.month - 1]} ${d.year}';

  // ============================ AKSI ============================
  Future<void> _pilihTanggal() async {
    final hasil = await showDatePicker(
      context: context,
      initialDate: _tanggal ?? DateTime(2000),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.accentDark),
        ),
        child: child!,
      ),
    );
    if (hasil != null) {
      setState(() {
        _tanggal = hasil;
        _tanggalTeks = _formatTanggal(hasil);
      });
    }
  }

  Future<void> _pilihFoto() async {
    final sumber = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded,
                    color: AppColors.accentDark),
                title: const Text('Pilih dari Galeri'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_rounded,
                    color: AppColors.accentDark),
                title: const Text('Ambil Foto dengan Kamera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );
    if (sumber == null || !mounted) return;

    final img = await _picker.pickImage(
      source: sumber,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (img != null) {
      setState(() => _fotoPath = img.path);
    }
  }

  // ============================ SIMPAN ============================
  Future<void> _simpan() async {
    final nama = _namaC.text.trim();
    final telepon = _teleponC.text.trim();

    if (nama.isEmpty) {
      _showSnack('Nama lengkap tidak boleh kosong');
      return;
    }
    if (telepon.length > 13) {
      _showSnack('Nomor telepon maksimal 13 digit');
      return;
    }

    setState(() => _menyimpan = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showSnack('Sesi berakhir, silakan masuk ulang');
        return;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'profile': {
          'namaLengkap': nama,
          'noTelepon': telepon,
          'tanggalLahir': _tanggalTeks,
          'jenisKelamin': _jenisKelamin ?? '',
          'bio': _bioC.text.trim(),
        },
        'profilDiperbaruiPada': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // foto tetap disimpan lokal (path) — fitur avatar
      ProfilPengguna.instance.fotoPath = _fotoPath;

      if (!mounted) return;
      _showSnack('Profil berhasil disimpan ✅');
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) _showSnack('ERROR: $e');
    } finally {
      if (mounted) setState(() => _menyimpan = false);
    }
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
              borderRadius: BorderRadius.circular(10)),
        ),
      );
  }

  // ============================ UI ============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ================= HEADER =================
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(Icons.arrow_back_rounded,
                              color: AppColors.textDark),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Edit Profil',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: _menyimpan ? null : _simpan,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.accentDark,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4),
                          ),
                          child: _menyimpan
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                )
                              : const Text(
                                  'Simpan',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700),
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // ================= AVATAR =================
                    Center(
                      child: GestureDetector(
                        onTap: _pilihFoto,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            _fotoPath != null
                                ? CircleAvatar(
                                    radius: 56,
                                    backgroundImage:
                                        FileImage(File(_fotoPath!)),
                                  )
                                : AvatarPengguna(
                                    radius: 56,
                                    showBadge: false,
                                    nama: _namaC.text.isEmpty
                                        ? 'P'
                                        : _namaC.text,
                                  ),
                            Positioned(
                              right: -2,
                              bottom: -2,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: AppColors.accentDark,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.edit_rounded,
                                    size: 14, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Center(
                      child: Text(
                        'Ketuk foto untuk mengganti',
                        style: TextStyle(
                            fontSize: 11, color: AppColors.textGrey),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ================= FORM =================
                    _label('Nama Lengkap'),
                    _textField(_namaC, hint: 'Masukkan nama lengkap'),
                    const SizedBox(height: 14),

                    _label('Email'),
                    TextField(
                      readOnly: true,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textGrey),
                      decoration: _dekorasi(hint: _email),
                    ),
                    const SizedBox(height: 14),

                    _label('No. Telepon'),
                    TextField(
                      controller: _teleponC,
                      keyboardType: TextInputType.phone,
                      maxLength: 13,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textDark),
                      decoration:
                          _dekorasi(hint: 'Masukkan nomor telepon')
                              .copyWith(counterText: ''),
                    ),
                    const SizedBox(height: 14),

                    _label('Tanggal Lahir'),
                    TextField(
                      readOnly: true,
                      controller:
                          TextEditingController(text: _tanggalTeks),
                      onTap: _pilihTanggal,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textDark),
                      decoration: _dekorasi(hint: 'Pilih tanggal lahir')
                          .copyWith(
                        suffixIcon: const Icon(Icons.calendar_month_rounded,
                            size: 19, color: AppColors.textGrey),
                      ),
                    ),
                    const SizedBox(height: 14),

                    _label('Jenis Kelamin'),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.outline),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _jenisKelamin,
                        hint: const Text('Pilih jenis kelamin',
                            style: TextStyle(
                                fontSize: 13, color: AppColors.textGrey)),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded,
                            color: AppColors.textGrey),
                        items: const ['Perempuan', 'Laki-laki']
                            .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e,
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textDark))))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _jenisKelamin = v),
                      ),
                    ),
                    const SizedBox(height: 14),

                    _label('Bio (opsional)'),
                    TextField(
                      controller: _bioC,
                      maxLines: 4,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textDark),
                      decoration: _dekorasi(hint: 'Tulis sesuatu...'),
                    ),
                    const SizedBox(height: 24),

                    // ================= TOMBOL SIMPAN =================
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _menyimpan ? null : _simpan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentDark,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              AppColors.accentDark.withValues(alpha: 0.6),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _menyimpan
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: Colors.white))
                            : const Text(
                                'Simpan Perubahan',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

    // ============================ WIDGET KECIL ============================
  Widget _label(String teks) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          teks,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
      );

  Widget _textField(TextEditingController controller, {String? hint}) =>   // ← TAMBAHAN
      TextField(
        controller: controller,
        style: const TextStyle(fontSize: 13, color: AppColors.textDark),
        decoration: _dekorasi(hint: hint),
      );

  InputDecoration _dekorasi({String? hint}) => InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(fontSize: 13, color: AppColors.textGrey),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: AppColors.accentDark, width: 1.4),
        ),
      );
}