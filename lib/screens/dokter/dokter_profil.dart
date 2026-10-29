import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/masuk.dart';
import '../keamanan_akun.dart';
import 'dokter_notifikasi.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class _Pf {
  static const bg = Color(0xFFFAF4EA);
  static const gold = Color(0xFFC9822E);
  static const goldSoft = Color(0xFFFDF3D7);
  static const textDark = Color(0xFF33261A);
  static const textGrey = Color(0xFF9C948A);
  static const outline = Color(0xFFE5DCCB);
  static const avatarBg = Color(0xFFF6DFC8);
  static const merah = Color(0xFFE55555);
  static const merahMuda = Color(0xFFFCE8E6);
}

class DokterProfilView extends StatefulWidget {
  const DokterProfilView({super.key});

  @override
  State<DokterProfilView> createState() => _DokterProfilViewState();
}

class _DokterProfilViewState extends State<DokterProfilView> {
  bool _memuat = true;
  String _nama = '';
  String _email = '';
  DateTime? _bergabung;
  String? _fotoProfil;

  @override
  void initState() {
    super.initState();
    _muatProfil();
  }

  /// Bisa dipanggil panel/beranda kalau perlu refresh data profil
  Future<void> muatUlang() => _muatProfil();

  Future<void> _muatProfil() async {
    String nama = '';
    String email = '';
    DateTime? bergabung;

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        final data = doc.data() ?? {};

                final profile = data['profile'];
        if (profile is Map) {
          nama = (profile['namaLengkap'] ?? '').toString().trim();
          final foto = (profile['fotoBase64'] ?? '').toString();
          _fotoProfil = foto.isEmpty ? null : foto;
          fotoDokterNotifier.value = _fotoProfil; // ← baru
        }
        final akun = data['akun'];
        if (akun is Map) {
          if (nama.isEmpty) {
            nama = (akun['namaLengkap'] ?? '').toString().trim();
          }
          email = (akun['email'] ?? '').toString().trim();
          final dibuat = akun['dibuatPada'];
          if (dibuat is Timestamp) bergabung = dibuat.toDate();
        }
        if (bergabung == null) {
          final t = data['dibuatPada'];
          if (t is Timestamp) bergabung = t.toDate();
        }
      }
      if (email.isEmpty) {
        email = FirebaseAuth.instance.currentUser?.email ?? '';
      }
      if (nama.isEmpty) nama = 'Dokter MigraCare';
    } catch (_) {
      email = FirebaseAuth.instance.currentUser?.email ?? '';
      if (nama.isEmpty) nama = 'Dokter MigraCare';
    }

    if (!mounted) return;
    setState(() {
      _nama = nama;
      _email = email;
      _bergabung = bergabung;
      _memuat = false;
    });
  }

  String _tanggal(DateTime t) {
    const bulan = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${t.day} ${bulan[t.month - 1]} ${t.year}';
  }

  void _dialogSederhana(String judul, String isi, IconData ikon) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(ikon, color: _Pf.gold, size: 22),
            const SizedBox(width: 10),
            Expanded(child: Text(judul, style: const TextStyle(fontSize: 17))),
          ],
        ),
        content: Text(isi,
            style: const TextStyle(fontSize: 13.5, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Future<void> _editProfil() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _EditProfilDokterPage()),
    );
    if (!mounted) return;
    muatUlang();
  }

  Future<void> _konfirmasiKeluar() async {
    final ya = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar dari Akun?'),
        content: const Text(
            'Kamu akan keluar dari akun dokter di perangkat ini. '
            'Sesudahnya kamu perlu login lagi untuk masuk.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Keluar',
                style: TextStyle(
                    color: _Pf.merah, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (ya != true) return;

    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => MasukPage()),
      (route) => false,
    );
  }

  Widget _menu(IconData ikon, String judul, String sub, VoidCallback onTap,
      {bool merah = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _Pf.outline),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: merah ? _Pf.merahMuda : _Pf.goldSoft,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(ikon,
                      size: 20, color: merah ? _Pf.merah : _Pf.gold),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        judul,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: merah ? _Pf.merah : _Pf.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(sub,
                          style: const TextStyle(
                              fontSize: 11, color: _Pf.textGrey)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: _Pf.textGrey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inisial =
        _nama.trim().isNotEmpty ? _nama.trim()[0].toUpperCase() : 'D';

    return Scaffold(
      backgroundColor: _Pf.bg,
      body: SafeArea(
        bottom: false,
        child: _memuat
            ? const Center(child: CircularProgressIndicator(color: _Pf.gold))
            : RefreshIndicator(
                onRefresh: _muatProfil,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: _Pf.outline),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 62,
                                height: 62,
                                decoration: const BoxDecoration(
                                    color: _Pf.avatarBg,
                                    shape: BoxShape.circle),
                                alignment: Alignment.center,
                                child: Text(inisial,
                                    style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: _Pf.gold)),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(_nama,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: _Pf.textDark)),
                                    const SizedBox(height: 4),
                                    Text(
                                        _email.isEmpty
                                            ? '-'
                                            : _email,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 12.5,
                                            color: _Pf.textGrey)),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                          color: _Pf.goldSoft,
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: const Text('Akun Dokter',
                                          style: TextStyle(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.bold,
                                              color: _Pf.gold)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (_bergabung != null) ...[
                            const SizedBox(height: 14),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                  color: _Pf.bg,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                children: [
                                  const Icon(Icons.verified_user_outlined,
                                      size: 16, color: _Pf.gold),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Bergabung sejak ${_tanggal(_bergabung!)}',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: _Pf.textGrey),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Pengaturan',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: _Pf.textDark)),
                    ),
                    const SizedBox(height: 10),
                    _menu(
                      Icons.edit_rounded,
                      'Edit Profil',
                      'Perbarui nama & data profil dokter',
                      _editProfil,
                    ),
                    _menu(
                      Icons.notifications_rounded,
                      'Notifikasi',
                      'Booking baru & update konsultasi',
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const NotifikasiDokterPage()),
                        );
                      },
                    ),
                    _menu(
                      Icons.lock_rounded,
                      'Keamanan Akun',
                      'Password, verifikasi email, info keamanan',
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const KeamananAkunPage()),
                        );
                      },
                    ),
                    _menu(
                      Icons.help_outline_rounded,
                      'Pusat Bantuan',
                      'Cara pakai aplikasi & hubungi tim',
                      () => _dialogSederhana(
                        'Pusat Bantuan',
                        'Ada kendala atau mau bertanya seputar MigraCare? '
                            'Hubungi tim lewat grup kelompok kalian ya.',
                        Icons.help_outline_rounded,
                      ),
                    ),
                    _menu(
                      Icons.info_outline_rounded,
                      'Tentang MigraCare',
                      'Versi aplikasi & kredit tim',
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const _TentangMigraCarePage()),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    _menu(
                      Icons.logout_rounded,
                      'Keluar',
                      'Keluar dari akun di perangkat ini',
                      _konfirmasiKeluar,
                      merah: true,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
class _TentangMigraCarePage extends StatelessWidget {
  const _TentangMigraCarePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Pf.bg,
      appBar: AppBar(
        backgroundColor: _Pf.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text('Tentang MigraCare',
            style: TextStyle(
                color: _Pf.textDark,
                fontWeight: FontWeight.w700,
                fontSize: 17)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
          children: [
            const SizedBox(height: 24),
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFFF6C67B), _Pf.gold]),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Icon(Icons.psychology_rounded,
                      size: 60, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Apa itu MigraCare?',
                  style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accentDark,)),
            ),
            const SizedBox(height: 10),
            const Text(
              'MigraCare adalah platform kesehatan digital yang menggabungkan teknologi dan ilmu kesehatan untuk membantu pengguna menilai risiko migraine, mencatat frekuensi dan pemicu serangan, serta menyediakan informasi dan rekomendasi yang relevan.',
              style: TextStyle(
                  fontSize: 14, color: _Pf.textGrey, height: 1.8),
            ),
            const SizedBox(height: 30),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Kami Siap Membantu',
                  style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accentDark,)),
            ),
            const SizedBox(height: 10),
            const Text(
              'Kami berkomitmen menjadi mitra yang dapat diandalkan dalam mengelola migraine dan menjaga kesehatan otak, baik bagi pengguna maupun para dokter pendamping.',
              style: TextStyle(
                  fontSize: 14, color: _Pf.textGrey, height: 1.8),
            ),
            const SizedBox(height: 70),
            const Center(
              child: Text('2024 MigraCare. All rights reserved.',
                  style: TextStyle(fontSize: 12, color: _Pf.textGrey)),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// HALAMAN EDIT PROFIL DOKTER
// ============================================================
class _EditProfilDokterPage extends StatefulWidget {
  const _EditProfilDokterPage({super.key});

  @override
  State<_EditProfilDokterPage> createState() => _EditProfilDokterPageState();
}

class _EditProfilDokterPageState extends State<_EditProfilDokterPage> {
  static const List<String> _bulan = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  final _formKey = GlobalKey<FormState>();
  final _namaC = TextEditingController();
  final _spesialisasiC = TextEditingController();
  final _teleponC = TextEditingController();
  final _bioC = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  String _email = '';
  DateTime? _tanggalLahir;
  String _jenisKelamin = '';
  String? _fotoBase64; // foto disimpan base64 di Firestore (tanpa Storage)
  bool _menyimpan = false;

  @override
  void initState() {
    super.initState();
    _muatDataLama();
  }

  @override
  void dispose() {
    _namaC.dispose();
    _spesialisasiC.dispose();
    _teleponC.dispose();
    _bioC.dispose();
    super.dispose();
  }

  String get _tanggalText {
    final t = _tanggalLahir;
    if (t == null) return 'Pilih tanggal lahir';
    return '${t.day} ${_bulan[t.month - 1]} ${t.year}';
  }

  // ---------------- MUAT DATA LAMA ----------------
  Future<void> _muatDataLama() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data();
    final profile = (data?['profile'] as Map?) ?? const {};
    final akun = (data?['akun'] as Map?) ?? const {};
    if (!mounted) return;
    setState(() {
      _namaC.text = (profile['namaLengkap'] ?? '').toString();
      _spesialisasiC.text = (profile['spesialisasi'] ?? '').toString();
      _teleponC.text = (profile['noTelepon'] ?? '').toString();
      _bioC.text = (profile['bio'] ?? '').toString();
      _email = (akun['email'] ?? '').toString();
      _jenisKelamin = (profile['jenisKelamin'] ?? '').toString();
      final foto = (profile['fotoBase64'] ?? '').toString();
      _fotoBase64 = foto.isEmpty ? null : foto;
      final tgl = (profile['tanggalLahir'] ?? '').toString();
      if (tgl.length >= 10) _tanggalLahir = DateTime.tryParse(tgl);
    });
  }

  // ---------------- SIMPAN ----------------
  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _menyimpan = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final nama = _namaC.text.trim();

      final profile = <String, dynamic>{
        'namaLengkap': nama,
        'spesialisasi': _spesialisasiC.text.trim(),
        'noTelepon': _teleponC.text.trim(),
        'jenisKelamin': _jenisKelamin,
        'bio': _bioC.text.trim(),
      };
      if (_tanggalLahir != null) {
        profile['tanggalLahir'] =
            '${_tanggalLahir!.year}-${_tanggalLahir!.month.toString().padLeft(2, '0')}-${_tanggalLahir!.day.toString().padLeft(2, '0')}';
      }
      if (_fotoBase64 != null) profile['fotoBase64'] = _fotoBase64;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'profile': profile,
        'akun': {'namaLengkap': nama},
      }, SetOptions(merge: true));
      fotoDokterNotifier.value = _fotoBase64;

      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _menyimpan = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e')),
      );
    }
  }

  // ---------------- FOTO ----------------
  void _pilihFoto() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 14),
            const Text(
              'Ganti Foto Profil',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: _Pf.textDark,
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: _Pf.gold),
              title: const Text('Pilih dari Galeri'),
              onTap: () => _ambilFoto(ImageSource.gallery),
            ),
            ListTile(
              leading:
                  const Icon(Icons.photo_camera_outlined, color: _Pf.gold),
              title: const Text('Ambil Foto dengan Kamera'),
              onTap: () => _ambilFoto(ImageSource.camera),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _ambilFoto(ImageSource sumber) async {
    Navigator.pop(context);
    try {
      final XFile? foto = await _picker.pickImage(
        source: sumber,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 70, // kompres biar base64 tidak melebihi batas Firestore
      );
      if (foto == null) return;
      final bytes = await foto.readAsBytes();
      if (!mounted) return;
      setState(() => _fotoBase64 = base64Encode(bytes));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat foto: $e')),
      );
    }
  }

  // ---------------- TANGGAL LAHIR ----------------
  Future<void> _pilihTanggal() async {
    final dipilih = await showDatePicker(
      context: context,
      initialDate: _tanggalLahir ?? DateTime(2000),
      firstDate: DateTime(1945),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: _Pf.gold),
        ),
        child: child!,
      ),
    );
    if (dipilih != null) setState(() => _tanggalLahir = dipilih);
  }

  // ---------------- JENIS KELAMIN ----------------
  void _pilihJenisKelamin() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 14),
            const Text(
              'Jenis Kelamin',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: _Pf.textDark,
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.male, color: _Pf.gold),
              title: const Text('Laki-laki'),
              trailing: _jenisKelamin == 'Laki-laki'
                  ? const Icon(Icons.check, color: _Pf.gold)
                  : null,
              onTap: () {
                Navigator.pop(sheetContext);
                setState(() => _jenisKelamin = 'Laki-laki');
              },
            ),
            ListTile(
              leading: const Icon(Icons.female, color: _Pf.gold),
              title: const Text('Perempuan'),
              trailing: _jenisKelamin == 'Perempuan'
                  ? const Icon(Icons.check, color: _Pf.gold)
                  : null,
              onTap: () {
                Navigator.pop(sheetContext);
                setState(() => _jenisKelamin = 'Perempuan');
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    final nama = _namaC.text.trim();
    final huruf = nama.isEmpty ? 'D' : nama[0].toUpperCase();

    return Scaffold(
      backgroundColor: _Pf.bg,
      appBar: AppBar(
        backgroundColor: _Pf.bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: _Pf.textDark),
        title: const Text(
          'Edit Profil',
          style: TextStyle(
            color: _Pf.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _menyimpan ? null : _simpan,
            child: _menyimpan
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _Pf.gold,
                    ),
                  )
                : const Text(
                    'Simpan',
                    style: TextStyle(
                      color: _Pf.gold,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pilihFoto,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 52,
                        backgroundColor: _Pf.goldSoft,
                        backgroundImage: _fotoBase64 != null
                            ? MemoryImage(base64Decode(_fotoBase64!))
                            : null,
                        child: _fotoBase64 == null
                            ? Text(
                                huruf,
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: _Pf.gold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Ketuk foto untuk mengganti',
                        style: TextStyle(fontSize: 12, color: _Pf.textGrey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _label('Nama Lengkap'),
              _kotakInput(
                controller: _namaC,
                hint: 'Contoh: dr. Andi Pratama',
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Nama tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 16),
              _label('Email'),
              _kotakInput(
                controller: TextEditingController(text: _email),
                hint: '-',
                readOnly: true,
                fillColor: const Color(0xFFF6F1E7),
                helperText: 'Email tidak dapat diubah',
              ),
              const SizedBox(height: 16),
              _label('Spesialisasi'),
              _kotakInput(
                controller: _spesialisasiC,
                hint: 'Contoh: Dokter Umum / Neurologi',
              ),
              const SizedBox(height: 16),
              _label('No. Telepon'),
              _kotakInput(
                controller: _teleponC,
                hint: 'Contoh: 0812xxxxxxx',
                keyboardType: TextInputType.phone,
                validator: (v) {
                  final t = (v ?? '').trim();
                  if (t.isEmpty) return null;
                  if (t.length < 9) return 'Nomor telepon tidak valid';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _label('Tanggal Lahir'),
              _kotakInput(
                controller: TextEditingController(text: _tanggalText),
                hint: 'Pilih tanggal lahir',
                readOnly: true,
                onTap: _pilihTanggal,
                suffix: const Icon(Icons.calendar_today_outlined,
                    size: 20, color: _Pf.textGrey),
              ),
              const SizedBox(height: 16),
              _label('Jenis Kelamin'),
              _kotakInput(
                controller:
                    TextEditingController(text: _jenisKelamin),
                hint: 'Pilih jenis kelamin',
                readOnly: true,
                onTap: _pilihJenisKelamin,
                suffix: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: _Pf.textGrey),
              ),
              const SizedBox(height: 16),
              _label('Bio (Opsional)'),
              _kotakInput(
                controller: _bioC,
                hint: 'Ceritakan sedikit tentang diri kamu',
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String teks) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        teks,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: _Pf.textGrey,
        ),
      ),
    );
  }

  Widget _kotakInput({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffix,
    Color? fillColor,
    String? helperText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      style: const TextStyle(color: _Pf.textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _Pf.textGrey),
        helperText: helperText,
        helperStyle: const TextStyle(fontSize: 11, color: _Pf.textGrey),
        suffixIcon: suffix,
        filled: true,
        fillColor: fillColor ?? Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _Pf.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _Pf.gold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _Pf.merah),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _Pf.merah, width: 1.5),
        ),
      ),
    );
  }
}

// ============================================================
// NOTIFIER GLOBAL FOTO PROFIL DOKTER
// Dipakai bareng: header profil, AppBar beranda, dst.
// ============================================================
final ValueNotifier<String?> fotoDokterNotifier = ValueNotifier<String?>(null);

/// Ambil foto dari Firestore & nyalakan notifier
Future<void> muatFotoDokterGlobal() async {
  try {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    final data = doc.data() ?? const {};
    final profile = data['profile'];
    final foto =
        profile is Map ? (profile['fotoBase64'] ?? '').toString() : '';
    fotoDokterNotifier.value = foto.isEmpty ? null : foto;
  } catch (_) {
    // diamkan — foto lama tetap dipakai
  }
}