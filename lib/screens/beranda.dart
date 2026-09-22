import 'package:flutter/material.dart';
import '../models/artikel.dart';
import 'detail_artikel.dart';
import 'skrining.dart';
import 'pengingat_obat.dart';
import '../models/obat.dart';
import 'informasi_layanan.dart'
    show InformasiLayananPage, daftarLayanan;
import 'detail_layanan.dart' show DetailLayananPage;

/// ==========================================================================
///  MIGRACARE — Halaman Beranda (v14)
///  Tombol khusus "Kelola Pengingat Obat" + kartu notifikasi (toggle)
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

void showAppSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.darkBrown,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
}

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key, this.onBukaSkrining});

  final VoidCallback? onBukaSkrining;

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  @override
  void initState() {
    super.initState();
    _muatDataPengingat();
  }

  Future<void> _muatDataPengingat() async {
    await PengingatStore.instance.muatDariDisk();
    if (mounted) setState(() {});
  }

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

  void _bukaSkrining() {
    if (widget.onBukaSkrining != null) {
      widget.onBukaSkrining!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => SkriningPage()),
      );
    }
  }

  void _bukaDetailLayanan(_Service service) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const InformasiLayananPage()),
    );
    final match = daftarLayanan.where((l) => l.name == service.name).toList();
    if (match.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DetailLayananPage(layanan: match.first),
        ),
      );
    }
  }

  Future<void> _bukaPengingatObat() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PengingatObatPage()),
    );
    setState(() {});
  }

  // ====== SECTION PENGINGAT OBAT (TOMBOL KHUSUS + KARTU NOTIFIKASI) ======
  Widget _buildSectionPengingatObat() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pengingat Obat',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),

          // ===== TOMBOL KHUSUS → HALAMAN PENGINGAT OBAT =====
          InkWell(
            onTap: _bukaPengingatObat,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.accent, width: 1.4),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1AF2C230),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.medication_rounded,
                        color: AppColors.darkBrown, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kelola Pengingat Obat',
                          style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Tambah obat, atur jadwal & lihat riwayat',
                          style: TextStyle(
                              fontSize: 11.5, color: AppColors.textGrey),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.accentDark),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ===== KARTU NOTIFIKASI (TOGGLE SAJA) =====
          _isiKartuPengingat(),
        ],
      ),
    );
  }

  Widget _isiKartuPengingat() {
    final store = PengingatStore.instance;

    if (store.daftarObat.isEmpty) {
      return _kartuPengingat(Row(
        children: [
          _ikonBulat(Icons.medication_outlined),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Belum ada pengingat obat',
              style: TextStyle(color: AppColors.textGrey, height: 1.4),
            ),
          ),
        ],
      ));
    }

    final jadwal = store.jadwalBerikutnyaHariIni();
    if (jadwal == null) {
      return _kartuPengingat(Row(
        children: [
          _ikonBulat(Icons.check_circle_rounded),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Semua obat sudah diminum hari ini 🎉',
              style: TextStyle(
                  fontWeight: FontWeight.w700, color: AppColors.textDark),
            ),
          ),
        ],
      ));
    }

    final obat = jadwal.obat;
    final keterangan =
        obat.catatanMinum.isNotEmpty ? obat.catatanMinum : obat.bentukSediaan;

    return _kartuPengingat(Row(
      children: [
        _ikonBulat(Icons.access_time_rounded),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(jadwal.jam,
                  style: const TextStyle(
                      color: AppColors.textGrey, fontSize: 13)),
              Text('${obat.nama} ${obat.dosis}',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark)),
              Text(keterangan,
                  style: const TextStyle(
                      color: AppColors.textGrey, fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(width: 8),

        if (!jadwal.sudahDiminum)
          ElevatedButton(
            onPressed: () =>
                setState(() => store.tandaiDiminum(obat, jadwal.jam)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.darkBrown,
              elevation: 0,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Sudah Diminum',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
          )
        else
          InkWell(
            onTap: () {
              setState(() => store.batalkanDiminum(obat, jadwal.jam));
              showAppSnack(context, 'Ditandai belum diminum');
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFE4F3E4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Color(0xFF3E7C3E), size: 16),
                  SizedBox(width: 6),
                  Text('Sudah diminum',
                      style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3E7C3E))),
                ],
              ),
            ),
          ),
      ],
    ));
  }

  Widget _kartuPengingat(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: child,
    );
  }

  Widget _ikonBulat(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: AppColors.background,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.primary),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const _GreetingHeader(),
              const SizedBox(height: 20),
              _AiMigraineBanner(onMulaiSkrining: _bukaSkrining),
              const SizedBox(height: 24),
              _SectionHeader(
                title: 'Informasi Layanan',
                onSeeAll: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const InformasiLayananPage()),
                  );
                },
              ),
              const SizedBox(height: 12),
              _ServiceList(services: _services, onCardTap: _bukaDetailLayanan),
              const SizedBox(height: 24),
              _buildSectionPengingatObat(),
              const SizedBox(height: 24),
              _SectionHeader(
                title: 'Artikel Populer',
                onSeeAll: () => _showSnack('Menuju halaman Artikel'),
              ),
              const SizedBox(height: 12),
              _ArticleList(articles: artikelPopuler),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================ HEADER SAPAAN ================================
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
                  // PENANDA VERSI v14
                  'Bagaimana Kondisi Anda hari ini?  •  v14',
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

