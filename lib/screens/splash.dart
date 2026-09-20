import 'package:flutter/material.dart';
import 'onboarding.dart';

/// ==========================================================================
///  MIGRACARE — Splash Screen (swipe up untuk masuk)
///  File: lib/screens/splash.dart
/// ==========================================================================

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
              Positioned(
                left: 0,
                right: 0,
                bottom: 50,
                height: 420, // tinggi area gelombang, coba-coba: 180 / 200 / 230
                child: Image.asset(
                  'assets/images/gelombang.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomCenter,
                ),
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
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Image.asset(
                            'assets/images/logo_atas.png',
                            height: 48,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                    const Spacer(flex: 2),

                    // Ilustrasi otak besar
                    Image.asset (
                      'assets/images/otak_besar.png',
                      width: 240,
                      height: 210,
                      fit: BoxFit.contain,
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
class _Sp {
  static const Color bg = Color(0xFFFDF9F4);
  static const Color textDark = Color(0xFF3A3028);
  static const Color textGrey = Color(0xFF8A8178);
  static const Color indicator = Color(0xFFC5A46D);
}