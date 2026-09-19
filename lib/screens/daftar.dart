import 'package:flutter/material.dart';
import 'masuk.dart';

/// ==========================================================================
///  MIGRACARE — Halaman Buat Akun (Registrasi)
///  File: lib/screens/daftar.dart
/// ==========================================================================

abstract class _Dr {
  static const Color bg = Color(0xFFFAF4EA);
  static const Color gold = Color(0xFFC08A2B);
  static const Color button = Color(0xFFD69348);
  static const Color textDark = Color(0xFF33261A);
  static const Color textGrey = Color(0xFF9C948A);
  static const Color outline = Color(0xFFE5DCCB);
}

class DaftarPage extends StatefulWidget {
  const DaftarPage({super.key});

  @override
  State<DaftarPage> createState() => _DaftarPageState();
}

class _DaftarPageState extends State<DaftarPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _konfirmasiController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureKonfirmasi = true;
  bool _setuju = false;

  @override
  void dispose() {
    _namaController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _konfirmasiController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  //  VALIDASI
  // -------------------------------------------------------------------------
  String? _validasiNama(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama lengkap wajib diisi';
    }
    if (value.trim().length < 3) {
      return 'Nama minimal 3 karakter';
    }
    return null;
  }

  String? _validasiUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username wajib diisi';
    }
    if (value.trim().contains(' ')) {
      return 'Username tidak boleh mengandung spasi';
    }
    if (value.trim().length < 4) {
      return 'Username minimal 4 karakter';
    }
    return null;
  }

  String? _validasiEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email wajib diisi';
    }
    final pattern = RegExp(r'^[\w\.\-+]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!pattern.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? _validasiPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password wajib diisi';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  String? _validasiKonfirmasi(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password wajib diisi';
    }
    if (value != _passwordController.text) {
      return 'Konfirmasi password tidak sama';
    }
    return null;
  }

  // -------------------------------------------------------------------------
  //  AKSI DAFTAR
  // -------------------------------------------------------------------------
  void _daftar() {
    // Checkbox dicek dulu (di luar form)
    if (!_setuju) {
      _showSnack('Centang "Saya menyetujui syarat dan ketentuan" dulu ya.');
      return;
    }

    // Validasi seluruh form
    if (!_formKey.currentState!.validate()) {
      _showSnack('Periksa kembali data yang diisi.');
      return;
    }

    // TODO: kirim data ke server/Firebase di sini.
    // Untuk sekarang: tampilkan dialog sukses → arahkan ke halaman Masuk.
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Color(0xFFFDF3D7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Color(0xFFC99A2C),
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Akun Berhasil Dibuat!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _Dr.textDark,
                ),
              ),
            ],
          ),
          content: const Text(
            'Selamat bergabung di MigraCare. Silakan masuk dengan akun Anda.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.5,
              color: _Dr.textGrey,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            SizedBox(
              width: 160,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // tutup dialog
                  // Kembali ke halaman Masuk (bersihkan tumpukan daftar)
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const MasukPage()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _Dr.button,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Masuk Sekarang',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _Dr.textDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }

  // -------------------------------------------------------------------------
  //  BUILD
  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Dr.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------------- Tombol kembali -----------------------------
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: _Dr.textDark,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ---------------- Judul --------------------------------------
                const Text(
                  'Buat Akun MigraCare',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _Dr.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Isi data di bawah ini untuk membuat akun baru',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: _Dr.textDark,
                  ),
                ),
                const SizedBox(height: 28),

                // ---------------- Nama Lengkap -------------------------------
                const _Label('Nama Lengkap'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _namaController,
                  textCapitalization: TextCapitalization.words,
                  validator: _validasiNama,
                  style: const TextStyle(fontSize: 13, color: _Dr.textDark),
                  decoration:
                      _inputDecoration('Masukkan nama lengkap'),
                ),
                const SizedBox(height: 18),

                // ---------------- Username -----------------------------------
                const _Label('Username'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _usernameController,
                  validator: _validasiUsername,
                  style: const TextStyle(fontSize: 13, color: _Dr.textDark),
                  decoration: _inputDecoration('Masukkan username'),
                ),
                const SizedBox(height: 18),

                // ---------------- Email --------------------------------------
                const _Label('Email'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validasiEmail,
                  style: const TextStyle(fontSize: 13, color: _Dr.textDark),
                  decoration: _inputDecoration('Masukkan email'),
                ),
                const SizedBox(height: 18),

                // ---------------- Password -----------------------------------
                const _Label('Password'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: _validasiPassword,
                  style: const TextStyle(fontSize: 13, color: _Dr.textDark),
                  decoration:
                      _inputDecoration('Buat password').copyWith(
                    suffixIcon: IconButton(
                      onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: _Dr.textGrey,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // ---------------- Konfirmasi Password ------------------------
                const _Label('Konfirmasi Password'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _konfirmasiController,
                  obscureText: _obscureKonfirmasi,
                  validator: _validasiKonfirmasi,
                  style: const TextStyle(fontSize: 13, color: _Dr.textDark),
                  decoration:
                      _inputDecoration('Konfirmasi password').copyWith(
                    suffixIcon: IconButton(
                      onPressed: () => setState(() =>
                          _obscureKonfirmasi = !_obscureKonfirmasi),
                      icon: Icon(
                        _obscureKonfirmasi
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: _Dr.textGrey,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // ---------------- Setuju syarat & ketentuan ------------------
                Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _setuju,
                        onChanged: (v) =>
                            setState(() => _setuju = v ?? false),
                        activeColor: _Dr.button,
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        side: const BorderSide(
                            color: _Dr.outline, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Saya menyetujui ',
                      style: TextStyle(
                          fontSize: 12.5, color: _Dr.textDark),
                    ),
                    GestureDetector(
                      onTap: () => _showSnack(
                          'Halaman syarat & ketentuan segera hadir 😊'),
                      child: const Text(
                        'syarat dan ketentuan',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: _Dr.gold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // ---------------- Tombol DAFTAR ------------------------------
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _daftar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _Dr.button,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Daftar',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: _Dr.textGrey),
      errorStyle: const TextStyle(fontSize: 11, color: Color(0xFFC0392B)),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _Dr.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _Dr.button, width: 1.4),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFC0392B), width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFC0392B)),
      ),
    );
  }
}

/// Label field (tebal, di atas input)
class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: _Dr.textDark,
      ),
    );
  }
}