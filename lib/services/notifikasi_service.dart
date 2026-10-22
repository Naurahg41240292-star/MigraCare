import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/obat.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const String _channelId = 'pengingat_obat_channel_v2';
  static const String _channelName = 'Pengingat Obat';
  static const String _channelDesc =
      'Notifikasi pengingat untuk minum obat sesuai jadwal';

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    try {
      final TimezoneInfo info = await FlutterTimezone.getLocalTimezone();
      final String timeZoneName = info.identifier;
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {}

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    await _createAndroidChannel();
    _initialized = true;
  }

  Future<void> _createAndroidChannel() async {
    final AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.high,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('alarm'),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([
        0, 1000, 500, 1000, 500, 1000, 500, 1000, 500, 1000,
      ]),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<bool> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final androidGranted =
        await android?.requestNotificationsPermission() ?? false;

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final iosGranted = await ios?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        false;

    return androidGranted || iosGranted;
  }

  Future<NotificationResponse?> getLaunchDetails() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    return details?.notificationResponse;
  }

  void Function(NotificationResponse)? onTapNotification;

  void _onNotificationTap(NotificationResponse response) {
    onTapNotification?.call(response);
  }

  int _idDariObatJam(String obatId, String jam) {
    final raw = '$obatId|$jam';
    return raw.hashCode & 0x7FFFFFFF;
  }

  String _buildPayload({
    required String obatId,
    required String nama,
    required String dosis,
    required String bentuk,
    required String aturan,
    required String jam,
  }) {
    return jsonEncode({
      'obatId': obatId,
      'nama': nama,
      'dosis': dosis,
      'bentuk': bentuk,
      'aturan': aturan,
      'jam': jam,
    });
  }

  Future<void> jadwalkanSatu({
    required Obat obat,
    required String jam,
  }) async {
    final parts = jam.split('.');
    final hour = int.tryParse(parts[0]) ?? 8;
    final minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;

    final id = _idDariObatJam(obat.id, jam);

    final payload = _buildPayload(
      obatId: obat.id,
      nama: obat.nama,
      dosis: obat.dosis,
      bentuk: obat.bentukSediaan,
      aturan: obat.aturanPakai,
      jam: jam,
    );

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFFB07E1F),
      playSound: true,
      enableVibration: true,
      sound: const RawResourceAndroidNotificationSound('alarm'),
      ongoing: true,
      autoCancel: true,
      category: AndroidNotificationCategory.alarm,
      fullScreenIntent: true,
      additionalFlags: Int32List.fromList([4]),
      vibrationPattern: Int64List.fromList([
        0, 1000, 500, 1000, 500, 1000, 500, 1000, 500, 1000,
      ]),
      styleInformation: BigTextStyleInformation(
        '${obat.nama} ${obat.dosis}\n'
        '${obat.bentukSediaan} • ${obat.aturanPakai}'
        '${obat.catatanMinum.isNotEmpty ? '\n${obat.catatanMinum}' : ''}',
        contentTitle: '⏰ SAATNYA MINUM OBAT: ${obat.nama}',
        summaryText: 'Pengingat Obat - MigraCare',
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id: id,
      title: '⏰ Saatnya minum obat: ${obat.nama}',
      body: '${obat.nama} ${obat.dosis} • ${obat.bentukSediaan}',
      scheduledDate: scheduled,
      notificationDetails: details,
      payload: payload,
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> jadwalkanObat(Obat obat) async {
    for (final jam in obat.jamList) {
      await jadwalkanSatu(obat: obat, jam: jam);
    }
  }

  Future<void> batalkanObat(Obat obat) async {
    for (final jam in obat.jamList) {
      final id = _idDariObatJam(obat.id, jam);
      await _plugin.cancel(id: id);
    }
  }

  Future<void> batalkanSemua() async {
    await _plugin.cancelAll();
  }

  Future<void> batalkanNotifikasiAktif(String obatId, String jam) async {
    final id = _idDariObatJam(obatId, jam);
    await _plugin.cancel(id: id);
  }

  Future<void> tundaNotifikasi({
    required String obatId,
    required String nama,
    required String dosis,
    required String bentuk,
    required String aturan,
    required String jam,
    required int menitTunda,
  }) async {
    final idTunda = '$obatId|${jam}_tunda'.hashCode & 0x7FFFFFFF;

    final payload = _buildPayload(
      obatId: obatId,
      nama: nama,
      dosis: dosis,
      bentuk: bentuk,
      aturan: aturan,
      jam: jam,
    );

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFFB07E1F),
      playSound: true,
      enableVibration: true,
      sound: const RawResourceAndroidNotificationSound('alarm'),
      ongoing: true,
      autoCancel: true,
      category: AndroidNotificationCategory.alarm,
      fullScreenIntent: true,
      additionalFlags: Int32List.fromList([4]),
      vibrationPattern: Int64List.fromList([
        0, 1000, 500, 1000, 500, 1000, 500, 1000, 500, 1000,
      ]),
      styleInformation: BigTextStyleInformation(
        '$nama $dosis\n$bentuk • $aturan',
        contentTitle: '⏰ PENGINGAT DITUNDA: $nama',
        summaryText: 'Pengingat Obat - MigraCare',
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final scheduled = tz.TZDateTime.now(tz.local).add(
      Duration(minutes: menitTunda),
    );

    await _plugin.zonedSchedule(
      id: idTunda,
      title: '⏰ Pengingat ditunda: $nama',
      body: '$nama $dosis • $bentuk',
      scheduledDate: scheduled,
      notificationDetails: details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> rescheduleSemua() async {
    if (!_initialized) await init();

    await batalkanSemua();

    final store = PengingatStore.instance;
    await store.muatDariDisk();

    for (final obat in store.daftarObat) {
      await jadwalkanObat(obat);
    }
  }

  Future<List<PendingNotificationRequest>> lihatJadwalPending() async {
    return await _plugin.pendingNotificationRequests();
  }
}