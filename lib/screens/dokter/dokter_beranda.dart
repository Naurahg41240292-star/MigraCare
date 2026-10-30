import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_booking.dart';
import 'lonceng_notifikasi.dart';
import 'dart:convert';
import 'dokter_profil.dart';

abstract class _Bd {
  static const Color bg = Color(0xFFFAF4EA);
  static const Color textDark = Color(0xFF33261A);
  static const Color textGrey = Color(0xFF9C948A);
  static const Color outline = Color(0xFFE5DCCB);
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

  @override
  void initState() {
    super.initState();
    muatFotoDokterGlobal();
    _muat();
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
                                      color:
                                          b['status'] == 'dikonfirmasi'
                                              ? const Color(0xFF3E7C3E)
                                              : (b['status'] == 'ditolak'
                                                  ? const Color(0xFFE55555)
                                                  : const Color(
                                                      0xFFC99A2C)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${b['hari']}, ${b['tanggal']} • ${b['jam']} (30 menit)',
                              style: const TextStyle(
                                  fontSize: 12.5, color: _Bd.textGrey),
                            ),
                            if (b['status'] == 'menunggu') ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () =>
                                          _ubahStatus(b['id'], 'ditolak'),
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
                            ] else ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 42,
                                child: ElevatedButton.icon(
                                  onPressed: () => _bukaChat(b),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFFC9822E),
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