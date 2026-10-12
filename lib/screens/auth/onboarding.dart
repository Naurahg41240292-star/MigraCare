import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'welcome.dart';

/// ==========================================================================
///  MIGRACARE — Onboarding v3
///  Teks di ATAS · gambar TIMBUL di kartu · dekorasi kilau ✦ (tanpa bulat)
///  File: lib/screens/onboarding.dart
/// ==========================================================================

abstract class _Ob {
  static const Color bgTop = Color(0xFFFDFBF7);
  static const Color bgBottom = Color(0xFFFAF1DE);
  static const Color button1 = Color(0xFFD69348);
  static const Color button2 = Color(0xFFBC7D33);
  static const Color textDark = Color(0xFF33261A);
  static const Color textGrey = Color(0xFF8F8578);
  static const Color dotActive = Color(0xFFBC7D33);
  static const Color dotInactive = Color(0xFFE3D7C0);
  static const Color sparkle = Color(0xFFE0A852); // kilauan bintang
  static const Color sparkleSoft = Color(0xFFF0CE8E);
  static const Color cardBorder = Color(0xFFF3E7CE);
}

class _OnboardData {
  const _OnboardData({
    required this.title,
    required this.description,
    required this.image,
  });

  final String title;
  final String description;
  final String image;
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  final PageController _controller = PageController();
  int _index = 0;

  late final AnimationController _float;

  static const List<_OnboardData> _pages = [
    _OnboardData(
      title: 'Kenali Migraine Anda',
      description:
          'Aplikasi yang membantu Anda melakukan skrining, memantau, mengelola migrain, dan menjaga kesehatan dengan lebih baik',
      image: 'assets/images/foto_onboarding 1.png',
    ),
    _OnboardData(
      title: 'Pantau Migraine Anda',
      description:
          'Catat intensitas, durasi, gejala, dan pemicu migraine dari waktu ke waktu',
      image: 'assets/images/foto_onboarding 2.png',
    ),
    _OnboardData(
      title: 'Kelola Kesehatan Anda',
      description:
          'Dapatkan wawasan dan rekomendasi pribadi berbantuan AI untuk hidup lebih nyaman tanpa migrain',
      image: 'assets/images/foto_onboarding 3.png',
    ),
  ];

  bool get _isLast => _index == _pages.length - 1;

  @override
  void initState() {
    super.initState();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
      lowerBound: 0,
      upperBound: 1,
    )..repeat(reverse: true);
  }

  void _next() {
    if (_isLast) {
      Navigator.of(context).push(_FadeRoute(page: const WelcomePage()));
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  void _skip() {
    Navigator.of(context).push(_FadeRoute(page: const WelcomePage()));
  }

  @override
  void dispose() {
    _controller.dispose();
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final judulFont = GoogleFonts.poppins;
    final isiFont = GoogleFonts.poppins;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_Ob.bgTop, _Ob.bgBottom],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ================= BAR ATAS =================
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 12, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) {
                        final page =
                            _controller.hasClients ? (_controller.page ?? 0) : 0.0;
                        final nomor = (page.round() + 1).toString().padLeft(2, '0');
                        return Text(
                          '$nomor / ${_pages.length.toString().padLeft(2, '0')}',
                          style: isiFont(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                            color: _Ob.dotInactive,
                          ),
                        );
                      },
                    ),
                    TextButton(
                      onPressed: _skip,
                      style: TextButton.styleFrom(
                        foregroundColor: _Ob.textGrey,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      child: Text(
                        'Lewati',
                        style: isiFont(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ================= HALAMAN SWIPE (parallax) =================
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (i) {
                    HapticFeedback.selectionClick();
                    setState(() => _index = i);
                  },
                  itemBuilder: (context, i) {
                    return AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        double offset = 0;
                        if (_controller.hasClients &&
                            _controller.position.haveDimensions) {
                          offset = (_controller.page ?? 0) - i;
                        }
                        final abs = offset.abs();
                        return Opacity(
                          opacity: (1 - abs * 0.55).clamp(0.0, 1.0),
                          child: Transform.translate(
                            offset: Offset(offset * -46, 0),
                            child: Transform.scale(
                              scale: 1.0 - (abs * 0.06),
                              child: child,
                            ),
                          ),
                        );
                      },
                      child: _SlideContent(data: _pages[i], float: _float),
                    );
                  },
                ),
              ),

              // ================= INDIKATOR (pill kecil) =================
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (i) {
                  final active = i == _index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 28 : 14,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active ? _Ob.dotActive : _Ob.dotInactive,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 26),

              // ================= TOMBOL GRADIEN =================
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [_Ob.button1, _Ob.button2],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _Ob.button1.withOpacity(0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: _next,
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: Row(
                              key: ValueKey(_isLast),
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _isLast ? 'Mulai Sekarang' : 'Selanjutnya',
                                  style: judulFont(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  _isLast
                                      ? Icons.rocket_launch_rounded
                                      : Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
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
    );
  }
}

