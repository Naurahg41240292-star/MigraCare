import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_booking.dart';
import 'lonceng_notifikasi.dart';
import 'dokter_profil.dart';

abstract class _Bd {
  static const Color bg = Color(0xFFFAF4EA);
  static const Color textDark = Color(0xFF33261A);
  static const Color textGrey = Color(0xFF9C948A);
  static const Color outline = Color(0xFFE5DCCB);
}

/// ==========================================================================
///  ATURAN SESI CHAT (revisi: chat dikunci sesuai status & jadwal)
///  --------------------------------------------------------------------------
///  Chat hanya bisa dibuka kalau SEMUA syarat terpenuhi:
///  1. Status booking = 'dikonfirmasi'
///  2. Waktu sekarang berada DI DALAM sesi konsultasi:
///        jam mulai  <=  sekarang  <=  jam mulai + durasi
///
///  Akibatnya otomatis:
///  - Booking 'ditolak'    -> tombol chat hilang total
///  - Booking 'menunggu'   -> tetap tampil tombol Tolak/Konfirmasi (bukan chat)
///  - Tanggal sudah lewat  -> chip 'Kedaluwarsa'/'Selesai', chat terkunci
/// ==========================================================================

const Map<String, int> _namaBulan = {
  'januari': 1, 'februari': 2, 'maret': 3, 'april': 4, 'mei': 5, 'juni': 6,
  'juli': 7, 'agustus': 8, 'september': 9, 'oktober': 10, 'november': 11,
  'desember': 12,
  'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'jun': 6, 'jul': 7, 'agu': 8,
  'ags': 8, 'sep': 9, 'okt': 10, 'nov': 11, 'des': 12,
  'january': 1, 'february': 2, 'march': 3, 'may': 5, 'june': 6, 'july': 7,
  'august': 8, 'sept': 9, 'october': 10, 'december': 12,
};

/// Ubah string 'tanggal' + 'jam' dari Firestore menjadi DateTime.
/// Mendukung: "5 November 2026", "05 nov 2026", "2026-11-05", "05/11/2026",
/// "November 5, 2026", jam "08:30", "8.30", "08:30 WIB", dsb.
DateTime? parseWaktuBooking(String tanggal, String jam) {
  // ---------------- jam ----------------
  int hh = 0, mm = 0;
  final mJam = RegExp(r'(\d{1,2})\s*[:.]\s*(\d{1,2})').firstMatch(jam.trim());
  if (mJam != null) {
    final h = int.tryParse(mJam.group(1)!) ?? 0;
    final mnt = int.tryParse(mJam.group(2)!) ?? 0;
    if (h <= 23 && mnt <= 59) {
      hh = h;
      mm = mnt;
    }
  } else {
    final mBulat = RegExp(r'^(\d{1,2})$').firstMatch(jam.trim());
    if (mBulat != null) {
      final h = int.tryParse(mBulat.group(1)!) ?? 0;
      if (h <= 23) hh = h;
    }
  }

  // ---------------- tanggal ----------------
  var t = tanggal.trim().toLowerCase();
  // buang nama hari kalau ikut tersimpan, mis. "Kamis, 5 November 2026"
  t = t.replaceFirst(
    RegExp(r'^(minggu|senin|selasa|rabu|kamis|jumat|jum.?at|sabtu)\s*,\s*'),
    '',
  );

  int? thn, bln, tgl;
  RegExpMatch? m;

  // 1) ISO: 2026-11-05
  m = RegExp(r'^(\d{4})[-/.](\d{1,2})[-/.](\d{1,2})$').firstMatch(t);
  if (m != null) {
    thn = int.tryParse(m.group(1)!);
    bln = int.tryParse(m.group(2)!);
    tgl = int.tryParse(m.group(3)!);
  }

  // 2) dd/mm/yyyy atau dd-mm-yyyy (hari dulu, gaya Indonesia)
  if (thn == null) {
    m = RegExp(r'^(\d{1,2})[-/.](\d{1,2})[-/.](\d{2,4})$').firstMatch(t);
    if (m != null) {
      tgl = int.tryParse(m.group(1)!);
      bln = int.tryParse(m.group(2)!);
      thn = int.tryParse(m.group(3)!);
      if (thn != null && thn < 100) thn += 2000;
    }
  }

  // 3) "5 november 2026" / "5 nov 2026"
  if (thn == null) {
    m = RegExp(r'^(\d{1,2})\s+([a-z]+)\.?\s+(\d{4})$').firstMatch(t);
    if (m != null) {
      tgl = int.tryParse(m.group(1)!);
      bln = _namaBulan[m.group(2)!];
      thn = int.tryParse(m.group(3)!);
    }
  }

  // 4) "november 5, 2026"
  if (thn == null) {
    m = RegExp(r'^([a-z]+)\.?\s+(\d{1,2})\s*,?\s*(\d{4})$').firstMatch(t);
    if (m != null) {
      bln = _namaBulan[m.group(1)!];
      tgl = int.tryParse(m.group(2)!);
      thn = int.tryParse(m.group(3)!);
    }
  }

  if (thn == null || bln == null || tgl == null) return null;
  if (bln < 1 || bln > 12 || tgl < 1 || tgl > 31) return null;

  return DateTime(thn, bln, tgl, hh, mm);
}

