import 'package:flutter/material.dart';

/// ==========================================================================
///  MIGRACARE — Sumber warna TUNGGAL (design tokens)
///  Semua warna aplikasi didefinisikan DI SINI SAJA.
///  Mau ganti tema? Ubah di file ini, seluruh aplikasi ikut.
/// ==========================================================================
abstract class AppColors {
  // ---------- Latar & permukaan ----------
  static const Color background = Color(0xFFFBF4E8); // krem hangat
  static const Color bg = background;                // alias nama lama
  static const Color surface = Colors.white;         // kartu / input
  static const Color card = surface;                 // alias nama lama

  // ---------- Warna utama & aksen ----------
  static const Color primary = Color(0xFFB7741F);    // emas-coklat (tombol, chip aktif)
  static const Color primarySoft = Color(0xFFF6E7CE);
  static const Color accent = Color(0xFFF2C230);     // kuning cerah (tombol kecil)
  static const Color accentDark = Color(0xFFB07E1F); // kuning tua (link "Lihat Semua")
  static const Color darkBrown = Color(0xFF3D2B1A);  // coklat gelap (snackbar, teks di tombol kuning)

  // ---------- Teks ----------
  static const Color textDark = Color(0xFF2B2417);
  static const Color textSoft = Color(0xFF8A8378);
  static const Color textGrey = textSoft;            // alias nama lama
  static const Color textFaint = Color(0xFFB4AC9E);

  // ---------- Garis / pembatas ----------
  static const Color outline = Color(0xFFEDE3D4);
  static const Color divider = outline;              // alias nama lama

  // ---------- Status ----------
  static const Color online = Color(0xFF2FA45C);
  static const Color onlineBg = Color(0xFFD9F3E3);
  static const Color star = Color(0xFFF2A33C);

  // ---------- Khusus fitur konsultasi ----------
  static const Color chipBg = Color(0xFFF3EADA);
  static const Color userBubble = Color(0xFFF7DBB0);
}

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x1486541F), blurRadius: 12, offset: Offset(0, 6)),
  ];

  static const List<BoxShadow> button = [
    BoxShadow(color: Color(0x40B7741F), blurRadius: 14, offset: Offset(0, 6)),
  ];
}