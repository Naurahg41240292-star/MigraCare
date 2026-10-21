import 'package:flutter/material.dart';
import 'dokter_beranda.dart';
import 'dokter_jadwal.dart';
import 'dokter_chat.dart';
import 'dokter_riwayat.dart';
import 'dokter_profil.dart';

/// Shell dokter — SATU-SATUNYA pemilik bottom nav (5 tab sesuai Figma)
class DokterPanelPage extends StatefulWidget {
  const DokterPanelPage({super.key});

  @override
  State<DokterPanelPage> createState() => _DokterPanelPageState();
}

class _DokterPanelPageState extends State<DokterPanelPage> {
  int _index = 0;

  void _pindahTab(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF4EA),
      body: IndexedStack(
        index: _index,
        children: [
          DokterBerandaView(onPindahTab: _pindahTab),
          const DokterJadwalView(),
          const DokterChatView(),
          const DokterRiwayatView(),
          const DokterProfilView(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: _pindahTab,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFFC08A2B),
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
              icon: Icon(Icons.event_available_outlined),
              activeIcon: Icon(Icons.event_available_rounded),
              label: 'Jadwal'),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              activeIcon: Icon(Icons.chat_bubble_rounded),
              label: 'Chat'),
          BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              label: 'Riwayat Pasien'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profil'),
        ],
      ),
    );
  }
}