import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/profil_service.dart';

import '../models/dokter.dart';
import '../theme.dart';
import '../utils/rute.dart';
import '../widgets/widget_konsultasi.dart';
import 'detail_dokter.dart';
import 'dokter/chat_booking.dart';

// ===========================================================================
//  ATURAN SESI CHAT (identik dengan beranda dokter & halaman chat)
//  Chat hanya boleh dibuka kalau:
//  1. Status booking = 'dikonfirmasi'
//  2. Waktu sekarang DI DALAM sesi: jam booking s/d jam booking + durasi
//  Booking 'ditolak' / 'menunggu' / yang tanggalnya sudah lewat
//  -> tombol chat tidak muncul (dan halaman chat juga tetap menolak).
// ===========================================================================

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
/// Mendukung "5/11/2026", "5 November 2026", "2026-11-05", jam "08:30"/"8.30".
DateTime? _parseWaktuBooking(String tanggal, String jam) {
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

  // 2) d/m/yyyy (hari dulu, gaya Indonesia — format yang disimpan saat booking)
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

int _durasiBookingMenit(Map<String, dynamic> b) {
  final v = b['durasiMenit'] ?? b['durasi'];
  if (v is int && v > 0) return v;
  if (v is num && v > 0) return v.round();
  if (v is String) {
    final n = int.tryParse(v.trim());
    if (n != null && n > 0) return n;
  }
  return 30;
}

String _labelDurasiBooking(int menit) {
  if (menit >= 60 && menit % 60 == 0) {
    final j = menit ~/ 60;
    return j == 1 ? '1 jam' : '$j jam';
  }
  return '$menit menit';
}

/// Kondisi sesi booking dibanding waktu sekarang:
/// 'belum' | 'aktif' | 'lewat' | 'tidak_diketahui'
String _hitungKondisiSesi(Map<String, dynamic> b, {DateTime? sekarang}) {
  final tanggalStr = (b['tanggal'] ?? '').toString();
  final jamStr = (b['jam'] ?? '').toString().trim();

  final mulai = _parseWaktuBooking(tanggalStr, jamStr);
  if (mulai == null) return 'tidak_diketahui';

  final n = sekarang ?? DateTime.now();

  // jam nggak tercatat/aneh -> anggap sesi sepanjang hari itu
  final jamTercatat = RegExp(r'\d').hasMatch(jamStr);
  final selesai = jamTercatat
      ? mulai.add(Duration(minutes: _durasiBookingMenit(b)))
      : DateTime(mulai.year, mulai.month, mulai.day, 23, 59, 59);

  if (n.isBefore(mulai)) return 'belum';
  if (n.isAfter(selesai)) return 'lewat';
  return 'aktif';
}

/// ATURAN UTAMA: chat boleh dibuka hanya kalau
/// status 'dikonfirmasi' DAN sesi sedang berjalan.
bool _bisaBukaChat(Map<String, dynamic> b, {DateTime? sekarang}) {
  if ((b['status'] ?? '').toString() != 'dikonfirmasi') return false;
  final kondisi = _hitungKondisiSesi(b, sekarang: sekarang);
  // format tanggal aneh/kosong -> jangan blokir (biar demo tetap jalan)
  if (kondisi == 'tidak_diketahui') return true;
  return kondisi == 'aktif';
}

class KonsultasiScreen extends StatefulWidget {
  final VoidCallback? onKembali;

  const KonsultasiScreen({
    super.key,
    this.onKembali,
  });

  @override
  State<KonsultasiScreen> createState() => _KonsultasiScreenState();
}

class _KonsultasiScreenState extends State<KonsultasiScreen> {
  static const List<String> _chips = ['Semua', 'Dokter Umum', 'Spesialis', 'Riwayat'];

  String _query = '';
  String _chip = 'Semua';

  // ✅ Nama user untuk sapaan
  String _nama = '';

  // ✅ Dokter REAL dari Firestore
  bool _loadingDokter = true;
  List<Dokter> _dokterFirestore = [];

  // ✅ booking milik pasien (dari koleksi booking/)
  List<Map<String, dynamic>> _bookings = [];
  bool _loadingBooking = false;

  // ✅ refresh status sesi otomatis (cuma pas tab Riwayat aktif)
  Timer? _ticker;

  bool get _tampilkanRiwayat => _chip == 'Riwayat';

  @override
  void initState() {
    super.initState();
    _muatNama();
    _muatDokterFirestore();
    _muatBooking();
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      // muat ulang booking tanpa spinner — status sesi & tombol chat
      // ikut ter-update otomatis saat dokter mengkonfirmasi / sesi lewat
      if (_tampilkanRiwayat) _muatBooking(senyap: true);
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  // ✅ Ambil nama user untuk sapaan
  Future<void> _muatNama() async {
    final nama = await ProfilService.instance.ambilNama();
    if (!mounted) return;
    setState(() => _nama = nama);
  }

  // ✅ Ambil dokter REAL dari Firestore (users role=dokter)
  Future<void> _muatDokterFirestore() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'dokter')
          .get();

      if (!mounted) return;
      setState(() {
        _dokterFirestore = snap.docs
            .map((d) => Dokter.fromFirestore(d.id, d.data()))
            .toList();
        _loadingDokter = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingDokter = false);
    }
  }

  // ✅ Ambil booking milik pasien yang login
  // [senyap=true] -> tanpa spinner & tanpa snackbar (untuk auto-refresh)
  Future<void> _muatBooking({bool senyap = false}) async {
    if (!senyap) setState(() => _loadingBooking = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted && !senyap) setState(() => _loadingBooking = false);
        return;
      }

      final snap = await FirebaseFirestore.instance
          .collection('booking')
          .where('pasienUid', isEqualTo: user.uid)
          .orderBy('dibuatPada', descending: true)
          .get();

      if (!mounted) return;
      setState(() {
        _bookings = snap.docs.map((d) {
          final data = d.data();
          return {
            'id': d.id,
            'dokterNama': (data['dokterNama'] ?? 'Dokter') as String,
            'hari': (data['hari'] ?? '-') as String,
            'tanggal': (data['tanggal'] ?? '') as String,
            'jam': (data['jam'] ?? '-') as String,
            'status': (data['status'] ?? 'menunggu') as String,
            'booking': data,
          };
        }).toList();
        if (!senyap) _loadingBooking = false;
      });
    } catch (e) {
      debugPrint('Gagal muat booking: $e');
      if (mounted && !senyap) {
        setState(() => _loadingBooking = false);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memuat booking: $e')));
      }
    }
  }

  List<Dokter> get _dokterTerfilter {
    final q = _query.trim().toLowerCase();
    final sumber = _dokterFirestore.isNotEmpty ? _dokterFirestore : daftarDokter;
    return sumber.where((d) {
      final bool sesuaiKategori;
      switch (_chip) {
        case 'Dokter Umum':
          sesuaiKategori = !d.isSpesialis;
          break;
        case 'Spesialis':
          sesuaiKategori = d.isSpesialis;
          break;
        default:
          sesuaiKategori = true;
      }
      return sesuaiKategori && d.nama.toLowerCase().contains(q);
    }).toList();
  }

  void _bukaDetail(Dokter d) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailDokterScreen(dokter: d),
        settings: const RouteSettings(name: Rute.detailDokter),
      ),
    );
  }

  // ✅ buka chat BOOKING (pasien ↔ dokter asli)
  void _bukaChatBooking(Map<String, dynamic> b) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatBookingPage(
          bookingId: b['id'],
          booking: b['booking'] as Map<String, dynamic>,
          sayaDokter: false, // ← dari sisi PASIEN
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOMBOL BACK → KEMBALI KE BERANDA
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: AppColors.textDark,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => widget.onKembali?.call(),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Konsultasi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),

            // SAPAAN
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hai, $_nama 👋',
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary)),
                  const SizedBox(height: 4),
                  const Text('Sehat hari ini, langkah baik untuk esok.',
                      style: TextStyle(fontSize: 13, color: AppColors.textSoft)),
                ],
              ),
            ),

            // SEARCH
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: _kolomCari(),
            ),

            // FILTER CHIP — ✅ saat pilih "Riwayat" → refresh booking
            SizedBox(
              height: 52,
              child: _chipBar(),
            ),

            // DAFTAR DOKTER / RIWAYAT
            Expanded(
              child: _tampilkanRiwayat
                  ? _listRiwayat()
                  : (_loadingDokter
                      ? const Center(child: CircularProgressIndicator())
                      : _listDokter()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kolomCari() {
    return TextField(
      onChanged: (v) => setState(() => _query = v),
      cursorColor: AppColors.primary,
      style: const TextStyle(fontSize: 14, color: AppColors.textDark),
      decoration: InputDecoration(
        hintText: 'Cari dokter...',
        hintStyle: const TextStyle(fontSize: 14, color: AppColors.textFaint),
        prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.textFaint),
        filled: true,
        fillColor: AppColors.card,
        contentPadding: EdgeInsets.zero,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
        ),
      ),
    );
  }

  Widget _chipBar() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: _chips.length,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (_, i) {
        final c = _chips[i];
        final terpilih = c == _chip;
        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            setState(() => _chip = c);
            // ✅ saat pilih "Riwayat" → muat ulang booking
            if (c == 'Riwayat') _muatBooking();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: terpilih ? AppColors.primary : AppColors.chipBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(c, style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: terpilih ? Colors.white : AppColors.textSoft,
              )),
            ),
          ),
        );
      },
    );
  }

  Widget _listDokter() {
    final dokter = _dokterTerfilter;
    if (dokter.isEmpty) return _kosong('Tidak ada dokter yang cocok dengan pencarianmu.');
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      itemCount: dokter.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _KartuDokter(dokter: dokter[i], onTap: () => _bukaDetail(dokter[i])),
    );
  }

  // ==================== RIWAYAT BOOKING PASIEN ====================

  Widget _listRiwayat() {
    if (_loadingBooking) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_bookings.isEmpty) {
      return _kosong('Belum ada booking konsultasi.\n'
          'Booking lewat detail dokter ya!');
    }
    return RefreshIndicator(
      onRefresh: _muatBooking,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
        itemCount: _bookings.length,
        itemBuilder: (_, i) => _kartuRiwayatBooking(_bookings[i]),
      ),
    );
  }

  Widget _kartuRiwayatBooking(Map<String, dynamic> b) {
    final booking = b['booking'] as Map<String, dynamic>;
    final status = (b['status'] ?? 'menunggu') as String;
    final kondisi = _hitungKondisiSesi(booking);
    final durasi = _durasiBookingMenit(booking);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- baris nama + badge status ----
          Row(
            children: [
              Expanded(
                child: Text(b['dokterNama'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _chipBg(status, kondisi),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(_chipLabel(status, kondisi),
                    style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: _chipTextColor(status, kondisi))),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${b['hari']}, ${b['tanggal']} • ${b['jam']} (${_labelDurasiBooking(durasi)})',
            style: const TextStyle(
                fontSize: 12.5, color: AppColors.textSoft),
          ),

          // ---- AREA AKSI (sesuai status + waktu) ----
          if (status == 'dikonfirmasi' && _bisaBukaChat(booking)) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton.icon(
                onPressed: () => _bukaChatBooking(b),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.chat_rounded, size: 16),
                label: const Text('Chat Sekarang',
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ] else if (status == 'dikonfirmasi' && kondisi == 'belum') ...[
            const SizedBox(height: 12),
            _infoRiwayat(
              Icons.schedule_rounded,
              'Chat terbuka saat sesi dimulai (${b['jam']}).',
            ),
          ] else if (status == 'dikonfirmasi' && kondisi == 'lewat') ...[
            const SizedBox(height: 12),
            _infoRiwayat(
              Icons.hourglass_bottom_rounded,
              'Sesi konsultasi sudah berakhir.',
            ),
          ] else if (status == 'menunggu' && kondisi != 'lewat') ...[
            const SizedBox(height: 12),
            _infoRiwayat(
              Icons.hourglass_top_rounded,
              'Menunggu konfirmasi dokter.',
            ),
          ] else if (status == 'menunggu' && kondisi == 'lewat') ...[
            const SizedBox(height: 12),
            _infoRiwayat(
              Icons.event_busy_rounded,
              'Booking kedaluwarsa — tanggal konsultasi sudah lewat.',
            ),
          ],
          // status 'ditolak' -> tidak ada tombol/info (chat terkunci)
        ],
      ),
    );
  }

  Widget _infoRiwayat(IconData icon, String text) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.chipBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textFaint),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSoft)),
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

  Widget _kosong(String pesan) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded, size: 44, color: AppColors.textFaint),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(pesan, textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.textSoft)),
          ),
        ],
      ),
    );
  }
}

class _KartuDokter extends StatelessWidget {
  final Dokter dokter;
  final VoidCallback onTap;

  const _KartuDokter({required this.dokter, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _cangkangKartu(
      onTap: onTap,
      child: Row(
        children: [
          AvatarDokter(dokter: dokter, size: 54),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dokter.nama, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                const SizedBox(height: 2),
                Text(dokter.spesialis, style: const TextStyle(fontSize: 12.5, color: AppColors.textSoft)),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.star_rounded, size: 14, color: AppColors.star),
                  const SizedBox(width: 3),
                  Text(dokter.rating.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  Text(' (${dokter.jumlahUlasan})',
                      style: const TextStyle(fontSize: 12, color: AppColors.textFaint)),
                ]),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const BadgeOnline(),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textFaint),
        ],
      ),
    );
  }
}

Widget _cangkangKartu({required VoidCallback onTap, required Widget child}) {
  return Container(
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(16),
      boxShadow: AppShadows.card,
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(14), child: child),
      ),
    ),
  );
}