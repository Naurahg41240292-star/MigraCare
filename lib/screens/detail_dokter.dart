import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  String? _slotTerpilih;
  bool _sedangBooking = false;

  // jadwal REAL dokter dari Firestore
  List<Map<String, dynamic>> _jadwal = [];
  bool _loadingJadwal = true;

  // ✅ BARU: tanggal terdekat (14 hari ke depan) yang hari-nya punya jadwal
  late final List<DateTime> _semuaHariDepan =
      List.generate(14, (i) => DateTime.now().add(Duration(days: i)));
  List<DateTime> _tanggalTersedia = [];
  DateTime? _tanggalPilihan;

  @override
  void initState() {
    super.initState();
    _muatJadwal();
  }

  /// Baca jadwal dokter dari users/{uidDokter}/jadwal
  Future<void> _muatJadwal() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.dokter.id)
          .collection('jadwal')
          .get();

      if (!mounted) return;
      setState(() {
        _jadwal = snap.docs.map((d) {
          final data = d.data();
          return {
            'hari': data['hari'] ?? '',
            'jamMulai': data['jamMulai'] ?? '',
            'jamSelesai': data['jamSelesai'] ?? '',
          };
        }).toList();

        // ✅ BARU: hitung tanggal terdekat yang hari-nya cocok dengan jadwal
        final hariAda = _jadwal.map((j) => j['hari'] as String).toSet();
        _tanggalTersedia = _semuaHariDepan
            .where((d) => hariAda.contains(Tanggal.namaHari[d.weekday - 1]))
            .toList();
        _tanggalPilihan =
            _tanggalTersedia.isNotEmpty ? _tanggalTersedia.first : null;

        _loadingJadwal = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingJadwal = false);
    }
  }

  // ================= LOGIKA SLOT 30 MENIT (revisi #2) =================
  int _jamKeMenit(String hhmm) {
    final p = hhmm.split(':');
    if (p.length != 2) return 0;
    return (int.tryParse(p[0]) ?? 0) * 60 + (int.tryParse(p[1]) ?? 0);
  }

  List<String> _hitungSlot(String mulai, String selesai) {
    final a = _jamKeMenit(mulai);
    final b = _jamKeMenit(selesai);
    final slots = <String>[];
    for (var t = a; t + 30 <= b; t += 30) {
      slots.add('${(t ~/ 60).toString().padLeft(2, '0')}:${(t % 60).toString().padLeft(2, '0')}');
    }
    return slots;
  }

  String get _namaHariPilihan =>
      _tanggalPilihan == null
          ? ''
          : Tanggal.namaHari[_tanggalPilihan!.weekday - 1];

  List<Map<String, dynamic>> get _jadwalHariIni =>
      _jadwal.where((j) => j['hari'] == _namaHariPilihan).toList();

  List<String> get _slotsHariIni {
    final all = <String>[];
    for (final j in _jadwalHariIni) {
      all.addAll(_hitungSlot(j['jamMulai'], j['jamSelesai']));
    }
    return all;
  }

  // ================= BOOKING (revisi #1) =================
  Future<void> _booking() async {
    if (_slotTerpilih == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Pilih salah satu slot jam dulu ya')));
      return;
    }

    setState(() => _sedangBooking = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      final uidPasien = user?.uid ?? '';
      String namaPasien = 'Pasien MigraCare';
      if (uidPasien.isNotEmpty) {
        final me = await FirebaseFirestore.instance
            .collection('users')
            .doc(uidPasien)
            .get();
        namaPasien = (me.data()?['profile']?['namaLengkap'] ??
                me.data()?['akun']?['namaLengkap'] ??
                'Pasien MigraCare') as String;
      }

      await FirebaseFirestore.instance.collection('booking').add({
        'pasienUid': uidPasien,
        'pasienNama': namaPasien,
        'dokterUid': widget.dokter.id,
        'dokterNama': widget.dokter.nama,
        'hari': _namaHariPilihan,
        'tanggal': '${_tanggalPilihan!.day}/${_tanggalPilihan!.month}/${_tanggalPilihan!.year}',
        'jam': _slotTerpilih,
        'durasiMenit': 30,
        'status': 'menunggu',
        'dibuatPada': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Booking berhasil! $_namaHariPilihan, $_slotTerpilih — menunggu konfirmasi dokter')));
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal booking: $e')));
      }
    } finally {
      if (mounted) setState(() => _sedangBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dokter = widget.dokter;

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

                          // ================= JADWAL REAL =================
                          const Text('Jadwal Konsultasi', style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                          const SizedBox(height: 12),

                          if (_loadingJadwal)
                            const Center(child: Padding(
                              padding: EdgeInsets.all(8),
                              child: CircularProgressIndicator(),
                            ))
                          else if (_jadwal.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Dokter belum mengatur jadwal konsultasi.',
                                style: TextStyle(fontSize: 12.5, color: AppColors.textSoft),
                              ),
                            )
                          else ...[
                            // ✅ INFO: jadwal mingguan dokter (biar pasien tahu hari apa tersedia)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.divider),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline_rounded,
                                      size: 18, color: AppColors.primary),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Tersedia setiap: ${_jamRingkas()}',
                                      style: const TextStyle(
                                          fontSize: 12.5,
                                          color: AppColors.textDark),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),

                            if (_tanggalTersedia.isEmpty)
                              const Text(
                                'Tidak ada tanggal yang cocok dalam 14 hari ke depan.',
                                style: TextStyle(fontSize: 12.5, color: AppColors.textSoft),
                              )
                            else ...[
                              SizedBox(height: 62, child: _chipHari()),
                              const SizedBox(height: 14),
                              if (_slotsHariIni.isNotEmpty) ...[
                                const Text('Pilih Jam (30 menit / sesi)',
                                    style: TextStyle(
                                        fontSize: 13, fontWeight: FontWeight.w700,
                                        color: AppColors.textDark)),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: _slotsHariIni.map((s) {
                                    final terpilih = s == _slotTerpilih;
                                    return InkWell(
                                      borderRadius: BorderRadius.circular(10),
                                      onTap: () => setState(() => _slotTerpilih = s),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: terpilih ? AppColors.primary : AppColors.card,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                              color: terpilih ? AppColors.primary : AppColors.divider),
                                        ),
                                        child: Text(s,
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: terpilih ? Colors.white : AppColors.textDark)),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _slotTerpilih == null
                                      ? 'Pilih jam di atas untuk booking konsultasi'
                                      : 'Terpilih: $_namaHariPilihan, $_slotTerpilih (30 menit)',
                                  style: const TextStyle(
                                      fontSize: 12.5, color: AppColors.textSoft),
                                ),
                              ],
                            ],
                          ],

                          const SizedBox(height: 18),
                          Row(children: [
                            Expanded(child: _KartuInfo(
                                icon: Icons.access_time_rounded,
                                label: 'JAM PRAKTIK', value: _jamRingkas())),
                            const SizedBox(width: 12),
                            Expanded(child: _KartuInfo(
                                icon: Icons.chat_rounded,
                                label: 'SESI', value: '30 menit')),
                          ]),
                          const SizedBox(height: 22),
                          _tombolBooking(dokter),
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

  /// Ringkas semua jadwal jadi satu teks ("Senin 08:00-12:00")
  String _jamRingkas() {
    if (_jadwal.isEmpty) return '-';
    return _jadwal.map((j) => '${j['hari']} ${j['jamMulai']}-${j['jamSelesai']}').join(', ');
  }

  // ---- ✅ chip hari: hanya tanggal yang PUNYA jadwal (dari 14 hari ke depan) ----
  Widget _chipHari() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _tanggalTersedia.length,
      separatorBuilder: (_, _) => const SizedBox(width: 10),
      itemBuilder: (_, i) {
        final d = _tanggalTersedia[i];
        final terpilih = _tanggalPilihan != null &&
            _tanggalPilihan!.day == d.day &&
            _tanggalPilihan!.month == d.month;
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => setState(() {
            _tanggalPilihan = d;
            _slotTerpilih = null;
          }),
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

  // ---- tombol BOOKING ----
  Widget _tombolBooking(Dokter dokter) {
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
            onTap: _sedangBooking ? null : _booking,
            child: Center(
              child: _sedangBooking
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4))
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_available_rounded, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text('Booking Konsultasi', style: TextStyle(
                            color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.w800)),
                      ],
                    ),
            ),
          ),
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
                Text(value, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textDark)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}