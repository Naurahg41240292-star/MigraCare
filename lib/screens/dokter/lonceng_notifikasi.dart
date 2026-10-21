import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dokter_notifikasi.dart';

class _Lk {
  static const gold = Color(0xFFC9822E);
  static const goldSoft = Color(0xFFFDF3D7);
  static const outline = Color(0xFFE5DCCB);
  static const merah = Color(0xFFE55555);
}

// ============================================================
// Ikon lonceng + badge merah = jumlah booking status `menunggu`.
// Real-time (StreamBuilder) -> angka langsung update tanpa refresh.
// Tap -> buka halaman NotifikasiDokterPage.
// Cara pakai: taruh `const LoncengNotifikasi(),` di header Beranda.
// ============================================================

class LoncengNotifikasi extends StatelessWidget {
  const LoncengNotifikasi({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('booking')
          .where('dokterUid', isEqualTo: uid)
          .where('status', isEqualTo: 'menunggu')
          .snapshots(),
      builder: (context, snap) {
        final jumlah = snap.hasData ? snap.data!.docs.length : 0;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Material(
              color: _Lk.goldSoft,
              borderRadius: BorderRadius.circular(13),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const NotifikasiDokterPage()),
                  );
                },
                borderRadius: BorderRadius.circular(13),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: _Lk.outline),
                  ),
                  child: const Icon(
                    Icons.notifications_rounded,
                    size: 22,
                    color: _Lk.gold,
                  ),
                ),
              ),
            ),
            if (jumlah > 0)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  constraints: const BoxConstraints(minWidth: 19),
                  decoration: BoxDecoration(
                    color: _Lk.merah,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Text(
                    jumlah > 99 ? '99+' : '$jumlah',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}