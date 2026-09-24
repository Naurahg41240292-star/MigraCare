import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash.dart'; // ← dulu: screens/beranda.dart

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MigracareApp());
}

class MigracareApp extends StatelessWidget {
  const MigracareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Migracare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6B4A2B)),
        scaffoldBackgroundColor: const Color(0xFFFAF4EA),
      ),
      home: const SplashScreen(),
    );
  }
}