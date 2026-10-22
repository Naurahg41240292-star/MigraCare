import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract class _W {
  static const bg = Color(0xFFFAF4EA);
  static const gold = Color(0xFFC08A2B);
  static const textDark = Color(0xFF33261A);
  static const textGrey = Color(0xFF9C948A);
  static const outline = Color(0xFFE5DCCB);
}

class AdminTambahDokterPage extends StatefulWidget {
  const AdminTambahDokterPage({super.key});

  @override
  State<AdminTambahDokterPage> createState() => _AdminTambahDokterPageState();
}

class _AdminTambahDokterPageState extends State<AdminTambahDokterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nama = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _spesialisasi = TextEditingController();
  final _telepon = TextEditingController();
  bool _lihatPassword = false;
  bool _sedangProses = false;

  @override
  void dispose() {
    _nama.dispose();
    _email.dispose();
    _password.dispose();
    _spesialisasi.dispose();
    _telepon.dispose();
    super.dispose();
  }

  String _pesanError(String kode) {
    switch (kode) {
      case 'email-already-in-use':
        return 'Email sudah dipakai akun lain.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'weak-password':
        return 'Password terlalu lemah (minimal 6 karakter).';
      case 'network-request-failed':
        return 'Koneksi internet bermasalah.';
      default:
        return 'Gagal membuat akun ($kode).';
    }
  }

  Future<void> _buatAkun() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sedangProses = true);
    final msg = ScaffoldMessenger.of(context);
    FirebaseApp? appSekunder;
    try {
      // App sekunder -> membuat akun TANPA mengeluarkan sesi admin yang login
      appSekunder = await Firebase.initializeApp(
        name: 'tambahDokter-${DateTime.now().millisecondsSinceEpoch}',
        options: Firebase.app().options,
      );
      final authSekunder = FirebaseAuth.instanceFor(app: appSekunder);

      final cred = await authSekunder.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text,
      );
      final uid = cred.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'role': 'dokter',
        'profile': {
          'namaLengkap': _nama.text.trim(),
          'spesialisasi': _spesialisasi.text.trim(),
          'noTelepon': _telepon.text.trim(),
        },
        'akun': {
          'email': _email.text.trim(),
          'dibuatPada': FieldValue.serverTimestamp(),
        },
      });

      await authSekunder.signOut();

      if (!mounted) return;
      _nama.clear();
      _email.clear();
      _password.clear();
      _spesialisasi.clear();
      _telepon.clear();
      msg.showSnackBar(SnackBar(
          content:
              Text('Akun dokter "${_nama.text}" berhasil dibuat')));
    } on FirebaseAuthException catch (e) {
      msg.showSnackBar(SnackBar(content: Text(_pesanError(e.code))));
    } catch (e) {
      msg.showSnackBar(SnackBar(content: Text('Gagal: $e')));
    } finally {
      try {
        await appSekunder?.delete();
      } catch (_) {}
      if (mounted) setState(() => _sedangProses = false);
    }
  }

  InputDecoration _dekor(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      );

  Widget _label(String teks, {bool wajib = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Text(teks,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            if (wajib) const Text(' *', style: TextStyle(color: Colors.red)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _W.bg,
      appBar: AppBar(
        backgroundColor: _W.bg,
        elevation: 0,
        foregroundColor: _W.textDark,
        title: const Text('Tambah Dokter',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF3D7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _W.outline),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 20, color: Color(0xFFC99A2C)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                        'Akun dokter yang dibuat di sini bisa langsung dipakai untuk login sebagai role "dokter".',
                        style:
                            TextStyle(fontSize: 11.5, color: _W.textGrey)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _label('Nama Lengkap', wajib: true),
            TextFormField(
              controller: _nama,
              decoration: _dekor('Dr. Nama Lengkap'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
            ),
            const SizedBox(height: 14),
            _label('Email', wajib: true),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: _dekor('dokter@email.com'),
              validator: (v) => (v == null || !v.contains('@'))
                  ? 'Email tidak valid'
                  : null,
            ),
            const SizedBox(height: 14),
            _label('Password', wajib: true),
            TextFormField(
              controller: _password,
              obscureText: !_lihatPassword,
              decoration: _dekor('Minimal 6 karakter').copyWith(
                suffixIcon: IconButton(
                  icon: Icon(_lihatPassword
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded),
                  onPressed: () =>
                      setState(() => _lihatPassword = !_lihatPassword),
                ),
              ),
              validator: (v) => (v == null || v.length < 6)
                  ? 'Password minimal 6 karakter'
                  : null,
            ),
            const SizedBox(height: 14),
            _label('Spesialisasi'),
            TextFormField(
              controller: _spesialisasi,
              decoration: _dekor('Contoh: Saraf / Umum'),
            ),
            const SizedBox(height: 14),
            _label('No. Telepon'),
            TextFormField(
              controller: _telepon,
              keyboardType: TextInputType.phone,
              maxLength: 13,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration:
                  _dekor('Contoh: 081234567890').copyWith(counterText: ''),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _sedangProses ? null : _buatAkun,
              style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFC9822E),
                  padding: const EdgeInsets.symmetric(vertical: 15)),
              child: _sedangProses
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Buat Akun Dokter',
                      style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}