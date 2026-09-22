import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// ==========================================================================
///  MIGRACARE — Model & Penyimpanan Data Pengingat Obat (v3.1)
///  File: lib/models/obat.dart
/// ==========================================================================

class Obat {
  String id;
  String nama;
  String dosis;
  String bentukSediaan;
  String catatan;
  String aturanPakai;
  List<String> jamList;
  String catatanMinum;
  List<int> hariList;   // 1=Senin ... 7=Minggu
  DateTime mulaiBerlaku;

  Obat({
    required this.id,
    required this.nama,
    this.dosis = '',
    this.bentukSediaan = 'Tablet',
    this.catatan = '',
    this.aturanPakai = '2x sehari',
    List<String>? jamList,
    this.catatanMinum = '',
    List<int>? hariList,
    DateTime? mulaiBerlaku,
  })  : jamList = jamList ?? <String>['08.00'],
        hariList = hariList ?? const [1, 2, 3, 4, 5, 6, 7],
        mulaiBerlaku = mulaiBerlaku ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'nama': nama,
        'dosis': dosis,
        'bentukSediaan': bentukSediaan,
        'catatan': catatan,
        'aturanPakai': aturanPakai,
        'jamList': jamList,
        'catatanMinum': catatanMinum,
        'hariList': hariList,
        'mulaiBerlaku': mulaiBerlaku.toIso8601String(),
      };

  factory Obat.fromJson(Map<String, dynamic> json) => Obat(
        id: (json['id'] ?? '').toString(),
        nama: (json['nama'] ?? '').toString(),
        dosis: (json['dosis'] ?? '').toString(),
        bentukSediaan: (json['bentukSediaan'] ?? 'Tablet').toString(),
        catatan: (json['catatan'] ?? '').toString(),
        aturanPakai: (json['aturanPakai'] ?? '2x sehari').toString(),
        jamList: (json['jamList'] as List<dynamic>? ?? ['08.00'])
            .map((e) => e.toString())
            .toList(),
        catatanMinum: (json['catatanMinum'] ?? '').toString(),
        hariList: (json['hariList'] as List<dynamic>? ??
                const [1, 2, 3, 4, 5, 6, 7])
            .map((e) => (e as num).toInt())
            .toList(),
        mulaiBerlaku:
            DateTime.tryParse((json['mulaiBerlaku'] ?? '').toString()) ??
                DateTime.now(),
      );
}

class RiwayatObat {
  String id;
  DateTime tanggal;
  String jam;
  String idObat;
  String namaObat;
  String dosisObat;
  bool sudahDiminum;
  String? waktuDiminum;
  String? catatan;

  RiwayatObat({
    required this.id,
    required this.tanggal,
    required this.jam,
    required this.idObat,
    required this.namaObat,
    required this.dosisObat,
    this.sudahDiminum = false,
    this.waktuDiminum,
    this.catatan,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'tanggal': tanggal.toIso8601String(),
        'jam': jam,
        'idObat': idObat,
        'namaObat': namaObat,
        'dosisObat': dosisObat,
        'sudahDiminum': sudahDiminum,
        'waktuDiminum': waktuDiminum,
        'catatan': catatan,
      };

  factory RiwayatObat.fromJson(Map<String, dynamic> json) => RiwayatObat(
        id: (json['id'] ?? '').toString(),
        tanggal: DateTime.tryParse((json['tanggal'] ?? '').toString()) ??
            DateTime.now(),
        jam: (json['jam'] ?? '').toString(),
        idObat: (json['idObat'] ?? '').toString(),
        namaObat: (json['namaObat'] ?? '').toString(),
        dosisObat: (json['dosisObat'] ?? '').toString(),
        sudahDiminum: json['sudahDiminum'] == true,
        waktuDiminum: json['waktuDiminum']?.toString(),
        catatan: json['catatan']?.toString(),
      );
}

class JadwalHariIni {
  final Obat obat;
  final String jam;
  final bool sudahDiminum;
  final String? waktuDiminum;

  const JadwalHariIni({
    required this.obat,
    required this.jam,
    this.sudahDiminum = false,
    this.waktuDiminum,
  });
}

class PengingatStore {
  PengingatStore._();
  static final PengingatStore instance = PengingatStore._();

  static const _keyObat = 'migracare_daftar_obat';
  static const _keyRiwayat = 'migracare_daftar_riwayat';

  final List<Obat> daftarObat = [];
  final List<RiwayatObat> daftarRiwayat = [];
  bool sudahDimuat = false;

  static String buatId() => DateTime.now().microsecondsSinceEpoch.toString();

