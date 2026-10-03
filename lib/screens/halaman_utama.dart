import 'package:flutter/material.dart';
import 'beranda.dart' hide AppColors;
import 'konsultasi.dart';
import 'skrining.dart';
import 'riwayat.dart';
import '../theme.dart';
import 'profil.dart' hide AppColors;

/// Shell utama — SATU-SATUNYA pemilik bottom nav.
/// Semua tab tinggal di dalam IndexedStack, nav tidak pernah berpindah.
class HalamanUtama extends StatefulWidget {
  const HalamanUtama({super.key});

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  int _index = 0;

  void _pindahTab(int i) {
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          // TAB 0 — BERANDA
          BerandaPage(
            onBukaSkrining: () => _pindahTab(1),
          ),

          // TAB 1 — SKRINING
          SkriningPage(
            onKembali: () => _pindahTab(0),
            onSelesai: () => _pindahTab(3),
          ),

          // TAB 2 — KONSULTASI
          KonsultasiScreen(
            onKembali: () => _pindahTab(0),
          ),

          // TAB 3 — RIWAYAT
          RiwayatPage(
            onKembali: () => _pindahTab(0),
            onBukaSkrining: () => _pindahTab(1),
          ),

          // TAB 4 — PROFIL
ProfilPage(
  onKembali: () => _pindahTab(0),
),
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

