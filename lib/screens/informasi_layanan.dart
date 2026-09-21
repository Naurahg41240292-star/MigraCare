import 'package:flutter/material.dart';
import 'detail_layanan.dart';

/// ==========================================================================
///  MIGRACARE — Halaman Informasi Layanan Kesehatan (pencarian + filter)
///  File: lib/screens/informasi_layanan.dart
/// ==========================================================================

abstract class AppColors {
  static const Color background = Color(0xFFFAF4EA);
  static const Color surface = Colors.white;
  static const Color primary = Color(0xFF6B4A2B);
  static const Color darkBrown = Color(0xFF3D2B1A);
  static const Color accent = Color(0xFFF2C230);
  static const Color accentDark = Color(0xFFB07E1F);
  static const Color textDark = Color(0xFF33261A);
  static const Color primaryText = Color(0xFF33261A);
  static const Color textGrey = Color(0xFF9C948A);
  static const Color outline = Color(0xFFEDE3D4);
}

class Layanan {
  const Layanan({
    required this.name,
    required this.location,
    required this.distance,
    required this.rating,
    required this.reviews,
    required this.imagePath,
    required this.icon,
    required this.category,
    this.description = '',
    this.hoursShort = 'Setiap hari, 24 jam',
    this.phone = 'Belum tersedia',
    this.email = 'Belum tersedia',
    this.jamOperasional = const {
      'Senin - Jumat': '08.00 - 20.00',
      'Sabtu': '08.00 - 14.00',
      'Minggu': 'Tutup (IGD 24 jam)',
    },
    this.services = const [],
  });

  final String name;
  final String location;
  final String distance;
  final double rating;
  final int reviews;
  final String imagePath;
  final IconData icon;
  final String category;
  final String description;
  final String hoursShort;
  final String phone;
  final String email;
  final Map<String, String> jamOperasional;
  final List<String> services;
}

/// Nama 3 layanan pertama HARUS sama persis dengan nama di beranda,
/// agar klik kartu di beranda bisa menemukan detailnya.
const List<Layanan> daftarLayanan = [
  Layanan(
    name: 'RS AL Huda Banyuwangi',
    category: 'Rumah Sakit',
    location: 'Jl. Raya Watukebo No. 8, Banyuwangi',
    distance: '± 3,2 km',
    rating: 4.7,
    reviews: 210,
    icon: Icons.local_hospital,
    imagePath:
        'https://images.unsplash.com/photo-1586773860418-d37222d8fce3?auto=format&fit=crop&w=600&q=60',
    description:
        'Rumah sakit umum dengan pelayanan kesehatan lengkap, didukung tenaga medis profesional dan fasilitas yang modern.',
    hoursShort: 'IGD 24 jam • Poliklinik 08.00 - 20.00',
    phone: '0333-123456',
    email: 'info@rsalhuda.co.id',
    services: [
      'Poliklinik Umum',
      'Poliklinik Spesialis',
      'IGD 24 jam',
      'Laboratorium',
      'Radiologi (USG, X-Ray)',
      'Farmasi',
    ],
  ),
  Layanan(
    name: 'RS. Jember Klinik',
    category: 'Rumah Sakit',
    location: 'Jember, Jawa Timur',
    distance: '± 12 km',
    rating: 4.8,
    reviews: 150,
    icon: Icons.local_hospital,
    imagePath:
        'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?auto=format&fit=crop&w=600&q=60',
    description:
        'Rumah sakit dengan layanan rawat inap dan rawat jalan, didukung dokter spesialis dari berbagai bidang.',
    phone: '0331-765432',
    services: ['Poliklinik Umum', 'Rawat Inap', 'Laboratorium', 'Farmasi'],
  ),
  Layanan(
    name: 'RSUD Dr. Haryoto Lumajang',
    category: 'Rumah Sakit',
    location: 'Lumajang, Jawa Timur',
    distance: '± 45 km',
    rating: 4.5,
    reviews: 142,
    icon: Icons.local_hospital,
    imagePath: 'https://picsum.photos/seed/rsudharyoto/600/400',
    description:
        'Rumah sakit daerah dengan pelayanan BPJS lengkap, mulai dari poliklinik hingga unit gawat darurat.',
    phone: '0334-881234',
    services: ['Poliklinik Umum', 'IGD 24 jam', 'Radiologi', 'Farmasi'],
  ),
  Layanan(
    name: 'Apotek K-24, Jl. Kalimantan',
    category: 'Apotek',
    location: 'Banyuwangi, Jawa Timur',
    distance: '± 1,4 km',
    rating: 4.8,
    reviews: 68,
    icon: Icons.local_pharmacy,
    imagePath:
        'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?auto=format&fit=crop&w=600&q=60',
    description:
        'Apotek 24 jam dengan stok obat lengkap dan layanan konsultasi farmasis gratis.',
    hoursShort: 'Buka 24 jam',
    phone: '0333-456789',
    services: ['Obat Resep', 'Obat Bebas', 'Konsultasi Farmasis', 'Vitamin'],
  ),
  Layanan(
    name: 'Apotek Sehat Jember',
    category: 'Apotek',
    location: 'Jember, Jawa Timur',
    distance: '± 3,6 km',
    rating: 4.3,
    reviews: 120,
    icon: Icons.local_pharmacy,
    imagePath: 'https://picsum.photos/seed/apoteksehat/600/400',
    description: 'Apotek dengan harga obat terjangkau dan layanan antar obat.',
    hoursShort: 'Senin - Sabtu, 08.00 - 21.00',
    services: ['Obat Resep', 'Obat Bebas', 'Alat Kesehatan'],
  ),
  Layanan(
    name: 'Klinik Pratama Sehat Bersama',
    category: 'Klinik',
    location: 'Banyuwangi, Jawa Timur',
    distance: '± 4,5 km',
    rating: 4.9,
    reviews: 120,
    icon: Icons.medical_services_rounded,
    imagePath: 'https://picsum.photos/seed/klinikpratama/600/400',
    description:
        'Klinik pratama dengan pelayanan dokter umum dan gigi, tanpa antre lama.',
    hoursShort: 'Senin - Sabtu, 08.00 - 21.00',
    phone: '0333-987654',
    services: ['Dokter Umum', 'Dokter Gigi', 'Vaksinasi', 'Laboratorium'],
  ),
  Layanan(
    name: 'Laboratorium Klinik Prodia',
    category: 'Laboratorium',
    location: 'Banyuwangi, Jawa Timur',
    distance: '± 2,8 km',
    rating: 4.7,
    reviews: 90,
    icon: Icons.science_rounded,
    imagePath: 'https://picsum.photos/seed/labprodia/600/400',
    description:
        'Laboratorium klinik dengan berbagai paket cek kesehatan dan hasil cepat.',
    hoursShort: 'Senin - Sabtu, 06.00 - 18.00',
    phone: '0333-222333',
    services: ['Cek Darah', 'Cek Urine', 'Medical Check Up', 'Swab Test'],
  ),
];