// ===========================================================================
//  ISI SATU HALAMAN — teks di atas, gambar melayang + bayangan tanah
// ===========================================================================
class _SlideContent extends StatelessWidget {
  const _SlideContent({required this.data, required this.float});

  final _OnboardData data;
  final AnimationController float;

  @override
  Widget build(BuildContext context) {
    final judulFont = GoogleFonts.poppins;
    final isiFont = GoogleFonts.poppins;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const SizedBox(height: 24),

          // ================= JUDUL =================
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeOutCubic,
            builder: (context, t, child) {
              return Opacity(
                opacity: t.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - t)),
                  child: child,
                ),
              );
            },
            child: Text(
              data.title,
              textAlign: TextAlign.center,
              style: judulFont(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                height: 1.3,
                color: _Ob.textDark,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ================= DESKRIPSI =================
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOut,
            builder: (context, t, child) {
              return Opacity(
                opacity: (t * 0.92).clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0, 14 * (1 - t)),
                  child: child,
                ),
              );
            },
            child: Text(
              data.description,
              textAlign: TextAlign.center,
              style: isiFont(
                fontSize: 17,
                height: 1.6,
                fontWeight: FontWeight.w500,
                color: _Ob.textGrey,
              ),
            ),
          ),

          // ========== GAMBAR MELAYANG + BAYANGAN TANAH ==========
          Expanded(
            child: Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 750),
                curve: Curves.easeOutBack,
                builder: (context, t, child) {
                  return Opacity(
                    opacity: t.clamp(0.0, 1.0),
                    child: Transform.scale(
                        scale: 0.88 + 0.12 * t, child: child),
                  );
                },
                child: AnimatedBuilder(
                  animation: float,
                  builder: (context, child) {
                    final t = Curves.easeInOut.transform(float.value);
                    return Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        // ---- Bayangan "tanah" di bawah gambar ----
                        Positioned(
                          bottom: 2,
                          child: Opacity(
                            opacity: (0.75 - 0.3 * t).clamp(0.0, 1.0),
                            child: Container(
                              width: 185 - 18 * t,
                              height: 20,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                gradient: const RadialGradient(
                                  colors: [
                                    Color(0x4DC08A4A),
                                    Color(0x00C08A4A),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        // ---- Gambar utama melayang ----
                        Transform.translate(
                          offset: Offset(0, -10 * t),
                          child: child,
                        ),
                      ],
                    );
                  },
                  child: Image.asset(
                    data.image,
                    width: 265,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
//  TRANSISI ANTAR HALAMAN
// ===========================================================================
class _FadeRoute<T> extends PageRouteBuilder<T> {
  _FadeRoute({required Widget page})
      : super(
          transitionDuration: const Duration(milliseconds: 450),
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
                  begin: const Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
        );
}