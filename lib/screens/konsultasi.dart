import 'package:flutter/material.dart';

import '../models/dokter.dart';
import '../theme.dart';
import '../utils/rute.dart';
import '../widgets/widget_konsultasi.dart';
import 'chat_konsultasi.dart';
import 'detail_dokter.dart';

class KonsultasiScreen extends StatefulWidget {
  const KonsultasiScreen({super.key});

  @override
  State<KonsultasiScreen> createState() => _KonsultasiScreenState();
}

class _KonsultasiScreenState extends State<KonsultasiScreen> {
  static const List<String> _chips = ['Semua', 'Dokter Umum', 'Spesialis', 'Riwayat'];

  String _query = '';
  String _chip = 'Semua';

  bool get _tampilkanRiwayat => _chip == 'Riwayat';

  List<Dokter> get _dokterTerfilter {
    final q = _query.trim().toLowerCase();
    return daftarDokter.where((d) {
      final bool sesuaiKategori;
      switch (_chip) {
        case 'Dokter Umum':
          sesuaiKategori = !d.isSpesialis;
          break;
        case 'Spesialis':
          sesuaiKategori = d.isSpesialis;
          break;
        default:
          sesuaiKategori = true;
      }
      return sesuaiKategori && d.nama.toLowerCase().contains(q);
    }).toList();
  }

  void _bukaDetail(Dokter d) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailDokterScreen(dokter: d),
        settings: const RouteSettings(name: Rute.detailDokter),
      ),
    );
  }

  void _bukaChat(Dokter d) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatKonsultasiScreen(dokter: d),
        settings: const RouteSettings(name: Rute.chatKonsultasi),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hai, Ananda! 👋', style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  SizedBox(height: 4),
                  Text('Sehat hari ini, langkah baik untuk esok.',
                      style: TextStyle(fontSize: 13, color: AppColors.textSoft)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: _kolomCari(),
            ),
            SizedBox(height: 52, child: _chipBar()),
            Expanded(child: _tampilkanRiwayat ? _listRiwayat() : _listDokter()),
          ],
        ),
      ),
    );
  }

  Widget _kolomCari() {
    return TextField(
      onChanged: (v) => setState(() => _query = v),
      cursorColor: AppColors.primary,
      style: const TextStyle(fontSize: 14, color: AppColors.textDark),
      decoration: InputDecoration(
        hintText: 'Cari dokter...',
        hintStyle: const TextStyle(fontSize: 14, color: AppColors.textFaint),
        prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.textFaint),
        filled: true,
        fillColor: AppColors.card,
        contentPadding: EdgeInsets.zero,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
        ),
      ),
    );
  }

  Widget _chipBar() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: _chips.length,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (_, i) {
        final c = _chips[i];
        final terpilih = c == _chip;
        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => setState(() => _chip = c),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: terpilih ? AppColors.primary : AppColors.chipBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(c, style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: terpilih ? Colors.white : AppColors.textSoft,
              )),
            ),
          ),
        );
      },
    );
  }

  Widget _listDokter() {
    final dokter = _dokterTerfilter;
    if (dokter.isEmpty) return _kosong('Tidak ada dokter yang cocok dengan pencarianmu.');
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      itemCount: dokter.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _KartuDokter(dokter: dokter[i], onTap: () => _bukaDetail(dokter[i])),
    );
  }

  Widget _listRiwayat() {
    if (daftarRiwayat.isEmpty) return _kosong('Belum ada riwayat konsultasi.');
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      itemCount: daftarRiwayat.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final r = daftarRiwayat[i];
        final d = daftarDokter.firstWhere((d) => d.id == r.dokterId);
        return _KartuRiwayat(
          dokter: d, topik: r.topik, tanggal: r.tanggal, status: r.status,
          onTap: () => _bukaChat(d),
        );
      },
    );
  }

  Widget _kosong(String pesan) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded, size: 44, color: AppColors.textFaint),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(pesan, textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.textSoft)),
          ),
        ],
      ),
    );
  }
}

class _KartuDokter extends StatelessWidget {
  final Dokter dokter;
  final VoidCallback onTap;

  const _KartuDokter({required this.dokter, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _cangkangKartu(
      onTap: onTap,
      child: Row(
        children: [
          AvatarDokter(dokter: dokter, size: 54),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dokter.nama, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                const SizedBox(height: 2),
                Text(dokter.spesialis, style: const TextStyle(fontSize: 12.5, color: AppColors.textSoft)),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.star_rounded, size: 14, color: AppColors.star),
                  const SizedBox(width: 3),
                  Text(dokter.rating.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  Text(' (${dokter.jumlahUlasan})',
                      style: const TextStyle(fontSize: 12, color: AppColors.textFaint)),
                ]),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const BadgeOnline(),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textFaint),
        ],
      ),
    );
  }
}

class _KartuRiwayat extends StatelessWidget {
  final Dokter dokter;
  final String topik;
  final String tanggal;
  final String status;
  final VoidCallback onTap;

  const _KartuRiwayat({
    required this.dokter,
    required this.topik,
    required this.tanggal,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _cangkangKartu(
      onTap: onTap,
      child: Row(
        children: [
          AvatarDokter(dokter: dokter, size: 54),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dokter.nama, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                const SizedBox(height: 2),
                Text('$topik • $tanggal', maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12.5, color: AppColors.textSoft)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          BadgeOnline(label: status),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textFaint),
        ],
      ),
    );
  }
}

Widget _cangkangKartu({required VoidCallback onTap, required Widget child}) {
  return Container(
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(16),
      boxShadow: AppShadows.card,
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(14), child: child),
      ),
    ),
  );
}