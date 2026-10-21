import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dokter_detail_pasien.dart';

abstract class _Rw {
  static const Color bg = Color(0xFFFAF4EA);
  static const Color gold = Color(0xFFC08A2B);
  static const Color textDark = Color(0xFF33261A);
  static const Color textGrey = Color(0xFF9C948A);
  static const Color outline = Color(0xFFE5DCCB);
}

/// TAB Riwayat Pasien — daftar pasien + ringkasan skrining
class DokterRiwayatView extends StatefulWidget {
  const DokterRiwayatView({super.key});

  @override
  State<DokterRiwayatView> createState() => _DokterRiwayatViewState();
}

class _DokterRiwayatViewState extends State<DokterRiwayatView> {
  bool _loading = true;
  List<Map<String, dynamic>> _pasien = [];

  @override
  void initState() {
    super.initState();
    _muat();
  }

  void muatUlang() => _muat();

  Future<void> _muat() async {
    setState(() => _loading = true);
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'pasien')
          .get();

      final pasien = <Map<String, dynamic>>[];
      for (final doc in snap.docs) {
        final data = doc.data();
        final skrining = await FirebaseFirestore.instance
            .collection('users')
            .doc(doc.id)
            .collection('screenings')
            .orderBy('waktu', descending: true)
            .get();

        pasien.add({
          'uid': doc.id,
          'nama': (data['profile']?['namaLengkap'] ??
                  data['akun']?['namaLengkap'] ??
                  'Tanpa nama') as String,
          'email': (data['akun']?['email'] ?? '-') as String,
          'jumlah': skrining.docs.length,
          'terakhir': skrining.docs.isNotEmpty
              ? (skrining.docs.first.data()['hasil'] ?? '-') as String
              : 'Belum ada',
        });
      }

      if (!mounted) return;
      setState(() {
        _pasien = pasien;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memuat pasien: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Rw.bg,
      appBar: AppBar(
        backgroundColor: _Rw.bg,
        elevation: 0,
        title: const Text('Riwayat Pasien',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: _Rw.textDark)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _muat,
              child: _pasien.isEmpty
                  ? ListView(children: const [
                      SizedBox(height: 140),
                      Icon(Icons.groups_rounded,
                          size: 48, color: _Rw.textGrey),
                      SizedBox(height: 12),
                      Center(
                          child: Text('Belum ada pasien terdaftar.',
                              style: TextStyle(
                                  color: _Rw.textGrey, fontSize: 13))),
                    ])
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      itemCount: _pasien.length,
                      itemBuilder: (context, i) {
                        final p = _pasien[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DetailPasienView(
                                      pasienUid: p['uid'] as String,
                                      pasienNama: p['nama'] as String?,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: _Rw.outline),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundColor:
                                          const Color(0xFFF6DFC8),
                                      child: Text(
                                        p['nama'].toString().isEmpty
                                            ? '?'
                                            : p['nama']
                                                .toString()[0]
                                                .toUpperCase(),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: _Rw.gold),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(p['nama'],
                                              maxLines: 1,
                                              overflow:
                                                  TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight:
                                                      FontWeight.w700,
                                                  color: _Rw.textDark)),
                                          const SizedBox(height: 3),
                                          Text(
                                              'Skrining ${p['jumlah']}x • Hasil terakhir: ${p['terakhir']}',
                                              maxLines: 1,
                                              overflow:
                                                  TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontSize: 11.5,
                                                  color: _Rw.textGrey)),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                        Icons.chevron_right_rounded,
                                        color: _Rw.textGrey),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}