/// Durasi konsultasi (menit) yang dipilih dokter saat atur jadwal.
/// Fallback 30 menit kalau datanya nggak ada.
int durasiBookingMenit(Map<String, dynamic> b) {
  final v = b['durasiMenit'] ?? b['durasi'];
  if (v is int && v > 0) return v;
  if (v is num && v > 0) return v.round();
  if (v is String) {
    final n = int.tryParse(v.trim());
    if (n != null && n > 0) return n;
  }
  return 30;
}

/// Label durasi cantik: 60 -> "1 jam", selain itu -> "X menit".
String labelDurasiBooking(int menit) {
  if (menit >= 60 && menit % 60 == 0) {
    final jam = menit ~/ 60;
    return jam == 1 ? '1 jam' : '$jam jam';
  }
  return '$menit menit';
}

/// Kondisi sesi sebuah booking DIBANDINGKAT dengan waktu sekarang.
/// Return: 'belum' | 'aktif' | 'lewat' | 'tidak_diketahui'
String hitungKondisiSesi(Map<String, dynamic> b, {DateTime? sekarang}) {
  final tanggalStr = (b['tanggal'] ?? '').toString();
  final jamStr = (b['jam'] ?? '').toString().trim();

  final mulai = parseWaktuBooking(tanggalStr, jamStr);
  if (mulai == null) return 'tidak_diketahui';

  final n = sekarang ?? DateTime.now();

  // Kalau jam nggak tercatat/aneh -> anggap sesi sepanjang hari itu
  final jamTercatat = RegExp(r'\d').hasMatch(jamStr);
  final selesai = jamTercatat
      ? mulai.add(Duration(minutes: durasiBookingMenit(b)))
      : DateTime(mulai.year, mulai.month, mulai.day, 23, 59, 59);

  if (n.isBefore(mulai)) return 'belum';
  if (n.isAfter(selesai)) return 'lewat';
  return 'aktif';
}

/// ATURAN UTAMA: chat boleh dibuka hanya kalau
/// status 'dikonfirmasi' DAN sesi sedang berjalan.
bool bisaBukaChat(Map<String, dynamic> b, {DateTime? sekarang}) {
  if ((b['status'] ?? '').toString() != 'dikonfirmasi') return false;
  final kondisi = hitungKondisiSesi(b, sekarang: sekarang);
  // Format tanggal aneh / kosong -> jangan blokir (biar demo tetap jalan)
  if (kondisi == 'tidak_diketahui') return true;
  return kondisi == 'aktif';
}

/// TAB Beranda — dashboard sesuai desain Figma + Booking Masuk
class DokterBerandaView extends StatefulWidget {
  const DokterBerandaView({super.key, this.onPindahTab});

  final ValueChanged<int>? onPindahTab;

  @override
  State<DokterBerandaView> createState() => _DokterBerandaViewState();
}

class _DokterBerandaViewState extends State<DokterBerandaView> {
  bool _loading = true;
  String _namaDokter = '...';
  int _totalPasien = 0;
  int _pasienBaruHariIni = 0;
  List<Map<String, dynamic>> _bookings = [];

  Timer? _ticker; // refresh status sesi otomatis

