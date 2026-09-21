import 'dart:math';

import 'package:flutter/material.dart';

import '../logic/migraine_bot.dart';
import '../models/dokter.dart';
import '../theme.dart';
import '../utils/rute.dart';
import '../utils/tanggal.dart';
import '../widgets/widget_konsultasi.dart';

class ChatKonsultasiScreen extends StatefulWidget {
  final Dokter dokter;

  const ChatKonsultasiScreen({super.key, required this.dokter});

  @override
  State<ChatKonsultasiScreen> createState() => _ChatKonsultasiScreenState();
}

class _Pesan {
  final String teks;
  final bool dariSaya;
  final DateTime waktu;

  const _Pesan(this.teks, this.dariSaya, this.waktu);
}

/// Item tampilan untuk ListView (pesan / tanggal / penanda sistem / mengetik).
class _Item {
  final _Pesan? pesan;
  final String? jenis; // 'tanggal' | 'sistem' | 'mengetik'

  const _Item.pesan(this.pesan) : jenis = null;
  const _Item.tanggal() : jenis = 'tanggal', pesan = null;
  const _Item.sistem() : jenis = 'sistem', pesan = null;
  const _Item.mengetik() : jenis = 'mengetik', pesan = null;
}

class _ChatKonsultasiScreenState extends State<ChatKonsultasiScreen> {
  final TextEditingController _controller = TextEditingController();
  final Random _acak = Random();

  late final List<_Pesan> _pesan = _pesanAwal();
  bool _sedangMengetik = false;
  bool _selesai = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Percakapan awal (demo topik migrain).
  List<_Pesan> _pesanAwal() {
    final now = DateTime.now();
    return [
      _Pesan(
        'Dok, sudah 3 hari ini kepala saya terasa berdenyut di satu sisi, '
            'kadang disertai mual ringan dan sensitif cahaya. Apakah ini migrain? '
            'Apakah berbahaya?',
        true, now.subtract(const Duration(minutes: 52)),
      ),
      _Pesan(
        'Halo, Ananda 👋\n'
            'Terima kasih sudah menghubungi. Nyeri berdenyut satu sisi yang disertai '
            'mual dan sensitif cahaya memang paling sering dijumpai pada migrain tanpa '
            'aura — umumnya tidak berbahaya, tapi cukup mengganggu aktivitas.\n\n'
            'Untuk sementara: istirahat di ruangan redup & tenang, minum air putih yang '
            'cukup, dan kurangi paparan layar HP dulu ya.\n\n'
            'Apakah nyerinya memburuk saat beraktivitas? Ada anggota keluarga yang juga migrain?',
        false, now.subtract(const Duration(minutes: 45)),
      ),
      _Pesan(
        'Iya dok, memburuk kalau gerak. Ibu saya juga sering migrain. '
            'Boleh minta rekomendasi buat mengurangi migrain?',
        true, now.subtract(const Duration(minutes: 38)),
      ),
      _Pesan(
        'Baik, saya catat ya. Rekomendasi untuk mengurangi migrain:\n\n'
            '1. Tidur 7–8 jam dengan jadwal konsisten.\n'
            '2. Minum air putih minimal 8 gelas/hari & jangan menunda makan.\n'
            '3. Kompres dingin di dahi/leher; istirahat di ruangan redup & sunyi.\n'
            '4. Hindari pemicu: stres, kafein & MSG berlebih, layar HP terlalu lama.\n'
            '5. Pernapasan dalam, yoga ringan, atau peregangan leher & bahu.\n'
            '6. Catat pemicu di fitur Skrining MigraCare sebagai diary migrain.\n\n'
            'Karena Ibu Anda juga migrain, risikonya memang lebih besar — pemicunya '
            'perlu lebih dijaga ya. Kalau nyeri semakin hebat, muntah terus, atau '
            'disertai demam/lemah satu sisi tubuh, segera periksa ke dokter. 😊',
        false, now.subtract(const Duration(minutes: 30)),
      ),
    ];
  }

