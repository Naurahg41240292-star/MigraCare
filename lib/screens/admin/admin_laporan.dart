import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ============================================================
/// HALAMAN LAPORAN ADMIN — MigraCare
/// Kode ini otomatis mendeteksi struktur field di Firestore:
/// - Tanggal dibuat : createdAt / dibuatPada / akun.createdAt / dll
/// - Role pengguna  : akun.role / role / akun.peran / dll
/// - Kategori artikel: kategori / category
/// - Jenis layanan  : jenis / tipe / hasil / status
/// Kalau field tidak ditemukan, data tetap tampil dengan label fallback.
/// ============================================================

// ============ ⚙️ KONFIGURASI — cukup ubah bagian ini saja ============
const String kKoleksiPengguna = 'users';
const List<String> kKoleksiArtikel = ['artikel', 'articles']; // dicoba berurutan
const String kKoleksiLayanan = 'screenings'; // subkoleksi di users/{uid}

const List<String> kPathTanggal = [
  'createdAt', 'dibuatPada', 'dibuat', 'tanggalDibuat', 'dibuat_pada',
  'akun.createdAt', 'akun.dibuatPada', 'timestamp', 'waktuDibuat',
];
const List<String> kPathRole = ['akun.role', 'role', 'akun.peran', 'peran'];
const List<String> kPathKategori = ['kategori', 'category', 'topik'];
const List<String> kPathJenisLayanan = ['jenis', 'tipe', 'type', 'kategori', 'hasil', 'status'];
// =====================================================================

// ========================= WARNA =========================
const Color _coklat = Color(0xFFA0722A);
const Color _coklatMuda = Color(0xFFF3E8D7);
const Color _latar = Color(0xFFFAF5EE);
const Color _teks = Color(0xFF33302B);
const Color _abu = Color(0xFF8B857C);
const Color _hijau = Color(0xFF2E9E5B);
const Color _merah = Color(0xFFD9534F);
const Color _garis = Color(0xFFECE5D8);

const List<String> _bulan = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
];

// ==================== HELPER ====================
String _formatAngka(num n) => n.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

String _fmtTanggal(DateTime d) => '${d.day} ${_bulan[d.month - 1]} ${d.year}';
String _fmtPendek(DateTime d) => '${d.day} ${_bulan[d.month - 1]}';

/// Baca field bersarang: 'akun.role' → data['akun']['role']
dynamic _bacaField(Map<String, dynamic> data, String path) {
  dynamic saatIni = data;
  for (final bagian in path.split('.')) {
    if (saatIni is Map && saatIni.containsKey(bagian)) {
      saatIni = saatIni[bagian];
    } else {
      return null;
    }
  }
  return saatIni;
}

DateTime? _keDateTime(dynamic v) {
  if (v is Timestamp) return v.toDate();
  if (v is DateTime) return v;
  if (v is String) return DateTime.tryParse(v);
  if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
  return null;
}

/// Samakan istilah role: user/pasien/umum → 'pengguna', dst.
String _normalisasiRole(String raw) {
  final s = raw.toLowerCase().trim();
  if (s == 'dokter') return 'dokter';
  if (s == 'admin' || s == 'administrator') return 'admin';
  return 'pengguna'; // user, pasien, umum, pengguna, kosong
}

// ==================== MODEL ====================
class _TitikGrafik {
  final DateTime tanggal;
  final int nilai;
  const _TitikGrafik(this.tanggal, this.nilai);
}

class _ItemRincian {
  final String label;
  final int jumlah;
  final double persen;
  final IconData ikon;
  const _ItemRincian(this.label, this.jumlah, this.persen, this.ikon);
}

class _DataLaporan {
  final int total;
  final double persen;
  final List<_TitikGrafik> grafik;
  final List<_ItemRincian> rincian;
  final bool adaTanggal; // false = field tanggal tidak ketemu di Firestore
  const _DataLaporan(
      this.total, this.persen, this.grafik, this.rincian, this.adaTanggal);
}

enum TabLaporan { pengguna, artikel, layanan }

// ==================== HALAMAN UTAMA ====================
class AdminLaporanPage extends StatefulWidget {
  final ValueChanged<int>? onNavTap;
  const AdminLaporanPage({super.key, this.onNavTap});

  @override
  State<AdminLaporanPage> createState() => _AdminLaporanPageState();
}

