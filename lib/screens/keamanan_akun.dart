
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

/// MIGRACARE — Halaman Keamanan Akun
/// File: lib/screens/keamanan_akun.dart

abstract class AppColors {
  static const Color background = Color(0xFFFAF4EA);
  static const Color surface = Colors.white;
  static const Color darkBrown = Color(0xFF3D2B1A);
  static const Color accent = Color(0xFFF2C230);
  static const Color accentDark = Color(0xFFB07E1F);
  static const Color textDark = Color(0xFF33261A);
  static const Color textGrey = Color(0xFF9C948A);
  static const Color outline = Color(0xFFEDE3D4);
  static const Color success = Color(0xFF4CAF7D);
  static const Color successBg = Color(0xFFE6F5EC);
  static const Color danger = Color(0xFFE55555);
}

Future<String> _ambilNamaLengkap(String uid) async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      final nama = (data['profile']?['namaLengkap'] ??
          data['akun']?['namaLengkap'] ??
          '') as String;

      if (nama.trim().isNotEmpty) return nama.trim();
    }
  } catch (_) {}

  return 'Pengguna MigraCare';
}

/// HALAMAN UTAMA KEAMANAN AKUN
class KeamananAkunPage extends StatefulWidget {
  final VoidCallback? onKembali;

  const KeamananAkunPage({super.key, this.onKembali});

  @override
  State<KeamananAkunPage> createState() => _KeamananAkunPageState();
}

class _KeamananAkunPageState extends State<KeamananAkunPage> {
  bool _emailTerverifikasi = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _muatStatusVerifikasi();
  }

  Future<void> _muatStatusVerifikasi() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.reload();
      final userTerbaru = FirebaseAuth.instance.currentUser;

      if (!mounted) return;

      setState(() {
        _emailTerverifikasi = userTerbaru?.emailVerified ?? false;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() => _loading = false);

      _showSnack(
        'Gagal memuat status verifikasi email.',
        bg: AppColors.danger,
      );
    }
  }

  void _showSnack(String msg, {Color? bg}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          behavior: SnackBarBehavior.floating,
          backgroundColor: bg ?? AppColors.darkBrown,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: AppColors.textDark,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      if (widget.onKembali != null) {
                        widget.onKembali!();
                      } else {
                        Navigator.of(context).maybePop();
                      }
                    },
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Keamanan Akun',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(64, 0, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Lindungi akunmu dengan mengatur keamanan di bawah ini',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textGrey,
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MenuKeamanan(
                      icon: Icons.lock_rounded,
                      iconBg: const Color(0xFFFDF3D7),
                      iconColor: const Color(0xFFC99A2C),
                      judul: 'Ubah Password',
                      sub: 'Kirim tautan reset password ke email',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const UbahPasswordPage(),
                        ),
                      ),
                    ),
                    _MenuKeamanan(
                      icon: Icons.mark_email_read_rounded,
                      iconBg: const Color(0xFFFDF3D7),
                      iconColor: const Color(0xFFC99A2C),
                      judul: 'Verifikasi Email',
                      sub: _loading
                          ? 'Memuat status...'
                          : (_emailTerverifikasi
                              ? 'Email sudah terverifikasi'
                              : 'Email belum terverifikasi'),
                      badge: _loading
                          ? null
                          : (_emailTerverifikasi ? 'Terverifikasi' : null),
                      badgeColor: AppColors.success,
                      badgeBg: AppColors.successBg,
                      onTap: () {
                        Navigator.of(context)
                            .push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    const VerifikasiEmailPage(),
                              ),
                            )
                            .then((_) => _muatStatusVerifikasi());
                      },
                    ),
                    _MenuKeamanan(
                      icon: Icons.shield_rounded,
                      iconBg: const Color(0xFFFDF3D7),
                      iconColor: const Color(0xFFC99A2C),
                      judul: 'Informasi Keamanan',
                      sub: 'Lihat detail login & aktivitas akun',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              const InformasiKeamananPage(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDF3D7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFEEDFA8),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.security_rounded,
                            size: 18,
                            color: AppColors.accentDark,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Akun Anda dilindungi oleh Firebase Authentication',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
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
}

