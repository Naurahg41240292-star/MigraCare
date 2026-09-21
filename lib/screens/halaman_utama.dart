import 'package:flutter/material.dart';
import 'beranda.dart';
import 'konsultasi.dart';
import 'skrining.dart';
import '../theme.dart';

/// Shell utama — SATU-SATUNYA pemilik bottom nav.
/// Semua tab tinggal di dalam IndexedStack, nav tidak pernah berpindah.
class HalamanUtama extends StatefulWidget {
  const HalamanUtama({super.key});

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  int _index = 0;

  void _pindahTab(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          BerandaPage(onBukaSkrining: () => _pindahTab(1)),
          const SkriningPage(),
          KonsultasiScreen(),
          const _Placeholder('Riwayat'),
          const _Placeholder('Profil'),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: _pindahTab,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.accentDark,
        unselectedItemColor: const Color(0xFFB9B2A8),
        selectedFontSize: 11.5,
        unselectedFontSize: 11.5,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fact_check_outlined),
            activeIcon: Icon(Icons.fact_check_rounded),
            label: 'Skrining',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            activeIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Konsultasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder(this.judul);

  final String judul;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction_rounded, size: 44, color: AppColors.textGrey),
            const SizedBox(height: 10),
            Text('Halaman $judul belum dibuat',
                style: const TextStyle(fontSize: 13, color: AppColors.textGrey)),
          ],
        ),
      ),
    );
  }
}