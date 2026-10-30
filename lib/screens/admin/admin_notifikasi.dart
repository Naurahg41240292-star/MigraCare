import 'package:flutter/material.dart';

import '../../services/notifikasi_service.dart';

/// ============================================================
///  MIGRACARE — Halaman Notifikasi Admin
///  File: lib/screens/admin/admin_notifikasi.dart
///  Dibuka dari ikon lonceng di beranda admin.
///  Menampilkan daftar notifikasi (mis. pengguna baru mendaftar).
/// ============================================================
class AdminNotifikasiPage extends StatefulWidget {
  const AdminNotifikasiPage({super.key});

  @override
  State<AdminNotifikasiPage> createState() => _AdminNotifikasiPageState();
}

class _AdminNotifikasiPageState extends State<AdminNotifikasiPage> {
  static const Color bg = Color(0xFFFAF4EA);
  static const Color textDark = Color(0xFF33261A);
  static const Color textGrey = Color(0xFF9C948A);
  static const Color outline = Color(0xFFE5DCCB);

  @override
  void initState() {
    super.initState();
    // Halaman sudah dibuka -> badge lonceng kembali 0
    NotifikasiService.tandaiSudahDibaca();
  }

  String _waktuLalu(String iso) {
    final d = DateTime.tryParse(iso);
    if (d == null) return '';
    final selisih = DateTime.now().difference(d);
    if (selisih.inMinutes < 1) return 'baru saja';
    if (selisih.inMinutes < 60) return '${selisih.inMinutes} menit lalu';
    if (selisih.inHours < 24) return '${selisih.inHours} jam lalu';
    return '${selisih.inDays} hari lalu';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: textDark),
        title: const Text('Notifikasi',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: textDark)),
      ),
      body: ValueListenableBuilder<List<Map<String, String>>>(
        valueListenable: NotifikasiService.daftarNotifikasi,
        builder: (context, daftar, _) {
          if (daftar.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.notifications_off_outlined,
                      size: 56, color: textGrey),
                  SizedBox(height: 12),
                  Text('Belum ada notifikasi',
                      style: TextStyle(fontSize: 13, color: textGrey)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            itemCount: daftar.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final n = daftar[i];
              final dokter = (n['judul'] ?? '').contains('Dokter');
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: outline),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFDF3D7),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        dokter
                            ? Icons.medical_services_outlined
                            : Icons.person_rounded,
                        color: const Color(0xFFC99A2C),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(n['judul'] ?? '-',
                              style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: textDark)),
                          const SizedBox(height: 2),
                          Text(n['isi'] ?? '-',
                              style: const TextStyle(
                                  fontSize: 12, color: textGrey)),
                        ],
                      ),
                    ),
                    Text(_waktuLalu(n['waktu'] ?? ''),
                        style: const TextStyle(
                            fontSize: 10.5, color: textGrey)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