  void _kirim() {
    final teks = _controller.text.trim();
    if (teks.isEmpty || _selesai) return;

    setState(() {
      _pesan.add(_Pesan(teks, true, DateTime.now()));
      _controller.clear();
      _sedangMengetik = true;
    });

    Future.delayed(Duration(milliseconds: 1400 + _acak.nextInt(900)), () {
      if (!mounted) return;
      setState(() {
        _sedangMengetik = false;
        _pesan.add(_Pesan(getBalasanDokter(teks), false, DateTime.now()));
      });
    });
  }

  Future<void> _onTapSelesai() async {
    final dikonfirmasi = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Selesaikan konsultasi?',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        content: Text(
          'Percakapan Anda dengan ${widget.dokter.nama} akan disimpan ke menu Riwayat MigraCare.',
          style: const TextStyle(fontSize: 13, height: 1.5, color: AppColors.textSoft),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Lanjut Chat',
                style: TextStyle(color: AppColors.textSoft, fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Selesaikan', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );

    if (dikonfirmasi != true || !mounted) return;

    setState(() {
      _selesai = true;
      _sedangMengetik = false;
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => _DialogRingkasan(
          namaDokter: widget.dokter.nama,
          tanggalLabel: Tanggal.lengkap(DateTime.now()),
          totalPesan: _pesan.length,
        ),
      );
    });
  }

  /// Urutan item untuk ListView (list dibalik: item pertama = paling bawah layar).
  List<_Item> get _itemTampilan => [
        if (_sedangMengetik) const _Item.mengetik(),
        if (_selesai) const _Item.sistem(),
        for (final p in _pesan.reversed) _Item.pesan(p),
        const _Item.tanggal(),
      ];

  @override
  Widget build(BuildContext context) {
    final items = _itemTampilan;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: ListView.builder(
                reverse: true,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: items.length,
                itemBuilder: (_, i) => _buatItem(items[i]),
              ),
            ),
            _barInput(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 12, 8),
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
          ),
          AvatarDokter(dokter: widget.dokter, size: 40),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.dokter.nama, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                const SizedBox(height: 2),
                const Row(children: [
                  _TitikOnline(),
                  SizedBox(width: 4),
                  Text('Online', style: TextStyle(
                      fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.online)),
                ]),
              ],
            ),
          ),
          if (!_selesai) ...[
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _onTapSelesai,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary, width: 1.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text('Selesai', style: TextStyle(
                    color: AppColors.primary, fontSize: 12.5, fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(width: 4),
          ],
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded, size: 20, color: AppColors.textDark),
          ),
        ],
      ),
    );
  }

  Widget _buatItem(_Item item) {
    switch (item.jenis) {
      case 'tanggal':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: Text(Tanggal.lengkap(DateTime.now()),
                style: const TextStyle(fontSize: 12, color: AppColors.textFaint)),
          ),
        );
      case 'sistem':
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.chipBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('Konsultasi telah selesai • Riwayat tersimpan',
                  style: TextStyle(fontSize: 11.5, color: AppColors.textSoft)),
            ),
          ),
        );
      case 'mengetik':
        return _gelembungMengetik();
      default:
        return _gelembungPesan(item.pesan!);
    }
  }

  Widget _gelembungMengetik() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          AvatarDokter(dokter: widget.dokter, size: 28),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: AppShadows.card,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                3,
                (i) => Padding(
                  padding: EdgeInsets.only(right: i == 2 ? 0 : 4),
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(color: Color(0xFFCBBFA8), shape: BoxShape.circle),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gelembungPesan(_Pesan p) {
    final dariSaya = p.dariSaya;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: dariSaya ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!dariSaya) ...[
            AvatarDokter(dokter: widget.dokter, size: 28),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .78),
              decoration: BoxDecoration(
                color: dariSaya ? AppColors.userBubble : AppColors.card,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(dariSaya ? 16 : 4),
                  bottomRight: Radius.circular(dariSaya ? 4 : 16),
                ),
                boxShadow: dariSaya ? null : AppShadows.card,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(p.teks,
                      style: const TextStyle(fontSize: 13.5, height: 1.45, color: AppColors.textDark)),
                  const SizedBox(height: 3),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (dariSaya) ...[
                        const Icon(Icons.done_all_rounded, size: 12, color: Color(0xFF7FB08A)),
                        const SizedBox(width: 3),
                      ],
                      Text(Tanggal.jam(p.waktu), style: TextStyle(
                          fontSize: 10.5,
                          color: dariSaya ? const Color(0xFFA9885B) : AppColors.textFaint)),
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
    final bisaKirim = _controller.text.trim().isNotEmpty && !_selesai;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          _TombolIkonBulat(
            icon: Icons.attach_file_rounded,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Fitur lampiran belum tersedia.')),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              constraints: const BoxConstraints(minHeight: 42),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(22),
                boxShadow: AppShadows.card,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onChanged: (_) => setState(() {}),
                      enabled: !_selesai,
                      minLines: 1,
                      maxLines: 4,
                      cursorColor: AppColors.primary,
                      style: const TextStyle(fontSize: 13.5, color: AppColors.textDark),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        hintText: _selesai ? 'Konsultasi telah selesai' : 'Ketik pesan...',
                        hintStyle: const TextStyle(fontSize: 13.5, color: AppColors.textFaint),
                      ),
                    ),
                  ),
                  const Icon(Icons.emoji_emotions_outlined, size: 20, color: AppColors.textFaint),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: bisaKirim ? _kirim : null,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: bisaKirim ? AppColors.primary : const Color(0xFFE4D9C6),
                shape: BoxShape.circle,
                boxShadow: bisaKirim ? AppShadows.button : null,
              ),
              child: const Icon(Icons.send_rounded, size: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _TitikOnline extends StatelessWidget {
  const _TitikOnline();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: const BoxDecoration(color: AppColors.online, shape: BoxShape.circle),
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
        decoration: const BoxDecoration(color: AppColors.card, shape: BoxShape.circle),
        child: Icon(icon, size: 20, color: AppColors.textSoft),
      ),
    );
  }
}

