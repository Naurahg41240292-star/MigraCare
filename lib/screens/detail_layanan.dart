import 'package:flutter/material.dart';
import 'informasi_layanan.dart'; // pakai AppColors, Layanan, _SmartImage? (lihat catatan)

/// ==========================================================================
///  MIGRACARE — Halaman Detail Layanan
///  File: lib/screens/detail_layanan.dart
/// ==========================================================================

class DetailLayananPage extends StatefulWidget {
  const DetailLayananPage({super.key, required this.layanan});

  final Layanan layanan;

  @override
  State<DetailLayananPage> createState() => _DetailLayananPageState();
}

class _DetailLayananPageState extends State<DetailLayananPage> {
  bool _isLiked = false;

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

  // ============ AKSI KLIK: Alamat / Jam Operasional / Kontak ============
  void _openInfoSheet(_InfoType type) {
    final l = widget.layanan;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.outline,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  type.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                // Isi sesuai tipe
                if (type == _InfoType.alamat) ...[
                  Text(
                    l.location,
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 16),
                  _FullWidthButton(
                    label: 'Buka di Google Maps',
                    icon: Icons.map_rounded,
                    onPressed: () =>
                        _showSnack('Membuka Google Maps... (segera)'),
                  ),
                ] else if (type == _InfoType.jam) ...[
                  ...l.jamOperasional.entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(e.key,
                              style: const TextStyle(
                                  fontSize: 13.5,
                                  color: AppColors.textDark)),
                          Text(
                            e.value,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: e.value.toLowerCase() == 'tutup'
                                  ? Colors.redAccent
                                  : AppColors.accentDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  _InfoRow(
                    icon: Icons.phone_rounded,
                    label: 'Telepon',
                    value: l.phone,
                    onTap: () => _showSnack('Menghubungi $l.phone...'),
                  ),
                  _InfoRow(
                    icon: Icons.chat_rounded,
                    label: 'WhatsApp',
                    value: l.phone,
                    onTap: () => _showSnack('Membuka WhatsApp... (segera)'),
                  ),
                  _InfoRow(
                    icon: Icons.email_rounded,
                    label: 'Email',
                    value: l.email,
                    onTap: () => _showSnack('Membuka email... (segera)'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================ SHEET ULASAN ============================
  void _openUlasanSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.outline,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Ulasan Pasien',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                ...sampleUlasan.map(
                  (u) => _UlasanCard(ulasan: u),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.layanan;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= HEADER: back + love =================
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: AppColors.darkBrown,
                    ),
                    // ⭐ TOMBOL LOVE — bisa diklik, berubah merah
                    GestureDetector(
                      onTap: () {
                        setState(() => _isLiked = !_isLiked);
                        _showSnack(
                          _isLiked ? 'Ditambahkan ke favorit ❤️' : 'Dihapus dari favorit',
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _isLiked
                              ? const Color(0xFFFDE8E8)
                              : AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.outline),
                        ),
                        child: Icon(
                          _isLiked
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: _isLiked
                              ? const Color(0xFFE55555)
                              : AppColors.darkBrown,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ================= GAMBAR UTAMA =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 190,
                    width: double.infinity,
                    child: _SmartImage(
                      path: l.imagePath,
                      icon: l.icon,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ================= NAMA + BADGE =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        l.name,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDEFD9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        l.category,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accentDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // ================= RATING + JARAK =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 18, color: Color(0xFFF2B01E)),
                    const SizedBox(width: 4),
                    Text(
                      '${l.rating}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      '  (${l.reviews} ulasan)',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textGrey),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.near_me_rounded,
                        size: 15, color: AppColors.accentDark),
                    const SizedBox(width: 4),
                    Text(
                      l.distance,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textGrey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ================= DESKRIPSI =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  l.description,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.55,
                    color: AppColors.textGrey,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ============ 3 KARTU INFO (bisa diklik!) ============
              _InfoCard(
                iconBg: const Color(0xFFFDF3D7),
                iconColor: const Color(0xFFC99A2C),
                icon: Icons.place_rounded,
                title: 'Alamat',
                subtitle: l.location,
                onTap: () => _openInfoSheet(_InfoType.alamat),
              ),
              _InfoCard(
                iconBg: const Color(0xFFE8F0FB),
                iconColor: const Color(0xFF5B8AC7),
                icon: Icons.access_time_rounded,
                title: 'Jam Operasional',
                subtitle: l.hoursShort,
                onTap: () => _openInfoSheet(_InfoType.jam),
              ),
              _InfoCard(
                iconBg: const Color(0xFFE6F4EA),
                iconColor: const Color(0xFF5BA97C),
                icon: Icons.phone_rounded,
                title: 'Kontak',
                subtitle: l.phone,
                onTap: () => _showSnack('Menghubungi ${l.phone}...'),
              ),
              const SizedBox(height: 24),

              // ================= LAYANAN TERSEDIA =================
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Layanan yang Tersedia',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: l.services
                      .map(
                        (s) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBEFD4),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.outline,
                            ),
                          ),
                          child: Text(
                            s,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryText,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 24),

              // ================= ULASAN PASIEN =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Ulasan Pasien',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _openUlasanSheet,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.accentDark,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Text(
                        'Lihat Semua',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      label: const Icon(Icons.chevron_right_rounded,
                          size: 18),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _UlasanCard(ulasan: sampleUlasan.first),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================ WIDGET PENDUKUNG =============================

enum _InfoType { alamat, jam, kontak }

extension _InfoTypeTitle on _InfoType {
  String get title {
    switch (this) {
      case _InfoType.alamat:
        return 'Alamat';
      case _InfoType.jam:
        return 'Jam Operasional';
      case _InfoType.kontak:
        return 'Kontak';
    }
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.iconBg,
    required this.iconColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final Color iconBg;
  final Color iconColor;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
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
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 21),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 11.5, color: AppColors.textGrey),
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
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outline),
            ),
            child: Row(
              children: [
                Icon(icon, size: 19, color: AppColors.accentDark),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textGrey)),
                      Text(value,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FullWidthButton extends StatelessWidget {
  const _FullWidthButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.darkBrown,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        icon: Icon(icon, size: 18),
        label: Text(label,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class Ulasan {
  const Ulasan({
    required this.nama,
    required this.rating,
    required this.tanggal,
    required this.teks,
    required this.inisial,
  });

  final String nama;
  final double rating;
  final String tanggal;
  final String teks;
  final String inisial;
}

const List<Ulasan> sampleUlasan = [
  Ulasan(
    nama: 'Rina Amalia',
    rating: 5,
    tanggal: '12 Jan 2026',
    teks:
        'Pelayanannya ramah, tunggu tidak lama, dan fasilitas lengkap. Dokternya juga sangat profesional.',
    inisial: 'RA',
  ),
  Ulasan(
    nama: 'Bagus Setiawan',
    rating: 4,
    tanggal: '3 Jan 2026',
    teks:
        'IGD-nya responsif 24 jam. Parkir agak penuh saat akhir pekan, tapi pelayanan medisnya bagus.',
    inisial: 'BS',
  ),
  Ulasan(
    nama: 'Siti Nurhaliza',
    rating: 5,
    tanggal: '28 Des 2025',
    teks:
        'Apoteknya lengkap dan petugas farmasi menjelaskan dosis obat dengan sabar. Recommended!',
    inisial: 'SN',
  ),
];

class _UlasanCard extends StatelessWidget {
  const _UlasanCard({required this.ulasan});

  final Ulasan ulasan;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFFDF3D7),
                child: Text(
                  ulasan.inisial,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentDark,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  ulasan.nama,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              Text(
                ulasan.tanggal,
                style: const TextStyle(
                    fontSize: 10.5, color: AppColors.textGrey),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: List.generate(
              5,
              (i) => Icon(
                Icons.star_rounded,
                size: 15,
                color: i < ulasan.rating.round()
                    ? const Color(0xFFF2B01E)
                    : const Color(0xFFE5DCCB),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            ulasan.teks,
            style: const TextStyle(
              fontSize: 12,
              height: 1.5,
              color: AppColors.textGrey,
            ),
          ),
        ],
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