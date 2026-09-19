import 'package:flutter/material.dart';
import 'onboarding.dart';

/// ==========================================================================
///  MIGRACARE — Splash Screen (swipe up untuk masuk)
///  File: lib/screens/splash.dart
/// ==========================================================================

abstract class _Sp {
  static const Color bg = Color(0xFFFAF4EA);
  static const Color gold = Color(0xFFC08A2B);
  static const Color textDark = Color(0xFF33261A);
  static const Color textGrey = Color(0xFF8F8578);
  static const Color brain = Color(0xFFEAD5AE);
  static const Color brainSoft = Color(0xFFF5E9D2);
  static const Color indicator = Color(0xFF6E5B41);
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounce;
  double _dragDy = 0;
  bool _dragging = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _bounce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
      lowerBound: 0,
      upperBound: 1,
    )..repeat(reverse: true);

    // OPSI: pindah otomatis setelah 6 detik seperti splash klasik.
    // Hapus komentar di bawah jika diinginkan:
    // Future.delayed(const Duration(seconds: 6), _go);
  }

  void _go() {
  if (_navigated || !mounted) return;
  _navigated = true;
  Navigator.of(context).pushReplacement(
    _SlideUpRoute(page: const OnboardingPage()),  // ← dulu: BerandaPage()
  );
}

  void _onDragUpdate(DragUpdateDetails d) {
    if (d.delta.dy >= 0) return; // hanya merespons tarikan ke atas
    setState(() {
      _dragging = true;
      _dragDy = (_dragDy + d.delta.dy).clamp(-220.0, 0.0);
    });
  }

  void _onDragEnd(DragEndDetails d) {
    final cepat = d.velocity.pixelsPerSecond.dy < -350;
    final jauh = _dragDy <= -140;
    setState(() => _dragging = false);
    if (cepat || jauh) {
      _go();
    } else {
      setState(() => _dragDy = 0); // memantul kembali (animasi implisit)
    }
  }

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Sp.bg,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _go,
        onVerticalDragUpdate: _onDragUpdate,
        onVerticalDragEnd: _onDragEnd,
        child: Stack(
          children: [
            // ---------------- Gelombang emas (paling belakang) -------------
            Positioned.fill(
              child: CustomPaint(painter: _WavePainter()),
            ),

            // ---------------- Konten ---------------------------------------
            SafeArea(
              child: AnimatedContainer(
                duration: _dragging
                    ? Duration.zero
                    : const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                transform: Matrix4.translationValues(0, _dragDy, 0),
                child: Column(
                  children: [
                    // Logo kiri atas
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
                      child: Row(
                        children: [
                          CustomPaint(
                            size: const Size(38, 32),
                            painter: _BrainPainter(showPlus: false),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '+ MigraCare',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              color: _Sp.gold,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 2),

                    // Ilustrasi otak besar
                    CustomPaint(
                      size: const Size(230, 200),
                      painter: _BrainPainter(),
                    ),

                    const SizedBox(height: 36),

                    // Judul
                    const Text(
                      'Your Migraine\nHealth Companion',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        height: 1.35,
                        color: _Sp.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Deskripsi
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 36),
                      child: Text(
                        'Aplikasi yang membantu Anda melakukan skrining, memantau, mengelola migrain, dan menjaga kesehatan dengan lebih baik',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.7,
                          color: _Sp.textGrey,
                        ),
                      ),
                    ),

                    const Spacer(flex: 3),

                    // Indikator SWIPE (berdenyut)
                    AnimatedBuilder(
                      animation: _bounce,
                      builder: (context, _) {
                        final t =
                            Curves.easeInOut.transform(_bounce.value);
                        return Column(
                          children: [
                            Transform.translate(
                              offset: Offset(0, -6 * t),
                              child: Opacity(
                                opacity: 0.35 + 0.65 * t,
                                child: const Icon(
                                  Icons.keyboard_double_arrow_up_rounded,
                                  color: _Sp.indicator,
                                  size: 26,
                                ),
                              ),
                            ),
                            const Text(
                              'SWIPE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 3,
                                color: _Sp.indicator,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 34),
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

// ===========================================================================
//  TRANSISI HALUS ke Beranda (fade + slide up)
// ===========================================================================
class _SlideUpRoute<T> extends PageRouteBuilder<T> {
  _SlideUpRoute({required Widget page})
      : super(
          transitionDuration: const Duration(milliseconds: 450),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, animation, __, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween(
                  begin: const Offset(0, 0.06),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
        );
}

// ===========================================================================
//  PAINTER: ILUSTRASI OTAK (outline krem, digambar manual)
// ===========================================================================
class _BrainPainter extends CustomPainter {
  _BrainPainter({this.showPlus = true});

  final bool showPlus;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    // Jalur belahan otak kiri (outline + belahan tengah + lipatan)
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

    void drawHalf() {
      // Lapisan lembut di bawah (efek emboss)
      final soft = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.075
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = _Sp.brainSoft;
      canvas.drawPath(half, soft);
      canvas.drawPath(mid, soft);

      // Outline utama
      final main = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.045
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = _Sp.brain;
      canvas.drawPath(half, main);
      canvas.drawPath(mid, main);
      canvas.drawPath(gyri, main);
    }

    drawHalf();

    // Belahan otak kanan = cermin kiri
    canvas.save();
    canvas.translate(w, 0);
    canvas.scale(-1, 1);
    drawHalf();
    canvas.restore();

    // Tanda plus di kanan bawah
    if (showPlus) {
      final cx = w * 0.88, cy = h * 0.76, arm = w * 0.075;
      final plus = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.05
        ..strokeCap = StrokeCap.round
        ..color = _Sp.brain;
      canvas.drawLine(Offset(cx - arm, cy), Offset(cx + arm, cy), plus);
      canvas.drawLine(Offset(cx, cy - arm), Offset(cx, cy + arm), plus);
    }
  }

  @override
  bool shouldRepaint(covariant _BrainPainter oldDelegate) =>
      oldDelegate.showPlus != showPlus;
}

// ===========================================================================
//  PAINTER: GELOMBANG SUTRA EMAS
// ===========================================================================
class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    // Lapis 1 — belakang, krem keemasan transparan
    final p1 = Path()
      ..moveTo(0, h * 0.60)
      ..cubicTo(w * 0.22, h * 0.36, w * 0.42, h * 0.86, w * 0.68, h * 0.62)
      ..cubicTo(w * 0.82, h * 0.50, w * 0.92, h * 0.54, w, h * 0.58)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      p1,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF3E2BE).withValues(alpha: 0.75),
            const Color(0xFFEBC98B).withValues(alpha: 0.45),
          ],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Lapis 2 — emas utama
    final p2 = Path()
      ..moveTo(0, h * 0.82)
      ..cubicTo(w * 0.28, h * 0.58, w * 0.52, h * 1.04, w * 0.78, h * 0.78)
      ..cubicTo(w * 0.88, h * 0.70, w * 0.95, h * 0.70, w, h * 0.74)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    final goldPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: const [Color(0xFFE3B25E), Color(0xFFB87A1D)],
      ).createShader(Rect.fromLTWH(0, h * 0.55, w, h * 0.45));
    canvas.drawPath(p2, goldPaint);

    // Garis kilau di puncak lapis 2
    final sheen = Path()
      ..moveTo(0, h * 0.82)
      ..cubicTo(w * 0.28, h * 0.58, w * 0.52, h * 1.04, w * 0.78, h * 0.78)
      ..cubicTo(w * 0.88, h * 0.70, w * 0.95, h * 0.70, w, h * 0.74);
    canvas.drawPath(
      sheen,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.55),
    );

    // Lapis 3 — pita terang di depan
    final p3 = Path()
      ..moveTo(0, h * 0.94)
      ..cubicTo(w * 0.34, h * 0.74, w * 0.58, h * 1.08, w, h * 0.84)
      ..cubicTo(w * 0.60, h * 1.16, w * 0.34, h * 0.84, 0, h * 1.02)
      ..close();
    canvas.drawPath(
      p3,
      Paint()..color = const Color(0xFFF8E9C9).withValues(alpha: 0.85),
    );
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) => false;
}