class _AdminLaporanPageState extends State<AdminLaporanPage> {
  late TabLaporan _tab = TabLaporan.pengguna;
  late DateTime _awal;
  late DateTime _akhir;
  late Future<_DataLaporan> _future;

  @override
  void initState() {
    super.initState();
    final sekarang = DateTime.now();
    _awal = DateTime(sekarang.year, sekarang.month, 1);
    _akhir = DateTime(sekarang.year, sekarang.month, sekarang.day);
    _future = _muatData();
  }

  // ==================== AMBIL DATA FIREBASE ====================
  Future<QuerySnapshot<Map<String, dynamic>>> _ambilSnapshot() async {
    final db = FirebaseFirestore.instance;

    if (_tab == TabLaporan.layanan) {
      // screenings adalah SUBKOLEKSI users/{uid}/screenings
      // → pakai collectionGroup supaya terkumpul dari semua user
      final grup = await db.collectionGroup(kKoleksiLayanan).get();
      if (grup.docs.isNotEmpty) return grup;
      return await db.collection('layanan').get(); // fallback
    }

    final kandidat = _tab == TabLaporan.pengguna
        ? [kKoleksiPengguna]
        : kKoleksiArtikel;

    for (final nama in kandidat) {
      final snap = await db.collection(nama).get();
      if (snap.docs.isNotEmpty) return snap;
    }
    return await db.collection(kandidat.first).get();
  }

  Future<_DataLaporan> _muatData() async {
    final docs = (await _ambilSnapshot()).docs;
    final akhirInklusif =
        DateTime(_akhir.year, _akhir.month, _akhir.day, 23, 59, 59);

    // --- cari path field yang benar-benar ada di data ---
    final kandidatGrup = switch (_tab) {
      TabLaporan.pengguna => kPathRole,
      TabLaporan.artikel => kPathKategori,
      TabLaporan.layanan => kPathJenisLayanan,
    };
    String? pathTanggal;
    String? pathGrup;
    for (final d in docs) {
      final data = d.data();
      pathTanggal ??= kPathTanggal
          .cast<String?>()
          .firstWhere((p) => _bacaField(data, p!) != null,
              orElse: () => null);
      pathGrup ??= kandidatGrup.cast<String?>().firstWhere(
          (p) =>
              (_bacaField(data, p!)?.toString().trim().isNotEmpty ?? false),
          orElse: () => null);
      if (pathTanggal != null && pathGrup != null) break;
    }

    // --- hitung ---
    int total = 0, baruPeriode = 0;
    final perHari = <String, int>{};
    final totalGrup = <String, int>{};
    final baruGrup = <String, int>{};
    final now = DateTime.now();

    for (final d in docs) {
      final data = d.data();
      total++;

      final grupKey = _nilaiGrup(data, pathGrup);
      totalGrup.update(grupKey, (v) => v + 1, ifAbsent: () => 1);

      var tgl =
          pathTanggal == null ? null : _keDateTime(_bacaField(data, pathTanggal));
      final adaTgl = tgl != null;
      // Kalau user tidak punya field tanggal, anggap "hari ini"
      // supaya angkanya tetap tampil (dengan catatan di banner).
      tgl ??= now;

      if (!tgl.isBefore(_awal) && !tgl.isAfter(akhirInklusif)) {
        baruPeriode++;
        baruGrup.update(grupKey, (v) => v + 1, ifAbsent: () => 1);
        if (adaTgl) {
          final kunci = '${tgl.year}-${tgl.month.toString().padLeft(2, '0')}-${tgl.day.toString().padLeft(2, '0')}';
          perHari.update(kunci, (v) => v + 1, ifAbsent: () => 1);
        }
      }
    }

    final totalSebelum = total - baruPeriode;
    final persen = totalSebelum > 0
        ? (baruPeriode / totalSebelum * 100)
        : (baruPeriode > 0 ? 100.0 : 0.0);

    // --- data grafik per hari ---
    final grafik = <_TitikGrafik>[];
    for (var hari = DateTime(_awal.year, _awal.month, _awal.day);
        !hari.isAfter(akhirInklusif);
        hari = hari.add(const Duration(days: 1))) {
      final kunci = '${hari.year}-${hari.month.toString().padLeft(2, '0')}-${hari.day.toString().padLeft(2, '0')}';
      grafik.add(_TitikGrafik(hari, perHari[kunci] ?? 0));
    }

    // --- rincian per kategori ---
    if (_tab == TabLaporan.pengguna) {
      for (final r in ['pengguna', 'dokter', 'admin']) {
        totalGrup.putIfAbsent(r, () => 0);
      }
    }

    final rincian = totalGrup.entries.map((e) {
      final (label, ikon) = _detailGrup(e.key);
      final baru = baruGrup[e.key] ?? 0;
      final sebelum = e.value - baru;
      final p = sebelum > 0 ? (baru / sebelum * 100) : (baru > 0 ? 100.0 : 0.0);
      return _ItemRincian(label, e.value, p, ikon);
    }).toList()
      ..sort((a, b) => b.jumlah.compareTo(a.jumlah));

    return _DataLaporan(
        total, persen, grafik, rincian, pathTanggal != null);
  }