// ============================ BANNER AI ====================================
class _AiMigraineBanner extends StatelessWidget {
  const _AiMigraineBanner({required this.onMulaiSkrining});

  final VoidCallback onMulaiSkrining;

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
            colors: [Color(0xFF7A4E24), Color(0xFFC08A47)],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x4D7A4E24),
              blurRadius: 16,
              offset: Offset(0, 8),
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
                        color: Colors.white70, fontSize: 12, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: onMulaiSkrining,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF7EAD0),
                      foregroundColor: AppColors.darkBrown,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Mulai Skrining',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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
    return SizedBox(
      width: 130,
      height: 130,
      child: Image.asset(
        'assets/images/otak_skrining.png',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
            const Text('🧠', style: TextStyle(fontSize: 54)),
      ),
    );
  }
}

// ============================ JUDUL SECTION ================================
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
          if (onSeeAll != null)
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

// ============================ DAFTAR LAYANAN ===============================
class _ServiceList extends StatelessWidget {
  const _ServiceList({required this.services, required this.onCardTap});

  final List<_Service> services;
  final ValueChanged<_Service> onCardTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
      child: Row(
        children: [
          for (int i = 0; i < services.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            _ServiceCard(
              service: services[i],
              onTap: () => onCardTap(services[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service, required this.onTap});

  final _Service service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        height: 195,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outline),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14A52A2A),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 84,
                width: double.infinity,
                child:
                    _SmartImage(path: service.imagePath, icon: service.icon),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${service.distance} • ${service.location}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textGrey),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 17,
                            color: Color(0xFFF2B01E),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${service.rating}',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            '  (${service.reviews} ulasan)',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================ DAFTAR ARTIKEL ===============================
class _ArticleList extends StatelessWidget {
  const _ArticleList({required this.articles});

  final List<Artikel> articles;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Row(
        children: [
          for (int i = 0; i < articles.length; i++) ...[
            if (i > 0) const SizedBox(width: 14),
            _ArticleCard(article: articles[i]),
          ],
        ],
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
          MaterialPageRoute(builder: (_) => DetailArtikelPage(artikel: article)),
        );
      },
      child: Container(
        width: 205,
        height: 240,
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
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================ HELPER & MODEL ===============================
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
  });

  final String name;
  final String location;
  final String distance;
  final double rating;
  final int reviews;
  final IconData icon;
  final String imagePath;
}