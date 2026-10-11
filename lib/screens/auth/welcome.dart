import 'package:flutter/material.dart';
import 'masuk.dart';
import 'daftar.dart';

/// ==========================================================================
///  MIGRACARE — Halaman Selamat Datang
///  File: lib/screens/welcome.dart
/// ==========================================================================

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Wc.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---------------- Tombol kembali -------------------------------
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: _Wc.textDark,
                    size: 26,
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // ---------------- Ilustrasi otak emas --------------------------
              Center(
                child: Image.asset(
                  'assets/images/otak_besar.png',
                  width: 290,
                  height: 230,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 18),

              // ---------------- Judul & deskripsi ----------------------------
              const Text(
                'Selamat Datang di\nMigraCare',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                  color: _Wc.textDark,
                ),
              ),
              const SizedBox(height: 14),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Mulai perjalanan Anda dalam mengenali dan mengelola migrain',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: _Wc.textGrey,
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // ---------------- Tombol MASUK ---------------------------------
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MasukPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _Wc.button,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Masuk',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ---------------- Tombol BUAT AKUN -----------------------------
              SizedBox(
                height: 54,
                child: OutlinedButton(
                  onPressed: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const DaftarPage()),
                        );
                        },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: _Wc.gold,
                    side: const BorderSide(color: _Wc.gold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Buat Akun',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
  class _Wc {
    static const Color bg = Color(0xFFFDF9F4);
    static const Color textDark = Color(0xFF3A3028);
    static const Color textGrey = Color(0xFF8A8178);
    static const Color button = Color(0xFFD5892C);
    static const Color gold = Color(0xFFC58A24);
  }