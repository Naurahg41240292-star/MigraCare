import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_booking.dart';

abstract class _Ct {
  static const Color bg = Color(0xFFFAF4EA);
  static const Color gold = Color(0xFFC08A2B);
  static const Color textDark = Color(0xFF33261A);
  static const Color textGrey = Color(0xFF9C948A);
  static const Color outline = Color(0xFFE5DCCB);
}

/// TAB Chat — daftar booking (semua status) → tap buka ChatBookingPage
class DokterChatView extends StatefulWidget {
  const DokterChatView({super.key});

  @override
  State<DokterChatView> createState() => _DokterChatViewState();
}

class _DokterChatViewState extends State<DokterChatView> {
  bool _loading = true;
  List<Map<String, dynamic>> _bookings = [];

  @override
  void initState() {
    super.initState();
    _muat();
  }

  void muatUlang() => _muat();

  Future<void> _muat() async {
    setState(() => _loading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final snap = await FirebaseFirestore.instance
          .collection('booking')
          .where('dokterUid', isEqualTo: uid)
          .orderBy('dibuatPada', descending: true)
          .get();
      if (!mounted) return;
      setState(() {
        _bookings = snap.docs.map((d) {
          final data = d.data();
          return {
            'id': d.id,
            'pasienNama': (data['pasienNama'] ?? 'Pasien') as String,
            'hari': (data['hari'] ?? '-') as String,
            'tanggal': (data['tanggal'] ?? '') as String,
            'jam': (data['jam'] ?? '-') as String,
            'status': (data['status'] ?? 'menunggu') as String,
          };
        }).toList();
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memuat chat: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Ct.bg,
      appBar: AppBar(
        backgroundColor: _Ct.bg,
        elevation: 0,
        title: const Text('Chat Pasien',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: _Ct.textDark)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _muat,
              child: _bookings.isEmpty
                  ? ListView(children: const [
                      SizedBox(height: 140),
                      Icon(Icons.chat_bubble_outline_rounded,
                          size: 48, color: _Ct.textGrey),
                      SizedBox(height: 12),
                      Center(
                          child: Text('Belum ada chat dengan pasien.',
                              style: TextStyle(
                                  color: _Ct.textGrey, fontSize: 13))),
                    ])
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      itemCount: _bookings.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final b = _bookings[i];
                        final bisaChat = b['status'] == 'dikonfirmasi';
                        return InkWell(
                          onTap: bisaChat
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChatBookingPage(
                                        bookingId: b['id'],
                                        booking: b,
                                        sayaDokter: true,
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: _Ct.outline),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor:
                                      const Color(0xFFF6DFC8),
                                  child: Text(
                                    b['pasienNama']
                                        .toString()
                                        .isEmpty
                                        ? '?'
                                        : b['pasienNama']
                                            .toString()[0]
                                            .toUpperCase(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: _Ct.gold),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(b['pasienNama'],
                                          maxLines: 1,
                                          overflow:
                                              TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight:
                                                  FontWeight.w700,
                                              color: _Ct.textDark)),
                                      const SizedBox(height: 3),
                                      Text(
                                          '${b['hari']}, ${b['tanggal']} • ${b['jam']}',
                                          maxLines: 1,
                                          overflow:
                                              TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontSize: 11.5,
                                              color: _Ct.textGrey)),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: b['status'] == 'dikonfirmasi'
                                        ? const Color(0xFFE4F3E4)
                                        : (b['status'] == 'ditolak'
                                            ? const Color(0xFFFCE8E6)
                                            : const Color(0xFFFDF3D7)),
                                    borderRadius:
                                        BorderRadius.circular(20),
                                  ),
                                  child: Text(b['status'],
                                      style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                          color: b['status'] ==
                                                  'dikonfirmasi'
                                              ? const Color(0xFF3E7C3E)
                                              : (b['status'] == 'ditolak'
                                                  ? const Color(0xFFE55555)
                                                  : const Color(
                                                      0xFFC99A2C)))),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}