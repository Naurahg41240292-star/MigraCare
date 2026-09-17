import 'package:flutter/material.dart';

void main() {
  runApp(const MigraCareApp());
}

class MigraCareApp extends StatelessWidget {
  const MigraCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MigraCare',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB98B73),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F5),

      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF8F5),
        elevation: 0,
        title: const Text(
          'MigraCare',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5C4033),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF5C4033),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Sapaan
            const Text(
              'Halo! 👋',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF806B60),
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              'Jaga kesehatanmu hari ini',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A342A),
              ),
            ),

            const SizedBox(height: 25),

            // Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE8D5C8),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kenali kondisi migrainmu',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5C4033),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Lakukan skrining untuk mengetahui kondisi kesehatanmu.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF806B60),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Fitur MigraCare',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A342A),
              ),
            ),

            const SizedBox(height: 15),

            // Grid fitur
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.15,
              children: [

                FeatureCard(
                  icon: Icons.health_and_safety_outlined,
                  title: 'Skrining',
                  subtitle: 'Cek kondisi migrain',
                  onTap: () {},
                ),

                FeatureCard(
                  icon: Icons.history_rounded,
                  title: 'Riwayat',
                  subtitle: 'Lihat riwayat kesehatan',
                  onTap: () {},
                ),

                FeatureCard(
                  icon: Icons.menu_book_rounded,
                  title: 'Artikel',
                  subtitle: 'Informasi kesehatan',
                  onTap: () {},
                ),

                FeatureCard(
                  icon: Icons.notifications_none_rounded,
                  title: 'Pengingat',
                  subtitle: 'Atur pengingat',
                  onTap: () {},
                ),

                FeatureCard(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'Konsultasi',
                  subtitle: 'Konsultasi kesehatan',
                  onTap: () {},
                ),

                FeatureCard(
                  icon: Icons.local_hospital_outlined,
                  title: 'Layanan',
                  subtitle: 'Informasi layanan kesehatan',
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 25),

            const Text(
              'Tips Kesehatan',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A342A),
              ),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 32,
                    color: Color(0xFFB98B73),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      'Istirahat yang cukup dan kenali pemicu migrainmu.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF66544B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Navigasi bawah
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: const Color(0xFF9B7058),
        unselectedItemColor: const Color(0xFFB7A59B),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: 'Skrining',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined),
            label: 'Artikel',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

// Widget kartu fitur
class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: const Color(0xFFB98B73),
            ),

            const SizedBox(height: 10),

            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5C4033),
              ),
            ),

            const SizedBox(height: 4),

            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF99877D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}