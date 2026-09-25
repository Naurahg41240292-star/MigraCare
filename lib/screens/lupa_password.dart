import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ==========================================================================
///  MIGRACARE — Halaman Lupa Password (Reset Password)
///  File: lib/screens/lupa_password.dart
///  (Tombol "Kembali ke Masuk" di bawah sudah dihapus)
/// ==========================================================================

abstract class _Lp {
  static const Color bgTop = Color(0xFFFCF8F0);
  static const Color bgBottom = Color(0xFFFAF0DC);
  static const Color surface = Colors.white;
  static const Color darkBrown = Color(0xFF3D2B1A);
  static const Color button1 = Color(0xFFD69348);
  static const Color button2 = Color(0xFFBC7D33);
  static const Color textDark = Color(0xFF33261A);
  static const Color textGrey = Color(0xFF9C948A);
  static const Color outline = Color(0xFFEDE3D4);
  static const Color glow = Color(0xFFF6E3C0);
  static const Color accentDark = Color(0xFFB07E1F);
}

class LupaPasswordPage extends StatefulWidget {
  const LupaPasswordPage({super.key});

  @override
  State<LupaPasswordPage> createState() => _LupaPasswordPageState();
}

class _LupaPasswordPageState extends State<LupaPasswordPage>
    with SingleTickerProviderStateMixin {
  final _emailC = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _mengirim = false;

  late final AnimationController _float;

  @override
  void initState() {
    super.initState();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
      lowerBound: 0,
      upperBound: 1,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _emailC.dispose();
    _float.dispose();
    super.dispose();
  }

  bool get _emailValid {
    final email = _emailC.text.trim();
    return RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(email);
  }

  void _kirimTautan() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _mengirim = true);

    // Simulasi pengiriman (nanti diganti Firebase Auth / backend)
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() => _mengirim = false);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => Dialog(
          backgroundColor: _Lp.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFE6F4EA),
                  ),
                  child: const Icon(
                    Icons.mark_email_read_rounded,
                    color: Color(0xFF5BA97C),
                    size: 34,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Tautan Terkirim! ✉️',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _Lp.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kami telah mengirimkan tautan reset password ke\n${_emailC.text.trim()}\n\nSilakan cek kotak masuk email Anda.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    height: 1.6,
                    color: _Lp.textGrey,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    // Cukup menutup dialog — kembali ke Masuk lewat ← di kiri atas
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _Lp.button1,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Oke',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Gradasi latar senada dengan tema aplikasi
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_Lp.bgTop, _Lp.bgBottom],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.vertical,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ================= HEADER =================
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back_rounded),
                            color: _Lp.darkBrown,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Lupa Password?',
                            style: GoogleFonts.poppins(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: _Lp.textDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // ================= ILUSTRASI AMPELOP =================
                      Center(
                        child: AnimatedBuilder(
                          animation: _float,
                          builder: (context, child) {
                            final t =
                                Curves.easeInOut.transform(_float.value);
                            return Transform.translate(
                              offset: Offset(0, -10 * t),
                              child: Transform.scale(
                                scale: 1.0 + 0.025 * t,
                                child: child,
                              ),
                            );
                          },
                          child: SizedBox(
                            width: 250,
                            height: 230,
                            child: Stack(
                              alignment: Alignment.center,
                              clipBehavior: Clip.none,
                              children: [
                                // ---- Lapis 1: halo PUTIH lembut ----
                                Container(
                                  width: 225,
                                  height: 225,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.95),
                                        Colors.white.withOpacity(0.55),
                                        Colors.white.withOpacity(0.0),
                                      ],
                                      stops: const [0.0, 0.5, 1.0],
                                    ),
                                  ),
                                ),
                                // ---- Lapis 2: sentuhan krem hangat tipis ----
                                Container(
                                  width: 175,
                                  height: 175,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        _Lp.glow.withOpacity(0.75),
                                        _Lp.glow.withOpacity(0.0),
                                      ],
                                    ),
                                  ),
                                ),
                                // ---- Ilustrasi amplop ----
                                Image.asset(
                                  'assets/images/amplop.png',
                                  width: 200,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) =>
                                      const _AmplopFallback(),
                                ),
                                // ---- Daun dekoratif ----
                                Positioned(
                                  bottom: 18,
                                  left: 6,
                                  child: Icon(
                                    Icons.eco_rounded,
                                    size: 20,
                                    color: const Color(0xFFE0B56F)
                                        .withOpacity(0.85),
                                  ),
                                ),
                                Positioned(
                                  bottom: 34,
                                  right: 8,
                                  child: Icon(
                                    Icons.eco_rounded,
                                    size: 16,
                                    color: const Color(0xFFE0B56F)
                                        .withOpacity(0.65),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 34),

                      // ================= JUDUL + DESKRIPSI =================
                      Text(
                        'Reset Password',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: _Lp.textDark,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Jangan khawatir, masukkan email yang terdaftar pada akun MigraCare Anda. Kami akan mengirimkan tautan untuk membuat password baru.',
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          height: 1.7,
                          color: _Lp.textGrey,
                        ),
                      ),

                      const Spacer(),

                      // ================= FORM EMAIL =================
                      Form(
                        key: _formKey,
                        child: TextFormField(
                          controller: _emailC,
                          keyboardType: TextInputType.emailAddress,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: _Lp.textDark,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Masukkan email Anda',
                            hintStyle: GoogleFonts.poppins(
                              fontSize: 13,
                              color: _Lp.textGrey,
                            ),
                            prefixIcon: const Icon(
                              Icons.mark_email_unread_outlined,
                              size: 20,
                              color: _Lp.textGrey,
                            ),
                            filled: true,
                            fillColor: _Lp.surface,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 14),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: _Lp.outline),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: _Lp.accentDark, width: 1.4),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Color(0xFFE55555)),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Color(0xFFE55555), width: 1.4),
                            ),
                          ),
                          validator: (value) {
                            final email = value?.trim() ?? '';
                            if (email.isEmpty) {
                              return 'Email tidak boleh kosong';
                            }
                            if (!_emailValid) {
                              return 'Format email tidak valid (contoh: nama@email.com)';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 14),

                      // ================= TOMBOL KIRIM =================
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: const LinearGradient(
                              colors: [_Lp.button1, _Lp.button2],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _Lp.button1.withOpacity(0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: _mengirim ? null : _kirimTautan,
                              child: Center(
                                child: _mengirim
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.4,
                                        ),
                                      )
                                    : Text(
                                        'Kirim Tautan Reset',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
//  ILUSTRASI AMPELOP — fallback kalau assets/images/amplop.png belum ada
// ===========================================================================
class _AmplopFallback extends StatelessWidget {
  const _AmplopFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFFD69348),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3BD69348),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 14,
            child: Container(
              width: 66,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE8D0B4)),
              ),
            ),
          ),
          Positioned(
            bottom: 18,
            child: Icon(
              Icons.mark_email_unread_rounded,
              size: 58,
              color: Colors.white.withOpacity(0.95),
            ),
          ),
        ],
      ),
    );
  }
}