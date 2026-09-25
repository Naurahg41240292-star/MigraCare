import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Cek status onboarding user (profil + syarat & ketentuan)
class ProfilService {
  ProfilService._();
  static final ProfilService instance = ProfilService._();

  Future<String> _ensureUid() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) return user.uid;
    final cred = await FirebaseAuth.instance.signInAnonymously();
    return cred.user!.uid;
  }

  /// true = sudah lengkapi profil & setuju S&K → login langsung HalamanUtama
  /// false = perlu lewat LengkapiProfil → SyaratKetentuan dulu
  Future<bool> sudahOnboarding() async {
    try {
      final uid = await _ensureUid();
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!doc.exists) return false;

      final data = doc.data()!;
      final profilOk = (data['profile']?['namaLengkap'] ?? '') != '';
      final skOk = data['syaratKetentuan']?['disetujui'] == true;
      return profilOk && skOk;
    } catch (_) {
      return false;
    }
  }

  /// Ambil nama depan user untuk sapaan beranda
  /// (mis. "Intan Novitasari" → "Intan")
  Future<String> ambilNama() async {
    try {
      final uid = await _ensureUid();
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!doc.exists) return 'Sahabat';

      final data = doc.data()!;
      // Prioritas: profile.namaLengkap → akun.namaLengkap (dari daftar)
      final nama = (data['profile']?['namaLengkap'] ??
              data['akun']?['namaLengkap'] ??
              '') as String;

      if (nama.trim().isEmpty) return 'Sahabat';
      return nama.trim().split(' ').first;
    } catch (_) {
      return 'Sahabat';
    }
  }
}