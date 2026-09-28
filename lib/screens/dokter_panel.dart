import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'masuk.dart';

abstract class _Dk {
  static const Color bg = Color(0xFFFAF4EA);
  static const Color gold = Color(0xFFC08A2B);
  static const Color textDark = Color(0xFF33261A);
  static const Color textGrey = Color(0xFF9C948A);
  static const Color outline = Color(0xFFE5DCCB);
}

/// ==========================================================================
///  MIGRACARE — Panel Dokter (daftar pasien & ringkasan skrining)
///  File: lib/screens/dokter_panel.dart
/// ==========================================================================

class DokterPanelPage extends StatefulWidget {
  const DokterPanelPage({super.key});

  @override
  State<DokterPanelPage> createState() => _DokterPanelPageState();
}

class _DokterPanelPageState extends State<DokterPanelPage> {
  bool _loading = true;
  List<Map<String, dynamic>> _pasien = [];

  @override
  void initState() {
    super.initState();
    _muat();
  }

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
          'nama': (data['profile']?['namaLengkap'] ??
                  data['akun']?['namaLengkap'] ??
                  'Tanpa nama') as String,
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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal memuat pasien: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Dk.bg,
            appBar: AppBar(
        backgroundColor: _Dk.bg,
        elevation: 0,
        centerTitle: false,
        title: const Text('Panel Dokter',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: _Dk.textDark)),
        actions: [
          IconButton(
            onPressed: _muat,
            icon: const Icon(Icons.refresh_rounded, color: _Dk.textDark),
          ),
          IconButton(
            onPressed: () async {
              // konfirmasi dulu biar nggak salah tekan
              final yakin = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  title: const Text('Keluar dari Akun?',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _Dk.textDark)),
                  content: const Text(
                      'Kamu harus masuk lagi untuk mengakses akunmu.',
                      style:
                          TextStyle(fontSize: 13, color: _Dk.textGrey)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Batal',
                          style: TextStyle(color: _Dk.textGrey)),
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
            },
            icon: const Icon(Icons.logout_rounded, color: _Dk.textDark),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _muat,
              child: _pasien.isEmpty
                  ? ListView(children: const [
                      SizedBox(height: 140),
                      Center(
                          child: Text('Belum ada pasien terdaftar.',
                              style: TextStyle(color: _Dk.textGrey))),
                    ])
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      itemCount: _pasien.length,
                      itemBuilder: (context, i) {
                        final p = _pasien[i];
                        return Container(
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
                                radius: 22,
                                backgroundColor: const Color(0xFFF6DFC8),
                                child: Text(
                                  p['nama'].toString().isEmpty
                                      ? '?'
                                      : p['nama']
                                          .toString()[0]
                                          .toUpperCase(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: _Dk.gold),
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
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: _Dk.textDark)),
                                    const SizedBox(height: 3),
                                    Text(
                                        'Skrining ${p['jumlah']}x • Hasil terakhir: ${p['terakhir']}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: _Dk.textGrey)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}