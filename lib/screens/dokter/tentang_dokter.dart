import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _bg = Color(0xFFFDF8F1);
const _teksUtama = Color(0xFF2D2A26);
const _teksLembut = Color(0xFF9B9285);
const _emas = Color(0xFFE8A13A);

class TentangDokterPage extends StatelessWidget {
  const TentangDokterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('Tentang MigraCare',
            style: GoogleFonts.poppins(
                color: _teksUtama, fontWeight: FontWeight.w600, fontSize: 17)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
          children: [
            const SizedBox(height: 24),
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFFF6C67B), _emas]),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Icon(Icons.psychology_rounded,
                      size: 60, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: Text('MigraCare',
                  style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: _teksUtama)),
            ),
            const SizedBox(height: 40),
            Text('Apa itu MigraCare?',
                style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _teksUtama)),
            const SizedBox(height: 10),
            Text(
              'MigraCare adalah platform kesehatan digital yang menggabungkan teknologi dan ilmu kesehatan untuk membantu pengguna menilai risiko migraine, mencatat frekuensi dan pemicu serangan, serta menyediakan informasi dan rekomendasi yang relevan.',
              style: GoogleFonts.poppins(
                  fontSize: 14, color: _teksLembut, height: 1.8),
            ),
            const SizedBox(height: 30),
            Text('Kami Siap Membantu',
                style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _teksUtama)),
            const SizedBox(height: 10),
            Text(
              'Kami berkomitmen menjadi mitra yang dapat diandalkan dalam mengelola migraine dan menjaga kesehatan otak, baik bagi pengguna maupun para dokter pendamping.',
              style: GoogleFonts.poppins(
                  fontSize: 14, color: _teksLembut, height: 1.8),
            ),
            const SizedBox(height: 70),
            Center(
              child: Text(
                '2024 MigraCare. All rights reserved.',
                style: GoogleFonts.poppins(fontSize: 12, color: _teksLembut),
              ),
            ),
          ],
        ),
      ),
    );
  }
}