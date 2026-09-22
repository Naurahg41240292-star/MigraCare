import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Model item riwayat skrining
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'waktu': waktu.toIso8601String(),
        'hasil': hasil,
        'confidence': confidence,
        'intensitas': intensitas,
        'probabilities': probabilities,
        'fitur': fitur,
        'detailJawaban': detailJawaban,
      };

  factory RiwayatItem.fromJson(Map<String, dynamic> json) {
    return RiwayatItem(
      id: json['id'] as String? ?? '',
      waktu:
          DateTime.tryParse(json['waktu'] as String? ?? '') ?? DateTime.now(),
      hasil: json['hasil'] as String? ?? '-',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      intensitas: json['intensitas'] as String? ?? '-',
      probabilities: (json['probabilities'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toDouble()),
          ) ??
          {},
      fitur: (json['fitur'] as List?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      detailJawaban:
          (json['detailJawaban'] as Map<String, dynamic>?) ?? {},
    );
  }
}

/// Service untuk menyimpan dan membaca riwayat skrining secara persisten
class RiwayatService extends ChangeNotifier {
  RiwayatService._();
  static final RiwayatService instance = RiwayatService._();

  static const String _storageKey = 'migracare_riwayat_skrining';

  /// Mengambil semua riwayat skrining, diurutkan dari yang paling baru
  Future<List<RiwayatItem>> ambilSemua() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawList = prefs.getStringList(_storageKey) ?? [];

      final items = <RiwayatItem>[];
      for (final raw in rawList) {
        try {
          final map = jsonDecode(raw) as Map<String, dynamic>;
          items.add(RiwayatItem.fromJson(map));
        } catch (_) {
          // Lewati item yang rusak
        }
      }

      // Urutkan dari waktu terbaru ke terlama
      items.sort((a, b) => b.waktu.compareTo(a.waktu));
      return items;
    } catch (_) {
      return [];
    }
  }

  /// Menambahkan riwayat baru
  Future<void> tambah(RiwayatItem item) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final items = await ambilSemua();

      // Tambah di awal list
      items.removeWhere((e) => e.id == item.id);
      items.insert(0, item);

      final stringList = items.map((e) => jsonEncode(e.toJson())).toList();
      await prefs.setStringList(_storageKey, stringList);

      notifyListeners();
    } catch (e) {
      debugPrint('Gagal menyimpan riwayat: $e');
    }
  }

  /// Menghapus satu riwayat berdasarkan ID
  Future<void> hapus(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final items = await ambilSemua();

      items.removeWhere((e) => e.id == id);

      final stringList = items.map((e) => jsonEncode(e.toJson())).toList();
      await prefs.setStringList(_storageKey, stringList);

      notifyListeners();
    } catch (e) {
      debugPrint('Gagal menghapus riwayat: $e');
    }
  }

  /// Menghapus seluruh riwayat
  Future<void> bersihkan() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      notifyListeners();
    } catch (e) {
      debugPrint('Gagal membersihkan riwayat: $e');
    }
  }
}