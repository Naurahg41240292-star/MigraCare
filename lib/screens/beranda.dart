import 'package:flutter/material.dart';
import '../models/artikel.dart';
import 'detail_artikel.dart';
import 'skrining.dart';

/// ==========================================================================
///  MIGRACARE — Halaman Beranda (v6)
///  File: lib/screens/beranda.dart
/// ==========================================================================

abstract class AppColors {
  static const Color background = Color(0xFFFAF4EA);
  static const Color surface = Colors.white;
  static const Color primary = Color(0xFF6B4A2B);
  static const Color darkBrown = Color(0xFF3D2B1A);
  static const Color accent = Color(0xFFF2C230);
  static const Color accentDark = Color(0xFFB07E1F);
  static const Color textDark = Color(0xFF33261A);
  static const Color textGrey = Color(0xFF9C948A);
  static const Color outline = Color(0xFFEDE3D4);
}

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  int _navIndex = 0;

  static const List<_Service> _services = [
    _Service(
      name: 'RS AL Huda Banyuwangi',
      location: 'Jl. Raya Watukebo No. 8',
      distance: '± 3,2 km',
      rating: 4.7,
      reviews: 210,
      icon: Icons.local_hospital,
      imagePath:
          'https://images.unsplash.com/photo-1586773860418-d37222d8fce3?auto=format&fit=crop&w=600&q=60',
      showDetailButton: true,
    ),
    _Service(
      name: 'RS. Jember Klinik',
      location: 'Jember, Jawa Timur',
      distance: '± 12 km',
      rating: 4.8,
      reviews: 150,
      icon: Icons.local_hospital,
      imagePath:
          'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?auto=format&fit=crop&w=600&q=60',
    ),
    _Service(
      name: 'Apotek K-24, Jl. Kalimantan',
      location: 'Banyuwangi, Jawa Timur',
      distance: '± 1,4 km',
      rating: 4.8,
      reviews: 68,
      icon: Icons.local_pharmacy,
      imagePath:
          'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?auto=format&fit=crop&w=600&q=60',
    ),
  ];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const _GreetingHeader(),
              const SizedBox(height: 20),
              const _AiMigraineBanner(),
              const SizedBox(height: 24),
              _SectionHeader(
                title: 'Informasi Layanan',
                onSeeAll: () => _showSnack('Menuju halaman Informasi Layanan'),
              ),
              const SizedBox(height: 12),
              _ServiceList(services: _services),
              const SizedBox(height: 24),
              _SectionHeader(
                title: 'Pengingat Obat',
                onSeeAll: () => _showSnack('Menuju halaman Pengingat Obat'),
              ),
              const SizedBox(height: 12),
              const _MedicationReminderCard(
                time: '20.00',
                medicine: 'Topiramate 50 mg',
                dosage: '1 tablet. Setelah makan',
              ),
              const SizedBox(height: 24),
              _SectionHeader(
                title: 'Artikel Populer',
                onSeeAll: () => _showSnack('Menuju halaman Artikel'),
              ),
              const SizedBox(height: 12),
              const _ArticleList(articles: artikelPopuler),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _BottomNavBar(
          currentIndex: _navIndex,
          onTap: (index) {
           if (index == 1) {
           // Tab "Skrining" → buka halaman skrining
      Navigator.of(context).push(
       MaterialPageRoute(builder: (_) => SkriningPage()),
      );
    } else {
      setState(() => _navIndex = index);
    }
  },
),
    );
  }
}

// ===========================================================================
//  HEADER SAPAAN
// ===========================================================================
class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Hi, Ananda 👋',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  // PENANDA VERSI: kalau "v6" tidak muncul di HP, kode baru
                  // belum terpasang!
                  'Bagaimana Kondisi Anda hari ini?  •  v6',
                  style: TextStyle(fontSize: 13, color: AppColors.textGrey),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.outline),
            ),
            child: IconButton(
              onPressed: () {},
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              iconSize: 22,
              color: AppColors.darkBrown,
              icon: const Icon(Icons.notifications_none_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
//  BANNER AI MIGRAINE CHECK
// ===========================================================================
class _AiMigraineBanner extends StatelessWidget {
  const _AiMigraineBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFF7A4E24),
              Color(0xFFC08A47),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7A4E24).withOpacity(0.30),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI Migraine Check',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Lakukan skrining migraine Anda dengan bantuan AI',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SkriningPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF7EAD0),
                      foregroundColor: AppColors.darkBrown,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Mulai Skrining',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            const _BrainIllustration(),
          ],
        ),
      ),
    );
  }
}