  @override
  void initState() {
    super.initState();
    muatFotoDokterGlobal();
    _muat();
    // Tiap 30 detik halaman di-refresh ringan supaya chip status &
    // tombol chat otomatis berubah saat sesi mulai/berakhir.
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  /// Dipanggil shell saat tab beranda aktif (refresh data)
  void muatUlang() => _muat();

  Future<void> _muat() async {
    setState(() => _loading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      final uid = user?.uid ?? '';

      if (uid.isNotEmpty) {
        final meDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        if (meDoc.exists) {
          final me = meDoc.data()!;
          _namaDokter = (me['profile']?['namaLengkap'] ??
                  me['akun']?['namaLengkap'] ??
                  'Dokter') as String;
        }
      }

      final snap = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'pasien')
          .get();

      final awalHari = DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day);
      int baruHariIni = 0;
      for (final doc in snap.docs) {
        final dibuat = doc.data()['akun']?['dibuatPada'];
        if (dibuat is Timestamp && dibuat.toDate().isAfter(awalHari)) {
          baruHariIni++;
        }
      }

      List<Map<String, dynamic>> bookings = [];
      if (uid.isNotEmpty) {
        final bSnap = await FirebaseFirestore.instance
            .collection('booking')
            .where('dokterUid', isEqualTo: uid)
            .orderBy('dibuatPada', descending: true)
            .get();
        bookings = bSnap.docs.map((d) {
          final data = d.data();
          return {
            'id': d.id,
            'pasienNama': (data['pasienNama'] ?? 'Pasien') as String,
            'hari': (data['hari'] ?? '-') as String,
            'tanggal': (data['tanggal'] ?? '') as String,
            'jam': (data['jam'] ?? '-') as String,
            'status': (data['status'] ?? 'menunggu') as String,
            // Durasi yang dipilih dokter (15/30/60 menit) —
            // dipakai untuk menghitung akhir sesi chat
            'durasiMenit': data['durasiMenit'] ?? data['durasi'] ?? 30,
          };
        }).toList();
      }

      if (!mounted) return;
      setState(() {
        _totalPasien = snap.docs.length;
        _pasienBaruHariIni = baruHariIni;
        _bookings = bookings;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memuat data: $e')));
      }
    }
  }

  Future<void> _ubahStatus(String id, String status) async {
    await FirebaseFirestore.instance
        .collection('booking')
        .doc(id)
        .update({'status': status});
    _muat();
  }

