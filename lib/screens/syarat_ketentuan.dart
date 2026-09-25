import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme.dart';
import 'halaman_utama.dart';

/// ==========================================================================
///  MIGRACARE — Halaman Syarat & Ketentuan
///  File: lib/screens/syarat_ketentuan.dart
/// ==========================================================================

class SyaratKetentuanPage extends StatefulWidget {
  const SyaratKetentuanPage({super.key});

  @override
  State<SyaratKetentuanPage> createState() => _SyaratKetentuanPageState();
}

class _SyaratKetentuanPageState extends State<SyaratKetentuanPage> {
  bool _setuju = false;
  bool _menyimpan = false;

  static const Color kontrol = Color(0xFFC9822E);

  Future<String> _ensureUid() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) return user.uid;
    final cred = await FirebaseAuth.instance.signInAnonymously();
    return cred.user!.uid;
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

  /// Simpan persetujuan ke Firestore lalu masuk ke halaman utama
  Future<void> _setujuDanMulai() async {
    if (!_setuju) {
      _showSnack('Centang dulu persetujuan syarat & ketentuan ya');
      return;
    }

    setState(() => _menyimpan = true);
    try {
      final uid = await _ensureUid();
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'syaratKetentuan': {
          'disetujui': true,
          'disetujuiPada': FieldValue.serverTimestamp(),
          'versi': 1,
        },
      }, SetOptions(merge: true));

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HalamanUtama()),
        (route) => false,
      );
    } catch (e) {
      if (mounted) _showSnack('ERROR: $e');
    } finally {
      if (mounted) setState(() => _menyimpan = false);
    }
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

              const Text('Syarat & Ketentuan',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark)),
              const SizedBox(height: 6),
              const Text(
                'Harap baca dengan teliti sebelum menggunakan aplikasi MigraCare.',
                style: TextStyle(fontSize: 12, color: AppColors.textGrey),
              ),
              const SizedBox(height: 18),

              // ---------- ISI SYARAT ----------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.outline),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kebijakan Privasi',
                        style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark)),
                    SizedBox(height: 8),
                    Text(
                      'Kami berkomitmen untuk melindungi privasi dan data pribadi '
                      'Anda. Informasi yang Anda berikan akan dikumpulkan dan '
                      'digunakan hanya untuk meningkatkan pengalaman Anda dalam '
                      'menggunakan aplikasi ini.',
                      style: TextStyle(
                          fontSize: 12,
                          height: 1.5,
                          color: AppColors.textGrey),
                    ),
                    SizedBox(height: 16),
                    Text('Ketentuan Penggunaan',
                        style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark)),
                    SizedBox(height: 8),
                    Text(
                      'Dengan menggunakan MigraCare, Anda menyatakan bahwa '
                      'aplikasi ini hanya menyediakan informasi dan tidak '
                      'menggantikan diagnosis atau saran medis dari tenaga '
                      'kesehatan profesional.',
                      style: TextStyle(
                          fontSize: 12,
                          height: 1.5,
                          color: AppColors.textGrey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // ---------- CHECKBOX ----------
              InkWell(
                onTap: () => setState(() => _setuju = !_setuju),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: _setuju ? kontrol : Colors.transparent,
                          border: Border.all(
                            color: _setuju ? kontrol : const Color(0xFFC9BFB0),
                            width: 1.8,
                          ),
                        ),
                        child: _setuju
                            ? const Icon(Icons.check,
                                size: 14, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Saya telah membaca dan menyetujui syarat & ketentuan',
                          style: TextStyle(
                              fontSize: 12.5, color: AppColors.textDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // ---------- TOMBOL ----------
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_setuju && !_menyimpan) ? _setujuDanMulai : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _setuju ? kontrol : const Color(0xFFD8CDBB),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        _setuju ? kontrol : const Color(0xFFD8CDBB),
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
                      : const Text('Setuju & Mulai',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}