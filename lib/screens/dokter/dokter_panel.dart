import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/masuk.dart';
import 'jadwal_saya.dart';
import 'chat_booking.dart';

abstract class _Dk {
  static const Color bg = Color(0xFFFAF4EA);
  static const Color gold = Color(0xFFC08A2B);
  static const Color textDark = Color(0xFF33261A);
  static const Color textGrey = Color(0xFF9C948A);
  static const Color outline = Color(0xFFE5DCCB);
}

/// ==========================================================================
///  MIGRACARE — Beranda Dokter (sesuai desain Figma) + Booking Masuk
///  File: lib/screens/dokter_panel.dart
/// ==========================================================================

class DokterPanelPage extends StatefulWidget {
  const DokterPanelPage({super.key});

  @override
  State<DokterPanelPage> createState() => _DokterPanelPageState();
}

class _DokterPanelPageState extends State<DokterPanelPage> {
  bool _loading = true;

  String _namaDokter = '...';
  int _totalPasien = 0;
  int _pasienBaruHariIni = 0;
  List<Map<String, dynamic>> _aktivitas = [];
  List<Map<String, dynamic>> _bookings = [];

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    setState(() => _loading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      final uid = user?.uid ?? '';

      // ---------- Nama dokter ----------
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

      // ---------- Data pasien ----------
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'pasien')
          .get();

