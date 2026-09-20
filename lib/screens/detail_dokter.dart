import 'package:flutter/material.dart';

import '../models/dokter.dart';
import '../theme.dart';
import '../utils/rute.dart';
import '../utils/tanggal.dart';
import '../widgets/widget_konsultasi.dart';
import 'chat_konsultasi.dart';

class DetailDokterScreen extends StatefulWidget {
  final Dokter dokter;

  const DetailDokterScreen({super.key, required this.dokter});

  @override
  State<DetailDokterScreen> createState() => _DetailDokterScreenState();
}

class _DetailDokterScreenState extends State<DetailDokterScreen> {
  int _hariTerpilih = 0;

  @override
  Widget build(BuildContext context) {
    final dokter = widget.dokter;
    final hari = Tanggal.hariKeDepan(5);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.more_vert_rounded, color: AppColors.textDark),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _hero(dokter),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 18),
                          Row(children: [
                            Expanded(
                              child: Text(dokter.nama, style: const TextStyle(
                                  fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                            ),
                            const BadgeOnline(),
                          ]),
                          const SizedBox(height: 4),
                          Text(dokter.spesialis,
                              style: const TextStyle(fontSize: 13.5, color: AppColors.textSoft)),
                          const SizedBox(height: 10),
                          Row(children: [
                            const Icon(Icons.star_rounded, size: 15, color: AppColors.star),
                            Text(' ${dokter.rating.toStringAsFixed(1)} ',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                            Text('(${dokter.jumlahUlasan})',
                                style: const TextStyle(fontSize: 13, color: AppColors.textSoft)),
                            const SizedBox(width: 16),
                            const Icon(Icons.assignment_outlined, size: 15, color: AppColors.primary),
                            Text(' ${dokter.pengalaman}',
                                style: const TextStyle(fontSize: 13, color: AppColors.textSoft)),
                          ]),
                          const SizedBox(height: 22),
                          const Text('Jadwal Praktik', style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                          const SizedBox(height: 12),
                          SizedBox(height: 62, child: _chipHari(hari)),
                          const SizedBox(height: 18),
                          Row(children: [
                            Expanded(child: _KartuInfo(
                                icon: Icons.access_time_rounded,
                                label: 'JAM PRAKTIK', value: dokter.jamPraktik)),
                            const SizedBox(width: 12),
                            Expanded(child: _KartuInfo(
                                icon: Icons.location_on_outlined,
                                label: 'LOKASI', value: dokter.lokasi)),
                          ]),
                          const SizedBox(height: 22),
                          _tombolChat(dokter),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hero(Dokter dokter) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 200,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: dokter.warnaAvatar,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
      ),
      child: dokter.foto != null
          ? Image.asset(dokter.foto!, fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _heroFallback(dokter))
          : _heroFallback(dokter),
    );
  }

  Widget _heroFallback(Dokter dokter) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🩺', style: TextStyle(fontSize: 44)),
          const SizedBox(height: 8),
          Text(dokter.nama, textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF6B5836))),
        ],
      ),
    );
  }

  Widget _chipHari(List<DateTime> hari) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: hari.length,
      separatorBuilder: (_, _) => const SizedBox(width: 10),
      itemBuilder: (_, i) {
        final d = hari[i];
        final terpilih = i == _hariTerpilih;
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => setState(() => _hariTerpilih = i),
          child: Container(
            width: 64,
            decoration: BoxDecoration(
              color: terpilih ? AppColors.primary : AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: terpilih ? AppColors.primary : AppColors.divider),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(Tanggal.namaHari[d.weekday - 1], style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: terpilih ? Colors.white : AppColors.textSoft)),
                const SizedBox(height: 2),
                Text('${d.day} ${Tanggal.namaBulan[d.month - 1]}', style: TextStyle(
                    fontSize: 12.5, fontWeight: FontWeight.w800,
                    color: terpilih ? Colors.white : AppColors.textDark)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _tombolChat(Dokter dokter) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), boxShadow: AppShadows.button),
        child: Material(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(28),
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatKonsultasiScreen(dokter: dokter),
                settings: const RouteSettings(name: Rute.chatKonsultasi),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Mulai Chat', style: TextStyle(
                    color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _KartuInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _KartuInfo({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w700,
                    letterSpacing: .5, color: AppColors.textFaint)),
                const SizedBox(height: 2),
                Text(value, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textDark)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}