import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/auth/splash.dart';
import 'screens/alarm_screen.dart';
import 'services/notifikasi_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService.instance.init();
  await NotificationService.instance.requestPermissions();

  NotificationService.instance.onTapNotification = (response) {
    _handleNotificationTap(response.payload);
  };

  final launchDetails = await NotificationService.instance.getLaunchDetails();
  if (launchDetails != null && launchDetails.payload != null) {
    Future.delayed(const Duration(milliseconds: 500), () {
      _handleNotificationTap(launchDetails.payload);
    });
  }

  runApp(const MigracareApp());
}

void _handleNotificationTap(String? payload) {
  if (payload == null || payload.isEmpty) return;

  final context = navigatorKey.currentContext;
  if (context == null) return;

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => AlarmScreen(payload: payload),
    ),
  );
}

class MigracareApp extends StatelessWidget {
  const MigracareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Migracare',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6B4A2B)),
        scaffoldBackgroundColor: const Color(0xFFFAF4EA),
      ),
      home: const SplashScreen(),
    );
  }
}