  Future<void> muatDariDisk() async {
    if (sudahDimuat) return;
    final prefs = await SharedPreferences.getInstance();
    final rawObat = prefs.getString(_keyObat);
    final rawRiwayat = prefs.getString(_keyRiwayat);

    daftarObat.clear();
    if (rawObat != null && rawObat.isNotEmpty) {
      final list = jsonDecode(rawObat) as List<dynamic>;
      daftarObat.addAll(list.map((e) => Obat.fromJson(e)));
    }

    daftarRiwayat.clear();
    if (rawRiwayat != null && rawRiwayat.isNotEmpty) {
      final list = jsonDecode(rawRiwayat) as List<dynamic>;
      daftarRiwayat.addAll(list.map((e) => RiwayatObat.fromJson(e)));
    }

    sudahDimuat = true;
  }

  Future<void> _simpanObat() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyObat,
      jsonEncode(daftarObat.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> _simpanRiwayat() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyRiwayat,
      jsonEncode(daftarRiwayat.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> simpanPerubahanObat() => _simpanObat();

  void tambahObat(Obat obat) {
    daftarObat.add(obat);
    _simpanObat();
  }

  void hapusObat(String id) {
    daftarObat.removeWhere((o) => o.id == id);
    _simpanObat();
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String _formatJam(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}.${t.minute.toString().padLeft(2, '0')}';

  void sinkronkanRiwayatHariIni() {
    final now = DateTime.now();
    bool berubah = false;

    final sebelum = daftarRiwayat.length;
    daftarRiwayat.removeWhere((r) {
      if (!_sameDay(r.tanggal, now) || r.sudahDiminum) return false;
      Obat? obat;
      for (final o in daftarObat) {
        if (o.id == r.idObat) {
          obat = o;
          break;
        }
      }
      if (obat == null) return true;
      final masihBerlaku = obat.jamList.contains(r.jam) &&
          obat.hariList.contains(now.weekday);
      return !masihBerlaku;
    });
    if (daftarRiwayat.length != sebelum) berubah = true;

    for (final obat in daftarObat) {
      for (final jam in obat.jamList) {
        RiwayatObat? entri;
        for (final r in daftarRiwayat) {
          if (_sameDay(r.tanggal, now) && r.idObat == obat.id && r.jam == jam) {
            entri = r;
            break;
          }
        }
        if (entri == null) {
          daftarRiwayat.add(RiwayatObat(
            id: buatId(),
            tanggal: DateTime(now.year, now.month, now.day),
            jam: jam,
            idObat: obat.id,
            namaObat: obat.nama,
            dosisObat: obat.dosis,
            sudahDiminum: false,
          ));
          berubah = true;
        }
      }
    }

    if (berubah) _simpanRiwayat();
  }

  List<JadwalHariIni> jadwalHariIni() {
    final now = DateTime.now();
    final hariIni = DateTime(now.year, now.month, now.day);
    final hasil = <JadwalHariIni>[];

    for (final obat in daftarObat) {
      final mulai = DateTime(obat.mulaiBerlaku.year, obat.mulaiBerlaku.month,
          obat.mulaiBerlaku.day);
      if (hariIni.isBefore(mulai)) continue;
      if (!obat.hariList.contains(now.weekday)) continue;

      for (final jam in obat.jamList) {
        RiwayatObat? entri;
        for (final r in daftarRiwayat) {
          if (_sameDay(r.tanggal, now) &&
              r.idObat == obat.id &&
              r.jam == jam) {
            entri = r;
            break;
          }
        }
        hasil.add(JadwalHariIni(
          obat: obat,
          jam: jam,
          sudahDiminum: entri?.sudahDiminum ?? false,
          waktuDiminum: entri?.waktuDiminum,
        ));
      }
    }

    hasil.sort((a, b) => a.jam.compareTo(b.jam));
    return hasil;
  }

  JadwalHariIni? jadwalBerikutnyaHariIni() {
    for (final j in jadwalHariIni()) {
      if (!j.sudahDiminum) return j;
    }
    return null;
  }

  void tandaiDiminum(Obat obat, String jam) {
    final now = DateTime.now();

    RiwayatObat? entri;
    for (final r in daftarRiwayat) {
      if (_sameDay(r.tanggal, now) && r.idObat == obat.id && r.jam == jam) {
        entri = r;
        break;
      }
    }

    if (entri == null) {
      daftarRiwayat.add(RiwayatObat(
        id: buatId(),
        tanggal: DateTime(now.year, now.month, now.day),
        jam: jam,
        idObat: obat.id,
        namaObat: obat.nama,
        dosisObat: obat.dosis,
        sudahDiminum: true,
        waktuDiminum: _formatJam(now),
        catatan: obat.catatanMinum.isNotEmpty ? obat.catatanMinum : null,
      ));
    } else {
      entri.sudahDiminum = true;
      entri.waktuDiminum = _formatJam(now);
    }

    _simpanRiwayat();
  }

  /// Batalkan status "sudah diminum" untuk jadwal hari ini
  void batalkanDiminum(Obat obat, String jam) {
    final now = DateTime.now();
    for (final r in daftarRiwayat) {
      if (_sameDay(r.tanggal, now) && r.idObat == obat.id && r.jam == jam) {
        r.sudahDiminum = false;
        r.waktuDiminum = null;
        _simpanRiwayat();
        return;
      }
    }
  }
}