  void _bukaChat(Map<String, dynamic> b) {
    // PINTU 2: cek ulang sebelum masuk halaman chat
    if (!bisaBukaChat(b)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Sesi konsultasi tidak sedang berlangsung — chat terkunci.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF3D2B1A),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatBookingPage(
          bookingId: b['id'],
          booking: b,
          sayaDokter: true,
        ),
      ),
    );
  }

  // ----------------------- KARTU BOOKING -----------------------

  Widget _bookingCard(Map<String, dynamic> b) {
    final status = (b['status'] ?? 'menunggu') as String;
    final kondisi = hitungKondisiSesi(b);
    final durasi = durasiBookingMenit(b);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: (status == 'menunggu' && kondisi != 'lewat')
              ? const Color(0xFFC9822E)
              : _Bd.outline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(b['pasienNama'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _Bd.textDark)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _chipBg(status, kondisi),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _chipLabel(status, kondisi),
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: _chipTextColor(status, kondisi),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${b['hari']}, ${b['tanggal']} • ${b['jam']} (${labelDurasiBooking(durasi)})',
            style: const TextStyle(
                fontSize: 12.5, color: _Bd.textGrey),
          ),

          // ------------- AREA AKSI (sesuai status + waktu) -------------
          if (status == 'menunggu' && kondisi != 'lewat') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _ubahStatus(b['id'], 'ditolak'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE55555),
                      side: const BorderSide(color: Color(0xFFE55555)),
                      padding:
                          const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Tolak',
                        style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        _ubahStatus(b['id'], 'dikonfirmasi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC9822E),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding:
                          const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Konfirmasi',
                        style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ] else if (status == 'menunggu' && kondisi == 'lewat') ...[
            const SizedBox(height: 12),
            _infoBar(
              Icons.event_busy_rounded,
              'Booking kedaluwarsa — tanggal konsultasi sudah lewat.',
            ),
          ] else if (status == 'dikonfirmasi' && bisaBukaChat(b)) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton.icon(
                onPressed: () => _bukaChat(b),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC9822E),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.chat_rounded, size: 16),
                label: const Text('Buka Chat',
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ] else if (status == 'dikonfirmasi' && kondisi == 'belum') ...[
            const SizedBox(height: 12),
            _infoBar(
              Icons.schedule_rounded,
              'Chat terbuka otomatis saat sesi dimulai (${b['jam']}).',
            ),
          ] else if (status == 'dikonfirmasi' && kondisi == 'lewat') ...[
            const SizedBox(height: 12),
            _infoBar(
              Icons.hourglass_bottom_rounded,
              'Sesi konsultasi sudah berakhir.',
            ),
          ],
          // status 'ditolak' -> tidak ada tombol apa pun (chat terkunci)
        ],
      ),
    );
  }

  Widget _infoBar(IconData icon, String text) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFF1ECE2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF9C948A)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9C948A))),
          ),
        ],
      ),
    );
  }

  Color _chipBg(String status, String kondisi) {
    if (status == 'ditolak') return const Color(0xFFFCE8E6);
    if (status == 'dikonfirmasi') {
      return kondisi == 'lewat'
          ? const Color(0xFFEFEAE1)
          : const Color(0xFFE4F3E4);
    }
    return kondisi == 'lewat'
        ? const Color(0xFFEFEAE1)
        : const Color(0xFFFDF3D7);
  }

  Color _chipTextColor(String status, String kondisi) {
    if (status == 'ditolak') return const Color(0xFFE55555);
    if (status == 'dikonfirmasi') {
      return kondisi == 'lewat'
          ? const Color(0xFF8A8075)
          : const Color(0xFF3E7C3E);
    }
    return kondisi == 'lewat'
        ? const Color(0xFF8A8075)
        : const Color(0xFFC99A2C);
  }

  String _chipLabel(String status, String kondisi) {
    if (status == 'ditolak') return 'Ditolak';
    if (status == 'dikonfirmasi') {
      return kondisi == 'lewat' ? 'Selesai' : 'Dikonfirmasi';
    }
    return kondisi == 'lewat' ? 'Kedaluwarsa' : 'Menunggu';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Bd.bg,
      appBar: AppBar(
        backgroundColor: _Bd.bg,
        elevation: 0,
        centerTitle: false,
        title: Image.asset('assets/images/logo_atas.png',
            height: 34, fit: BoxFit.contain),
        actions: [
          // LONCENG + BADGE MERAH (jumlah booking menunggu)
          // Tap -> langsung buka halaman Notifikasi
          const Padding(
            padding: EdgeInsets.only(right: 4),
            child: LoncengNotifikasi(),
          ),
          IconButton(
            onPressed: () => widget.onPindahTab?.call(4),
            icon: ValueListenableBuilder<String?>(
              valueListenable: fotoDokterNotifier,
              builder: (context, foto, _) => CircleAvatar(
                radius: 14,
                backgroundColor: const Color(0xFFC9822E),
                backgroundImage: foto != null
                    ? MemoryImage(base64Decode(foto))
                    : null,
                child: foto == null
                    ? const Icon(Icons.person_rounded,
                        size: 16, color: Colors.white)
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _muat,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  Text('Halo, $_namaDokter',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: _Bd.textDark)),
                  const SizedBox(height: 6),
                  const Text(
                    'Semoga hari ini berjalan lancar dalam memberikan pelayanan terbaik.',
                    style: TextStyle(
                        fontSize: 12.5,
                        height: 1.5,
                        color: _Bd.textGrey),
                  ),
                  const SizedBox(height: 20),

                  // ---------- KARTU STATISTIK ----------
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0xFF7A4E24), Color(0xFFC08A47)],
                      ),
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0x4D7A4E24),
                            blurRadius: 16,
                            offset: Offset(0, 8)),
                      ],
                    ),
                    child: Row(
                      children: [
                        _statItem(Icons.person_search_rounded,
                            'Pasien Terdaftar', '$_totalPasien'),
                        Container(
                            width: 1,
                            height: 44,
                            color: Colors.white24),
                        _statItem(
                            Icons.person_add_rounded,
                            'Pasien Baru Hari Ini',
                            '$_pasienBaruHariIni orang'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ---------- BOOKING MASUK ----------
                  const Text('Booking Masuk',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _Bd.textDark)),
                  const SizedBox(height: 12),

                  if (_bookings.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _Bd.outline),
                      ),
                      child: const Text(
                        'Belum ada booking konsultasi.',
                        style: TextStyle(
                            fontSize: 12.5, color: _Bd.textGrey),
                      ),
                    )
                  else
                    for (final b in _bookings) _bookingCard(b),
                  const SizedBox(height: 24),

                  // ---------- AKSES CEPAT ----------
                  const Text('Akses Cepat',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _Bd.textDark)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _aksesCepat(Icons.event_available_rounded,
                          'Jadwal', () => widget.onPindahTab?.call(1)),
                      const SizedBox(width: 12),
                      _aksesCepat(Icons.chat_rounded, 'Chat Pasien',
                          () => widget.onPindahTab?.call(2)),
                      const SizedBox(width: 12),
                      _aksesCepat(Icons.groups_rounded, 'Riwayat Pasien',
                          () => widget.onPindahTab?.call(3)),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _statItem(IconData icon, String label, String nilai) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white70, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 11.5)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(nilai,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }

  Widget _aksesCepat(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _Bd.outline),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFFDF3D7),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: const Color(0xFFC99A2C)),
              ),
              const SizedBox(height: 8),
              Text(label,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: _Bd.textDark)),
            ],
          ),
        ),
      ),
    );
  }
}