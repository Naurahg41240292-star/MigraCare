import 'package:flutter/material.dart';
import '../models/obat.dart';
import 'detail_riwayat.dart';

/// ==========================================================================
///  MIGRACARE — Halaman Riwayat Pengingat
///  File: lib/screens/riwayat_pengingat.dart
/// ==========================================================================

class RiwayatPengingatPage extends StatefulWidget {
  const RiwayatPengingatPage({super.key});

  @override
  State<RiwayatPengingatPage> createState() => _RiwayatPengingatPageState();
}

class _RiwayatPengingatPageState extends State<RiwayatPengingatPage> {
  static const Color background = Color(0xFFFAF4EA);
  static const Color surface = Colors.white;
  static const Color orange = Color(0xFFDE8500);
  static const Color textDark = Color(0xFF33261A);
  static const Color textGrey = Color(0xFF9C948A);
  static const Color outline = Color(0xFFEDE3D4);
  static const Color rowFill = Color(0xFFFBF3E3);
  static const Color cardBorder = Color(0xFFE3BC77);
  static const Color green = Color(0xFF3E7C3E);
  static const Color greenBg = Color(0xFFE4F3E4);
  static const Color orangeBg = Color(0xFFFDEEDC);

  static const List<String> _namaHari = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
  ];
  static const List<String> _namaBulan = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli',
    'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  String _filter = 'Semua';
  late DateTime _bulan;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _bulan = DateTime(now.year, now.month);
    PengingatStore.instance.muatDariDisk().then((_) {
      PengingatStore.instance.sinkronkanRiwayatHariIni();
      if (mounted) setState(() {});
    });
  }

  String _formatTanggal(DateTime d) =>
      '${_namaHari[d.weekday - 1]}, ${d.day} ${_namaBulan[d.month - 1]} ${d.year}';

  String _formatBulan(DateTime d) => '${_namaBulan[d.month - 1]} ${d.year}';

  String _jamTampil(String jam) => jam.replaceAll('.', ':');

  @override
  Widget build(BuildContext context) {
    final store = PengingatStore.instance;
    final now = DateTime.now();
    final opsiBulan = List.generate(12, (i) {
      final m = DateTime(now.year, now.month - i);
      return DateTime(m.year, m.month);
    });

    final terfilter = store.daftarRiwayat.where((r) {
      final samaBulan =
          r.tanggal.year == _bulan.year && r.tanggal.month == _bulan.month;
      if (!samaBulan) return false;
      if (_filter == 'Sudah Diminum') return r.sudahDiminum;
      if (_filter == 'Belum Diminum') return !r.sudahDiminum;
      return true;
    }).toList()
      ..sort((a, b) {
        final bandingTanggal = b.tanggal.compareTo(a.tanggal);
        if (bandingTanggal != 0) return bandingTanggal;
        return a.jam.compareTo(b.jam);
      });

    final grup = <DateTime, List<RiwayatObat>>{};
    for (final r in terfilter) {
      final kunci = DateTime(r.tanggal.year, r.tanggal.month, r.tanggal.day);
      grup.putIfAbsent(kunci, () => []).add(r);
    }

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        iconTheme: const IconThemeData(color: textDark),
        title: const Text('Riwayat Pengingat',
            style: TextStyle(color: textDark, fontWeight: FontWeight.w800)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Wrap(
              spacing: 8,
              children: ['Semua', 'Sudah Diminum', 'Belum Diminum']
                  .map(_chip)
                  .toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cardBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<DateTime>(
                        value: _bulan,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded,
                            color: textDark),
                        items: opsiBulan
                            .map((b) => DropdownMenuItem(
                                  value: b,
                                  child: Text(_formatBulan(b),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: textDark)),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _bulan = v ?? _bulan),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.calendar_month_rounded, color: orange),
                ],
              ),
            ),
          ),
          Expanded(
            child: grup.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.history_rounded,
                              size: 48, color: textGrey),
                          SizedBox(height: 12),
                          Text('Belum ada riwayat untuk bulan ini',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: textDark)),
                          SizedBox(height: 6),
                          Text(
                            'Riwayat terisi otomatis saat kamu menandai obat sudah diminum.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: textGrey, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                    children: [
                      for (final entry in grup.entries) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(_formatTanggal(entry.key),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13.5,
                                  color: textDark)),
                        ),
                        _kartuGrup(entry.key, entry.value),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cardBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.notifications_active_rounded,
                    color: orange),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Konsisten minum obat membantu pengobatan lebih efektif',
                    style: TextStyle(
                        fontSize: 12.5, color: textDark, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label) {
    final terpilih = _filter == label;
    return GestureDetector(
      onTap: () => setState(() => _filter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: terpilih ? orange : surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: terpilih ? orange : outline),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: terpilih ? Colors.white : textDark,
          ),
        ),
      ),
    );
  }

  Widget _kartuGrup(DateTime tanggal, List<RiwayatObat> items) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cardBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          children: [
            for (int i = 0; i < items.length; i++) ...[
              if (i > 0) const Divider(height: 1, color: outline),
              _barisRiwayat(items[i], tanggal),
            ],
          ],
        ),
      ),
    );
  }

  Widget _barisRiwayat(RiwayatObat r, DateTime tanggalGrup) {
    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailRiwayatPage(tanggal: tanggalGrup),
          ),
        );
        setState(() {});
      },
      child: Container(
        color: rowFill,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Text(_jamTampil(r.jam),
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: textDark)),
            const SizedBox(width: 10),
            Expanded(
              child: Text('${r.namaObat} ${r.dosisObat}',
                  style: const TextStyle(fontSize: 13, color: textDark)),
            ),
            _chipStatus(r.sudahDiminum),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded,
                size: 20, color: textGrey),
          ],
        ),
      ),
    );
  }

  Widget _chipStatus(bool sudah) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: sudah ? greenBg : orangeBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            sudah ? 'Sudah diminum' : 'Belum diminum',
            style: TextStyle(
                fontSize: 10.5, color: sudah ? green : orange),
          ),
          const SizedBox(width: 3),
          Icon(
            sudah ? Icons.check_circle : Icons.notifications_active,
            size: 13,
            color: sudah ? green : orange,
          ),
        ],
      ),
    );
  }
}