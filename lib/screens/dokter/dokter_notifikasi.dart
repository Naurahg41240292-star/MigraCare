import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_booking.dart';

class _Nt {
  static const Color bg = Color(0xFFFAF4EA);
  static const Color gold = Color(0xFFC9822E);
  static const Color goldSoft = Color(0xFFFDF3D7);
  static const Color textDark = Color(0xFF33261A);
  static const Color textGrey = Color(0xFF9C948A);
  static const Color outline = Color(0xFFE5DCCB);
  static const Color hijauMuda = Color(0xFFE4F3E4);
  static const Color hijauTua = Color(0xFF3E7C3E);
  static const Color merah = Color(0xFFE55555);
  static const Color merahMuda = Color(0xFFFCE8E6);
  static const Color kuningTua = Color(0xFFC99A2C);
}

/// Halaman Notifikasi Dokter (Level 1 — in-app, dari koleksi booking)
class NotifikasiDokterPage extends StatefulWidget {
  const NotifikasiDokterPage({super.key});

  @override
  State<NotifikasiDokterPage> createState() => _NotifikasiDokterPageState();
}

class _NotifikasiDokterPageState extends State<NotifikasiDokterPage> {
  String? get _uidSaya => FirebaseAuth.instance.currentUser?.uid;

  String _waktuLalu(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'Baru saja';
    if (d.inMinutes < 60) return '${d.inMinutes} menit lalu';
    if (d.inHours < 24) return '${d.inHours} jam lalu';
    return '${d.inDays} hari lalu';
  }

  Future<void> _setStatus(String id, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('booking')
          .doc(id)
          .update({'status': status});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(status == 'dikonfirmasi'
              ? 'Booking dikonfirmasi. Chat dengan pasien sudah aktif.'
              : 'Booking ditolak.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui booking: $e')),
      );
    }
  }

  void _dialogPermintaan(String id, Map<String, dynamic> b) {
    final nama = (b['pasienNama'] ?? 'Pasien').toString();
    final hari = (b['hari'] ?? '-').toString();
    final tanggal = (b['tanggal'] ?? '').toString();
    final jam = (b['jam'] ?? '-').toString();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Permintaan Konsultasi',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _Nt.textDark)),
        content: Text(
          '$nama meminta konsultasi pada:\n\n$hari, $tanggal • $jam\n\nKonfirmasi booking ini?',
          style: const TextStyle(
              fontSize: 13, height: 1.5, color: _Nt.textDark),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _setStatus(id, 'ditolak');
            },
            child: const Text('Tolak',
                style: TextStyle(
                    color: _Nt.merah, fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _setStatus(id, 'dikonfirmasi');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _Nt.hijauTua,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Konfirmasi',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _bukaChat(String id, Map<String, dynamic> b) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatBookingPage(
          bookingId: id,
          booking: b,
          sayaDokter: true,
        ),
      ),
    );
  }

  Widget _kosong(String pesan) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.notifications_off_rounded,
                size: 48, color: _Nt.textGrey),
            const SizedBox(height: 12),
            Text(pesan,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(color: _Nt.textGrey, fontSize: 13.5)),
          ],
        ),
      ),
    );
  }

  Widget _kartuNotifikasi(String id, Map<String, dynamic> b) {
    final status = (b['status'] ?? 'menunggu').toString();
    final nama = (b['pasienNama'] ?? 'Pasien').toString();
    final hari = (b['hari'] ?? '-').toString();
    final tanggal = (b['tanggal'] ?? '').toString();
    final jam = (b['jam'] ?? '-').toString();
    final dibuat = b['dibuatPada'] is Timestamp
        ? (b['dibuatPada'] as Timestamp).toDate()
        : null;

    IconData ikon;
    Color ikonBg;
    Color ikonWarna;
    String judul;
    String chip;
    Color chipBg;
    Color chipTeks;

    if (status == 'menunggu') {
      ikon = Icons.notifications_active_rounded;
      ikonBg = _Nt.goldSoft;
      ikonWarna = _Nt.gold;
      judul = 'Permintaan konsultasi baru';
      chip = 'Menunggu';
      chipBg = _Nt.goldSoft;
      chipTeks = _Nt.kuningTua;
    } else if (status == 'dikonfirmasi') {
      ikon = Icons.check_circle_rounded;
      ikonBg = _Nt.hijauMuda;
      ikonWarna = _Nt.hijauTua;
      judul = 'Konsultasi aktif';
      chip = 'Dikonfirmasi';
      chipBg = _Nt.hijauMuda;
      chipTeks = _Nt.hijauTua;
    } else {
      ikon = Icons.cancel_rounded;
      ikonBg = _Nt.merahMuda;
      ikonWarna = _Nt.merah;
      judul = 'Booking ditolak';
      chip = 'Ditolak';
      chipBg = _Nt.merahMuda;
      chipTeks = _Nt.merah;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            if (status == 'menunggu') {
              _dialogPermintaan(id, b);
            } else if (status == 'dikonfirmasi') {
              _bukaChat(id, b);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Booking ini sudah ditolak.')),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _Nt.outline),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: ikonBg,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(ikon, size: 20, color: ikonWarna),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(judul,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: _Nt.textDark)),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: chipBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(chip,
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: chipTeks)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text('$nama • $hari, $tanggal • $jam',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, color: _Nt.textGrey)),
                      if (dibuat != null) ...[
                        const SizedBox(height: 3),
                        Text(_waktuLalu(dibuat),
                            style: const TextStyle(
                                fontSize: 10.5, color: _Nt.textGrey)),
                      ],
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

  @override
  Widget build(BuildContext context) {
    final me = _uidSaya;
    return Scaffold(
      backgroundColor: _Nt.bg,
      appBar: AppBar(
        backgroundColor: _Nt.bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: _Nt.textDark),
        title: const Text('Notifikasi',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: _Nt.textDark)),
      ),
      body: me == null
          ? _kosong('Gagal memuat akun. Coba login ulang.')
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('booking')
                  .where('dokterUid', isEqualTo: me)
                  .orderBy('dibuatPada', descending: true)
                  .limit(30)
                  .snapshots(),
              builder: (context, snap) {
                if (snap.hasError) {
                  return _kosong('Gagal memuat notifikasi.');
                }
                if (!snap.hasData) {
                  return const Center(
                      child: CircularProgressIndicator(color: _Nt.gold));
                }
                final docs = snap.data!.docs;
                final menunggu = docs
                    .where((d) => d.data()['status'] == 'menunggu')
                    .length;

                if (docs.isEmpty) {
                  return _kosong(
                      'Belum ada notifikasi.\nNotifikasi muncul saat ada booking konsultasi.');
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  itemCount: docs.length + 1,
                  itemBuilder: (context, i) {
                    if (i == 0) {
                      if (menunggu == 0) return const SizedBox.shrink();
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _Nt.goldSoft,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _Nt.outline),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.notifications_active_rounded,
                                color: _Nt.gold, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '$menunggu permintaan konsultasi menunggu respons kamu',
                                style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: _Nt.textDark),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    final doc = docs[i - 1];
                    return _kartuNotifikasi(doc.id, doc.data());
                  },
                );
              },
            ),
    );
  }
}