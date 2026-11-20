import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'admin_tambah_dokter.dart';

abstract class _Mu {
  static const bg = Color(0xFFFAF4EA);
  static const gold = Color(0xFFC08A2B);
  static const textDark = Color(0xFF33261A);
  static const textGrey = Color(0xFF9C948A);
  static const outline = Color(0xFFE5DCCB);
}

String _fmtWaktuLalu(DateTime d) {
  final selisih = DateTime.now().difference(d);
  if (selisih.inMinutes < 1) return 'baru saja';
  if (selisih.inMinutes < 60) return '${selisih.inMinutes} menit lalu';
  if (selisih.inHours < 24) return '${selisih.inHours} jam lalu';
  return '${selisih.inDays} hari lalu';
}

/// ==========================================================================
///  MIGRACARE — Halaman MANAJEMEN USER (Admin)
///  Isi: pencarian, tombol Tambah (dokter), filter role,
///       daftar pengguna + ubah role, Riwayat Pengguna Baru.
///  Dibuka dari tab Pengaturan admin (admin_pengaturan.dart).
///  File: lib/screens/admin/admin_manajemen_user.dart
/// ==========================================================================

class AdminManajemenUserPage extends StatefulWidget {
  const AdminManajemenUserPage({super.key});

  @override
  State<AdminManajemenUserPage> createState() => _AdminManajemenUserPageState();
}

class _AdminManajemenUserPageState extends State<AdminManajemenUserPage> {
  late Future<QuerySnapshot<Map<String, dynamic>>> _future;
  String _cari = '';
  String _filter = 'semua'; // semua | pasien | dokter | admin

  @override
  void initState() {
    super.initState();
    _future = FirebaseFirestore.instance.collection('users').get();
  }

  void _muatUlang() {
    setState(() {
      _future = FirebaseFirestore.instance.collection('users').get();
    });
  }

  DateTime? _tanggalDoc(Map<String, dynamic> d) {
    final v = d['akun']?['dibuatPada'];
    if (v is Timestamp) return v.toDate();
    return null;
  }

