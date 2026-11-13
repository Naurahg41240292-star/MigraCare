import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dokter_detail_pasien.dart';

/// ==========================================================================
///  MIGRACARE — Chat Pasien ↔ Dokter (berbasis Booking, realtime Firestore)
///  - ✅ [REVISI DOSEN] Durasi sesi ikut pilihan dokter (15 / 30 / 60 menit)
///  - ✅ [REVISI DOSEN] Sesi chat TERIKAT SLOT BOOKING:
///        mulai  = jam booking
///        berakhir = jam booking + durasi
///    Di luar window itu chat TERKUNCI:
///      • sebelum jam booking -> layar "Chat Belum Dibuka" + hitung mundur
///      • setelah sesi lewat  -> ditendang keluar (tidak bisa chat lagi)
///      • status 'ditolak' / 'menunggu' -> ditendang keluar
///    Field chatDimulaiPada tetap ditulis sebagai penanda, tapi tidak
///    lagi menentukan akhir sesi.
///  - Dokter bisa kirim pesan REKOMENDASI (tampil khusus)
///  - Titik tiga kanan atas -> Detail Pasien (khusus dokter)
///  File: lib/screens/dokter/chat_booking.dart
///  ✅ Mandiri: warna internal (_Cb) — tidak bergantung theme.dart
/// ==========================================================================

abstract class _Cb {
  static const Color bg = Color(0xFFFAF4EA);
  static const Color card = Colors.white;
  static const Color userBubble = Color(0xFFC9822E);
  static const Color primary = Color(0xFF6B4A2B);
  static const Color accentDark = Color(0xFFB07E1F);
  static const Color accent = Color(0xFFF2C230);
  static const Color textDark = Color(0xFF33261A);
  static const Color textGrey = Color(0xFF9C948A);
  static const Color textFaint = Color(0xFFB9B2A8);
  static const Color textSoft = Color(0xFF9C948A);
  static const Color online = Color(0xFF5BA97C);
  static const Color divider = Color(0xFFEDE3D4);

  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 3)),
  ];
  static const List<BoxShadow> buttonShadow = [
    BoxShadow(color: Color(0x3B6B4A2B), blurRadius: 10, offset: Offset(0, 5)),
  ];
}

// ===========================================================================
//  UTILITAS WAKTU BOOKING (mandiri, sama logikanya dengan beranda dokter)
//  Mendukung: "5/11/2026", "5 November 2026", "2026-11-05", "05.11.2026",
//  jam "08:30", "8.30", "08:30 WIB", dsb.
// ===========================================================================

const Map<String, int> _namaBulan = {
  'januari': 1, 'februari': 2, 'maret': 3, 'april': 4, 'mei': 5, 'juni': 6,
  'juli': 7, 'agustus': 8, 'september': 9, 'oktober': 10, 'november': 11,
  'desember': 12,
  'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'jun': 6, 'jul': 7, 'agu': 8,
  'ags': 8, 'sep': 9, 'okt': 10, 'nov': 11, 'des': 12,
  'january': 1, 'february': 2, 'march': 3, 'may': 5, 'june': 6, 'july': 7,
  'august': 8, 'sept': 9, 'october': 10, 'december': 12,
};

