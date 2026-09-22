import 'package:flutter/material.dart';

/// ==========================================================================
///  MIGRACARE — Halaman Pengaturan Notifikasi
///  File: lib/screens/pengaturan_notifikasi.dart
/// ==========================================================================

abstract class AppColors {
  static const Color background = Color(0xFFFAF4EA);
  static const Color surface = Colors.white;
  static const Color darkBrown = Color(0xFF3D2B1A);
  static const Color accent = Color(0xFFF2C230);
  static const Color accentDark = Color(0xFFB07E1F);
  static const Color textDark = Color(0xFF33261A);
  static const Color textGrey = Color(0xFF9C948A);
  static const Color outline = Color(0xFFEDE3D4);
}

/// Penyimpanan status toggle (berlaku selama aplikasi terbuka)
class SetelanNotifikasi {
  SetelanNotifikasi._();
  static final SetelanNotifikasi instance = SetelanNotifikasi._();

  bool pengingatObat = true;
  bool tipsEdukasi = true;
  bool artikelTerbaru = false;
}

class PengaturanNotifikasiPage extends StatefulWidget {
  const PengaturanNotifikasiPage({super.key});

  @override
  State<PengaturanNotifikasiPage> createState() =>
      _PengaturanNotifikasiPageState();
}

class _PengaturanNotifikasiPageState extends State<PengaturanNotifikasiPage> {
  @override
  Widget build(BuildContext context) {
    final s = SetelanNotifikasi.instance;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= HEADER =================
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: AppColors.darkBrown,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Notifikasi',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ================= DAFTAR TOGGLE =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _ToggleCard(
                    icon: Icons.medication_rounded,
                    judul: 'Pengingat Minum Obat',
                    sub: 'Aktifkan pengingat minum obat',
                    nilai: s.pengingatObat,
                    onChanged: (v) => setState(() => s.pengingatObat = v),
                  ),
                  const SizedBox(height: 12),
                  _ToggleCard(
                    icon: Icons.lightbulb_rounded,
                    judul: 'Tips & Edukasi',
                    sub: 'Informasi dan edukasi kesehatan',
                    nilai: s.tipsEdukasi,
                    onChanged: (v) => setState(() => s.tipsEdukasi = v),
                  ),
                  const SizedBox(height: 12),
                  _ToggleCard(
                    icon: Icons.article_rounded,
                    judul: 'Artikel Terbaru',
                    sub: 'Notifikasi artikel baru dan terbaru',
                    nilai: s.artikelTerbaru,
                    onChanged: (v) => setState(() => s.artikelTerbaru = v),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================ KARTU TOGGLE =================================
class _ToggleCard extends StatelessWidget {
  const _ToggleCard({
    required this.icon,
    required this.judul,
    required this.sub,
    required this.nilai,
    required this.onChanged,
  });

  final IconData icon;
  final String judul;
  final String sub;
  final bool nilai;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFDF3D7),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: const Color(0xFFC99A2C), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  judul,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textGrey),
                ),
              ],
            ),
          ),
          Switch(
            value: nilai,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: AppColors.accentDark,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFD8D2C8),
          ),
        ],
      ),
    );
  }
}