class _FilterCategory {
  const _FilterCategory(this.label, this.icon);
  final String label;
  final IconData icon;
}

const List<_FilterCategory> _kategoriFilters = [
  _FilterCategory('Rumah Sakit', Icons.local_hospital_rounded),
  _FilterCategory('Klinik', Icons.medical_services_rounded),
  _FilterCategory('Apotek', Icons.local_pharmacy_rounded),
  _FilterCategory('Laboratorium', Icons.science_rounded),
];

class InformasiLayananPage extends StatefulWidget {
  const InformasiLayananPage({super.key});

  @override
  State<InformasiLayananPage> createState() => _InformasiLayananPageState();
}

class _InformasiLayananPageState extends State<InformasiLayananPage> {
  String _query = '';
  int _selectedKategori = 0; // default: Rumah Sakit (sesuai Figma)

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
    final kategoriAktif = _kategoriFilters[_selectedKategori].label;
    final results = daftarLayanan.where((l) {
      final cocokKategori = l.category == kategoriAktif;
      final q = _query.trim().toLowerCase();
      final cocokCari = q.isEmpty ||
          l.name.toLowerCase().contains(q) ||
          l.location.toLowerCase().contains(q);
      return cocokKategori && cocokCari;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= HEADER =================
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: AppColors.darkBrown,
                  ),
                  const SizedBox(width: 4),
                  const Expanded(
                    child: Text(
                      'Informasi Layanan Kesehatan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showSnack('Fitur filter lanjutan segera'),
                    icon: const Icon(Icons.filter_list_rounded),
                    color: AppColors.darkBrown,
                  ),
                ],
              ),
            ),

            // ================= PENCARIAN =================
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: TextField(
                onChanged: (value) => setState(() => _query = value),
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Cari rumah sakit, klinik, apotek, atau layanan...',
                  hintStyle: const TextStyle(
                      fontSize: 12, color: AppColors.textGrey),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppColors.textGrey),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.accentDark),
                  ),
                ),
              ),
            ),

            // ================= TAB KATEGORI =================
            SizedBox(
              height: 84,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _kategoriFilters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final k = _kategoriFilters[index];
                  final aktif = index == _selectedKategori;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedKategori = index),
                    child: Container(
                      width: 72,
                      decoration: BoxDecoration(
                        color: aktif ? AppColors.accent : AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: aktif ? AppColors.accent : AppColors.outline,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            k.icon,
                            size: 22,
                            color: aktif
                                ? AppColors.darkBrown
                                : AppColors.accentDark,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            k.label,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight:
                                  aktif ? FontWeight.w700 : FontWeight.w500,
                              color: aktif
                                  ? AppColors.darkBrown
                                  : AppColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // ================= JUDUL LIST =================
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: Text(
                'Rekomendasi Terdekat',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ),

            // ================= DAFTAR LAYANAN =================
            Expanded(
              child: results.isEmpty
                  ? const Center(
                      child: Text(
                        'Layanan tidak ditemukan',
                        style: TextStyle(color: AppColors.textGrey),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
                      itemCount: results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) =>
                          _LayananCard(layanan: results[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================ KARTU LAYANAN ================================
class _LayananCard extends StatelessWidget {
  const _LayananCard({required this.layanan});

  final Layanan layanan;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DetailLayananPage(layanan: layanan),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(10),
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
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: _SmartImage(
                      path: layanan.imagePath, icon: layanan.icon),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      layanan.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDEFD9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        layanan.category,
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accentDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 15, color: Color(0xFFF2B01E)),
                        const SizedBox(width: 3),
                        Text(
                          '${layanan.rating}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          ' (${layanan.reviews} ulasan)',
                          style: const TextStyle(
                              fontSize: 10.5, color: AppColors.textGrey),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.near_me_rounded,
                            size: 12, color: AppColors.accentDark),
                        const SizedBox(width: 3),
                        Text(
                          layanan.distance,
                          style: const TextStyle(
                              fontSize: 10.5, color: AppColors.textGrey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textGrey),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================ HELPER GAMBAR ================================
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