DateTime? _parseWaktuBooking(String tanggal, String jam) {
  // ---------------- jam ----------------
  int hh = 0, mm = 0;
  final mJam = RegExp(r'(\d{1,2})\s*[:.]\s*(\d{1,2})').firstMatch(jam.trim());
  if (mJam != null) {
    final h = int.tryParse(mJam.group(1)!) ?? 0;
    final mnt = int.tryParse(mJam.group(2)!) ?? 0;
    if (h <= 23 && mnt <= 59) {
      hh = h;
      mm = mnt;
    }
  } else {
    final mBulat = RegExp(r'^(\d{1,2})$').firstMatch(jam.trim());
    if (mBulat != null) {
      final h = int.tryParse(mBulat.group(1)!) ?? 0;
      if (h <= 23) hh = h;
    }
  }

  // ---------------- tanggal ----------------
  var t = tanggal.trim().toLowerCase();
  t = t.replaceFirst(
    RegExp(r'^(minggu|senin|selasa|rabu|kamis|jumat|jum.?at|sabtu)\s*,\s*'),
    '',
  );

  int? thn, bln, tgl;
  RegExpMatch? m;

  // 1) ISO: 2026-11-05
  m = RegExp(r'^(\d{4})[-/.](\d{1,2})[-/.](\d{1,2})$').firstMatch(t);
  if (m != null) {
    thn = int.tryParse(m.group(1)!);
    bln = int.tryParse(m.group(2)!);
    tgl = int.tryParse(m.group(3)!);
  }

  // 2) d/m/yyyy (hari dulu, gaya Indonesia)
  if (thn == null) {
    m = RegExp(r'^(\d{1,2})[-/.](\d{1,2})[-/.](\d{2,4})$').firstMatch(t);
    if (m != null) {
      tgl = int.tryParse(m.group(1)!);
      bln = int.tryParse(m.group(2)!);
      thn = int.tryParse(m.group(3)!);
      if (thn != null && thn < 100) thn += 2000;
    }
  }

  // 3) "5 november 2026" / "5 nov 2026"
  if (thn == null) {
    m = RegExp(r'^(\d{1,2})\s+([a-z]+)\.?\s+(\d{4})$').firstMatch(t);
    if (m != null) {
      tgl = int.tryParse(m.group(1)!);
      bln = _namaBulan[m.group(2)!];
      thn = int.tryParse(m.group(3)!);
    }
  }

  // 4) "november 5, 2026"
  if (thn == null) {
    m = RegExp(r'^([a-z]+)\.?\s+(\d{1,2})\s*,?\s*(\d{4})$').firstMatch(t);
    if (m != null) {
      bln = _namaBulan[m.group(1)!];
      tgl = int.tryParse(m.group(2)!);
      thn = int.tryParse(m.group(3)!);
    }
  }

  if (thn == null || bln == null || tgl == null) return null;
  if (bln < 1 || bln > 12 || tgl < 1 || tgl > 31) return null;

  return DateTime(thn, bln, tgl, hh, mm);
}

int _durasiDariMap(Map<String, dynamic> b) {
  final v = b['durasiMenit'] ?? b['durasi'];
  if (v is int && v > 0) return v;
  if (v is num && v > 0) return v.round();
  if (v is String) {
    final n = int.tryParse(v.trim());
    if (n != null && n > 0) return n;
  }
  return 30;
}

String _labelDurasi(int menit) {
  if (menit >= 60 && menit % 60 == 0) {
    final j = menit ~/ 60;
    return j == 1 ? '1 jam' : '$j jam';
  }
  return '$menit menit';
}

class ChatBookingPage extends StatefulWidget {
  const ChatBookingPage({
    super.key,
    required this.bookingId,
    required this.booking,
    required this.sayaDokter,
  });

  final String bookingId;
  final Map<String, dynamic> booking;
  final bool sayaDokter;

  @override
  State<ChatBookingPage> createState() => _ChatBookingPageState();
}