      final awalHari = DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day);

      int baruHariIni = 0;
      final aktivitas = <Map<String, dynamic>>[];

      for (final doc in snap.docs) {
        final data = doc.data();
        final nama = (data['profile']?['namaLengkap'] ??
                data['akun']?['namaLengkap'] ??
                'Tanpa nama') as String;

        final dibuat = data['akun']?['dibuatPada'];
        DateTime? dibuatDate;
        if (dibuat is Timestamp) dibuatDate = dibuat.toDate();
        if (dibuatDate != null && dibuatDate.isAfter(awalHari)) {
          baruHariIni++;
        }
        if (dibuatDate != null) {
          aktivitas.add({'nama': nama, 'waktu': dibuatDate});
        }
      }
      aktivitas.sort((a, b) =>
          (b['waktu'] as DateTime).compareTo(a['waktu'] as DateTime));

      // ---------- BOOKING MASUK ----------
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
          };
        }).toList();
      }

    
      if (!mounted) return;
      setState(() {
        _totalPasien = snap.docs.length;
        _pasienBaruHariIni = baruHariIni;
        _aktivitas = aktivitas.take(3).toList();
        _bookings = bookings;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
      }
    }
  }


  // ================= KONFIRMASI / TOLAK BOOKING =================
  Future<void> _ubahStatus(String bookingId, String statusBaru) async {
    try {
      await FirebaseFirestore.instance
          .collection('booking')
          .doc(bookingId)
          .update({'status': statusBaru});
      _muat();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal mengubah status: $e')));
      }
    }
  }

  String _waktuLalu(DateTime d) {
    final selisih = DateTime.now().difference(d);
    if (selisih.inMinutes < 1) return 'baru saja';
    if (selisih.inMinutes < 60) return '${selisih.inMinutes} menit lalu';
    if (selisih.inHours < 24) return '${selisih.inHours} jam lalu';
    return '${selisih.inDays} hari lalu';
  }

  void _showSnack(String m) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(m),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _Dk.textDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Dk.bg,
      body: SafeArea(
        bottom: false,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _muat,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ---------- HEADER ----------
                      Row(
                        children: [
                          Image.asset('assets/images/logo_atas.png',
                              height: 34, fit: BoxFit.contain),
                          const Spacer(),
                          const Icon(Icons.notifications_none_rounded,
                              color: _Dk.textDark, size: 26),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: _konfirmasiKeluar,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: const Color(0xFFC9822E),
                              child: const Icon(Icons.logout_rounded,
                                  size: 18, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // ---------- SAPAAN ----------
                      Text('Halo, $_namaDokter',
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: _Dk.textDark)),
                      const SizedBox(height: 6),
                      const Text(
                        'Semoga hari ini berjalan lancar dalam memberikan pelayanan terbaik.',
                        style: TextStyle(
                            fontSize: 12.5,
                            height: 1.5,
                            color: _Dk.textGrey),
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
                        child: Column(
                          children: [
                            Row(
                              children: [
                                _statItem(
                                    Icons.person_search_rounded,
                                    'Pasien Terdaftar',
                                    '$_totalPasien'),
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
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                                            // ---------- BOOKING MASUK ----------
                      const Text('Booking Masuk',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _Dk.textDark)),
                      const SizedBox(height: 12),

                      if (_bookings.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: _Dk.outline),
                          ),
                          child: const Text(
                            'Belum ada booking konsultasi.',
                            style: TextStyle(
                                fontSize: 12.5, color: _Dk.textGrey),
                          ),
                        )
                      else
                        for (final b in _bookings)
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: b['status'] == 'menunggu'
                                    ? const Color(0xFFC9822E)
                                    : _Dk.outline,
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
                                              color: _Dk.textDark)),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: b['status'] == 'dikonfirmasi'
                                            ? const Color(0xFFE4F3E4)
                                            : (b['status'] == 'ditolak'
                                                ? const Color(0xFFFCE8E6)
                                                : const Color(0xFFFDF3D7)),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        b['status'],
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                          color: b['status'] == 'dikonfirmasi'
                                              ? const Color(0xFF3E7C3E)
                                              : (b['status'] == 'ditolak'
                                                  ? const Color(0xFFE55555)
                                                  : const Color(0xFFC99A2C)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${b['hari']}, ${b['tanggal']} • ${b['jam']} (30 menit)',
                                  style: const TextStyle(
                                      fontSize: 12.5, color: _Dk.textGrey),
                                ),
                                if (b['status'] == 'menunggu') ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () => _ubahStatus(
                                              b['id'], 'ditolak'),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor:
                                                const Color(0xFFE55555),
                                            side: const BorderSide(
                                                color: Color(0xFFE55555)),
                                            padding: const EdgeInsets
                                                .symmetric(vertical: 8),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10)),
                                          ),
                                          child: const Text('Tolak',
                                              style: TextStyle(
                                                  fontSize: 12.5,
                                                  fontWeight:
                                                      FontWeight.w700)),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () => _ubahStatus(
                                              b['id'], 'dikonfirmasi'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFFC9822E),
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            padding: const EdgeInsets
                                                .symmetric(vertical: 8),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10)),
                                          ),
                                          child: const Text('Konfirmasi',
                                              style: TextStyle(
                                                  fontSize: 12.5,
                                                  fontWeight:
                                                      FontWeight.w700)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                // ✅ TAMBAH: tombol Buka Chat (booking yang dikonfirmasi)
                                if (b['status'] == 'dikonfirmasi') ...[
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 42,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
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
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF6B4A2B),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                      icon: const Icon(Icons.chat_rounded,
                                          size: 16),
                                      label: const Text('Buka Chat',
                                          style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w700)),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                      const SizedBox(height: 24),
                    
                      // ---------- AKSES CEPAT ----------
                      const Text('Akses Cepat',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _Dk.textDark)),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          _aksesCepat(Icons.event_available_rounded,
                              'Jadwal Saya', () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const JadwalSayaPage()),
                            );
                          }),
                          const SizedBox(width: 12),
                          _aksesCepat(Icons.groups_rounded, 'Daftar Pasien',
                              () => _showSnack('Daftar Pasien (menyusul)')),
                          const SizedBox(width: 12),
                          _aksesCepat(Icons.history_rounded,
                              'Riwayat Skrining',
                              () => _showSnack('Riwayat Skrining (menyusul)')),
                          const SizedBox(width: 12),
                          _aksesCepat(Icons.article_rounded, 'Artikel',
                              () => _showSnack('Artikel (menyusul)')),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // ---------- AKTIVITAS TERBARU ----------
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Aktivitas Terbaru',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: _Dk.textDark)),
                          Text('Lihat Semua >',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _Dk.gold)),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (_aktivitas.isEmpty)
                        const Text('Belum ada aktivitas.',
                            style: TextStyle(
                                fontSize: 12, color: _Dk.textGrey))
                      else
                        for (final a in _aktivitas)
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: _Dk.outline),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 21,
                                  backgroundColor: const Color(0xFFF6DFC8),
                                  child: Text(
                                    (a['nama'] as String).isEmpty
                                        ? '?'
                                        : (a['nama'] as String)[0]
                                            .toUpperCase(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: _Dk.gold),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text((a['nama'] as String),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                          color: _Dk.textDark)),
                                ),
                                Text(_waktuLalu(a['waktu'] as DateTime),
                                    style: const TextStyle(
                                        fontSize: 10.5,
                                        color: _Dk.textGrey)),
                              ],
                            ),
                          ),
                    ],
                  ),
                ),
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
            border: Border.all(color: _Dk.outline),
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
                      color: _Dk.textDark)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _konfirmasiKeluar() async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar dari Akun?',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _Dk.textDark)),
        content: const Text('Kamu harus masuk lagi untuk mengakses akunmu.',
            style: TextStyle(fontSize: 13, color: _Dk.textGrey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: _Dk.textGrey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar',
                style: TextStyle(
                    color: Color(0xFFE55555),
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (yakin != true || !mounted) return;

    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MasukPage()),
      (route) => false,
    );
  }
}