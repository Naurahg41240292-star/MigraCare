import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/profil_pengguna.dart';
import 'profil.dart' show AppColors, AvatarPengguna;

/// ==========================================================================
///  MIGRACARE — Halaman Edit Profil
///  File: lib/screens/edit_profil.dart
/// ==========================================================================

class EditProfilPage extends StatefulWidget {
  const EditProfilPage({super.key});

  @override
  State<EditProfilPage> createState() => _EditProfilPageState();
}

class _EditProfilPageState extends State<EditProfilPage> {
  final _namaC = TextEditingController();
  final _emailC = TextEditingController();
  final _telpC = TextEditingController();
  final _bioC = TextEditingController();
  final _tglC = TextEditingController();

  DateTime? _tgl;
  String _jenisKelamin = 'Perempuan';
  String? _fotoBaru;

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final p = ProfilPengguna.instance;
    _namaC.text = p.nama;
    _emailC.text = p.email;
    _telpC.text = p.noTelpon;
    _bioC.text = p.bio;
    _tgl = p.tanggalLahirDate;
    _tglC.text = p.tanggalLahir == '-' ? '' : p.tanggalLahir;
    _jenisKelamin = p.jenisKelamin;
  }

  @override
  void dispose() {
    _namaC.dispose();
    _emailC.dispose();
    _telpC.dispose();
    _bioC.dispose();
    _tglC.dispose();
    super.dispose();
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

  // ======================= PILIH FOTO (Galeri/Kamera) ======================
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

    if (sumber == null) return;
    final img = await _picker.pickImage(
      source: sumber,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (img != null) {
      setState(() => _fotoBaru = img.path);
    }
  }

  // ============================== TANGGAL LAHIR ============================
  Future<void> _pilihTanggal() async {
    final hasil = await showDatePicker(
      context: context,
      initialDate: _tgl ?? DateTime(2003, 2, 17),
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
        _tgl = hasil;
        _tglC.text = formatTanggal(hasil);
      });
    }
  }

  // ================================ SIMPAN =================================
  void _simpan() {
    if (_namaC.text.trim().isEmpty) {
      _showSnack('Nama lengkap tidak boleh kosong');
      return;
    }
    final p = ProfilPengguna.instance;
    p.nama = _namaC.text.trim();
    p.email = _emailC.text.trim();
    p.noTelpon = _telpC.text.trim();
    p.jenisKelamin = _jenisKelamin;
    p.bio = _bioC.text.trim();
    p.tanggalLahirDate = _tgl;
    if (_fotoBaru != null) p.fotoPath = _fotoBaru;

    Navigator.pop(context);
    // Snack ditampilkan lewat halaman Profil saat kembali? — tampilkan di sini
    // sebelum pop agar terlihat:
    _showSnack('Profil berhasil disimpan ✅');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= HEADER =================
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: AppColors.darkBrown,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Edit Profil',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _simpan,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.accentDark,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                    child: const Text(
                      'Simpan',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // ================= AVATAR =================
              Center(
                child: GestureDetector(
                  onTap: _pilihFoto,
                  child: AvatarPengguna(radius: 56),
                ),
              ),
              const SizedBox(height: 4),
              const Center(
                child: Text(
                  'Ketuk foto untuk mengganti',
                  style: TextStyle(fontSize: 11, color: AppColors.textGrey),
                ),
              ),
              const SizedBox(height: 20),

              // ================= FORM =================
              _label('Nama Lengkap'),
              _textField(_namaC, hint: 'Nama lengkapmu'),
              const SizedBox(height: 14),

              _label('Email'),
              _textField(_emailC, hint: 'email@contoh.com'),
              const SizedBox(height: 14),

              _label('No. Telpon'),
              _textField(_telpC, hint: '+62 ...'),
              const SizedBox(height: 14),

              _label('Tanggal Lahir'),
              TextField(
                controller: _tglC,
                readOnly: true,
                onTap: _pilihTanggal,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textDark),
                decoration: _dekorasi(
                  suffixIcon: const Icon(Icons.calendar_today_rounded,
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
                  items: ['Perempuan', 'Laki-laki']
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textDark)),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _jenisKelamin = v);
                  },
                  icon: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textGrey),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              _label('Bio (opsional)'),
              TextField(
                controller: _bioC,
                maxLines: 4,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textDark),
                decoration: _dekorasi(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ============================ WIDGET KECIL ===============================
  Widget _label(String teks) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          teks,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
      );

  InputDecoration _dekorasi({Widget? suffixIcon}) => InputDecoration(
        hintText: ' ',
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.accentDark),
        ),
        suffixIcon: suffixIcon,
      );

  Widget _textField(TextEditingController controller, {String? hint}) =>
      TextField(
        controller: controller,
        style: const TextStyle(fontSize: 13, color: AppColors.textDark),
        decoration: _dekorasi().copyWith(
          hintText: hint,
          hintStyle: const TextStyle(
              fontSize: 13, color: AppColors.textGrey),
        ),
      );
}