class _ChatBookingPageState extends State<ChatBookingPage> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  // ✅ [REVISI DOSEN] durasi sesi ikut pilihan dokter saat booking
  int _durasiMenit = 30;

  Timer? _ticker;
  int _sisaDetik = -1;
  bool _sudahDialogBerakhir = false;

  // 🔒 Gerbang jadwal: true = belum jam booking, chat terkunci
  bool _gerbangTutup = false;
  Timer? _gerbangTicker;

  // 🔒 Kalau tidak null -> halaman ditendang keluar dengan alasan ini
  String? _alasanTerkunci;

  FirebaseFirestore get _db => FirebaseFirestore.instance;
  DocumentReference<Map<String, dynamic>> get _bookingRef =>
      _db.collection('booking').doc(widget.bookingId);
  CollectionReference<Map<String, dynamic>> get _pesanRef =>
      _bookingRef.collection('pesan');

  String get _namaSaya => widget.sayaDokter
      ? (widget.booking['dokterNama'] ?? 'Dokter')
      : (widget.booking['pasienNama'] ?? 'Pasien');
  String get _namaLawan => widget.sayaDokter
      ? (widget.booking['pasienNama'] ?? 'Pasien')
      : (widget.booking['dokterNama'] ?? 'Dokter');
  String get _peranSaya => widget.sayaDokter ? 'dokter' : 'pasien';

  // 🔒 Waktu mulai sesi = jam booking (tanggal + jam dari data booking)
  DateTime? get _waktuBooking => _parseWaktuBooking(
        (widget.booking['tanggal'] ?? '').toString(),
        (widget.booking['jam'] ?? '').toString(),
      );

  // 🔒 Akhir sesi = jam booking + durasi (terikat slot, bukan saat dibuka)
  DateTime? get _akhirSesi {
    final wb = _waktuBooking;
    if (wb == null) return null;
    final jamTercatat = RegExp(r'\d')
        .hasMatch((widget.booking['jam'] ?? '').toString().trim());
    return jamTercatat
        ? wb.add(Duration(minutes: _durasiMenit))
        : DateTime(wb.year, wb.month, wb.day, 23, 59, 59);
  }

  /// Countdown "terbuka dalam" (HH:MM:SS)
  String get _hitungMundur {
    final wb = _waktuBooking;
    if (wb == null) return '--:--:--';
    var sisa = wb.difference(DateTime.now()).inSeconds;
    if (sisa < 0) sisa = 0;
    String dua(int v) => v.toString().padLeft(2, '0');
    return '${dua(sisa ~/ 3600)}:${dua((sisa % 3600) ~/ 60)}:${dua(sisa % 60)}';
  }

  // =========================================================================
  //  GERBANG AKSES — dipanggil sekali di initState
  // =========================================================================
  void _evaluasiAkses() {
    _durasiMenit = _durasiDariMap(widget.booking);
    final statusRaw = widget.booking['status'];
    final status = statusRaw == null ? '' : statusRaw.toString();

    // status jelas ditolak / belum dikonfirmasi -> langsung tendang
    if (status == 'ditolak') {
      _alasanTerkunci = 'Booking ini telah ditolak — chat tidak tersedia.';
    } else if (status == 'menunggu') {
      _alasanTerkunci = 'Booking belum dikonfirmasi dokter.';
    }

    // cek window waktu (untuk semua status, kecuali yang sudah ditendang di atas)
    if (_alasanTerkunci == null) {
      final wb = _waktuBooking;
      if (wb != null) {
        final sekarang = DateTime.now();
        if (sekarang.isBefore(wb)) {
          _gerbangTutup = true; // belum mulai -> layar hitung mundur
        } else {
          final akhir = _akhirSesi;
          if (akhir != null && sekarang.isAfter(akhir)) {
            _alasanTerkunci =
                'Jadwal konsultasi sudah lewat — sesi chat berakhir.';
          }
        }
      }
    }

    if (_alasanTerkunci != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _tendangKeluar());
      return;
    }

    if (_gerbangTutup) {
      // belum jam booking → pantau tiap detik, begitu tepat waktu buka chat
      _gerbangTicker = Timer.periodic(const Duration(seconds: 1), (_) {
        final w = _waktuBooking;
        if (w == null || !DateTime.now().isBefore(w)) {
          _gerbangTicker?.cancel();
          if (mounted) {
            setState(() => _gerbangTutup = false);
            _mulaiSesi(); // baru sekarang sesi berjalan
          }
        }
      });
    } else {
      _mulaiSesi();
    }
  }

  // =========================================================================
  //  CEK LIVE: status terbaru dari Firestore (map bisa saja basi)
  // =========================================================================
  Future<void> _verifikasiBookingLive() async {
    try {
      final doc = await _bookingRef.get();
      final data = doc.data();
      if (data == null || !mounted) return;

      // update durasi kalau ada di firestore
      final v = data['durasiMenit'] ?? data['durasi'];
      int? d;
      if (v is num && v > 0) d = v.round();
      if (v is String) d = int.tryParse(v.trim());
      if (d != null && d > 0 && d != _durasiMenit) {
        setState(() => _durasiMenit = d!);
      }

      final statusLive =
          (data['status'] ?? widget.booking['status'] ?? 'menunggu')
              .toString();
      if (statusLive != 'dikonfirmasi') {
        _alasanTerkunci = statusLive == 'ditolak'
            ? 'Booking ini telah ditolak — chat tidak tersedia.'
            : 'Booking belum dikonfirmasi dokter.';
        _tendangKeluar();
      }
    } catch (_) {
      // gagal baca (offline dsb) -> biarkan pakai data map
    }
  }

  /// Tendang keluar + snackbar alasan (tampil di halaman sebelumnya)
  void _tendangKeluar() {
    if (!mounted) return;
    final alasan = _alasanTerkunci ?? 'Sesi konsultasi tidak tersedia.';
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).maybePop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(alasan),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF3D2B1A),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // =========================================================================
  //  SESI BERJALAN
  // =========================================================================
  Future<void> _mulaiSesi() async {
    // penanda chat pernah dibuka (tidak menentukan akhir sesi)
    try {
      final doc = await _bookingRef.get();
      if (doc.data()?['chatDimulaiPada'] == null) {
        await _bookingRef
            .update({'chatDimulaiPada': FieldValue.serverTimestamp()});
      }
    } catch (_) {}

    _hitungSisa();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _hitungSisa();
    });
  }

  void _hitungSisa() {
    final akhir = _akhirSesi;
    if (akhir == null) {
      if (_sisaDetik != -1) setState(() => _sisaDetik = -1);
      return;
    }
    final sisa = akhir.difference(DateTime.now()).inSeconds;
    final baru = sisa < 0 ? 0 : sisa;
    if (baru != _sisaDetik) setState(() => _sisaDetik = baru);
    if (baru == 0 && !_sudahDialogBerakhir) {
      _sudahDialogBerakhir = true;
      _showDialogBerakhir();
    }
  }

  void _showDialogBerakhir() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.hourglass_bottom_rounded,
                size: 22, color: _Cb.accentDark),
            SizedBox(width: 8),
            Text('Sesi Berakhir',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _Cb.textDark)),
          ],
        ),
        content: Text(
          'Waktu konsultasi ${_labelDurasi(_durasiMenit)} sudah habis. '
          'Chat ditutup otomatis sesuai jadwal booking.',
          style: const TextStyle(
              fontSize: 13, height: 1.5, color: _Cb.textGrey),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: _Cb.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Mengerti',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------

  String get _formatSisa {
    if (_sisaDetik < 0) return '--:--';
    final m = (_sisaDetik ~/ 60).toString().padLeft(2, '0');
    final s = (_sisaDetik % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  bool get _sesiHabis => _sisaDetik == 0;

  Future<void> _kirimPesan(String teks, String tipe) async {
    if (teks.trim().isEmpty) return;
    await _pesanRef.add({
      'dari': _peranSaya,
      'namaPengirim': _namaSaya,
      'tipe': tipe,
      'teks': teks.trim(),
      'waktu': FieldValue.serverTimestamp(),
    });
    _scrollKeBawah();
  }

  void _kirimDariInput() {
    final teks = _controller.text.trim();
    if (teks.isEmpty) return;
    _controller.clear();
    _kirimPesan(teks, 'teks');
  }

  Future<void> _kirimRekomendasi() async {
    final teksCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Kirim Rekomendasi',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _Cb.textDark)),
        content: TextField(
          controller: teksCtrl,
          maxLines: 5,
          style: const TextStyle(fontSize: 13, color: _Cb.textDark),
          decoration: InputDecoration(
            hintText: 'Tulis rekomendasi / tindakan untuk pasien...',
            hintStyle:
                const TextStyle(fontSize: 12.5, color: _Cb.textFaint),
            filled: true,
            fillColor: _Cb.bg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: _Cb.textFaint)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _Cb.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child:
                const Text('Kirim', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _kirimPesan(teksCtrl.text.trim(), 'rekomendasi');
    }
  }

  void _scrollKeBawah() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut);
      }
    });
  }

  void _bukaDetailPasien() {
    final uid = widget.booking['pasienUid']?.toString() ?? '';
    if (uid.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Data pasien tidak ditemukan di booking ini.')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailPasienView(
          pasienUid: uid,
          pasienNama: _namaLawan,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _evaluasiAkses();          // gerbang cepat dari data map
    _verifikasiBookingLive();  // konfirmasi status terbaru dari Firestore
  }

  @override
  void dispose() {
    _gerbangTicker?.cancel();
    _ticker?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Cb.bg,
      appBar: AppBar(
        backgroundColor: _Cb.bg,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: _Cb.textDark),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_namaLawan,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: _Cb.textDark)),
            Text(
              _gerbangTutup
                  ? 'Chat dibuka saat jadwal booking'
                  : _sesiHabis
                      ? 'Sesi ${_labelDurasi(_durasiMenit)} berakhir'
                      : (_sisaDetik < 0
                          ? 'Sesi konsultasi berjalan'
                          : 'Sesi: $_formatSisa tersisa'),
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _gerbangTutup
                      ? _Cb.textGrey
                      : _sesiHabis
                          ? _Cb.textFaint
                          : _Cb.online),
            ),
          ],
        ),
        actions: [
          if (widget.sayaDokter)
            IconButton(
              onPressed: _bukaDetailPasien,
              tooltip: 'Detail Pasien',
              icon: const Icon(Icons.more_vert_rounded, color: _Cb.textDark),
            ),
        ],
      ),
      body: _gerbangTutup
          ? _gerbangTutupView()
          : Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _pesanRef
                        .orderBy('waktu', descending: true)
                        .limit(100)
                        .snapshots(),
                    builder: (context, snap) {
                      if (snap.hasError) {
                        return const Center(child: Text('Gagal memuat pesan.'));
                      }
                      if (!snap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final docs = snap.data!.docs;
                      return ListView.builder(
                        reverse: true,
                        controller: _scroll,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        itemCount: docs.length,
                        itemBuilder: (_, i) {
                          final data = docs[i].data();
                          final dariSaya = data['dari'] == _peranSaya;
                          final tipe = (data['tipe'] ?? 'teks') as String;
                          final teks = (data['teks'] ?? '') as String;
                          final waktu = data['waktu'] is Timestamp
                              ? (data['waktu'] as Timestamp).toDate()
                              : DateTime.now();
                          return _gelembungPesan(
                            teks: teks,
                            dariSaya: dariSaya,
                            waktu: waktu,
                            rekomendasi: tipe == 'rekomendasi',
                          );
                        },
                      );
                    },
                  ),
                ),
                _barInput(),
              ],
            ),
    );
  }

  // 🔒 Layar terkunci: chat belum boleh dimulai sebelum jam booking
  Widget _gerbangTutupView() {
    final hari = (widget.booking['hari'] ?? '').toString();
    final tanggal = (widget.booking['tanggal'] ?? '').toString();
    final jam = (widget.booking['jam'] ?? '').toString();
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                  color: Color(0xFFFDF3D7), shape: BoxShape.circle),
              child: const Icon(Icons.lock_clock_rounded,
                  size: 40, color: _Cb.accentDark),
            ),
            const SizedBox(height: 18),
            const Text('Chat Belum Dibuka',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: _Cb.textDark)),
            const SizedBox(height: 8),
            Text(
              'Sesi chat dengan $_namaLawan baru bisa dimulai\nsesuai jadwal booking ya 😊',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 12.5, height: 1.5, color: _Cb.textGrey),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _Cb.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _Cb.divider),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.event_available_rounded,
                          size: 16, color: _Cb.primary),
                      const SizedBox(width: 6),
                      Text('$hari, $tanggal',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _Cb.textDark)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // ✅ [REVISI DOSEN] tampilin durasi sesi juga
                  Text('Pukul $jam • ${_labelDurasi(_durasiMenit)}',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _Cb.primary)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Terbuka dalam',
                style: TextStyle(fontSize: 11.5, color: _Cb.textGrey)),
            const SizedBox(height: 4),
            Text(_hitungMundur,
                style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: _Cb.primary)),
            const SizedBox(height: 14),
            const Text(
              'Halaman ini boleh dibuka duluan —\nchat otomatis aktif tepat pada jam booking ✨',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.5, height: 1.5, color: _Cb.textFaint),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gelembungPesan({
    required String teks,
    required bool dariSaya,
    required DateTime waktu,
    bool rekomendasi = false,
  }) {
    final jam =
        '${waktu.hour.toString().padLeft(2, '0')}:${waktu.minute.toString().padLeft(2, '0')}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: dariSaya ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!dariSaya) ...[
            const CircleAvatar(
              radius: 14,
              backgroundColor: Color(0xFFF6DFC8),
              child: Icon(Icons.person_rounded, size: 16, color: Color(0xFFC9822E)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * .78),
              decoration: BoxDecoration(
                color: rekomendasi
                    ? const Color(0xFFFDF3D7)
                    : (dariSaya ? _Cb.userBubble : _Cb.card),
                border: rekomendasi
                    ? Border.all(color: _Cb.accentDark, width: 1.2)
                    : null,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(dariSaya ? 16 : 4),
                  bottomRight: Radius.circular(dariSaya ? 4 : 16),
                ),
                boxShadow: dariSaya ? null : _Cb.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (rekomendasi)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.medical_services_rounded,
                              size: 13, color: _Cb.accentDark),
                          SizedBox(width: 4),
                          Text('Rekomendasi Dokter',
                              style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: _Cb.accentDark)),
                        ],
                      ),
                    ),
                  Text(teks,
                      style: const TextStyle(
                          fontSize: 13.5,
                          height: 1.45,
                          color: _Cb.textDark)),
                  const SizedBox(height: 3),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (dariSaya) ...[
                        const Icon(Icons.done_all_rounded,
                            size: 12, color: Color(0xFF7FB08A)),
                        const SizedBox(width: 3),
                      ],
                      Text(jam,
                          style: TextStyle(
                              fontSize: 10.5,
                              color: dariSaya
                                  ? const Color(0xFFA9885B)
                                  : _Cb.textFaint)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _barInput() {
    final mati = _sesiHabis;
    final bisaKirim = _controller.text.trim().isNotEmpty && !mati;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: const BoxDecoration(
        color: _Cb.bg,
        border: Border(top: BorderSide(color: _Cb.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (widget.sayaDokter) ...[
              _TombolIkonBulat(
                icon: Icons.medical_services_rounded,
                onTap: mati ? null : _kirimRekomendasi,
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                constraints: const BoxConstraints(minHeight: 42),
                decoration: BoxDecoration(
                  color: _Cb.card,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: _Cb.cardShadow,
                ),
                child: TextField(
                  controller: _controller,
                  onChanged: (_) => setState(() {}),
                  enabled: !mati,
                  minLines: 1,
                  maxLines: 4,
                  cursorColor: _Cb.primary,
                  style: const TextStyle(fontSize: 13.5, color: _Cb.textDark),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    hintText: mati
                        ? 'Sesi ${_labelDurasi(_durasiMenit)} telah berakhir'
                        : 'Ketik pesan...',
                    hintStyle:
                        const TextStyle(fontSize: 13.5, color: _Cb.textFaint),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: bisaKirim ? _kirimDariInput : null,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: bisaKirim ? _Cb.primary : const Color(0xFFE4D9C6),
                  shape: BoxShape.circle,
                  boxShadow: bisaKirim ? _Cb.buttonShadow : null,
                ),
                child: const Icon(Icons.send_rounded, size: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TombolIkonBulat extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _TombolIkonBulat({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration:
            const BoxDecoration(color: _Cb.card, shape: BoxShape.circle),
        child: Icon(icon, size: 20, color: _Cb.textSoft),
      ),
    );
  }
}