import 'package:flutter/material.dart';
import 'welcome.dart';

/// ==========================================================================
///  MIGRACARE — Onboarding (3 halaman, swipe kiri/kanan)
///  File: lib/screens/onboarding.dart
/// ==========================================================================

abstract class _Ob {
  static const Color bg = Color(0xFFFAF4EA);
  static const Color button = Color(0xFFD69348);
  static const Color textDark = Color(0xFF33261A);
  static const Color textGrey = Color(0xFF8F8578);
  static const Color dotActive = Color(0xFF8A6A3F);
  static const Color dotInactive = Color(0xFFD9CCB4);
  static const Color glow = Color(0xFFF7EDD9);
}

/// Elemen dekoratif di sekitar ilustrasi utama
class _Deco {
  const _Deco(this.emoji, this.alignment, this.size, {this.rotation = 0});
  final String emoji;
  final Alignment alignment;
  final double size;
  final double rotation;
}

/// Data satu halaman onboarding
class _OnboardData {
  const _OnboardData({
    required this.title,
    required this.description,
    required this.emoji,
    required this.decorations,
  });

  final String title;
  final String description;
  final String emoji;
  final List<_Deco> decorations;
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _index = 0;

  static const List<_OnboardData> _pages = [
    _OnboardData(
      title: 'Kenali Migraine Anda',
      description:
          'Aplikasi yang membantu Anda melakukan skrining, memantau, mengelola migrain, dan menjaga kesehatan dengan lebih baik',
      emoji: '🤦‍♀️',
      decorations: [
        _Deco('🌀', Alignment(-0.72, -0.92), 30),
        _Deco('⚡', Alignment(-0.85, -0.30), 40, rotation: -0.25),
        _Deco('⚡', Alignment(0.78, -0.72), 44, rotation: 0.2),
        _Deco('➕', Alignment(0.88, -0.20), 26),
        _Deco('➕', Alignment(-0.88, 0.20), 20),
        _Deco('✨', Alignment(0.92, 0.15), 18),
      ],
    ),
    _OnboardData(
      title: 'Pantau Migraine Anda',
      description:
          'Catat intensitas, durasi, gejala, dan pemicu migraine dari waktu ke waktu',
      emoji: '📋',
      decorations: [
        _Deco('📅', Alignment(-0.72, -0.85), 42, rotation: -0.1),
        _Deco('⏰', Alignment(0.78, -0.80), 38),
        _Deco('➕', Alignment(0.45, -0.95), 20),
        _Deco('✏️', Alignment(0.80, 0.20), 32, rotation: 0.3),
        _Deco('✨', Alignment(-0.85, 0.15), 20),
      ],
    ),
    _OnboardData(
      title: 'Kelola Kesehatan Anda',
      description:
          'Dapatkan wawasan dan rekomendasi pribadi berbantuan AI untuk hidup lebih nyaman tanpa migrain',
      emoji: '🧠',
      decorations: [
        _Deco('✨', Alignment(0.80, -0.88), 30),
        _Deco('💊', Alignment(-0.80, -0.45), 34, rotation: -0.2),
        _Deco('📈', Alignment(0.78, 0.25), 36),
        _Deco('💛', Alignment(-0.78, 0.50), 24),
      ],
    ),
  ];

  bool get _isLast => _index == _pages.length - 1;

  void _next() {
    if (_isLast) {
      // Halaman terakhir → ke halaman Selamat Datang
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const WelcomePage()),
      );
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Ob.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---------- Halaman (bisa di-swipe kiri/kanan) ------------------
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final data = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        Text(
                          data.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: _Ob.textDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          data.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.7,
                            fontWeight: FontWeight.w500,
                            color: _Ob.textGrey,
                          ),
                        ),
                        Expanded(child: _Illustration(data: data)),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ---------- Indikator titik ------------------------------------
            _Dots(count: _pages.length, activeIndex: _index),
            const SizedBox(height: 26),

            // ---------- Tombol Selanjutnya ---------------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _Ob.button,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _isLast ? 'Mulai Sekarang' : 'Selanjutnya',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
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
//  INDIKATOR TITIK
// ===========================================================================
class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.activeIndex});

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: active ? _Ob.dotActive : _Ob.dotInactive,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}

// ===========================================================================
//  ILUSTRASI (emoji utama + dekorasi + glow lembut — tanpa aset)
//  Nanti kalau sudah punya gambar asli: ganti Text(data.emoji) dengan
//  Image.asset('assets/images/onboard1.png', width: 260).
// ===========================================================================
class _Illustration extends StatelessWidget {
  const _Illustration({required this.data});

  final _OnboardData data;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 300,
        height: 300,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Cahaya lembut di belakang
            Center(
              child: Container(
                width: 240,
                height: 240,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [_Ob.glow, _Ob.bg],
                    stops: [0.0, 1.0],
                  ),
                ),
              ),
            ),
            // Karakter utama
            Center(
              child: Text(data.emoji, style: const TextStyle(fontSize: 120)),
            ),
            // Elemen dekoratif melayang
            for (final d in data.decorations)
              Align(
                alignment: d.alignment,
                child: Transform.rotate(
                  angle: d.rotation,
                  child: Text(d.emoji, style: TextStyle(fontSize: d.size)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}