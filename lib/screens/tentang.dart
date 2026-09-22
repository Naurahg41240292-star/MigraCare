import 'package:flutter/material.dart';

/// ==========================================================================
///  MIGRACARE — Halaman Tentang MigraCare
///  File: lib/screens/tentang.dart
/// ==========================================================================

abstract class AppColors {
  static const Color background = Color(0xFFFAF4EA);
  static const Color surface = Colors.white;
  static const Color darkBrown = Color(0xFF3D2B1A);
  static const Color accentDark = Color(0xFFB07E1F);
  static const Color textDark = Color(0xFF33261A);
  static const Color textGrey = Color(0xFF9C948A);
  static const Color outline = Color(0xFFEDE3D4);
}

class TentangPage extends StatelessWidget {
  const TentangPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= HEADER =================
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: AppColors.darkBrown,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Tentang MigraCare',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ================= LOGO =================
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 110,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Text(
                        '🧠',
                        style: TextStyle(fontSize: 64),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ================= APA ITU MIGRACARE? =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: const [
                    Icon(Icons.psychology_rounded,
                        color: AppColors.accentDark, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Apa itu MigraCare?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accentDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'MigraCare merupakan platform kesehatan digital yang menggabungkan teknologi dan ilmu kesehatan untuk membantu pengguna melakukan skrining risiko migrain, mencatat episode dan pemicunya, serta mendapatkan informasi dan rekomendasi yang relevan.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.65,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ================= KAMI HADIR UNTUK MEMBANTU =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: const [
                    Icon(Icons.favorite_rounded,
                        color: AppColors.accentDark, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Kami hadir untuk membantu',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accentDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Kami berkomitmen untuk menjadi teman terpercaya dalam perjalanan adha mengelola migrain dan menjaga kesehatan otak setiap hari.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.65,
                    color: AppColors.textDark,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // ================= FOOTER =================
              const Center(
                child: Text(
                  '2024 MigraCare.\nAll rights reserved.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.5,
                    color: AppColors.textGrey,
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