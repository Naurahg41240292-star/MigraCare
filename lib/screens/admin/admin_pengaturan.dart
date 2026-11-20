
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import '../auth/masuk.dart';
import '../keamanan_akun.dart';
import 'admin_notifikasi.dart';
import 'admin_manajemen_user.dart';

abstract class _Pg {
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

/// ==========================================================================
/// MIGRACARE — Tab PENGATURAN Admin
/// ==========================================================================

class AdminPengaturanTab extends StatefulWidget {
  const AdminPengaturanTab({super.key});

  @override
  State<AdminPengaturanTab> createState() => _AdminPengaturanTabState();
}

class _AdminPengaturanTabState extends State<AdminPengaturanTab> {
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

  Future<void> muatUlang() => _muatProfil();

  Future<void> _muatProfil() async {
    String nama = '';
    String email = '';
    DateTime? bergabung;
    String? fotoProfil;

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
          fotoProfil = foto.isEmpty ? null : foto;
        }

        final akun = data['akun'];

        if (akun is Map) {
          if (nama.isEmpty) {
            nama = (akun['namaLengkap'] ?? '').toString().trim();
          }

          email = (akun['email'] ?? '').toString().trim();

          final dibuat = akun['dibuatPada'];
          if (dibuat is Timestamp) {
            bergabung = dibuat.toDate();
          }
        }

        if (bergabung == null) {
          final t = data['dibuatPada'];
          if (t is Timestamp) {
            bergabung = t.toDate();
          }
        }
      }

      if (email.isEmpty) {
        email = FirebaseAuth.instance.currentUser?.email ?? '';
      }

