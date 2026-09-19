import 'package:flutter/material.dart';
import 'masuk.dart';
import 'daftar.dart';

/// ==========================================================================
///  MIGRACARE — Halaman Selamat Datang
///  File: lib/screens/welcome.dart
/// ==========================================================================

abstract class _Wc {
  static const Color bg = Color(0xFFFAF4EA);
  static const Color gold = Color(0xFFC08A2B);
  static const Color button = Color(0xFFD69348);
  static const Color textDark = Color(0xFF33261A);
  static const Color textGrey = Color(0xFF8F8578);
  static const Color brainSoft = Color(0xFFF5E9D2);
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _Wc.textDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Wc.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---------------- Tombol kembali -------------------------------
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: _Wc.textDark,
                    size: 26,
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // ---------------- Ilustrasi otak emas --------------------------
              Center(
                child: SizedBox(
                  width: 190,
                  height: 150,
                  child: CustomPaint(painter: _GoldBrainPainter()),
                ),
              ),
              const SizedBox(height: 28),

              // ---------------- Judul & deskripsi ----------------------------
              const Text(
                'Selamat Datang di\nMigraCare',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  height: 1.35,
                  color: _Wc.textDark,
                ),
              ),
              const SizedBox(height: 14),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Mulai perjalanan Anda dalam mengenali dan mengelola migrain',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: _Wc.textGrey,
                  ),
                ),
              ),

              const Spacer(flex: 3),

              // ---------------- Tombol MASUK ---------------------------------
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MasukPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _Wc.button,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Masuk',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ---------------- Tombol BUAT AKUN -----------------------------
              SizedBox(
                height: 54,
                child: OutlinedButton(
                  onPressed: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const DaftarPage()),
                        );
                        },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: _Wc.gold,
                    side: const BorderSide(color: _Wc.gold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Buat Akun',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
//  PAINTER: OTAK EMAS (outline gradien emas + tanda plus)
// ===========================================================================
class _GoldBrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    final half = Path()
      ..moveTo(w * 0.53, h * 0.80)
      ..cubicTo(w * 0.40, h * 0.88, w * 0.24, h * 0.85, w * 0.20, h * 0.70)
      ..cubicTo(w * 0.06, h * 0.67, w * 0.01, h * 0.50, w * 0.11, h * 0.40)
      ..cubicTo(w * 0.07, h * 0.22, w * 0.24, h * 0.08, w * 0.40, h * 0.14)
      ..cubicTo(w * 0.44, h * 0.02, w * 0.50, h * 0.04, w * 0.50, h * 0.12);

    final mid = Path()
      ..moveTo(w * 0.50, h * 0.12)
      ..quadraticBezierTo(w * 0.485, h * 0.45, w * 0.53, h * 0.80);

    final gyri = Path()
      ..moveTo(w * 0.34, h * 0.16)
      ..quadraticBezierTo(w * 0.28, h * 0.28, w * 0.36, h * 0.32)
      ..moveTo(w * 0.14, h * 0.36)
      ..quadraticBezierTo(w * 0.26, h * 0.40, w * 0.28, h * 0.52)
      ..moveTo(w * 0.20, h * 0.60)
      ..quadraticBezierTo(w * 0.32, h * 0.58, w * 0.36, h * 0.68)
      ..moveTo(w * 0.44, h * 0.24)
      ..quadraticBezierTo(w * 0.40, h * 0.36, w * 0.46, h * 0.44);

    final shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: const [Color(0xFFE3B25E), Color(0xFFB87A1D)],
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    final soft = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.075
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = _Wc.brainSoft;

    final main = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.045
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = shader;

    void drawHalf() {
      canvas.drawPath(half, soft);
      canvas.drawPath(mid, soft);
      canvas.drawPath(half, main);
      canvas.drawPath(mid, main);
      canvas.drawPath(gyri, main);
    }

    drawHalf();
    canvas.save();
    canvas.translate(w, 0);
    canvas.scale(-1, 1);
    drawHalf();
    canvas.restore();

    // Tanda plus
    final cx = w * 0.90, cy = h * 0.78, arm = w * 0.08;
    final plus = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.05
      ..strokeCap = StrokeCap.round
      ..shader = shader;
    canvas.drawLine(Offset(cx - arm, cy), Offset(cx + arm, cy), plus);
    canvas.drawLine(Offset(cx, cy - arm), Offset(cx, cy + arm), plus);
  }

  @override
  bool shouldRepaint(covariant _GoldBrainPainter oldDelegate) => false;
}