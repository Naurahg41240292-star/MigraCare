import 'package:flutter/material.dart';
import 'screens/beranda.dart';

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
      home: const BerandaPage(),
    );
  }
}
