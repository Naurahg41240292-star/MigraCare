import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'admin_laporan.dart';
import 'admin_artikel.dart';
import 'admin_layanan.dart';
import 'admin_notifikasi.dart';
import 'admin_pengaturan.dart';
import '../../models/artikel.dart';
import '../../services/notifikasi_service.dart';
import '../informasi_layanan.dart' show daftarLayanan;
import '../auth/masuk.dart';

/// ==========================================================================
///  MIGRACARE — Panel Admin (Beranda + Bottom Nav 5 tab)
///  File: lib/screens/admin/admin_beranda.dart
///  Tab: Beranda | Laporan | Artikel | Layanan | Pengaturan
/// ==========================================================================

abstract class _Ab {
  static const Color bg = Color(0xFFFAF4EA);
  static const Color gold = Color(0xFFC08A2B);
  static const Color textDark = Color(0xFF33261A);
  static const Color textGrey = Color(0xFF9C948A);
  static const Color outline = Color(0xFFE5DCCB);
}

String _fmtWaktuLalu(DateTime d) {
  final selisih = DateTime.now().difference(d);
  if (selisih.inMinutes < 1) return 'baru saja';
  if (selisih.inMinutes < 60) return '${selisih.inMinutes} menit lalu';
  if (selisih.inHours < 24) return '${selisih.inHours} jam lalu';
  return '${selisih.inDays} hari lalu';
}

// ==================== DEKOR SPRINKLE (SAMAR) ====================
/// Latar dekoratif halus untuk area "Selamat Datang, Admin":
/// logo MigraCare dimiringkan + lingkaran lembut dengan opacity rendah,
/// supaya tampil cantik tapi teks tetap jelas terbaca.
class _SprinkleDekor extends StatelessWidget {
  const _SprinkleDekor();

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFC08A2B);
    return Stack(
      children: [
        // lingkaran lembut pojok kanan-atas
        Positioned(
          right: -20,
          top: -26,
          child: Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: gold.withValues(alpha: 0.08),
            ),
          ),
        ),
        // lingkaran kecil pojok kiri-bawah
        Positioned(
          left: -14,
          bottom: -18,
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: gold.withValues(alpha: 0.07),
            ),
          ),
        ),
        // titik hiasan kecil
        Positioned(
          left: 84,
          top: 6,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: gold.withValues(alpha: 0.15),
            ),
          ),
        ),
        Positioned(
          right: 88,
          bottom: 2,
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: gold.withValues(alpha: 0.15),
            ),
          ),
        ),
        // logo samar — utama (kanan)
        Positioned(
          right: 6,
          top: 0,
          child: Transform.rotate(
            angle: -0.16,
            child: Opacity(
              opacity: 0.10,
              child: Image.asset('assets/images/logo_atas.png',
                  height: 50, fit: BoxFit.contain),
            ),
          ),
        ),
        // logo samar — kecil (kiri bawah)
        Positioned(
          left: 42,
          bottom: -8,
          child: Transform.rotate(
            angle: 0.2,
            child: Opacity(
              opacity: 0.07,
              child: Image.asset('assets/images/logo_atas.png',
                  height: 32, fit: BoxFit.contain),
            ),
          ),
        ),
      ],
    );
  }
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
    NotifikasiService.init();
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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
      }
    }
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
            const AdminLaporanPage(),
            const AdminArtikelPage(),
            AdminLayananPage(),
                        const AdminPengaturanTab(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) {
          setState(() => _index = i);
          if (i == 0) _muatData(); // refresh statistik tiap balik ke Beranda
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: _Ab.gold,
        unselectedItemColor: const Color(0xFFB9B2A8),
        selectedFontSize: 11,
        unselectedFontSize: 11,
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
              icon: Icon(Icons.local_hospital_outlined),
              activeIcon: Icon(Icons.local_hospital_rounded),
              label: 'Layanan'),
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
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AdminNotifikasiPage()),
                  ),
                  child: ValueListenableBuilder<int>(
                    valueListenable: NotifikasiService.penggunaBaru,
                    builder: (context, jumlah, _) => Stack(
                      children: [
                        const Icon(Icons.notifications_none_rounded,
                            color: _Ab.textDark, size: 26),
                        if (jumlah > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                  color: Colors.redAccent,
                                  shape: BoxShape.circle),
                              child: Text('$jumlah',
                                  style: const TextStyle(
                                      fontSize: 8,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                      ],
                    ),
                  ),
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
                          MaterialPageRoute(builder: (_) => const MasukPage()),
                          (route) => false);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ---------- SELAMAT DATANG + SPRINKLE SAMAR ----------
            SizedBox(
              width: double.infinity,
              child: Stack(
                children: [
                  // dekorasi samar di belakang teks (tidak bisa disentuh)
                  Positioned.fill(
                    child: IgnorePointer(child: const _SprinkleDekor()),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Selamat datang,',
                          style:
                              TextStyle(fontSize: 13, color: _Ab.textGrey)),
                      SizedBox(height: 2),
                      Text('Admin',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: _Ab.textDark)),
                      SizedBox(height: 2),
                      Text('Kelola data aplikasi dengan mudah.',
                          style: TextStyle(
                              fontSize: 12.5, color: _Ab.textGrey)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ---------- KARTU TOTAL PENGGUNA (tekan -> Pengaturan) ----------
            GestureDetector(
              onTap: () => setState(() => _index = 4),
              child: Container(
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
                            child: CircularProgressIndicator(color: Colors.white)))
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
            ),
            const SizedBox(height: 16),

            // ---------- 3 STAT KECIL (semua bisa ditekan) ----------
            Row(
              children: [
                _statKecil('Artikel', '0',
                    onTap: () => setState(() => _index = 2)),
                const SizedBox(width: 12),
                _statKecil('Layanan', '0',
                    onTap: () => setState(() => _index = 3)),
                const SizedBox(width: 12),
                _statKecil('Manajemen User', '$_totalDokter',
                    onTap: () => setState(() => _index = 4)),
              ],
            ),
            const SizedBox(height: 24),

            // ---------- AKTIVITAS TERBARU ----------
            const Text('Aktivitas Terbaru',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _Ab.textDark)),
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
                              ? Icons.medical_services_outlined
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
                      Text(_fmtWaktuLalu(a['waktu'] as DateTime),
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

  
Widget _statKecil(String judul, String nilai, {VoidCallback? onTap}) {
  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        height: 97,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _Ab.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              judul,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 11.5,
                color: _Ab.textGrey,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              nilai,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _Ab.textDark,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}