  String _roleNormal(Map<String, dynamic> d) {
    final r = (d['role'] ?? 'pasien').toString();
    return ['pasien', 'dokter', 'admin'].contains(r) ? r : 'pasien';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Mu.bg,
      appBar: AppBar(
        backgroundColor: _Mu.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Manajemen User',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: _Mu.textDark)),
            Text('Kelola pengguna & akun',
                style: TextStyle(fontSize: 11.5, color: _Mu.textGrey)),
          ],
        ),
      ),
      body: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data!.docs;

          int pasien = 0, dokter = 0, admin = 0;
          for (final d in docs) {
            final r = _roleNormal(d.data());
            if (r == 'dokter') {
              dokter++;
            } else if (r == 'admin') {
              admin++;
            } else {
              pasien++;
            }
          }

          final q = _cari.toLowerCase().trim();
          final hasil = docs.where((doc) {
            final data = doc.data();
            if (_filter != 'semua' && _roleNormal(data) != _filter) return false;
            if (q.isEmpty) return true;
            final nama = (data['profile']?['namaLengkap'] ??
                    data['akun']?['namaLengkap'] ??
                    '')
                .toString()
                .toLowerCase();
            final email =
                (data['akun']?['email'] ?? '').toString().toLowerCase();
            return nama.contains(q) || email.contains(q);
          }).toList()
            ..sort((a, b) {
              final ta = _tanggalDoc(a.data()), tb = _tanggalDoc(b.data());
              if (ta == null && tb == null) return 0;
              if (ta == null) return 1;
              if (tb == null) return -1;
              return tb.compareTo(ta);
            });

          final riwayat = docs
              .where((d) => _tanggalDoc(d.data()) != null)
              .toList()
            ..sort((a, b) =>
                _tanggalDoc(b.data())!.compareTo(_tanggalDoc(a.data())!));

          return RefreshIndicator(
            onRefresh: () async => _muatUlang(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                // ---- pencarian + tombol tambah ----
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (v) => setState(() => _cari = v),
                        decoration: InputDecoration(
                          hintText: 'Cari nama atau email...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          isDense: true,
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.zero,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFC9822E),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                      ),
                      onPressed: _bukaSheetTambah,
                      icon: const Icon(Icons.person_add_alt_1_rounded,
                          size: 18),
                      label: const Text('Tambah', style: TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ---- filter role ----
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _chip('semua', 'Semua', docs.length),
                    _chip('pasien', 'Pasien', pasien),
                    _chip('dokter', 'Dokter', dokter),
                    _chip('admin', 'Admin', admin),
                  ],
                ),
                const SizedBox(height: 12),

                // ---- daftar pengguna ----
                if (hasil.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                        child: Text('Tidak ada pengguna yang cocok.',
                            style: TextStyle(
                                fontSize: 12.5, color: _Mu.textGrey))),
                  )
                else
                  for (final doc in hasil) _kartuUser(doc),

                const SizedBox(height: 22),

                // ---- riwayat pengguna baru ----
                const Text('Riwayat Pengguna Baru',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _Mu.textDark)),
                const SizedBox(height: 10),
                if (riwayat.isEmpty)
                  const Text('Belum ada riwayat pendaftaran.',
                      style: TextStyle(fontSize: 12, color: _Mu.textGrey))
                else
                  for (final d in riwayat.take(5)) _itemRiwayat(d.data()),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _chip(String nilai, String label, int jumlah) {
    final terpilih = _filter == nilai;
    return ChoiceChip(
      label: Text('$label ($jumlah)'),
      selected: terpilih,
      onSelected: (_) => setState(() => _filter = nilai),
      selectedColor: _Mu.gold,
      showCheckmark: false,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: terpilih ? Colors.white : _Mu.textDark),
    );
  }

  Widget _kartuUser(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final role = _roleNormal(data);
    final nama = (data['profile']?['namaLengkap'] ??
            data['akun']?['namaLengkap'] ??
            'Tanpa nama')
        .toString();
    final email = (data['akun']?['email'] ?? '-').toString();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _Mu.outline),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nama,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _Mu.textDark)),
                Text(email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(fontSize: 11, color: _Mu.textGrey)),
              ],
            ),
          ),
          DropdownButton<String>(
            value: role,
            underline: const SizedBox(),
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _Mu.gold),
            items: const [
              DropdownMenuItem(value: 'pasien', child: Text('Pasien')),
              DropdownMenuItem(value: 'dokter', child: Text('Dokter')),
              DropdownMenuItem(value: 'admin', child: Text('Admin')),
            ],
            onChanged: (v) async {
              if (v == null || v == role) return;
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(doc.id)
                  .update({'role': v});
              _muatUlang();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Role $nama diubah menjadi $v')));
            },
          ),
        ],
      ),
    );
  }

  Widget _itemRiwayat(Map<String, dynamic> data) {
    final role = _roleNormal(data);
    final nama = (data['profile']?['namaLengkap'] ??
            data['akun']?['namaLengkap'] ??
            'Tanpa nama')
        .toString();
    final tgl = _tanggalDoc(data)!;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _Mu.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
                color: Color(0xFFFDF3D7), shape: BoxShape.circle),
            child: Icon(
                role == 'dokter'
                    ? Icons.medical_services_outlined
                    : Icons.person_rounded,
                color: const Color(0xFFC99A2C),
                size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    role == 'dokter'
                        ? 'Dokter baru terdaftar'
                        : 'Pengguna baru mendaftar',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _Mu.textDark)),
                Text(nama,
                    style: const TextStyle(
                        fontSize: 11.5, color: _Mu.textGrey)),
              ],
            ),
          ),
          Text(_fmtWaktuLalu(tgl),
              style: const TextStyle(fontSize: 10.5, color: _Mu.textGrey)),
        ],
      ),
    );
  }

  void _bukaSheetTambah() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tambah Pengguna',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _Mu.textDark)),
              const SizedBox(height: 4),
              const Text('Pilih jenis akun yang ingin dibuat:',
                  style: TextStyle(fontSize: 12, color: _Mu.textGrey)),
              const SizedBox(height: 14),
              _opsiAkun(
                ctx,
                ikon: Icons.medical_services_rounded,
                judul: 'Tambah Dokter',
                deskripsi: 'Buat akun login untuk dokter',
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AdminTambahDokterPage()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _opsiAkun(BuildContext ctx,
      {required IconData ikon,
      required String judul,
      required String deskripsi,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFDF3D7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _Mu.outline),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
              child: Icon(ikon, color: const Color(0xFFC99A2C), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(judul,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5,
                          color: _Mu.textDark)),
                  Text(deskripsi,
                      style: const TextStyle(
                          fontSize: 11.5, color: _Mu.textGrey)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: _Mu.textGrey),
          ],
        ),
      ),
    );
  }
}