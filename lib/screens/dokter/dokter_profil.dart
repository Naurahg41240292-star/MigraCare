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
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _muatProfil();
  }

  /// Bisa dipanggil panel/beranda kalau perlu refresh data profil
  Future<void> muatUlang() => _muatProfil();
  Future<void> _editProfil() async {
      await Navigator.push(
          context,
                MaterialPageRoute(builder: (_) => const _EditProfilDokterPage()),
      );
    if (!mounted) return;
    muatUlang();
  }

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
              onTap: () {
                Navigator.pop(sheetContext);
                _ambilFoto(ImageSource.gallery);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.photo_camera_outlined, color: _Pf.gold),
              title: const Text('Ambil Foto dengan Kamera'),
              onTap: () {
                Navigator.pop(sheetContext);
                _ambilFoto(ImageSource.camera);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _ambilFoto(ImageSource sumber) async {
    try {
      final XFile? foto = await _picker.pickImage(
        source: sumber,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 70, 
      );
      if (foto == null) return;
      final bytes = await foto.readAsBytes();
      final base64Foto = base64Encode(bytes);

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({'profile': {'fotoBase64': base64Foto}},
              SetOptions(merge: true));

      if (!mounted) return;
      setState(() => _fotoProfil = base64Foto);
      fotoDokterNotifier.value = base64Foto;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto profil berhasil diperbarui')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat foto: $e')),
      );
    }
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
                              GestureDetector(
                                onTap: _pilihFoto,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      width: 62,
                                      height: 62,
                                      decoration: BoxDecoration(
                                          color: _Pf.avatarBg,
                                          shape: BoxShape.circle,
                                          image: _fotoProfil != null
                                              ? DecorationImage(
                                                  image: MemoryImage(
                                                      base64Decode(
                                                          _fotoProfil!)),
                                                  fit: BoxFit.cover)
                                              : null),
                                      alignment: Alignment.center,
                                      child: _fotoProfil == null
                                          ? Text(inisial,
                                              style: const TextStyle(
                                                  fontSize: 26,
                                                  fontWeight:
                                                      FontWeight.bold,
                                                  color: _Pf.gold))
                                          : null,
                                    ),
                                    Positioned(
                                      right: -2,
                                      bottom: -2,
                                      child: Container(
                                        width: 22,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          color: _Pf.gold,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Colors.white,
                                              width: 2),
                                        ),
                                        child: const Icon(
                                            Icons.photo_camera_rounded,
                                            size: 11,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(_nama,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontSize: 17,
                                                  fontWeight:
                                                      FontWeight.bold,
                                                  color: _Pf.textDark)),
                                        ),
                                      ],
                                    ),
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
                                        borderRadius: BorderRadius.circular(20)),
                                      child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                    Text(
                                      'Akun Dokter',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: _Pf.textGrey,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: _editProfil,
                                      child: Text(
                                        'Edit Profil',
                                      style: TextStyle(
                                      fontSize: 12,
                                      color: _Pf.gold,
                                      fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
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
  final _formKey = GlobalKey<FormState>();
  final _nama = TextEditingController();
  final _spesialisasi = TextEditingController();
  final _telepon = TextEditingController();
  final _bio = TextEditingController();

  String _email = '';
  String? _tanggalLahir;
  String? _jenisKelamin;
  String? _fotoBase64;
  bool _menyimpan = false;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  @override
  void dispose() {
    _nama.dispose();
    _spesialisasi.dispose();
    _telepon.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _muat() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data() ?? const {};

      final akun = data['akun'];
      if (akun is Map) _email = (akun['email'] ?? '').toString();

      final profile = data['profile'];
      if (profile is Map) {
        _nama.text = (profile['namaLengkap'] ?? '').toString();
        _spesialisasi.text = (profile['spesialisasi'] ?? '').toString();
        _telepon.text = (profile['noTelepon'] ?? '').toString();
        _bio.text = (profile['bio'] ?? '').toString();
        final tgl = (profile['tanggalLahir'] ?? '').toString();
        _tanggalLahir = tgl.isEmpty ? null : tgl;
        final jk = (profile['jenisKelamin'] ?? '').toString();
        _jenisKelamin = jk.isEmpty ? null : jk;
        final foto = (profile['fotoBase64'] ?? '').toString();
        _fotoBase64 = foto.isEmpty ? null : foto;
      }
      if (mounted) setState(() {});
    } catch (_) {}
  }

  // ---------- PILIH FOTO ----------
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
            const SizedBox(height: 12),
            ListTile(
              leading:
                  const Icon(Icons.photo_library_outlined, color: _Pf.gold),
              title: const Text('Pilih dari Galeri'),
              onTap: () => _ambilFoto(ImageSource.gallery),
            ),
            ListTile(
              leading:
                  const Icon(Icons.photo_camera_outlined, color: _Pf.gold),
              title: const Text('Ambil dari Kamera'),
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
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: sumber,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 70,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      setState(() => _fotoBase64 = base64Encode(bytes));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat foto')),
      );
    }
  }

  // ---------- TANGGAL LAHIR ----------
  Future<void> _pilihTanggal() async {
    DateTime awal = DateTime(1995, 1, 1);
    if (_tanggalLahir != null && _tanggalLahir!.isNotEmpty) {
      final p = DateTime.tryParse(_tanggalLahir!);
      if (p != null) awal = p;
    }
    final pilih = await showDatePicker(
      context: context,
      initialDate: awal,
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: _Pf.gold),
        ),
        child: child!,
      ),
    );
    if (pilih == null) return;
    setState(() {
      _tanggalLahir =
          '${pilih.year.toString().padLeft(4, '0')}-${pilih.month.toString().padLeft(2, '0')}-${pilih.day.toString().padLeft(2, '0')}';
    });
  }

  // ---------- JENIS KELAMIN ----------
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
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.male_outlined, color: _Pf.gold),
              title: const Text('Laki-laki'),
              onTap: () => Navigator.pop(sheetContext, 'Laki-laki'),
            ),
            ListTile(
              leading: const Icon(Icons.female_outlined, color: _Pf.gold),
              title: const Text('Perempuan'),
              onTap: () => Navigator.pop(sheetContext, 'Perempuan'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ).then((hasil) {
      if (hasil is String && mounted) setState(() => _jenisKelamin = hasil);
    });
  }

  // ---------- SIMPAN ----------
  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _menyimpan = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final profile = <String, dynamic>{
        'namaLengkap': _nama.text.trim(),
        'spesialisasi': _spesialisasi.text.trim(),
        'noTelepon': _telepon.text.trim(),
        'jenisKelamin': _jenisKelamin ?? '',
        'bio': _bio.text.trim(),
      };
      if (_tanggalLahir != null && _tanggalLahir!.isNotEmpty) {
        profile['tanggalLahir'] = _tanggalLahir;
      }
      if (_fotoBase64 != null && _fotoBase64!.isNotEmpty) {
        profile['fotoBase64'] = _fotoBase64;
      }

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'profile': profile,
        'akun': {'namaLengkap': _nama.text.trim()},
      }, SetOptions(merge: true));

      // Foto langsung tersinkron ke beranda & bagian atas
      fotoDokterNotifier.value =
          (_fotoBase64 != null && _fotoBase64!.isNotEmpty) ? _fotoBase64 : null;

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui')),
      );
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan profil')),
      );
    } finally {
      if (mounted) setState(() => _menyimpan = false);
    }
  }

  // ---------- HELPER UI ----------
  Widget _label(String teks) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          teks,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _Pf.textDark,
          ),
        ),
      );

  Widget _kotakInput({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    TextInputType? tipeKeyboard,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: tipeKeyboard,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      style: const TextStyle(color: _Pf.textDark, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _Pf.textGrey, fontSize: 14),
        filled: true,
        fillColor: readOnly ? const Color(0xFFF6F1E7) : Colors.white,
        suffixIcon: suffix,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _Pf.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _Pf.gold, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _Pf.merah),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _Pf.merah, width: 1.4),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Pf.bg,
      appBar: AppBar(
        backgroundColor: _Pf.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: _Pf.textDark),
        centerTitle: true,
        title: const Text(
          'Edit Profil',
          style: TextStyle(
            color: _Pf.textDark,
            fontWeight: FontWeight.w700,
            fontSize: 18,
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
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
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
                            ? const Icon(Icons.person,
                                size: 48, color: _Pf.gold)
                            : null,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Ketuk foto untuk mengganti',
                        style: TextStyle(fontSize: 12, color: _Pf.textGrey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _label('Nama Lengkap'),
              _kotakInput(
                controller: _nama,
                hint: 'Nama lengkap',
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Nama tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 14),
              _label('Email'),
              _kotakInput(
                controller: TextEditingController(text: _email),
                hint: 'Email',
                readOnly: true,
              ),
              const SizedBox(height: 14),
              _label('Spesialisasi'),
              _kotakInput(
                controller: _spesialisasi,
                hint: 'Contoh: Dokter Umum',
              ),
              const SizedBox(height: 14),
              _label('No. Telepon'),
              _kotakInput(
                controller: _telepon,
                hint: 'Contoh: 0812xxxxxxx',
                tipeKeyboard: TextInputType.phone,
                validator: (v) {
                  final t = (v ?? '').trim();
                  if (t.isEmpty) return 'No. telepon tidak boleh kosong';
                  if (t.length < 9) return 'No. telepon minimal 9 digit';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _label('Tanggal Lahir'),
              _kotakInput(
                controller: TextEditingController(text: _tanggalLahir ?? ''),
                hint: 'Pilih tanggal lahir',
                readOnly: true,
                onTap: _pilihTanggal,
                suffix: const Icon(Icons.calendar_today_outlined,
                    size: 20, color: _Pf.textGrey),
              ),
              const SizedBox(height: 14),
              _label('Jenis Kelamin'),
              _kotakInput(
                controller: TextEditingController(text: _jenisKelamin ?? ''),
                hint: 'Pilih jenis kelamin',
                readOnly: true,
                onTap: _pilihJenisKelamin,
                suffix: const Icon(Icons.keyboard_arrow_down_rounded,
                    size: 20, color: _Pf.textGrey),
              ),
              const SizedBox(height: 14),
              _label('Bio'),
              _kotakInput(
                controller: _bio,
                hint: 'Ceritakan sedikit tentang diri Anda',
                maxLines: 3,
              ),
            ],
          ),
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