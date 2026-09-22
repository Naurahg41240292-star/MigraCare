import 'dart:io';
import 'package:flutter/material.dart';
import '../models/profil_pengguna.dart';
import 'edit_profil.dart';

/// ==========================================================================
///  MIGRACARE — Halaman Profil
///  File: lib/screens/profil.dart
///  (Tanpa bottom nav — nav milik halaman_utama)
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

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.darkBrown,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }

  Future<void> _bukaEditProfil() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const EditProfilPage()),
    );
    setState(() {}); // refresh tampilan setelah kembali dari edit
  }

  Future<void> _konfirmasiKeluar() async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Keluar dari Akun?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        content: const Text(
          'Kamu harus masuk lagi untuk mengakses akunmu.',
          style: TextStyle(fontSize: 13, color: AppColors.textGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.textGrey)),
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
    if (yakin == true) {
      _showSnack('Berhasil keluar (demo)');
      // Nanti bisa diarahkan ke halaman Masuk di sini.
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = ProfilPengguna.instance;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= HEADER =================
              const Text(
                'Profil',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Kelola akun dan pengaturan privasi anda',
                style: TextStyle(fontSize: 12.5, color: AppColors.textGrey),
              ),
              const SizedBox(height: 16),

              // ================= KARTU PROFIL =================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outline),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14A52A2A),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        AvatarPengguna(radius: 34),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.nama,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                p.email,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: _bukaEditProfil,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentDark,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Edit Profil',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ================= PENGATURAN APLIKASI =================
              const Text(
                'Pengaturan Aplikasi',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              _MenuSetting(
                icon: Icons.notifications_rounded,
                iconBg: const Color(0xFFFDF3D7),
                iconColor: const Color(0xFFC99A2C),
                judul: 'Notifikasi',
                sub: 'Kelola pengingat dan notifikasi penting',
                onTap: () => _showSnack('Pengaturan Notifikasi (segera)'),
              ),
              _MenuSetting(
                icon: Icons.grid_view_rounded,
                iconBg: const Color(0xFFFDF3D7),
                iconColor: const Color(0xFFC99A2C),
                judul: 'Tema',
                sub: 'Pilih tampilan aplikasi MigraCare',
                onTap: () => _showSnack('Pengaturan Tema (segera)'),
              ),
              _MenuSetting(
                icon: Icons.public_rounded,
                iconBg: const Color(0xFFFDF3D7),
                iconColor: const Color(0xFFC99A2C),
                judul: 'Bahasa',
                sub: 'Pilih bahasa aplikasi',
                nilai: 'Bahasa Indonesia',
                onTap: () => _showSnack('Pengaturan Bahasa (segera)'),
              ),
              _MenuSetting(
                icon: Icons.lock_rounded,
                iconBg: const Color(0xFFFDF3D7),
                iconColor: const Color(0xFFC99A2C),
                judul: 'Keamanan Akun',
                sub: 'Kelola data pribadi dan keamanan akun',
                onTap: () => _showSnack('Keamanan Akun (segera)'),
              ),
              _MenuSetting(
                icon: Icons.info_outline_rounded,
                iconBg: const Color(0xFFFDF3D7),
                iconColor: const Color(0xFFC99A2C),
                judul: 'Tentang MigraCare',
                sub: 'Tentang aplikasi MigraCare',
                onTap: () => _showSnack('Tentang MigraCare v1.0 (demo)'),
              ),
              const SizedBox(height: 20),

              // ================= KELUAR =================
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _konfirmasiKeluar,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE55555),
                    side: const BorderSide(color: Color(0xFFE55555)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: const Text(
                    'Keluar dari Akun',
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================ MENU PENGATURAN ==============================
class _MenuSetting extends StatelessWidget {
  const _MenuSetting({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.judul,
    required this.sub,
    required this.onTap,
    this.nilai,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String judul;
  final String sub;
  final String? nilai;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.outline),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
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
                if (nilai != null)
                  Text(
                    nilai!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentDark,
                    ),
                  ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textGrey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================ AVATAR BERSAMA ===============================
// Publik, dipakai juga oleh halaman Edit Profil.
class AvatarPengguna extends StatelessWidget {
  const AvatarPengguna({super.key, this.radius = 34, this.showBadge = true});

  final double radius;
  final bool showBadge;

  String get _inisial {
    final p = ProfilPengguna.instance;
    final kata = p.nama.trim().split(RegExp(r'\s+'));
    if (kata.isEmpty || kata.first.isEmpty) return '?';
    final a = kata.first[0];
    final b = kata.length > 1 ? kata[1][0] : '';
    return (a + b).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final p = ProfilPengguna.instance;
    final badgeD = radius * 0.78;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: radius * 2,
          height: radius * 2,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFF5C04E),
          ),
          child: p.fotoPath == null
              ? Center(
                  child: Text(
                    _inisial,
                    style: TextStyle(
                      fontSize: radius * 0.72,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkBrown,
                    ),
                  ),
                )
              : ClipOval(
                  child: Image.file(
                    File(p.fotoPath!),
                    fit: BoxFit.cover,
                    width: radius * 2,
                    height: radius * 2,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text(
                        _inisial,
                        style: TextStyle(
                          fontSize: radius * 0.72,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkBrown,
                        ),
                      ),
                    ),
                  ),
                ),
        ),
        if (showBadge)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: badgeD,
              height: badgeD,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.darkBrown,
                border: Border.all(color: AppColors.surface, width: 2),
              ),
              child: Icon(
                Icons.photo_camera_rounded,
                color: Colors.white,
                size: badgeD * 0.5,
              ),
            ),
          ),
      ],
    );
  }
}