/// Dialog ringkasan + rating setelah konsultasi selesai.
class _DialogRingkasan extends StatefulWidget {
  final String namaDokter;
  final String tanggalLabel;
  final int totalPesan;

  const _DialogRingkasan({
    required this.namaDokter,
    required this.tanggalLabel,
    required this.totalPesan,
  });

  @override
  State<_DialogRingkasan> createState() => _DialogRingkasanState();
}

class _DialogRingkasanState extends State<_DialogRingkasan> {
  int _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: const BoxDecoration(color: AppColors.online, shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 34),
            ),
            const SizedBox(height: 12),
            const Text('Konsultasi Selesai 🎉', style: TextStyle(
                fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            const SizedBox(height: 8),
            _barisInfo('Dokter', widget.namaDokter),
            _barisInfo('Tanggal', widget.tanggalLabel),
            _barisInfo('Total pesan', '${widget.totalPesan}'),
            const SizedBox(height: 12),
            const Text('Bagaimana penilaian Anda?', style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final n = i + 1;
                return IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => setState(() => _rating = n),
                  icon: Icon(
                    n <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: AppColors.star,
                    size: 30,
                  ),
                );
              }),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: const StadiumBorder(),
                ),
                onPressed: () {
                  Navigator.of(context)
                    ..pop() // tutup dialog ringkasan
                    ..popUntil((route) =>
                        route.settings.name != Rute.chatKonsultasi &&
                        route.settings.name != Rute.detailDokter);
                  // → berhenti di halaman daftar dokter,
                  //   di manapun KonsultasiScreen dibuka (tab maupun push).
                },
                child: const Text('Kembali ke Daftar Dokter',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Konsultasi ini bersifat edukatif dan bukan pengganti pemeriksaan medis langsung.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10.5, height: 1.4, color: AppColors.textFaint),
            ),
          ],
        ),
      ),
    );
  }

  Widget _barisInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSoft)),
          const Spacer(),
          Flexible(
            child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          ),
        ],
      ),
    );
  }
}