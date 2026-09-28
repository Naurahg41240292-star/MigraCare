import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/artikel.dart';
import 'informasi_layanan.dart' show daftarLayanan;
import 'admin_panel.dart';
import 'masuk.dart';

/// ==========================================================================
///  MIGRACARE — Panel Admin (Beranda + Bottom Nav 4 tab)
///  File: lib/screens/admin_beranda.dart
/// ==========================================================================

abstract class _Ab {
  static const Color bg = Color(0xFFFAF4EA);
  static const Color gold = Color(0xFFC08A2B);
  static const Color textDark = Color(0xFF33261A);
  static const Color textGrey = Color(0xFF9C948A);
  static const Color outline = Color(0xFFE5DCCB);
}

class AdminBerandaPage extends StatefulWidget {
  const AdminBerandaPage({super.key});

  @override
  State<AdminBerandaPage> createState() => _AdminBerandaPageState();
}

class _AdminBerandaPageState extends State<AdminBerandaPage> {
  int _index = 0;

  int _totalPengguna = 0;
  int _totalDokter = 0;
  List<Map<String, dynamic>> _aktivitas = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  Future<void> _muatData() async {
    setState(() => _loading = true);
    try {
      final usersSnap =
          await FirebaseFirestore.instance.collection('users').get();

      int dokter = 0;
      final aktivitas = <Map<String, dynamic>>[];

      for (final doc in usersSnap.docs) {
        final data = doc.data();
        final role = (data['role'] ?? 'pasien') as String;
        if (role == 'dokter') dokter++;

        // aktivitas terbaru: user yang baru mendaftar
        final dibuat = data['akun']?['dibuatPada'];
        if (dibuat != null) {
          aktivitas.add({
            'nama': (data['profile']?['namaLengkap'] ??
                    data['akun']?['namaLengkap'] ??
                    'Tanpa nama') as String,
            'waktu': (dibuat as Timestamp).toDate(),
            'role': role,
          });
        }
      }
      aktivitas.sort((a, b) =>
          (b['waktu'] as DateTime).compareTo(a['waktu'] as DateTime));

      if (!mounted) return;
      setState(() {
        _totalPengguna = usersSnap.docs.length;
        _totalDokter = dokter;
        _aktivitas = aktivitas.take(3).toList();
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

  String _waktuLalu(DateTime d) {
    final selisih = DateTime.now().difference(d);
    if (selisih.inMinutes < 1) return 'baru saja';
    if (selisih.inMinutes < 60) return '${selisih.inMinutes} menit lalu';
    if (selisih.inHours < 24) return '${selisih.inHours} jam lalu';
    return '${selisih.inDays} hari lalu';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Ab.bg,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _index,
          children: [
            _dashboard(),
            _placeholder('Laporan'),
            _placeholder('Artikel'),
            _kelolaUserTab(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: _Ab.gold,
        unselectedItemColor: const Color(0xFFB9B2A8),
        selectedFontSize: 11.5,
        unselectedFontSize: 11.5,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Beranda'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded),
              activeIcon: Icon(Icons.bar_chart_rounded),
              label: 'Laporan'),
          BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_rounded),
              activeIcon: Icon(Icons.menu_book_rounded),
              label: 'Artikel'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings_rounded),
              label: 'Pengaturan'),
        ],
      ),
    );
  }

  // ============================ TAB 0: DASHBOARD ============================
  Widget _dashboard() {
    return RefreshIndicator(
      onRefresh: _muatData,
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
                Stack(
                  children: [
                    const Icon(Icons.notifications_none_rounded,
                        color: _Ab.textDark, size: 26),
                    if (_loading)
                      const SizedBox.shrink()
                    else
                      const Positioned(
                        right: 0,
                        top: 0,
                        child: CircleAvatar(
                            radius: 4, backgroundColor: Colors.redAccent),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFC9822E),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.logout_rounded,
                        size: 18, color: Colors.white),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (!context.mounted) return;
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MasukPage()),
                          (route) => false);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            const Text('Selamat datang,',
                style: TextStyle(fontSize: 13, color: _Ab.textGrey)),
            const Text('Admin',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _Ab.textDark)),
            const Text('Kelola data aplikasi dengan mudah.',
                style: TextStyle(fontSize: 12.5, color: _Ab.textGrey)),
            const SizedBox(height: 20),

            // ---------- KARTU TOTAL PENGGUNA ----------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
              child: _loading
                  ? const SizedBox(
                      height: 60,
                      child: Center(
                          child: CircularProgressIndicator(
                              color: Colors.white)))
                  : Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Total Pengguna',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 13)),
                              const SizedBox(height: 6),
                              Text('$_totalPengguna',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 34,
                                      fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.groups_rounded,
                              color: Colors.white, size: 30),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 16),

            // ---------- 3 STAT KECIL ----------
            Row(
              children: [
                _statKecil('Artikel', '${artikelPopuler.length}'),
                const SizedBox(width: 12),
                _statKecil('Layanan', '${daftarLayanan.length}'),
                const SizedBox(width: 12),
                _statKecil('Dokter', '$_totalDokter'),
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
                        color: _Ab.textDark)),
                Text('Lihat Semua >',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _Ab.gold)),
              ],
            ),
            const SizedBox(height: 12),

            if (!_loading && _aktivitas.isEmpty)
              const Text('Belum ada aktivitas.',
                  style: TextStyle(fontSize: 12, color: _Ab.textGrey))
            else
              for (final a in _aktivitas)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _Ab.outline),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFDF3D7),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          a['role'] == 'dokter'
                              ? Icons.person_outline_rounded
                              : Icons.person_rounded,
                          color: const Color(0xFFC99A2C),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                a['role'] == 'dokter'
                                    ? 'Dokter baru terdaftar'
                                    : 'Pengguna baru mendaftar',
                                style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: _Ab.textDark)),
                            const SizedBox(height: 2),
                            Text(a['nama'],
                                style: const TextStyle(
                                    fontSize: 12, color: _Ab.textGrey)),
                          ],
                        ),
                      ),
                      Text(_waktuLalu(a['waktu']),
                          style: const TextStyle(
                              fontSize: 10.5, color: _Ab.textGrey)),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _statKecil(String judul, String nilai) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _Ab.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(judul,
                style:
                    const TextStyle(fontSize: 11.5, color: _Ab.textGrey)),
            const SizedBox(height: 6),
            Text(nilai,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _Ab.textDark)),
          ],
        ),
      ),
    );
  }

  // ============================ TAB 3: KELOLA USER ==========================
  Widget _kelolaUserTab() {
    return Scaffold(
      backgroundColor: _Ab.bg,
      appBar: AppBar(
        backgroundColor: _Ab.bg,
        elevation: 0,
        title: const Text('Kelola Pengguna',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: _Ab.textDark)),
      ),
      body: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance.collection('users').get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i].data();
              final role = (data['role'] ?? 'pasien') as String;
              final nama = (data['profile']?['namaLengkap'] ??
                      data['akun']?['namaLengkap'] ??
                      'Tanpa nama') as String;
              final email = (data['akun']?['email'] ?? '-') as String;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _Ab.outline),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(nama,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: _Ab.textDark)),
                          Text(email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 11, color: _Ab.textGrey)),
                        ],
                      ),
                    ),
                    DropdownButton<String>(
                      value: role,
                      underline: const SizedBox(),
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _Ab.gold),
                      items: const [
                        DropdownMenuItem(value: 'pasien', child: Text('Pasien')),
                        DropdownMenuItem(value: 'dokter', child: Text('Dokter')),
                        DropdownMenuItem(value: 'admin', child: Text('Admin')),
                      ],
                      onChanged: (v) {
                        if (v != null && v != role) {
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(docs[i].id)
                              .update({'role': v});
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ============================ TAB PLACEHOLDER =============================
  Widget _placeholder(String judul) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.construction_rounded,
              size: 44, color: _Ab.textGrey),
          const SizedBox(height: 10),
          Text('Halaman $judul (segera hadir)',
              style:
                  const TextStyle(fontSize: 13, color: _Ab.textGrey)),
        ],
      ),
    );
  }
}