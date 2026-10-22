import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../models/obat.dart';
import '../services/notifikasi_service.dart';

class AlarmScreen extends StatefulWidget {
  final String payload;

  const AlarmScreen({super.key, required this.payload});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  static const Color background = Color(0xFFFAF4EA);
  static const Color darkBrown = Color(0xFF3D2B1A);
  static const Color accentDark = Color(0xFFB07E1F);
  static const Color textDark = Color(0xFF33261A);
  static const Color textGrey = Color(0xFF9C948A);
  static const Color green = Color(0xFF3E7C3E);
  static const Color orange = Color(0xFFDE8500);

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isLoading = false;

  String _obatId = '';
  String _namaObat = '';
  String _dosis = '';
  String _bentuk = '';
  String _aturan = '';
  String _jam = '';

  @override
  void initState() {
    super.initState();
    _parsePayload();
    _startAlarm();
  }

  void _parsePayload() {
    try {
      final data = jsonDecode(widget.payload) as Map<String, dynamic>;
      _obatId = data['obatId'] ?? '';
      _namaObat = data['nama'] ?? 'Obat';
      _dosis = data['dosis'] ?? '';
      _bentuk = data['bentuk'] ?? '';
      _aturan = data['aturan'] ?? '';
      _jam = data['jam'] ?? '';
    } catch (_) {
      _namaObat = 'Obat';
    }
  }

  Future<void> _startAlarm() async {
    try {
      await WakelockPlus.enable();
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.play(AssetSource('audio/alarm.mp3'));
    } catch (e) {
      debugPrint('Error start alarm: $e');
    }
  }

  Future<void> _stopAlarm() async {
    try {
      await _audioPlayer.stop();
      await WakelockPlus.disable();
    } catch (_) {}
  }

  Future<void> _sudahDiminum() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    await _stopAlarm();

    try {
      final store = PengingatStore.instance;
      await store.muatDariDisk();
      Obat? obat;
      for (final o in store.daftarObat) {
        if (o.id == _obatId) {
          obat = o;
          break;
        }
      }
      if (obat != null) {
        store.tandaiDiminum(obat, _jam);
      }
    } catch (e) {
      debugPrint('Error tandai diminum: $e');
    }

    try {
      await NotificationService.instance.batalkanNotifikasiAktif(_obatId, _jam);
    } catch (_) {}

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _tunda15Menit() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    await _stopAlarm();

    try {
      await NotificationService.instance.batalkanNotifikasiAktif(_obatId, _jam);
    } catch (_) {}

    try {
      await NotificationService.instance.tundaNotifikasi(
        obatId: _obatId,
        nama: _namaObat,
        dosis: _dosis,
        bentuk: _bentuk,
        aturan: _aturan,
        jam: _jam,
        menitTunda: 15,
      );
    } catch (e) {
      debugPrint('Error tunda notifikasi: $e');
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pengingat ditunda 15 menit'),
        backgroundColor: accentDark,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _stopAlarm();
    _audioPlayer.dispose();
    super.dispose();
  }

  String get _jamTampilan => _jam.replaceAll('.', ':');

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDF3D7),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: accentDark.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.alarm_rounded,
                    size: 64,
                    color: accentDark,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'SAATNYA MINUM OBAT',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: textDark,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pukul $_jamTampilan',
                  style: const TextStyle(
                    fontSize: 16,
                    color: textGrey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEDE3D4)),
                    boxShadow: [
                      BoxShadow(
                        color: darkBrown.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        _namaObat,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$_dosis • $_bentuk',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          color: textGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_aturan.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          _aturan,
                          style: const TextStyle(
                            fontSize: 12,
                            color: textGrey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDF3D7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.info_outline_rounded,
                          size: 18, color: accentDark),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Minum obat tepat waktu untuk hasil optimal',
                          style: TextStyle(
                            fontSize: 12,
                            color: textDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _sudahDiminum,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_circle_rounded, size: 24),
                    label: const Text(
                      'SUDAH DIMINUM',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _tunda15Menit,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: orange,
                      side: const BorderSide(color: orange, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.snooze_rounded, size: 22),
                    label: const Text(
                      'Tunda 15 Menit',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}