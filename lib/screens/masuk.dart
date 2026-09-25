import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'halaman_utama.dart';
import 'daftar.dart';
import 'lengkapi_profil.dart';
import '../services/profil_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// ==========================================================================
///  MIGRACARE — Halaman Masuk (Login)
///  File: lib/screens/masuk.dart
/// ==========================================================================

abstract class _Mk {
  static const Color bg = Color(0xFFFAF4EA);
  static const Color gold = Color(0xFFC08A2B);
  static const Color button = Color(0xFFD69348);
  static const Color textDark = Color(0xFF33261A);
  static const Color textGrey = Color(0xFF9C948A);
  static const Color outline = Color(0xFFE5DCCB);
}

class MasukPage extends StatefulWidget {
  const MasukPage({super.key});

  @override
  State<MasukPage> createState() => _MasukPageState();
}

class _MasukPageState extends State<MasukPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _ingatSaya = false;
  bool _loading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _Mk.textDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }

  // ---------------- LOGIN KE FIREBASE ----------------
  Future<void> _masuk() async {
    final email = _usernameController.text.trim();
    final pass = _passwordController.text;

    if (email.isEmpty || pass.isEmpty) {
      _showSnack('Email dan password wajib diisi ya.');
      return;
    }

    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: pass);

      if (!mounted) return;

      // Sudah lengkapi profil & setuju S&K? → HalamanUtama, jika belum → onboarding
      final sudah = await ProfilService.instance.sudahOnboarding();
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) =>
              sudah ? const HalamanUtama() : const LengkapiProfilPage(),
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) _showSnack(_pesanError(e.code));
    } catch (e) {
      if (mounted) _showSnack('ERROR: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _pesanError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email atau password salah';
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti';
      case 'network-request-failed':
        return 'Tidak ada koneksi internet';
      default:
        return 'Gagal masuk ($code)';
    }
  }

  // ---------------- LUPA PASSWORD (kirim link reset ke email) ----------------
  Future<void> _lupaPassword() async {
    final emailCtrl = TextEditingController();
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Lupa Password?',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _Mk.textDark),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukkan email akun Anda. Kami akan mengirim tautan '
              'untuk mengatur ulang password.',
              style: TextStyle(fontSize: 12.5, color: _Mk.textGrey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(fontSize: 13, color: _Mk.textDark),
              decoration: _inputDecoration('Masukkan email.'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal', style: TextStyle(color: _Mk.textGrey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _Mk.button,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Kirim'),
          ),
        ],
      ),
    );

    if (konfirmasi != true) return;
    final email = emailCtrl.text.trim();
    if (email.isEmpty) {
      _showSnack('Email wajib diisi');
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        _showSnack('Tautan reset password sudah dikirim ke $email');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) _showSnack(_pesanError(e.code));
    } catch (e) {
      if (mounted) _showSnack('ERROR: $e');
    }
  }

  // ================= LOGIN DENGAN GOOGLE =================
  Future<void> _masukDenganGoogle() async {
    setState(() => _loading = true);
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _loading = false);
        return;
      }
      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return;
      final sudah = await ProfilService.instance.sudahOnboarding();
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) =>
              sudah ? const HalamanUtama() : const LengkapiProfilPage(),
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) _showSnack('Gagal masuk dengan Google (${e.code})');
    } catch (e) {
      if (mounted) _showSnack('ERROR: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Mk.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------- Tombol kembali -------------------------------
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: _Mk.textDark,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ---------------- Judul ---------------------------------------
              const Text(
                'Masuk Ke MigraCare',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _Mk.textDark,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Silahkan masuk untuk melanjutkan',
                style: TextStyle(fontSize: 13, color: _Mk.textDark),
              ),
              const SizedBox(height: 36),

              // ---------------- Email ---------------------------------------
              const Text(
                'Username / Email',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _Mk.textDark,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _usernameController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(
                  fontSize: 13,
                  color: _Mk.textDark,
                ),
                decoration:
                    _inputDecoration('Masukkan username atau email.'),
              ),
              const SizedBox(height: 20),

              // ---------------- Password ------------------------------------
              const Text(
                'Password',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _Mk.textDark,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscure,
                style: const TextStyle(
                  fontSize: 13,
                  color: _Mk.textDark,
                ),
                decoration: _inputDecoration('Masukkan password.').copyWith(
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: _Mk.textGrey,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // ---------------- Ingat saya & lupa password -------------------
              Row(
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: _ingatSaya,
                      onChanged: (v) =>
                          setState(() => _ingatSaya = v ?? false),
                      activeColor: _Mk.button,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      side: const BorderSide(color: _Mk.outline, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Ingat Saya',
                    style: TextStyle(fontSize: 12.5, color: _Mk.textDark),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _lupaPassword,
                    style: TextButton.styleFrom(
                      foregroundColor: _Mk.gold,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Lupa Password?',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ---------------- Tombol MASUK ---------------------------------
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _loading ? null : _masuk,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _Mk.button,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        _Mk.button.withValues(alpha: 0.6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Masuk',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                ),
              ),

              // ---------------- CONTINUE WITH GOOGLE -------------------------
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: _loading ? null : _masukDenganGoogle,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: _Mk.textDark,
                    side: const BorderSide(color: _Mk.outline, width: 1.2),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.g_mobiledata_rounded,
                      size: 30, color: Color(0xFF4285F4)),
                  label: const Text(
                    'Continue with Google',
                    style: TextStyle(
                        fontSize: 14.5, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              const SizedBox(height: 18),

              // ---------------- Daftar di sini -------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Belum punya akun? ',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: _Mk.textDark,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const DaftarPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Daftar di sini',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: _Mk.gold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: _Mk.textGrey),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _Mk.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _Mk.button, width: 1.4),
      ),
    );
  }
}