class _MenuKeamanan extends StatelessWidget {
  const _MenuKeamanan({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.judul,
    required this.sub,
    required this.onTap,
    this.badge,
    this.badgeColor,
    this.badgeBg,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String judul;
  final String sub;
  final VoidCallback onTap;
  final String? badge;
  final Color? badgeColor;
  final Color? badgeBg;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.outline),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        judul,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sub,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (badge != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: badgeBg ?? AppColors.successBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 12,
                          color: badgeColor ?? AppColors.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          badge!,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: badgeColor ?? AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                ] else
                  const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textGrey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// HALAMAN UBAH PASSWORD
class UbahPasswordPage extends StatefulWidget {
  const UbahPasswordPage({super.key});

  @override
  State<UbahPasswordPage> createState() =>
      _UbahPasswordPageState();
}

class _UbahPasswordPageState extends State<UbahPasswordPage> {
  bool _mengirim = false;

  void _showSnack(String msg, {Color? bg}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          behavior: SnackBarBehavior.floating,
          backgroundColor: bg ?? AppColors.darkBrown,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }

  Future<void> _kirimResetLink() async {
    final email =
        FirebaseAuth.instance.currentUser?.email ?? '';

    if (email.isEmpty) {
      _showSnack(
        'Email tidak ditemukan. Silakan login ulang.',
        bg: AppColors.danger,
      );
      return;
    }

    setState(() => _mengirim = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
      );

      if (!mounted) return;

      _showSnack(
        'Tautan reset password telah dikirim ke $email',
      );

      await Future.delayed(
        const Duration(milliseconds: 600),
      );

      if (!mounted) return;

      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      var pesan = 'Gagal mengirim tautan reset.';

      if (e.code == 'user-not-found') {
        pesan = 'Akun dengan email ini tidak ditemukan.';
      } else if (e.code == 'invalid-email') {
        pesan = 'Format email tidak valid.';
      } else if (e.code == 'too-many-requests') {
        pesan = 'Terlalu banyak permintaan. Coba lagi nanti.';
      }

      if (mounted) {
        _showSnack(pesan, bg: AppColors.danger);
      }
    } catch (_) {
      if (mounted) {
        _showSnack(
          'Terjadi kesalahan. Coba lagi.',
          bg: AppColors.danger,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _mengirim = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final email =
        FirebaseAuth.instance.currentUser?.email ?? '-';

    return PopScope(
      canPop: !_mengirim,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_mengirim) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  16,
                  20,
                  8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                      ),
                      color: AppColors.textDark,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        if (!_mengirim) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Ubah Password',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    8,
                    20,
                    24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFDF3D7),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lock_reset_rounded,
                            size: 44,
                            color: AppColors.accentDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Center(
                        child: Text(
                          'Reset Password',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Center(
                        child: Text(
                          'Kami akan mengirimkan tautan reset password ke email Anda. Tautan ini berlaku selama 1 jam.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textGrey,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.outline,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFDF3D7),
                                borderRadius:
                                    BorderRadius.circular(11),
                              ),
                              child: const Icon(
                                Icons.email_rounded,
                                color: AppColors.accentDark,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Email Terdaftar',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textGrey,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    email,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _mengirim
                              ? null
                              : _kirimResetLink,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentDark,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                          ),
                          child: _mengirim
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Kirim Tautan Reset',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// HALAMAN VERIFIKASI EMAIL
class VerifikasiEmailPage extends StatefulWidget {
  const VerifikasiEmailPage({super.key});

  @override
  State<VerifikasiEmailPage> createState() =>
      _VerifikasiEmailPageState();
}

class _VerifikasiEmailPageState
    extends State<VerifikasiEmailPage> {
  bool _terverifikasi = false;
  bool _loading = true;
  bool _mengirim = false;

  @override
  void initState() {
    super.initState();
    _muatStatus();
  }

  Future<void> _muatStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.reload();

      final userTerbaru = FirebaseAuth.instance.currentUser;

      if (!mounted) return;

      setState(() {
        _terverifikasi =
            userTerbaru?.emailVerified ?? false;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() => _loading = false);

      _showSnack(
        'Gagal memuat status verifikasi email.',
        bg: AppColors.danger,
      );
    }
  }

  void _showSnack(String msg, {Color? bg}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          behavior: SnackBarBehavior.floating,
          backgroundColor: bg ?? AppColors.darkBrown,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }

  Future<void> _kirimUlangVerifikasi() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showSnack(
        'Sesi tidak ditemukan. Silakan login ulang.',
        bg: AppColors.danger,
      );
      return;
    }

    setState(() => _mengirim = true);

    try {
      await user.sendEmailVerification();

      if (!mounted) return;

      _showSnack(
        'Email verifikasi telah dikirim ke ${user.email}',
      );
    } on FirebaseAuthException catch (e) {
      final pesan = e.code == 'too-many-requests'
          ? 'Terlalu banyak permintaan. Coba lagi nanti.'
          : 'Gagal mengirim email verifikasi.';

      if (mounted) {
        _showSnack(pesan, bg: AppColors.danger);
      }
    } catch (_) {
      if (mounted) {
        _showSnack(
          'Gagal mengirim email verifikasi.',
          bg: AppColors.danger,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _mengirim = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final email =
        FirebaseAuth.instance.currentUser?.email ?? '-';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                16,
                20,
                8,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                    ),
                    color: AppColors.textDark,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () =>
                        Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Verifikasi Email',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  24,
                ),
                child: Column(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: const BoxDecoration(
                        color: AppColors.successBg,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified_rounded,
                        size: 56,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _loading
                          ? 'Memuat...'
                          : (_terverifikasi
                              ? 'Email Terverifikasi'
                              : 'Email Belum Terverifikasi'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _terverifikasi
                          ? 'Email Anda sudah berhasil terverifikasi. Akun Anda aman dan siap digunakan.'
                          : 'Verifikasi email diperlukan untuk mengamankan akun Anda. Klik tombol di bawah untuk mengirim ulang email verifikasi.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textGrey,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.outline,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDF3D7),
                              borderRadius:
                                  BorderRadius.circular(11),
                            ),
                            child: const Icon(
                              Icons.email_rounded,
                              color: AppColors.accentDark,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Email',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textGrey,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  email,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!_loading && _terverifikasi)
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.successBg,
                                borderRadius:
                                    BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 12,
                                    color: AppColors.success,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Terverifikasi',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (!_loading && !_terverifikasi)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _mengirim
                              ? null
                              : _kirimUlangVerifikasi,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentDark,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                          ),
                          icon: _mengirim
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.send_rounded,
                                  size: 18,
                                ),
                          label: Text(
                            _mengirim
                                ? 'Mengirim...'
                                : 'Kirim Ulang Email Verifikasi',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
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
}

/// HALAMAN INFORMASI KEAMANAN
class InformasiKeamananPage extends StatefulWidget {
  const InformasiKeamananPage({super.key});

  @override
  State<InformasiKeamananPage> createState() =>
      _InformasiKeamananPageState();
}

class _InformasiKeamananPageState
    extends State<InformasiKeamananPage> {
  String _nama = '...';
  String _email = '...';
  String _metodeLogin = 'Email & Password';
  String _lastLogin = '...';
  bool _emailTerverifikasi = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _muatInfo();
  }

  Future<void> _muatInfo() async {
    final user = FirebaseAuth.instance.currentUser;

    var nama = 'Pengguna MigraCare';
    var email = user?.email ?? '-';
    var metode = 'Email & Password';
    var lastLogin = '-';
    var emailTerverifikasi = false;

    try {
      if (user != null) {
        await user.reload();

        final userTerbaru = FirebaseAuth.instance.currentUser;

        nama = await _ambilNamaLengkap(user.uid);
        email = userTerbaru?.email ?? '-';
        emailTerverifikasi =
            userTerbaru?.emailVerified ?? false;

        if (user.providerData.isNotEmpty) {
          final provider = user.providerData.first;

          if (provider.providerId == 'google.com') {
            metode = 'Google';
          } else if (provider.providerId == 'password') {
            metode = 'Email & Password';
          } else if (provider.providerId == 'phone') {
            metode = 'Nomor Telepon';
          } else {
            metode = provider.providerId;
          }
        }

        final lastSignIn = user.metadata.lastSignInTime;

        if (lastSignIn != null) {
          try {
            lastLogin = DateFormat(
              'd MMMM yyyy, HH:mm',
              'id_ID',
            ).format(lastSignIn);
          } catch (_) {
            lastLogin = DateFormat(
              'd MMMM yyyy, HH:mm',
            ).format(lastSignIn);
          }
        }
      }
    } catch (_) {}

    if (!mounted) return;

    setState(() {
      _nama = nama;
      _email = email;
      _metodeLogin = metode;
      _lastLogin = lastLogin;
      _emailTerverifikasi = emailTerverifikasi;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                16,
                20,
                8,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                    ),
                    color: AppColors.textDark,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () =>
                        Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Informasi Keamanan',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(64, 0, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Detail akun & aktivitas login terakhir',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textGrey,
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFDF3D7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.shield_rounded,
                          size: 38,
                          color: AppColors.accentDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Center(
                      child: Text(
                        'Informasi Akun',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.outline,
                        ),
                      ),
                      child: Column(
                        children: [
                          _InfoRow(
                            icon: Icons.person_rounded,
                            label: 'Nama',
                            value: _loading ? '...' : _nama,
                          ),
                          const Divider(
                            height: 24,
                            color: AppColors.outline,
                          ),
                          _InfoRow(
                            icon: Icons.email_rounded,
                            label: 'Email',
                            value: _loading ? '...' : _email,
                            badge: !_loading && _emailTerverifikasi
                                ? 'Terverifikasi'
                                : null,
                          ),
                          const Divider(
                            height: 24,
                            color: AppColors.outline,
                          ),
                          _InfoRow(
                            icon: Icons.login_rounded,
                            label: 'Metode Login',
                            value: _loading ? '...' : _metodeLogin,
                          ),
                          const Divider(
                            height: 24,
                            color: AppColors.outline,
                          ),
                          _InfoRow(
                            icon: Icons.access_time_rounded,
                            label: 'Login Terakhir',
                            value: _loading ? '...' : _lastLogin,
                          ),
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
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.badge,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFFDF3D7),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppColors.accentDark,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
        if (badge != null)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.successBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 12,
                  color: AppColors.success,
                ),
                SizedBox(width: 4),
                Text(
                  'Terverifikasi',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