  String _nilaiGrup(Map<String, dynamic> data, String? path) {
    if (path == null) return _tab == TabLaporan.layanan ? 'screening' : 'lainnya';
    final v = _bacaField(data, path)?.toString().trim() ?? '';
    if (v.isEmpty) return _tab == TabLaporan.layanan ? 'screening' : 'lainnya';
    if (_tab == TabLaporan.pengguna) return _normalisasiRole(v);
    return v;
  }

  (String, IconData) _detailGrup(String nilai) {
    switch (_tab) {
      case TabLaporan.pengguna:
        switch (nilai) {
          case 'dokter':
            return ('Dokter', Icons.person_outline);
          case 'admin':
            return ('Admin', Icons.shield_outlined);
          case 'pengguna':
            return ('Pengguna Umum', Icons.groups_outlined);
          default:
            return (nilai, Icons.person_outline);
        }
      case TabLaporan.artikel:
        return (
          nilai == 'lainnya' ? 'Tanpa Kategori' : nilai,
          Icons.article_outlined
        );
      case TabLaporan.layanan:
        return (
          nilai == 'screening' ? 'Screening' : nilai,
          Icons.medical_services_outlined
        );
    }
  }

  // ==================== UI ====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _latar,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Laporan',
                        style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: _teks)),
                    const SizedBox(height: 4),
                    Text('Pantau data dan aktivitas aplikasi',
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: _abu)),
                    const SizedBox(height: 16),
                    _kartuRentangTanggal(),
                    const SizedBox(height: 16),
                    _tabPill(),
                    const SizedBox(height: 16),
                    FutureBuilder<_DataLaporan>(
                      future: _future,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(48),
                            child: Center(
                                child: CircularProgressIndicator(
                                    color: _coklat)),
                          );
                        }
                        if (snapshot.hasError) {
                          return _kartuError('${snapshot.error}');
                        }
                        final data = snapshot.data!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!data.adaTanggal) _bannerPeringatan(),
                            _kartuUtama(data),
                            const SizedBox(height: 20),
                            Text('Rincian ${_labelTab(_tab)}',
                                style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: _teks)),
                            const SizedBox(height: 12),
                            if (data.rincian.isEmpty)
                              Text('Belum ada data.',
                                  style: GoogleFonts.poppins(
                                      fontSize: 13, color: _abu)),
                            ...data.rincian.map(_barisRincian),
                          ],
                        );
                      },
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

  Widget _bannerPeringatan() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: const Color(0xFFFFF6E5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF0DDB0))),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: _coklat, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Field tanggal tidak ditemukan di Firestore. '
              'Grafik & filter periode mungkin belum akurat.',
              style: GoogleFonts.poppins(fontSize: 11.5, color: _teks),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kartuRentangTanggal() {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: _pilihRentang,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _garis)),
        child: Row(
          children: [
            const Icon(Icons.trending_up, size: 18, color: _coklat),
            const SizedBox(width: 10),
            Expanded(
              child: Text('${_fmtTanggal(_awal)} - ${_fmtTanggal(_akhir)}',
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _teks)),
            ),
            const Icon(Icons.calendar_today_outlined,
                size: 18, color: _teks),
          ],
        ),
      ),
    );
  }

  Future<void> _pilihRentang() async {
    final hasil = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _awal, end: _akhir),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
              primary: _coklat, onPrimary: Colors.white),
        ),
        child: child!,
      ),
    );
    if (hasil != null && mounted) {
      setState(() {
        _awal = DateTime(
            hasil.start.year, hasil.start.month, hasil.start.day);
        _akhir =
            DateTime(hasil.end.year, hasil.end.month, hasil.end.day);
        _future = _muatData();
      });
    }
  }

  Widget _tabPill() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: _garis)),
      child: Row(
        children: TabLaporan.values.map((t) {
          final aktif = t == _tab;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (_tab != t) {
                  setState(() => _tab = t);
                  setState(() => _future = _muatData());
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: aktif ? _coklat : Colors.transparent,
                    borderRadius: BorderRadius.circular(24)),
                child: Text(_labelTab(t),
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight:
                            aktif ? FontWeight.w600 : FontWeight.w400,
                        color: aktif ? Colors.white : _abu)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _kartuUtama(_DataLaporan data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _garis)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_judulKartu(_tab),
              style: GoogleFonts.poppins(fontSize: 13, color: _abu)),
          const SizedBox(height: 4),
          Text(_formatAngka(data.total),
              style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: _teks)),
          const SizedBox(height: 4),
          _chipPersen(data.persen, 'dari periode sebelumnya'),
          const SizedBox(height: 16),
          SizedBox(height: 180, child: _GrafikGaris(titik: data.grafik)),
        ],
      ),
    );
  }

  Widget _chipPersen(double persen, String keterangan) {
    final warna =
        persen == 0 ? _abu : (persen > 0 ? _hijau : _merah);
    final panah =
        persen > 0 ? '↑' : (persen < 0 ? '↓' : '→');
    return Row(
      children: [
        Text('$panah ${persen.abs().round()}%',
            style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: warna)),
        const SizedBox(width: 6),
        Text(keterangan,
            style: GoogleFonts.poppins(fontSize: 12, color: _abu)),
      ],
    );
  }

  Widget _barisRincian(_ItemRincian item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _garis)),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
                color: _coklatMuda,
                borderRadius: BorderRadius.circular(12)),
            child: Icon(item.ikon, color: _coklat, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(item.label,
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _teks)),
          ),
          Text(_formatAngka(item.jumlah),
              style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _teks)),
          const SizedBox(width: 12),
          SizedBox(
            width: 62,
            child: Text(
              '${item.persen > 0 ? '↑' : (item.persen < 0 ? '↓' : '→')} ${item.persen.abs().round()}%',
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: item.persen > 0
                      ? _hijau
                      : (item.persen < 0 ? _merah : _abu)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kartuError(String pesan) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _garis)),
      child: Column(
        children: [
          const Icon(Icons.cloud_off, color: _merah, size: 40),
          const SizedBox(height: 8),
          Text('Gagal memuat data dari Firebase',
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _teks)),
          const SizedBox(height: 4),
          Text(pesan,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 11, color: _abu)),
          TextButton(
            onPressed: () => setState(() => _future = _muatData()),
            child: const Text('Coba Lagi',
                style: TextStyle(
                    color: _coklat, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _bottomNav() {
    // ⚠️ Kalau bottom nav sudah ada di admin_panel.dart, hapus baris
    //    "_bottomNav()," di atas dan method ini.
    const items = [
      (Icons.home_outlined, 'Beranda'),
      (Icons.bar_chart_outlined, 'Laporan'),
      (Icons.menu_book_outlined, 'Artikel'),
      (Icons.settings_outlined, 'Pengaturan'),
    ];
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: _garis))),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: List.generate(items.length, (i) {
              final (ikon, label) = items[i];
              final aktif = i == 1;
              return Expanded(
                child: InkWell(
                  onTap: () => widget.onNavTap?.call(i),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(ikon,
                          size: 24, color: aktif ? _coklat : _abu),
                      const SizedBox(height: 2),
                      Text(label,
                          style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: aktif
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: aktif ? _coklat : _abu)),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  String _labelTab(TabLaporan t) => switch (t) {
        TabLaporan.pengguna => 'Pengguna',
        TabLaporan.artikel => 'Artikel',
        TabLaporan.layanan => 'Layanan',
      };

  String _judulKartu(TabLaporan t) => switch (t) {
        TabLaporan.pengguna => 'Jumlah Pengguna',
        TabLaporan.artikel => 'Jumlah Artikel',
        TabLaporan.layanan => 'Jumlah Layanan',
      };
}

// ==================== GRAFIK GARIS (tanpa package tambahan) ====================
class _GrafikGaris extends StatelessWidget {
  final List<_TitikGrafik> titik;
  const _GrafikGaris({required this.titik});

  @override
  Widget build(BuildContext context) {
    if (titik.isEmpty) {
      return Center(
          child: Text('Tidak ada data pada periode ini',
              style: GoogleFonts.poppins(fontSize: 12, color: _abu)));
    }
    return CustomPaint(
        painter: _GrafikPainter(titik: titik), size: Size.infinite);
  }
}

class _GrafikPainter extends CustomPainter {
  final List<_TitikGrafik> titik;
  _GrafikPainter({required this.titik});

  @override
  void paint(Canvas canvas, Size size) {
    const padKiri = 42.0, padKanan = 10.0, padAtas = 10.0, padBawah = 24.0;
    final kiri = padKiri;
    final kanan = size.width - padKanan;
    final bawah = size.height - padBawah;
    final lebar = kanan - kiri;
    final tinggi = bawah - padAtas;

    final nilaiMax =
        titik.map((t) => t.nilai).fold<int>(0, (a, b) => a > b ? a : b);
    double sumbuMax, langkah;
    if (nilaiMax <= 0) {
      sumbuMax = 4;
      langkah = 1;
    } else {
      langkah = _langkahNice(nilaiMax / 3);
      sumbuMax = (nilaiMax / langkah).ceilToDouble() * langkah;
    }

    double yDari(double v) => bawah - (v / sumbuMax) * tinggi;

    final catGaris = Paint()
      ..color = _garis
      ..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) {
      final v = langkah * i;
      if (v > sumbuMax) break;
      final yy = yDari(v);
      canvas.drawLine(Offset(kiri, yy), Offset(kanan, yy), catGaris);
      _gambarTeks(canvas, _formatAngka(v.round()),
          Offset(kiri - 6, yy - 6),
          kananRata: true);
    }

    final posisi = <Offset>[];
    for (var i = 0; i < titik.length; i++) {
      final xx = titik.length == 1
          ? kiri + lebar / 2
          : kiri + lebar * i / (titik.length - 1);
      posisi.add(Offset(xx, yDari(titik[i].nilai.toDouble())));
    }

    if (posisi.length > 1) {
      final garis = Paint()
        ..color = _coklat
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      final path = Path()..moveTo(posisi.first.dx, posisi.first.dy);
      for (var i = 1; i < posisi.length; i++) {
        path.lineTo(posisi[i].dx, posisi[i].dy);
      }
      canvas.drawPath(path, garis);
    }

    final jarak = ((posisi.length / 7).ceil()).clamp(1, 1000000).toInt();
    final isi = Paint()..color = Colors.white;
    final tepi = Paint()
      ..color = _coklat
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < posisi.length; i++) {
      if (i % jarak != 0 && i != posisi.length - 1) continue;
      canvas.drawCircle(posisi[i], 4, isi);
      canvas.drawCircle(posisi[i], 4, tepi);
    }

    final n = titik.length;
    final indeks = <int>{0, n - 1};
    if (n > 4) {
      indeks..add(n ~/ 4)..add(n ~/ 2)..add((n * 3) ~/ 4);
    }
    for (final i in indeks) {
      _gambarTeks(canvas, _fmtPendek(titik[i].tanggal),
          Offset(posisi[i].dx, bawah + 6),
          tengah: true);
    }
  }

  double _langkahNice(double mentah) {
    if (mentah <= 0) return 1;
    final eksponen = (log(mentah) / ln10).floor();
    final f = mentah / pow(10, eksponen);
    var nice = 10.0;
    if (f <= 1) {
      nice = 1;
    } else if (f <= 2) {
      nice = 2;
    } else if (f <= 5) {
      nice = 5;
    }
    return nice * pow(10, eksponen).toDouble();
  }

  void _gambarTeks(Canvas canvas, String teks, Offset pos,
      {bool kananRata = false, bool tengah = false}) {
    final tp = TextPainter(
      text: TextSpan(
          text: teks,
          style: GoogleFonts.poppins(fontSize: 10, color: _abu)),
      textDirection: TextDirection.ltr,
    )..layout();
    var dx = pos.dx;
    if (kananRata) dx -= tp.width;
    if (tengah) dx -= tp.width / 2;
    tp.paint(canvas, Offset(dx, pos.dy));
  }

  @override
  bool shouldRepaint(covariant _GrafikPainter old) => old.titik != titik;
}