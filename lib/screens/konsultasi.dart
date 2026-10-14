import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/profil_service.dart';

import '../models/dokter.dart';
import '../theme.dart';
import '../utils/rute.dart';
import '../widgets/widget_konsultasi.dart';
import 'chat_konsultasi.dart';
import 'detail_dokter.dart';
import 'dokter/chat_booking.dart';

class KonsultasiScreen extends StatefulWidget {
  final VoidCallback? onKembali;

  const KonsultasiScreen({
    super.key,
    this.onKembali,
  });

  @override
  State<KonsultasiScreen> createState() => _KonsultasiScreenState();
}

class _KonsultasiScreenState extends State<KonsultasiScreen> {
  static const List<String> _chips = ['Semua', 'Dokter Umum', 'Spesialis', 'Riwayat'];

  String _query = '';
  String _chip = 'Semua';

  // ✅ Nama user untuk sapaan
  String _nama = '';

  // ✅ Dokter REAL dari Firestore
  bool _loadingDokter = true;
  List<Dokter> _dokterFirestore = [];

  // ✅ BARU: booking milik pasien (dari koleksi booking/)
  List<Map<String, dynamic>> _bookings = [];
  bool _loadingBooking = false;

  bool get _tampilkanRiwayat => _chip == 'Riwayat';

  @override
  void initState() {
    super.initState();
    _muatNama();
    _muatDokterFirestore();
    _muatBooking();
  }

  // ✅ Ambil nama user untuk sapaan
  Future<void> _muatNama() async {
    final nama = await ProfilService.instance.ambilNama();
    if (!mounted) return;
    setState(() => _nama = nama);
  }

  // ✅ Ambil dokter REAL dari Firestore (users role=dokter)
  Future<void> _muatDokterFirestore() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'dokter')
          .get();

      if (!mounted) return;
      setState(() {
        _dokterFirestore = snap.docs
            .map((d) => Dokter.fromFirestore(d.id, d.data()))
            .toList();
        _loadingDokter = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingDokter = false);
    }
  }
  // ✅ Ambil booking milik pasien yang login
  Future<void> _muatBooking() async {
    setState(() => _loadingBooking = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) setState(() => _loadingBooking = false);   // ← loading dimatikan
        return;
      }

      final snap = await FirebaseFirestore.instance
          .collection('booking')
          .where('pasienUid', isEqualTo: user.uid)
          .orderBy('dibuatPada', descending: true)
          .get();

      if (!mounted) return;
      setState(() {
        _bookings = snap.docs.map((d) {
          final data = d.data();
          return {
            'id': d.id,
            'dokterNama': (data['dokterNama'] ?? 'Dokter') as String,
            'hari': (data['hari'] ?? '-') as String,
            'tanggal': (data['tanggal'] ?? '') as String,
            'jam': (data['jam'] ?? '-') as String,
            'status': (data['status'] ?? 'menunggu') as String,
            'booking': data,
          };
        }).toList();
        _loadingBooking = false;                                 // ← loading dimatikan ✅
      });
    } catch (e) {
      debugPrint('Gagal muat booking: $e');                      // ← error TAMPIL di console
      if (mounted) {
        setState(() => _loadingBooking = false);                 // ← loading dimatikan ✅
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memuat booking: $e'))); // ← error TAMPIL di layar
      }
    }
  }
  
  List<Dokter> get _dokterTerfilter {
    final q = _query.trim().toLowerCase();
    final sumber = _dokterFirestore.isNotEmpty ? _dokterFirestore : daftarDokter;
    return sumber.where((d) {
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

  // ✅ BARU: buka chat BOOKING (pasien ↔ dokter asli)
  void _bukaChatBooking(Map<String, dynamic> b) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatBookingPage(
          bookingId: b['id'],
          booking: b['booking'] as Map<String, dynamic>,
          sayaDokter: false, // ← dari sisi PASIEN
        ),
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
            // TOMBOL BACK → KEMBALI KE BERANDA
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: AppColors.textDark,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => widget.onKembali?.call(),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Konsultasi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),

            // SAPAAN
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hai, $_nama 👋',
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary)),
                  const SizedBox(height: 4),
                  const Text('Sehat hari ini, langkah baik untuk esok.',
                      style: TextStyle(fontSize: 13, color: AppColors.textSoft)),
                ],
              ),
            ),

            // SEARCH
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: _kolomCari(),
            ),

            // FILTER CHIP — ✅ saat pilih "Riwayat" → refresh booking
            SizedBox(
              height: 52,
              child: _chipBar(),
            ),

            // DAFTAR DOKTER / RIWAYAT
            Expanded(
              child: _tampilkanRiwayat
                  ? _listRiwayat()
                  : (_loadingDokter
                      ? const Center(child: CircularProgressIndicator())
                      : _listDokter()),
            ),
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
          onTap: () {
            setState(() => _chip = c);
            // ✅ BARU: saat pilih "Riwayat" → muat ulang booking
            if (c == 'Riwayat') _muatBooking();
          },
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

  // ✅ DIGANTI: Riwayat = daftar BOOKING real dari Firestore + tombol Chat
  Widget _listRiwayat() {
    if (_loadingBooking) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_bookings.isEmpty) {
      return _kosong('Belum ada booking konsultasi.\n'
          'Booking lewat detail dokter ya!');
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      itemCount: _bookings.length,
      itemBuilder: (_, i) {
        final b = _bookings[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppShadows.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- baris nama + badge status ----
              Row(
                children: [
                  Expanded(
                    child: Text(b['dokterNama'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: b['status'] == 'dikonfirmasi'
                          ? const Color(0xFFE4F3E4)
                          : (b['status'] == 'ditolak'
                              ? const Color(0xFFFCE8E6)
                              : const Color(0xFFFDF3D7)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(b['status'],
                        style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: b['status'] == 'dikonfirmasi'
                                ? const Color(0xFF3E7C3E)
                                : (b['status'] == 'ditolak'
                                    ? const Color(0xFFE55555)
                                    : const Color(0xFFC99A2C)))),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('${b['hari']}, ${b['tanggal']} • ${b['jam']} (30 menit)',
                  style: const TextStyle(
                      fontSize: 12.5, color: AppColors.textSoft)),

              // ---- ✅ TOMBOL CHAT — hanya untuk booking DIKONFIRMASI ----
              if (b['status'] == 'dikonfirmasi') ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton.icon(
                    onPressed: () => _bukaChatBooking(b),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.chat_rounded, size: 16),
                    label: const Text('Chat Sekarang',
                        style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ],
          ),
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