import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class _Ak {
  static const Color bg = Color(0xFFFAF4EA);
  static const Color gold = Color(0xFFC08A2B);
  static const Color textDark = Color(0xFF33261A);
  static const Color textGrey = Color(0xFF9C948A);
  static const Color outline = Color(0xFFE5DCCB);
}

/// ==========================================================================
///  MIGRACARE — Panel Admin (kelola role pengguna)
///  File: lib/screens/admin_panel.dart
/// ==========================================================================

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  bool _loading = true;
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    setState(() => _loading = true);
    try {
      final snap =
          await FirebaseFirestore.instance.collection('users').get();
      if (!mounted) return;
      setState(() {
        _users = snap.docs.map((d) {
          final data = d.data();
          return {
            'uid': d.id,
            'nama': (data['profile']?['namaLengkap'] ??
                    data['akun']?['namaLengkap'] ??
                    'Tanpa nama') as String,
            'email': (data['akun']?['email'] ?? '-') as String,
            'role': (data['role'] ?? 'pasien') as String,
          };
        }).toList();
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal memuat user: $e')));
      }
    }
  }

  Future<void> _ubahRole(String uid, String role) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'role': role});
    _muat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Ak.bg,
      appBar: AppBar(
        backgroundColor: _Ak.bg,
        elevation: 0,
        centerTitle: false,
        title: const Text('Panel Admin',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: _Ak.textDark)),
        actions: [
          IconButton(
            onPressed: _muat,
            icon: const Icon(Icons.refresh_rounded, color: _Ak.textDark),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _muat,
              child: _users.isEmpty
                  ? ListView(children: const [
                      SizedBox(height: 140),
                      Center(
                          child: Text('Belum ada pengguna terdaftar.',
                              style: TextStyle(color: _Ak.textGrey))),
                    ])
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      itemCount: _users.length,
                      itemBuilder: (context, i) {
                        final u = _users[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: _Ak.outline),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: const Color(0xFFF6DFC8),
                                child: Text(
                                  u['nama'].toString().isEmpty
                                      ? '?'
                                      : u['nama']
                                          .toString()[0]
                                          .toUpperCase(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: _Ak.gold),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(u['nama'],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: _Ak.textDark)),
                                    const SizedBox(height: 2),
                                    Text(u['email'],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: _Ak.textGrey)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              DropdownButton<String>(
                                value: u['role'],
                                underline: const SizedBox(),
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _Ak.gold),
                                items: const [
                                  DropdownMenuItem(
                                      value: 'pasien',
                                      child: Text('Pasien')),
                                  DropdownMenuItem(
                                      value: 'dokter',
                                      child: Text('Dokter')),
                                  DropdownMenuItem(
                                      value: 'admin',
                                      child: Text('Admin')),
                                ],
                                onChanged: (v) {
                                  if (v != null && v != u['role']) {
                                    _ubahRole(u['uid'], v);
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}