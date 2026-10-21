import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_booking.dart';

abstract class _Dp {
  static const Color bg = Color(0xFFFAF4EA);
  static const Color textDark = Color(0xFF33261A);
  static const Color textGrey = Color(0xFF9C948A);
  static const Color outline = Color(0xFFE5DCCB);
  static const Color gold = Color(0xFFC9822E);
  static const Color goldSoft = Color(0xFFFDF3D7);
}

/// Halaman Detail Pasien — Ringkasan / Riwayat Skrining / Riwayat Chat
class DetailPasienView extends StatefulWidget {
  const DetailPasienView({super.key, required this.pasienUid, this.pasienNama});

  final String pasienUid;
  final String? pasienNama;

  @override
  State<DetailPasienView> createState() => _DetailPasienViewState();
}

class _DetailPasienViewState extends State<DetailPasienView>
    with TickerProviderStateMixin {
  late final TabController _tab = TabController(length: 3, vsync: this);

  bool _loading = true;
  String _nama = '-';
  String _email = '-';
  String _lahir = '-';
  String _umur = '-';
  String _gender = '-';
  String _telepon = '-';
  String _alergi = '-';
  String _komorbid = '-';
  String _obat = '-';
  List<Map<String, dynamic>> _skrining = [];
  List<Map<String, dynamic>> _chat = [];

  @override
  void initState() {
    super.initState();
    _nama = (widget.pasienNama == null || widget.pasienNama!.isEmpty)
        ? '-'
        : widget.pasienNama!;
    _muat();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  String _s(dynamic v, String fallback) =>
      (v == null || v.toString().trim().isEmpty) ? fallback : v.toString();

  String _umurDari(dynamic lahir) {
    DateTime? t;
    if (lahir is Timestamp) t = lahir.toDate();
    if (lahir is String) t = DateTime.tryParse(lahir);
    if (t == null) return '-';
    final now = DateTime.now();
    int umur = now.year - t.year;
    if (now.month < t.month || (now.month == t.month && now.day < t.day)) {
      umur--;
    }
    return umur < 0 ? '-' : '$umur tahun';
  }

  String _fmtTanggal(DateTime t) =>
      '${t.day.toString().padLeft(2, '0')}/${t.month.toString().padLeft(2, '0')}/${t.year}';

  Future<void> _muat() async {
    setState(() => _loading = true);
    try {
      final uidDokter = FirebaseAuth.instance.currentUser?.uid ?? '';

      // ---------- data profil pasien ----------
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.pasienUid)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        final profile = data['profile'];
        final akun = data['akun'];
        if (profile is Map) {
          _nama = _s(profile['namaLengkap'], _nama);
          _gender = _s(profile['jenisKelamin'], '-');
          _telepon = _s(profile['telepon'], '-');
          _alergi = _s(profile['alergi'], '-');
          _komorbid = _s(profile['komorbid'], '-');
          _obat = _s(profile['obatRutin'], '-');
          final lahir = profile['tanggalLahir'];
          _umur = _umurDari(lahir);
          if (lahir is Timestamp) {
            _lahir = _fmtTanggal(lahir.toDate());
          } else if (lahir is String && lahir.trim().isNotEmpty) {
            _lahir = lahir;
          }
        }
        if (akun is Map) {
          _email = _s(akun['email'], '-');
        }
      }

      // ---------- riwayat skrining (sub-koleksi users/{uid}/screenings) ----------
      List<Map<String, dynamic>> skrining = [];
      try {
        final sSnap = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.pasienUid)
            .collection('screenings')
            .orderBy('waktu', descending: true)
            .get();
        skrining = sSnap.docs.map((d) {
          final data = d.data();
          final waktu = data['waktu'];
          final skor = data['skor'] ?? data['nilai'];
          return {
            'id': d.id,
            'hasil': _s(data['hasil'], '-'),
            'skor': skor == null ? null : skor.toString(),
            'waktu':
                waktu is Timestamp ? _fmtTanggal(waktu.toDate()) : '-',
          };
        }).toList();
      } catch (_) {
        skrining = [];
      }

      // ---------- riwayat chat (booking dikonfirmasi) ----------
      List<Map<String, dynamic>> chat = [];
      final bSnap = await FirebaseFirestore.instance
          .collection('booking')
          .where('pasienUid', isEqualTo: widget.pasienUid)
          .where('status', isEqualTo: 'dikonfirmasi')
          .get();
      final bDocs = bSnap.docs.toList();
      if (uidDokter.isNotEmpty) {
        bDocs.retainWhere((d) => d.data()['dokterUid'] == uidDokter);
      }
      bDocs.sort((a, b) {
        final ta = a.data()['dibuatPada'];
        final tb = b.data()['dibuatPada'];
        final da = ta is Timestamp ? ta.millisecondsSinceEpoch : 0;
        final db = tb is Timestamp ? tb.millisecondsSinceEpoch : 0;
        return db.compareTo(da);
      });
      chat = bDocs.map((d) {
        final data = d.data();
        return {
          'id': d.id,
          'pasienUid': widget.pasienUid,
          'pasienNama': _s(data['pasienNama'], _nama),
          'hari': _s(data['hari'], '-'),
          'tanggal': _s(data['tanggal'], ''),
          'jam': _s(data['jam'], '-'),
          'status': _s(data['status'], 'dikonfirmasi'),
        };
      }).toList();

      if (!mounted) return;
      setState(() {
        _skrining = skrining;
        _chat = chat;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memuat data pasien: $e')));
      }
    }
  }

  void _hubungiPasien() {
    if (_chat.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Belum ada booking terkonfirmasi dengan pasien ini. Chat terbuka setelah booking dikonfirmasi.')));
      return;
    }
    _bukaChat(_chat.first);
  }

  Future<void> _bukaChat(Map<String, dynamic> b) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatBookingPage(
          bookingId: b['id'],
          booking: b,
          sayaDokter: true,
        ),
      ),
    );
    _muat();
  }

  Widget _baris(String label, String nilai) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12.5, color: _Dp.textGrey)),
          ),
          Expanded(
            child: Text(nilai,
                style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: _Dp.textDark)),
          ),
        ],
      ),
    );
  }

  Widget _kartu(String judul, List<Widget> isi) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _Dp.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(judul,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _Dp.textDark)),
          const SizedBox(height: 12),
          ...isi,
        ],
      ),
    );
  }

  Widget _tabRingkasan() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        _kartu('Informasi Pribadi', [
          _baris('Nama Lengkap', _nama),
          _baris('Tanggal Lahir', _lahir == '-' ? '-' : '$_lahir ($_umur)'),
          _baris('Jenis Kelamin', _gender),
          _baris('No. Telepon', _telepon),
          _baris('Email', _email),
        ]),
        const SizedBox(height: 16),
        _kartu('Riwayat Kesehatan', [
          _baris('Alergi', _alergi),
          _baris('Komorbid', _komorbid),
          _baris('Obat Rutin', _obat),
        ]),
      ],
    );
  }

  Widget _tabSkrining() {
    if (_skrining.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _Dp.outline),
            ),
            child: const Text(
              'Belum ada riwayat skrining dari pasien ini.',
              style: TextStyle(fontSize: 12.5, color: _Dp.textGrey),
            ),
          ),
        ],
      );
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      itemCount: _skrining.length,
      itemBuilder: (context, i) {
        final s = _skrining[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _Dp.outline),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: _Dp.goldSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.psychology_alt_rounded,
                    size: 20, color: _Dp.gold),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s['hasil'] as String,
                        style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: _Dp.textDark)),
                    const SizedBox(height: 3),
                    Text(
                      'Skrining pada ${s['waktu']}'
                      '${s['skor'] == null ? '' : ' • Skor ${s['skor']}'}',
                      style: const TextStyle(
                          fontSize: 12, color: _Dp.textGrey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _tabChat() {
    if (_chat.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _Dp.outline),
            ),
            child: const Text(
              'Belum ada chat dengan pasien ini.\nChat terbuka setelah booking dikonfirmasi.',
              style: TextStyle(
                  fontSize: 12.5, height: 1.5, color: _Dp.textGrey),
            ),
          ),
        ],
      );
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      itemCount: _chat.length,
      itemBuilder: (context, i) {
        final b = _chat[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _Dp.outline),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${b['hari']}, ${b['tanggal']} • ${b['jam']}',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _Dp.textDark)),
                    const SizedBox(height: 3),
                    const Text('Booking dikonfirmasi',
                        style: TextStyle(
                            fontSize: 12, color: _Dp.textGrey)),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _bukaChat(b),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _Dp.gold,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.chat_rounded, size: 15),
                label: const Text('Chat',
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Dp.bg,
      appBar: AppBar(
        backgroundColor: _Dp.bg,
        elevation: 0,
        title: const Text('Detail Pasien',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: _Dp.textDark)),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _hubungiPasien,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _Dp.gold,
                    side: const BorderSide(color: _Dp.gold),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.chat_rounded, size: 18),
                  label: const Text('Hubungi Pasien',
                      style: TextStyle(
                          fontSize: 12.5, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _tab.animateTo(1),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _Dp.gold,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.description_rounded, size: 18),
                  label: const Text('Lihat Rekam Medis',
                      style: TextStyle(
                          fontSize: 12.5, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: _Dp.goldSoft,
                        child: Text(
                          _nama == '-' ? '?' : _nama[0].toUpperCase(),
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: _Dp.gold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_nama,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: _Dp.textDark)),
                            const SizedBox(height: 2),
                            Text(
                              _umur == '-'
                                  ? _gender
                                  : (_gender == '-'
                                      ? _umur
                                      : '$_umur • $_gender'),
                              style: const TextStyle(
                                  fontSize: 12.5, color: _Dp.textGrey),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE4F3E4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Pasien Aktif',
                            style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF3E7C3E))),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                TabBar(
                  controller: _tab,
                  labelColor: _Dp.gold,
                  unselectedLabelColor: _Dp.textGrey,
                  indicatorColor: _Dp.gold,
                  labelStyle: const TextStyle(
                      fontSize: 12.5, fontWeight: FontWeight.w700),
                  unselectedLabelStyle: const TextStyle(fontSize: 12.5),
                  tabs: const [
                    Tab(text: 'Ringkasan'),
                    Tab(text: 'Riwayat Skrining'),
                    Tab(text: 'Riwayat Chat'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tab,
                    children: [
                      _tabRingkasan(),
                      _tabSkrining(),
                      _tabChat(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}