class _BrainIllustration extends StatelessWidget {
  const _BrainIllustration();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 92,
      height: 92,
      child: Stack(
        children: [
          Center(child: Text('🧠', style: TextStyle(fontSize: 56))),
          Positioned(
            top: 0,
            right: 0,
            child: Text('✨', style: TextStyle(fontSize: 16)),
          ),
          Positioned(
            bottom: 4,
            left: 0,
            child: Text('💫', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
//  JUDUL SECTION + "LIHAT SEMUA"
// ===========================================================================
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.onSeeAll});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          TextButton.icon(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accentDark,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: const Text(
              'Lihat Semua',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            label: const Icon(Icons.chevron_right_rounded, size: 18),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
//  DAFTAR LAYANAN
// ===========================================================================
class _ServiceList extends StatelessWidget {
  const _ServiceList({required this.services});

  final List<_Service> services;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
        scrollDirection: Axis.horizontal,
        itemCount: services.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) => _ServiceCard(service: services[index]),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service});

  final _Service service;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outline),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 86,
              width: double.infinity,
              child: _SmartImage(
                path: service.imagePath,
                icon: service.icon,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${service.distance} • ${service.location}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 9.5,
                      color: AppColors.textGrey,
                    ),
                  ),
                  const Spacer(),
                  service.showDetailButton
                      ? ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: AppColors.darkBrown,
                            elevation: 0,
                            minimumSize: const Size(0, 26),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Lihat Detail',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      : Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: Color(0xFFF2B01E),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${service.rating}',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              '  (${service.reviews} ulasan)',
                              style: const TextStyle(
                                fontSize: 9.5,
                                color: AppColors.textGrey,
                              ),
                            ),
                          ],
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

// ===========================================================================
//  KARTU PENGINGAT OBAT
// ===========================================================================
class _MedicationReminderCard extends StatefulWidget {
  const _MedicationReminderCard({
    required this.time,
    required this.medicine,
    required this.dosage,
  });

  final String time;
  final String medicine;
  final String dosage;

  @override
  State<_MedicationReminderCard> createState() =>
      _MedicationReminderCardState();
}

class _MedicationReminderCardState extends State<_MedicationReminderCard> {
  bool _isTaken = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outline),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFFDF3D7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.access_time_rounded,
                color: Color(0xFFC99A2C),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.time,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textGrey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.medicine,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.dosage,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _isTaken ? null : () => setState(() => _isTaken = true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.darkBrown,
                disabledBackgroundColor: const Color(0xFFE8E2D6),
                disabledForegroundColor: const Color(0xFF9A938B),
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                _isTaken ? '✓ Selesai' : 'Sudah Diminum',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
//  DAFTAR ARTIKEL (dipencet → DetailArtikelPage)
// ===========================================================================
class _ArticleList extends StatelessWidget {
  const _ArticleList({required this.articles});

  final List<Artikel> articles;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 252,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
        scrollDirection: Axis.horizontal,
        itemCount: articles.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) => _ArticleCard(article: articles[index]),
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  const _ArticleCard({required this.article});

  final Artikel article;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DetailArtikelPage(artikel: article),
          ),
        );
      },
      child: Container(
        width: 205,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outline),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 112,
                width: double.infinity,
                child: _SmartImage(
                  path: article.imageUrl,
                  icon: Icons.psychology_alt_rounded,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBEFD4),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        article.category,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accentDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      article.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        height: 1.35,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
//  BOTTOM NAVIGATION BAR
// ===========================================================================
class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.accentDark,
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

// ===========================================================================
//  HELPER & MODEL
// ===========================================================================
class _SmartImage extends StatelessWidget {
  const _SmartImage({required this.path, required this.icon});

  final String path;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final candidates = [
      path,
      if (path.startsWith('http'))
        'https://picsum.photos/seed/${path.hashCode.abs()}/600/400',
    ];
    return Stack(
      fit: StackFit.expand,
      children: [
        _GradientPlaceholder(icon: icon),
        _buildImage(candidates, 0),
      ],
    );
  }

  Widget _buildImage(List<String> candidates, int index) {
    if (index >= candidates.length) return const SizedBox.shrink();
    return Image.network(
      candidates[index],
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildImage(candidates, index + 1),
    );
  }
}

class _GradientPlaceholder extends StatelessWidget {
  const _GradientPlaceholder({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEFE3CF), Color(0xFFE0CDAF)],
        ),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: Color(0xFFB99B6B), size: 34),
    );
  }
}

class _Service {
  const _Service({
    required this.name,
    required this.location,
    required this.distance,
    required this.rating,
    required this.reviews,
    required this.icon,
    required this.imagePath,
    this.showDetailButton = false,
  });

  final String name;
  final String location;
  final String distance;
  final double rating;
  final int reviews;
  final IconData icon;
  final String imagePath;
  final bool showDetailButton;
}