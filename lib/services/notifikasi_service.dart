import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Service notifikasi untuk panel Admin:
/// - Badge lonceng: mendeteksi pengguna baru lewat Firestore
/// - FCM: izin notifikasi + token + pesan saat app foreground
class NotifikasiService {
  NotifikasiService._();

  static final ValueNotifier<int> penggunaBaru = ValueNotifier<int>(0);
  static StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;
  static bool _sudahInit = false;
  static bool _snapshotPertama = false;

  static Future<void> init() async {
    if (_sudahInit) return;
    _sudahInit = true;

    // 1) Pantau koleksi users -> deteksi pengguna yang baru mendaftar
    _sub = FirebaseFirestore.instance.collection('users').snapshots().listen(
      (snap) {
        // snapshot pertama = data lama, jangan dihitung sebagai "baru"
        if (!_snapshotPertama) {
          _snapshotPertama = true;
          return;
        }
        for (final change in snap.docChanges) {
          if (change.type == DocumentChangeType.added) {
            penggunaBaru.value++;
          }
        }
      },
    );

    // 2) Izin notifikasi FCM (Android 13+ butuh permission)
    try {
      final fcm = FirebaseMessaging.instance;
      await fcm.requestPermission();
      final token = await fcm.getToken();
      debugPrint('FCM Token: $token');
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint(
            'Notifikasi (foreground): ${message.notification?.title}');
      });
    } catch (e) {
      debugPrint('FCM dilewati: $e');
    }
  }
}