      if (nama.isEmpty) nama = 'Admin MigraCare';
    } catch (_) {
      email = FirebaseAuth.instance.currentUser?.email ?? '';
      if (nama.isEmpty) nama = 'Admin MigraCare';
    }

    if (!mounted) return;

    setState(() {
      _nama = nama;
      _email = email;
      _bergabung = bergabung;
      _fotoProfil = fotoProfil;
      _memuat = false;
    });
  }

  String _tanggal(DateTime t) {
    const bulan = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];

    return '${t.day} ${bulan[t.month - 1]} ${t.year}';
  }

  void _dialogSederhana(String judul, String isi, IconData ikon) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(ikon, color: _Pg.gold, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                judul,
                style: const TextStyle(fontSize: 17),
              ),
            ),
          ],
        ),
        content: Text(
          isi,
          style: const TextStyle(fontSize: 13.5, height: 1.5),
        ),
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
      MaterialPageRoute(
        builder: (_) => const _EditProfilAdminPage(),
      ),
    );

    if (!mounted) return;
    muatUlang();
  }

  Future<void> _konfirmasiKeluar() async {
    final ya = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Keluar dari Akun?'),
        content: const Text(
          'Kamu akan keluar dari akun Admin di perangkat ini. '
          'Sesudahnya kamu perlu login lagi untuk masuk.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Ya, Keluar',
              style: TextStyle(
                color: _Pg.merah,
                fontWeight: FontWeight.bold,
              ),
            ),
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

  Widget _menu(
    IconData ikon,
    String judul,
    String sub,
    VoidCallback onTap, {
    bool merah = false,
  }) {
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
              border: Border.all(color: _Pg.outline),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: merah ? _Pg.merahMuda : _Pg.goldSoft,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    ikon,
                    size: 20,
                    color: merah ? _Pg.merah : _Pg.gold,
                  ),
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
                          color: merah ? _Pg.merah : _Pg.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sub,
                        style: const TextStyle(
                          fontSize: 11,
                          color: _Pg.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: _Pg.textGrey,
                ),
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
        _nama.trim().isNotEmpty ? _nama.trim()[0].toUpperCase() : 'A';

    return Scaffold(
      backgroundColor: _Pg.bg,
      body: SafeArea(
        bottom: false,
        child: _memuat
            ? const Center(
                child: CircularProgressIndicator(color: _Pg.gold),
              )
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
                        border: Border.all(color: _Pg.outline),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 62,
                                height: 62,
                                decoration: const BoxDecoration(
                                  color: _Pg.avatarBg,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: _fotoProfil != null
                                    ? ClipOval(
                                        child: Image.memory(
                                          base64Decode(_fotoProfil!),
                                          width: 62,
                                          height: 62,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Text(
                                            inisial,
                                            style: const TextStyle(
                                              fontSize: 26,
                                              fontWeight: FontWeight.bold,
                                              color: _Pg.gold,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Text(
                                        inisial,
                                        style: const TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          color: _Pg.gold,
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _nama,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: _Pg.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _email.isEmpty ? '-' : _email,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        color: _Pg.textGrey,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _Pg.goldSoft,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        'Akun Admin',
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                          color: _Pg.gold,
                                        ),
                                      ),
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
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: _Pg.bg,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.verified_user_outlined,
                                    size: 16,
                                    color: _Pg.gold,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Bergabung sejak ${_tanggal(_bergabung!)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: _Pg.textGrey,
                                      ),
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
                      child: Text(
                        'Pengaturan',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: _Pg.textDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _menu(
                      Icons.groups_rounded,
                      'Manajemen User',
                      'Tambah dokter/pasien, ubah role & riwayat pengguna',
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AdminManajemenUserPage(),
                          ),
                        );
                      },
                    ),
                    _menu(
                      Icons.edit_rounded,
                      'Edit Profil',
                      'Perbarui nama, foto & data profil admin',
                      _editProfil,
                    ),
                    _menu(
                      Icons.notifications_rounded,
                      'Notifikasi',
                      'Pengguna baru & aktivitas aplikasi',
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AdminNotifikasiPage(),
                          ),
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
                            builder: (_) => const KeamananAkunPage(),
                          ),
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
                          MaterialPageRoute(
                            builder: (_) => const _TentangAdminPage(),
                          ),
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

// ============================================================
// HALAMAN TENTANG MIGRACARE (ADMIN)
// ============================================================

class _TentangAdminPage extends StatelessWidget {
  const _TentangAdminPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Pg.bg,
      appBar: AppBar(
        backgroundColor: _Pg.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Tentang MigraCare',
          style: TextStyle(
            color: _Pg.textDark,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
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
                      colors: [Color(0xFFF6C67B), _Pg.gold],
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Icon(
                    Icons.psychology_rounded,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Apa itu MigraCare?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _Pg.textDark,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'MigraCare adalah platform kesehatan digital yang menggabungkan teknologi dan ilmu kesehatan untuk membantu pengguna menilai risiko migraine, mencatat frekuensi dan pemicu serangan, serta menyediakan informasi dan rekomendasi yang relevan.',
              style: TextStyle(
                fontSize: 14,
                color: _Pg.textGrey,
                height: 1.8,
              ),
            ),
            const SizedBox(height: 30),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Kami Siap Membantu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _Pg.textDark,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Kami berkomitmen menjadi mitra yang dapat diandalkan dalam mengelola migraine dan menjaga kesehatan otak, baik bagi pengguna maupun para dokter pendamping.',
              style: TextStyle(
                fontSize: 14,
                color: _Pg.textGrey,
                height: 1.8,
              ),
            ),
            const SizedBox(height: 70),
            const Center(
              child: Text(
                '2024 MigraCare. All rights reserved.',
                style: TextStyle(
                  fontSize: 12,
                  color: _Pg.textGrey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// HALAMAN EDIT PROFIL ADMIN
// ============================================================

class _EditProfilAdminPage extends StatefulWidget {
  const _EditProfilAdminPage({super.key});

  @override
  State<_EditProfilAdminPage> createState() =>
      _EditProfilAdminPageState();
}

class _EditProfilAdminPageState extends State<_EditProfilAdminPage> {
  static const List<String> _bulan = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  final _formKey = GlobalKey<FormState>();
  final _namaC = TextEditingController();
  final _teleponC = TextEditingController();
  final _bioC = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String _email = '';
  DateTime? _tanggalLahir;
  String _jenisKelamin = '';
  String? _fotoBase64;
  bool _menyimpan = false;

  @override
  void initState() {
    super.initState();
    _muatDataLama();
  }

  @override
  void dispose() {
    _namaC.dispose();
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

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    final data = doc.data();
    final profile = (data?['profile'] as Map?) ?? const {};
    final akun = (data?['akun'] as Map?) ?? const {};

    if (!mounted) return;

    setState(() {
      _namaC.text = (profile['namaLengkap'] ?? '').toString();
      _teleponC.text = (profile['noTelepon'] ?? '').toString();
      _bioC.text = (profile['bio'] ?? '').toString();
      _email = (akun['email'] ?? '').toString();
      _jenisKelamin = (profile['jenisKelamin'] ?? '').toString();

      final foto = (profile['fotoBase64'] ?? '').toString();
      _fotoBase64 = foto.isEmpty ? null : foto;

      final tgl = (profile['tanggalLahir'] ?? '').toString();
      if (tgl.length >= 10) {
        _tanggalLahir = DateTime.tryParse(tgl);
      }
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
        'noTelepon': _teleponC.text.trim(),
        'jenisKelamin': _jenisKelamin,
        'bio': _bioC.text.trim(),
      };

      if (_tanggalLahir != null) {
        profile['tanggalLahir'] =
            '${_tanggalLahir!.year}-${_tanggalLahir!.month.toString().padLeft(2, '0')}-${_tanggalLahir!.day.toString().padLeft(2, '0')}';
      }

      if (_fotoBase64 != null) {
        profile['fotoBase64'] = _fotoBase64;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({
        'profile': profile,
        'akun': {'namaLengkap': nama},
      }, SetOptions(merge: true));

      if (!mounted) return;

      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil diperbarui'),
        ),
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
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
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
                color: _Pg.textDark,
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: _Pg.gold,
              ),
              title: const Text('Pilih dari Galeri'),
              onTap: () => _ambilFoto(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_camera_outlined,
                color: _Pg.gold,
              ),
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
        imageQuality: 70,
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
          colorScheme: const ColorScheme.light(
            primary: _Pg.gold,
          ),
        ),
        child: child!,
      ),
    );

    if (dipilih != null) {
      setState(() => _tanggalLahir = dipilih);
    }
  }

  // ---------------- JENIS KELAMIN ----------------

  void _pilihJenisKelamin() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
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
                color: _Pg.textDark,
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.male, color: _Pg.gold),
              title: const Text('Laki-laki'),
              trailing: _jenisKelamin == 'Laki-laki'
                  ? const Icon(Icons.check, color: _Pg.gold)
                  : null,
              onTap: () {
                Navigator.pop(sheetContext);
                setState(() => _jenisKelamin = 'Laki-laki');
              },
            ),
            ListTile(
              leading: const Icon(Icons.female, color: _Pg.gold),
              title: const Text('Perempuan'),
              trailing: _jenisKelamin == 'Perempuan'
                  ? const Icon(Icons.check, color: _Pg.gold)
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
    final huruf = nama.isEmpty ? 'A' : nama[0].toUpperCase();

    return Scaffold(
      backgroundColor: _Pg.bg,
      appBar: AppBar(
        backgroundColor: _Pg.bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: _Pg.textDark),
        title: const Text(
          'Edit Profil',
          style: TextStyle(
            color: _Pg.textDark,
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
                      color: _Pg.gold,
                    ),
                  )
                : const Text(
                    'Simpan',
                    style: TextStyle(
                      color: _Pg.gold,
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
                        backgroundColor: _Pg.goldSoft,
                        backgroundImage: _fotoBase64 != null
                            ? MemoryImage(base64Decode(_fotoBase64!))
                            : null,
                        child: _fotoBase64 == null
                            ? Text(
                                huruf,
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: _Pg.gold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Ketuk untuk mengubah foto',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _namaC,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nama lengkap',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty)
                        ? 'Nama tidak boleh kosong'
                        : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _teleponC,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'No. telepon',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pilihTanggal,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tanggal lahir',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_month_outlined),
                  ),
                  child: Text(_tanggalText),
                ),
              ),
              const SizedBox(height: 16),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                child: Text(_email.isEmpty ? '-' : _email),
              ),
              const SizedBox(height: 16),

              // Pilihan jenis kelamin disamakan dengan data yang disimpan.
              DropdownButtonFormField<String>(
                initialValue: _jenisKelamin.isEmpty
                    ? null
                    : _jenisKelamin,
                decoration: const InputDecoration(
                  labelText: 'Jenis kelamin',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Laki-laki',
                    child: Text('Laki-laki'),
                  ),
                  DropdownMenuItem(
                    value: 'Perempuan',
                    child: Text('Perempuan'),
                  ),
                ],
                onChanged: (v) {
                  setState(() => _jenisKelamin = v ?? '');
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioC,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _menyimpan ? null : _simpan,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _menyimpan
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Simpan Perubahan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
