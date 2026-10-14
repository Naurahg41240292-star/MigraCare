import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// ==========================================================================
///  MIGRACARE — Chat Pasien ↔ Dokter (berbasis Booking, realtime Firestore)
///  - Timer 30 menit (revisi #2): dimulai saat chat pertama dibuka
///  - Dokter bisa kirim pesan REKOMENDASI (tampil khusus)
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

  static const int durasiMenit = 30;

  Timer? _ticker;
  int _sisaDetik = -1;

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

  @override
  void initState() {
    super.initState();
    _initChatMulai();
  }

  Future<void> _initChatMulai() async {
    try {
      final doc = await _bookingRef.get();
      if (doc.data()?['chatDimulaiPada'] == null) {
        await _bookingRef
            .update({'chatDimulaiPada': FieldValue.serverTimestamp()});
      }
    } catch (_) {}
    _mulaiTicker();
  }

  void _mulaiTicker() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) async {
      try {
        final doc = await _bookingRef.get();
        final mulai = doc.data()?['chatDimulaiPada'];
        if (mulai is! Timestamp || !mounted) return;
        final habis = mulai.toDate().add(const Duration(minutes: durasiMenit));
        final sisa = habis.difference(DateTime.now()).inSeconds;
        setState(() => _sisaDetik = sisa < 0 ? 0 : sisa);
      } catch (_) {}
    });
  }

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

  @override
  void dispose() {
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
              _sesiHabis
                  ? 'Sesi 30 menit berakhir'
                  : 'Sesi: $_formatSisa tersisa',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _sesiHabis ? _Cb.textFaint : _Cb.online),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _pesanRef.orderBy('waktu', descending: true).limit(100).snapshots(),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        ? 'Sesi 30 menit telah berakhir'
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