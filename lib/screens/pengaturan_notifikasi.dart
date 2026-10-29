import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notifikasi_service.dart';

/// ==========================================================================
///  MIGRACARE — Halaman Pengaturan Notifikasi
///  File: lib/screens/pengaturan_notifikasi.dart
///
///  Versi 2.0:
///    - State tersimpan di SharedPreferences (persistent)
///    - Toggle "Pengingat Minum Obat" terhubung ke NotificationService
///    - Sinkron dengan toggle di halaman Pengingat Obat
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

/// Penyimpanan status toggle (persistent via SharedPreferences)
class SetelanNotifikasi {
  SetelanNotifikasi._();
  static final SetelanNotifikasi instance = SetelanNotifikasi._();

  // Key untuk SharedPreferences
  static const String _keyPengingatObat = 'pengingat_aktif'; // SAMA dengan di pengingat_obat.dart!
  static const String _keyTipsEdukasi = 'setelan_tips_edukasi';
  static const String _keyArtikelTerbaru = 'setelan_artikel_terbaru';

  bool pengingatObat = true;
  bool tipsEdukasi = true;
  bool artikelTerbaru = false;

  /// Load semua setelan dari SharedPreferences
  Future<void> muatDariDisk() async {
    final prefs = await SharedPreferences.getInstance();
    pengingatObat = prefs.getBool(_keyPengingatObat) ?? true;
    tipsEdukasi = prefs.getBool(_keyTipsEdukasi) ?? true;
    artikelTerbaru = prefs.getBool(_keyArtikelTerbaru) ?? false;
  }

  /// Save setelan pengingat obat
  Future<void> setPengingatObat(bool value) async {
    pengingatObat = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPengingatObat, value);

    // ===== HUBUNGKAN KE NotificationService =====
    if (value) {
      // ON → reschedule semua notifikasi obat
      await NotificationService.instance.rescheduleSemua();
    } else {
      // OFF → batalkan semua notifikasi obat
      await NotificationService.instance.batalkanSemua();
    }
  }

  Future<void> setTipsEdukasi(bool value) async {
    tipsEdukasi = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTipsEdukasi, value);
  }

  Future<void> setArtikelTerbaru(bool value) async {
    artikelTerbaru = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyArtikelTerbaru, value);
  }
}

class PengaturanNotifikasiPage extends StatefulWidget {
  const PengaturanNotifikasiPage({super.key});

  @override
  State<PengaturanNotifikasiPage> createState() =>
      _PengaturanNotifikasiPageState();
}

class _PengaturanNotifikasiPageState extends State<PengaturanNotifikasiPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _muatSetelan();
  }

  Future<void> _muatSetelan() async {
    await SetelanNotifikasi.instance.muatDariDisk();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, {Color? bg}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          behavior: SnackBarBehavior.floating,
          backgroundColor: bg ?? AppColors.darkBrown,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }

  Future<void> _togglePengingatObat(bool value) async {
    setState(() => SetelanNotifikasi.instance.pengingatObat = value);
    await SetelanNotifikasi.instance.setPengingatObat(value);

    if (!mounted) return;
    _showSnack(
      value ? 'Pengingat minum obat diaktifkan ✓' : 'Pengingat minum obat dimatikan',
      bg: value ? AppColors.accentDark : AppColors.textGrey,
    );
  }

  Future<void> _toggleTipsEdukasi(bool value) async {
    setState(() => SetelanNotifikasi.instance.tipsEdukasi = value);
    await SetelanNotifikasi.instance.setTipsEdukasi(value);
  }

  Future<void> _toggleArtikelTerbaru(bool value) async {
    setState(() => SetelanNotifikasi.instance.artikelTerbaru = value);
    await SetelanNotifikasi.instance.setArtikelTerbaru(value);
  }

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
            const SizedBox(height: 4),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Atur preferensi notifikasi yang kamu terima',
                style: TextStyle(fontSize: 12.5, color: AppColors.textGrey),
              ),
            ),
            const SizedBox(height: 16),

            // ================= LOADING STATE =================
            if (_isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.accentDark),
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ===== SECTION: PENGINGAT =====
                      const Text(
                        'Pengingat',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textGrey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _ToggleCard(
                        icon: Icons.medication_rounded,
                        judul: 'Pengingat Minum Obat',
                        sub: 'Aktifkan pengingat minum obat sesuai jadwal',
                        nilai: s.pengingatObat,
                        onChanged: _togglePengingatObat,
                      ),
                      const SizedBox(height: 20),

                      // ===== SECTION: INFO & EDUKASI =====
                      const Text(
                        'Info & Edukasi',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textGrey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _ToggleCard(
                        icon: Icons.lightbulb_rounded,
                        judul: 'Tips & Edukasi',
                        sub: 'Informasi dan edukasi kesehatan',
                        nilai: s.tipsEdukasi,
                        onChanged: _toggleTipsEdukasi,
                      ),
                      const SizedBox(height: 12),
                      _ToggleCard(
                        icon: Icons.article_rounded,
                        judul: 'Artikel Terbaru',
                        sub: 'Notifikasi artikel baru dan terbaru',
                        nilai: s.artikelTerbaru,
                        onChanged: _toggleArtikelTerbaru,
                      ),
                      const SizedBox(height: 20),

                      // ===== INFO BANTUAN =====
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDF3DC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Icon(Icons.info_outline_rounded,
                                size: 18, color: AppColors.accentDark),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Pengingat minum obat menggunakan alarm yang muncul walau aplikasi ditutup. Pastikan izin notifikasi diaktifkan.',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.textDark,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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