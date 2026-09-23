import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Model item riwayat skrining — field & constructor TIDAK BERUBAH
class RiwayatItem {
  final String id;
  final DateTime waktu;
  final String hasil;
  final double confidence;
  final String intensitas;
  final Map<String, double> probabilities;
  final List<double> fitur;
  final Map<String, dynamic> detailJawaban;

  RiwayatItem({
    String? id,
    required this.waktu,
    required this.hasil,
    required this.confidence,
    required this.intensitas,
    Map<String, double>? probabilities,
    this.fitur = const [],
    Map<String, dynamic>? detailJawaban,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        probabilities = probabilities ?? const {},
        detailJawaban = detailJawaban ?? const {};

  /// Ke format dokumen Firestore ('id' tidak disimpan — id = doc id)
  Map<String, dynamic> toFirestore() => {
        'waktu': Timestamp.fromDate(waktu),
        'hasil': hasil,
        'confidence': confidence,
        'intensitas': intensitas,
        'probabilities': probabilities,
        'fitur': fitur,
        'detailJawaban': detailJawaban,
      };

  /// Dari dokumen Firestore
  factory RiwayatItem.fromDoc(String docId, Map<String, dynamic> m) {
    final rawWaktu = m['waktu'];
    final waktu = rawWaktu is Timestamp
        ? rawWaktu.toDate()
        : (DateTime.tryParse(rawWaktu?.toString() ?? '') ?? DateTime.now());

    return RiwayatItem(
      id: docId,
      waktu: waktu,
      hasil: m['hasil'] as String? ?? '-',
      confidence: (m['confidence'] as num?)?.toDouble() ?? 0.0,
      intensitas: m['intensitas'] as String? ?? '-',
      probabilities: (m['probabilities'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toDouble()),
          ) ??
          {},
      fitur: (m['fitur'] as List?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      detailJawaban: (m['detailJawaban'] as Map<String, dynamic>?) ?? {},
    );
  }
}

/// Service riwayat — sekarang tersimpan di CLOUD FIRESTORE ☁️
/// Struktur: users/{uid}/screenings/{docId}
class RiwayatService extends ChangeNotifier {
  RiwayatService._();
  static final RiwayatService instance = RiwayatService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Pastikan ada user (anonymous) — uid dipakai sebagai folder data user
  Future<User> _ensureUser() async {
    User? user = _auth.currentUser;
    user ??= (await _auth.signInAnonymously()).user!;
    return user;
  }

  CollectionReference<Map<String, dynamic>> _col(String uid) => _db
      .collection('users')
      .doc(uid)
      .collection('screenings');

  /// Mengambil semua riwayat, terbaru duluan
  Future<List<RiwayatItem>> ambilSemua() async {
    try {
      final uid = (await _ensureUser()).uid;
      final snap =
          await _col(uid).orderBy('waktu', descending: true).get();
      return snap.docs
          .map((d) => RiwayatItem.fromDoc(d.id, d.data()))
          .toList();
    } catch (e) {
      debugPrint('Gagal membaca riwayat: $e');
      return [];
    }
  }

  /// Menambahkan riwayat baru ke Firestore
  Future<void> tambah(RiwayatItem item) async {
    try {
      final uid = (await _ensureUser()).uid;
      await _col(uid).doc(item.id).set(item.toFirestore());
      notifyListeners();
    } catch (e) {
      debugPrint('Gagal menyimpan riwayat: $e');
    }
  }

  /// Menghapus satu riwayat berdasarkan ID
  Future<void> hapus(String id) async {
    try {
      final uid = (await _ensureUser()).uid;
      await _col(uid).doc(id).delete();
      notifyListeners();
    } catch (e) {
      debugPrint('Gagal menghapus riwayat: $e');
    }
  }

  /// Menghapus seluruh riwayat
  Future<void> bersihkan() async {
    try {
      final uid = (await _ensureUser()).uid;
      final snap = await _col(uid).get();
      for (final doc in snap.docs) {
        await doc.reference.delete();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Gagal membersihkan riwayat: $e');
    }
  }
}