import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'onboarding.dart';

/// ==========================================================================
///  MIGRACARE — Splash Screen v3 (latar gradasi menyatu + animasi)
///  File: lib/screens/splash.dart
/// ==========================================================================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _float;
  late final AnimationController _bounce;

  late final Animation<double> _waveFade;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoSlide;
  late final Animation<double> _brainFade;
  late final Animation<double> _brainScale;
  late final Animation<double> _textFade;
  late final Animation<double> _textSlide;
  late final Animation<double> _descFade;
  late final Animation<double> _indicatorFade;

  double _dragDy = 0;
  bool _dragging = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _waveFade = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );
    _logoFade = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.08, 0.38, curve: Curves.easeOut),
    );
    _logoSlide = Tween<double>(begin: -16, end: 0).animate(_logoFade);
    _brainFade = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
    );
    _brainScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.2, 0.65, curve: Curves.easeOutBack),
      ),
    );
    _textFade = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.42, 0.78, curve: Curves.easeOut),
    );
    _textSlide = Tween<double>(begin: 24, end: 0).animate(_textFade);
    _descFade = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.55, 0.88, curve: Curves.easeOut),
    );
    _indicatorFade = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
    );

    _entrance.forward();

    _float = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
      lowerBound: 0,
      upperBound: 1,
    )..repeat(reverse: true);

    _bounce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
      lowerBound: 0,
      upperBound: 1,
    )..repeat(reverse: true);
  }

  void _go() {
    if (_navigated || !mounted) return;
    _navigated = true;
    HapticFeedback.lightImpact();
    Navigator.of(context).pushReplacement(
      _SlideUpRoute(page: const OnboardingPage()),
    );
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (d.delta.dy >= 0) return;
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
      setState(() => _dragDy = 0);
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    _float.dispose();
    _bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Sp.bgTop,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _go,
        onVerticalDragUpdate: _onDragUpdate,
        onVerticalDragEnd: _onDragEnd,
        child: Stack(
          children: [
            // ============ LAPISAN 1: GRADASI LATAR PENUH ============
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _Sp.bgTop,     // atas: hampir putih
                      _Sp.bgMid,     // tengah: krem lembut
                      _Sp.bgBottom,  // bawah: krem keemasan (nyatu dgn gelombang)
                    ],
                    stops: [0.0, 0.52, 1.0],
                  ),
                ),
              ),
            ),

            // ===== LAPISAN 2: GELOMBANG (fade di tepi atas → menyatu) =====
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 470,
              child: ShaderMask(
                // Fade: 25% atas gelombang dibuat transparan bertahap
                shaderCallback: (rect) => LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.white,
                  ],
                  stops: const [0.0, 0.28],
                ).createShader(rect),
                blendMode: BlendMode.dstIn,
                child: FadeTransition(
                  opacity: _waveFade,
                  child: Image.asset(
                    'assets/images/gelombang.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // ============================ KONTEN ============================
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
                        child: AnimatedBuilder(
                          animation: _logoFade,
                          builder: (context, child) => Opacity(
                            opacity: _logoFade.value,
                            child: Transform.translate(
                              offset: Offset(0, _logoSlide.value),
                              child: child,
                            ),
                          ),
                          child: Image.asset(
                            'assets/images/logo_atas.png',
                            height: 48,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),

                    const Spacer(flex: 2),

                    // ======== Otak: pop masuk + melayang + glow ========
                    AnimatedBuilder(
                      animation:
                          Listenable.merge([_brainFade, _float, _entrance]),
                      builder: (context, child) {
                        final naikTurun =
                            Curves.easeInOut.transform(_float.value);
                        final glowOpacity = 0.12 + 0.08 * naikTurun;
                        final melayang = -7.0 * naikTurun;

                        return Opacity(
                          opacity: _brainFade.value,
                          child: Transform.scale(
                            scale: _brainScale.value,
                            child: SizedBox(
                              width: 260,
                              height: 240,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Halo glow lembut — warnanya menyatu
                                  // dengan gradasi latar
                                  Container(
                                    width: 230,
                                    height: 230,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          _Sp.glow.withOpacity(glowOpacity),
                                          _Sp.glow
                                              .withOpacity(glowOpacity * 0.4),
                                          _Sp.glow.withOpacity(0),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Transform.translate(
                                    offset: Offset(0, melayang),
                                    child: child,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      child: Image.asset(
                        'assets/images/otak_besar.png',
                        width: 240,
                        height: 210,
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Judul
                    AnimatedBuilder(
                      animation: _textFade,
                      builder: (context, child) => Opacity(
                        opacity: _textFade.value,
                        child: Transform.translate(
                          offset: Offset(0, _textSlide.value),
                          child: child,
                        ),
                      ),
                      child: const Text(
                        'Your Migraine\nHealth Companion',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          height: 1.35,
                          color: _Sp.textDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Deskripsi
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 36),
                      child: FadeTransition(
                        opacity: _descFade,
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
                    ),

                    const Spacer(flex: 3),

                    // Indikator SWIPE
                    AnimatedBuilder(
                      animation: Listenable.merge([_bounce, _indicatorFade]),
                      builder: (context, _) {
                        final t = Curves.easeInOut.transform(_bounce.value);
                        return Opacity(
                          opacity: _indicatorFade.value,
                          child: Column(
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
                          ),
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
//  TRANSISI HALUS ke Onboarding
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

class _Sp {
  // ---- Warna gradasi latar (atas → bawah, makin hangat) ----
  static const Color bgTop = Color(0xFFFDFBF7);
  static const Color bgMid = Color(0xFFFAF2E3);
  static const Color bgBottom = Color(0xFFF6E7C6);

  static const Color bg = bgTop; // fallback
  static const Color textDark = Color(0xFF3A3028);
  static const Color textGrey = Color(0xFF8A8178);
  static const Color indicator = Color(0xFFC5A46D);
  static const Color glow = Color(0xFFE8C77D);
}