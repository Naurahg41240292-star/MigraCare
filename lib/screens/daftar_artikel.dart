import 'package:flutter/material.dart';
import '../models/artikel.dart';
import 'detail_artikel.dart';

// =======================================================================
//  MIGRACARE — Halaman Daftar Artikel (dibuka dari "Lihat Semua")
//  File: lib/screens/daftar_artikel.dart
// =======================================================================

/// Palet warna lokal (konsisten dengan beranda.dart & detail_artikel.dart)
abstract class _C {
  static const Color background = Color(0xFFFAF4EA);
  static const Color surface = Colors.white;
  static const Color darkBrown = Color(0xFF3D2B1A);
  static const Color accent = Color(0xFFF2C230);
  static const Color accentDark = Color(0xFFB07E1F);
  static const Color textDark = Color(0xFF33261A);
  static const Color textGrey = Color(0xFF9C948A);
  static const Color outline = Color(0xFFEDE3D4);
}

class DaftarArtikelPage extends StatefulWidget {
  const DaftarArtikelPage({super.key});

  @override
  State<DaftarArtikelPage> createState() => _DaftarArtikelPageState();
}

class _DaftarArtikelPageState extends State<DaftarArtikelPage> {
  String _query = '';
  String _activeCategory = 'Semua';

  /// Kategori diambil otomatis dari data artikel
  late final List<String> _categories = [
    'Semua',
    ...artikelPopuler.map((a) => a.category).toSet(),
  ];

  List<Artikel> get _hasilFilter {
    final q = _query.trim().toLowerCase();
    return artikelPopuler.where((a) {
      final cocokKategori =
          _activeCategory == 'Semua' || a.category == _activeCategory;
      final cocokPencarian = q.isEmpty ||
          a.title.toLowerCase().contains(q) ||
          a.subtitle.toLowerCase().contains(q) ||
          a.category.toLowerCase().contains(q);
      return cocokKategori && cocokPencarian;
    }).toList();
  }

  void _bukaDetail(Artikel artikel) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DetailArtikelPage(artikel: artikel)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasil = _hasilFilter;

    return Scaffold(
      backgroundColor: _C.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSearchField(),
            _buildCategoryChips(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
              child: Text(
                '${hasil.length} artikel',
                style: const TextStyle(fontSize: 11, color: _C.textGrey),
              ),
            ),
            Expanded(
              child: hasil.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      itemCount: hasil.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) => _ArtikelListCard(
                        artikel: hasil[index],
                        onTap: () => _bukaDetail(hasil[index]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------- HEADER ---------------------------------
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded,
                color: _C.darkBrown, size: 26),
          ),
          const SizedBox(width: 2),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Artikel Migrain',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: _C.textDark,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Baca informasi seputar migrain dan cara mengatasinya',
                  style: TextStyle(fontSize: 12, color: _C.textGrey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------ PENCARIAN -------------------------------
  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
      child: TextField(
        onChanged: (value) => setState(() => _query = value),
        style: const TextStyle(fontSize: 13.5, color: _C.textDark),
        decoration: InputDecoration(
          hintText: 'Cari artikel…',
          hintStyle: const TextStyle(fontSize: 13.5, color: _C.textGrey),
          prefixIcon:
              const Icon(Icons.search_rounded, color: _C.textGrey, size: 22),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.close_rounded,
                      size: 18, color: _C.textGrey),
                  onPressed: () => setState(() => _query = ''),
                ),
          filled: true,
          fillColor: _C.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _C.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _C.accentDark, width: 1.2),
          ),
        ),
      ),
    );
  }

  // --------------------------- FILTER KATEGORI ----------------------------
  Widget _buildCategoryChips() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final kategori = _categories[index];
          final aktif = kategori == _activeCategory;
          return GestureDetector(
            onTap: () => setState(() => _activeCategory = kategori),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: aktif ? _C.accent : _C.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: aktif ? _C.accent : _C.outline),
              ),
              child: Text(
                kategori,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: aktif ? _C.darkBrown : _C.textGrey,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ------------------------------ EMPTY STATE -----------------------------
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded,
              size: 56, color: Color(0x669C948A)),
          const SizedBox(height: 12),
          const Text(
            'Artikel tidak ditemukan',
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w700, color: _C.textDark),
          ),
          const SizedBox(height: 6),
          const Text(
            'Coba kata kunci atau kategori lain.',
            style: TextStyle(fontSize: 12.5, color: _C.textGrey),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
//  KARTU ARTIKEL (list vertikal — sesuai mockup)
// ===========================================================================
class _ArtikelListCard extends StatelessWidget {
  const _ArtikelListCard({required this.artikel, required this.onTap});

  final Artikel artikel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.outline),
        boxShadow: const [
          BoxShadow(
            color: Color(0x143D2B1A),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 96,
                    height: 104,
                    child: _CardImage(url: artikel.imageUrl),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        artikel.category,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                          color: _C.accentDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        artikel.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                          color: _C.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        artikel.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          height: 1.35,
                          color: _C.textGrey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded,
                              size: 11, color: _C.textGrey),
                          const SizedBox(width: 4),
                          Text(
                            artikel.date,
                            style: const TextStyle(
                                fontSize: 10.5, color: _C.textGrey),
                          ),
                          if (artikel.readMinutes != null) ...[
                            const SizedBox(width: 10),
                            const Icon(Icons.schedule_rounded,
                                size: 12, color: _C.textGrey),
                            const SizedBox(width: 4),
                            Text(
                              '${artikel.readMinutes} mnt baca',
                              style: const TextStyle(
                                  fontSize: 10.5, color: _C.textGrey),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right_rounded,
                    size: 22, color: _C.accentDark),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
//  GAMBAR KARTU (anti-kosong, ada fallback)
// ===========================================================================
class _CardImage extends StatelessWidget {
  const _CardImage({required this.url});

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
          child: const Icon(Icons.health_and_safety_rounded,
              color: Color(0xFFB99B6B), size: 30),
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