import 'package:flutter/material.dart';
import '../models/artikel.dart';

/// =======================================================================
///  MIGRACARE — Halaman Detail Artikel
///  File: lib/screens/detail_artikel.dart
/// =======================================================================

/// Palet warna (salinan dari beranda.dart — nanti bisa dipindah ke file tema)
abstract class _C {
  static const Color background = Color(0xFFFAF4EA);
  static const Color surface = Colors.white;
  static const Color darkBrown = Color(0xFF3D2B1A);
  static const Color accentDark = Color(0xFFB07E1F);
  static const Color textDark = Color(0xFF33261A);
  static const Color textGrey = Color(0xFF9C948A);
  static const Color outline = Color(0xFFEDE3D4);
  static const Color cardBorder = Color(0xFFE9C98F);
  static const Color noteBg = Color(0xFFFBEFD4);
}

class DetailArtikelPage extends StatelessWidget {
  const DetailArtikelPage({super.key, required this.artikel});

  final Artikel artikel;

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _C.darkBrown,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------- Tombol atas: kembali & bagikan --------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: _C.darkBrown,
                      size: 26,
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        _showSnack(context, 'Fitur bagikan segera hadir 😊'),
                    icon: const Icon(
                      Icons.ios_share_rounded,
                      color: _C.darkBrown,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // ---------------- Gambar + kartu judul ------------------------
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: SizedBox(
                      height: 240,
                      width: double.infinity,
                      child: _ArticleImage(url: artikel.imageUrl),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: -34,
                    child: _TitleCard(artikel: artikel),
                  ),
                ],
              ),
              const SizedBox(height: 54),

              // ---------------- Isi artikel per bagian ----------------------
              for (final bagian in artikel.sections) ...[
                _ContentCard(bagian: bagian),
                if (bagian.note != null) ...[
                  const SizedBox(height: 12),
                  _NoteBox(text: bagian.note!),
                ],
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: _BottomNavBar(
        onHomeTap: () => Navigator.of(context).pop(),
        onOtherTap: (label) =>
            _showSnack(context, 'Halaman $label belum tersedia'),
      ),
    );
  }
}

// ===========================================================================
//  KARTU JUDUL
// ===========================================================================
class _TitleCard extends StatelessWidget {
  const _TitleCard({required this.artikel});

  final Artikel artikel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.outline),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _C.accentDark,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  artikel.category,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                artikel.date,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: _C.textGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            artikel.title.toUpperCase(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              height: 1.3,
              letterSpacing: 0.2,
              color: _C.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            artikel.subtitle,
            style: const TextStyle(
              fontSize: 12,
              height: 1.5,
              color: _C.textGrey,
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
//  KARTU ISI
// ===========================================================================
class _ContentCard extends StatelessWidget {
  const _ContentCard({required this.bagian});

  final ArtikelSection bagian;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            bagian.heading.toUpperCase(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: _C.accentDark,
            ),
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < bagian.paragraphs.length; i++) ...[
            Text(
              bagian.paragraphs[i],
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.65,
                color: _C.textDark,
              ),
            ),
            if (i != bagian.paragraphs.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

// ===========================================================================
//  KOTAK INFO KUNING
// ===========================================================================
class _NoteBox extends StatelessWidget {
  const _NoteBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _C.noteBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_rounded, color: Color(0xFFC98A2B), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 11.5,
                height: 1.5,
                fontWeight: FontWeight.w600,
                color: _C.darkBrown,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
//  GAMBAR ARTIKEL (anti-kosong)
// ===========================================================================
class _ArticleImage extends StatelessWidget {
  const _ArticleImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFEFE3CF), Color(0xFFE0CDAF)],
            ),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.health_and_safety_rounded,
            color: Color(0xFFB99B6B),
            size: 44,
          ),
        ),
        Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// ===========================================================================
//  BOTTOM NAV
// ===========================================================================
class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({required this.onHomeTap, required this.onOtherTap});

  final VoidCallback onHomeTap;
  final ValueChanged<String> onOtherTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      onTap: (index) {
        const labels = ['Beranda', 'Skrining', 'Riwayat', 'Pengingat', 'Profil'];
        if (index == 0) {
          onHomeTap();
        } else {
          onOtherTap(labels[index]);
        }
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: _C.accentDark,
      unselectedItemColor: const Color(0xFFB9B2A8),
      selectedFontSize: 11.5,
      unselectedFontSize: 11.5,
      elevation: 12,
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
          icon: Icon(Icons.history_rounded),
          label: 'Riwayat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.medication_outlined),
          activeIcon: Icon(Icons.medication_rounded),
          label: 'Pengingat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          activeIcon: Icon(Icons.person_rounded),
          label: 'Profil',
        ),
      ],
    );
  }
}