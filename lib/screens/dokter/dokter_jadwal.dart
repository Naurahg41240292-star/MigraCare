import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class _Jd {
  static const Color bg = Color(0xFFFAF4EA);
  static const Color gold = Color(0xFFC08A2B);
  static const Color textDark = Color(0xFF33261A);
  static const Color textGrey = Color(0xFF9C948A);
  static const Color outline = Color(0xFFE5DCCB);
}

/// TAB Jadwal — CRUD jadwal dokter (revisi #8)
class DokterJadwalView extends StatefulWidget {
  const DokterJadwalView({super.key});

  @override
  State<DokterJadwalView> createState() => _DokterJadwalViewState();
}

class _DokterJadwalViewState extends State<DokterJadwalView> {
  bool _loading = true;
  List<Map<String, dynamic>> _jadwal = [];

  static const List<String> _hariList = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
  ];
  static const int durasiMenit = 30;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  void muatUlang() => _muat();

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('jadwal');

  Future<void> _muat() async {
    setState(() => _loading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final snap = await _col(uid).orderBy('hari').get();
      if (!mounted) return;
      setState(() {
        _jadwal = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memuat jadwal: $e')));
      }
    }
  }

  int _jamKeMenit(String hhmm) {
    final p = hhmm.split(':');
    return (int.tryParse(p[0]) ?? 0) * 60 + (int.tryParse(p[1]) ?? 0);
  }

  String _menitKeJam(int m) {
    final h = (m ~/ 60).toString().padLeft(2, '0');
    final mm = (m % 60).toString().padLeft(2, '0');
    return '$h:$mm';
  }

  List<String> hitungSlot(String mulai, String selesai) {
    final a = _jamKeMenit(mulai);
    final b = _jamKeMenit(selesai);
    return [
      for (var t = a; t + durasiMenit <= b; t += durasiMenit) _menitKeJam(t)
    ];
  }

  Future<void> _formJadwal({Map<String, dynamic>? existing}) async {
    String? hari = existing?['hari'] ?? 'Senin';
    TimeOfDay mulai = existing != null
        ? TimeOfDay(
            hour: int.parse((existing['jamMulai'] as String).split(':')[0]),
            minute:
                int.parse((existing['jamMulai'] as String).split(':')[1]))
        : const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay selesai = existing != null
        ? TimeOfDay(
            hour:
                int.parse((existing['jamSelesai'] as String).split(':')[0]),
            minute:
                int.parse((existing['jamSelesai'] as String).split(':')[1]))
        : const TimeOfDay(hour: 12, minute: 0);

    final ok = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(existing == null ? 'Tambah Jadwal' : 'Edit Jadwal',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _Jd.textDark)),
              const SizedBox(height: 18),
              const Text('Hari',
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: _Jd.textDark)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _hariList.map((h) {
                  final selected = hari == h;
                  return ChoiceChip(
                    label: Text(h),
                    selected: selected,
                    selectedColor: const Color(0xFFC9822E),
                    labelStyle: TextStyle(
                        color: selected ? Colors.white : _Jd.textDark,
                        fontSize: 12.5),
                    onSelected: (_) => setSheet(() => hari = h),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Jam Mulai',
                            style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: _Jd.textDark)),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            final t = await showTimePicker(
                                context: context, initialTime: mulai);
                            if (t != null) setSheet(() => mulai = t);
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: _Jd.outline),
                            ),
                            child: Text(mulai.format(context),
                                style: const TextStyle(
                                    fontSize: 13, color: _Jd.textDark)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Jam Selesai',
                            style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: _Jd.textDark)),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            final t = await showTimePicker(
                                context: context, initialTime: selesai);
                            if (t != null) setSheet(() => selesai = t);
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: _Jd.outline),
                            ),
                            child: Text(selesai.format(context),
                                style: const TextStyle(
                                    fontSize: 13, color: _Jd.textDark)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${hitungSlot(_menitKeJam(mulai.hour * 60 + mulai.minute), _menitKeJam(selesai.hour * 60 + selesai.minute)).length} slot × $durasiMenit menit tersedia',
                style:
                    const TextStyle(fontSize: 11.5, color: _Jd.textGrey),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC9822E),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Simpan',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (ok != true || !mounted) return;

    if (_jamKeMenit(mulai.format(context)) >=
        _jamKeMenit(selesai.format(context))) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Jam selesai harus lebih besar dari jam mulai')));
      return;
    }

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final data = {
      'hari': hari,
      'jamMulai': mulai.format(context),
      'jamSelesai': selesai.format(context),
      'durasiMenit': durasiMenit,
    };

    try {
      if (existing != null) {
        await _col(uid).doc(existing['id']).update(data);
      } else {
        await _col(uid).add(data);
      }
      _muat();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menyimpan jadwal: $e')));
      }
    }
  }

  Future<void> _hapus(String id) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await _col(uid).doc(id).delete();
    _muat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Jd.bg,
      appBar: AppBar(
        backgroundColor: _Jd.bg,
        elevation: 0,
        title: const Text('Jadwal Saya',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: _Jd.textDark)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFC9822E),
        onPressed: () => _formJadwal(),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _muat,
              child: _jadwal.isEmpty
                  ? ListView(children: const [
                      SizedBox(height: 120),
                      Icon(Icons.event_available_rounded,
                          size: 48, color: _Jd.textGrey),
                      SizedBox(height: 12),
                      Center(
                          child: Text(
                              'Belum ada jadwal.\nTekan tombol + untuk menambah.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: _Jd.textGrey, fontSize: 13))),
                    ])
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
                      itemCount: _jadwal.length,
                      itemBuilder: (context, i) {
                        final j = _jadwal[i];
                        final slots =
                            hitungSlot(j['jamMulai'], j['jamSelesai']);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: _Jd.outline),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFDF3D7),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.schedule_rounded,
                                    color: Color(0xFFC99A2C)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(j['hari'],
                                        style: const TextStyle(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w800,
                                            color: _Jd.textDark)),
                                    const SizedBox(height: 3),
                                    Text(
                                        '${j['jamMulai']} – ${j['jamSelesai']} • ${slots.length} slot',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: _Jd.textGrey)),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () =>
                                    _formJadwal(existing: j),
                                icon: const Icon(Icons.edit_rounded,
                                    size: 20,
                                    color: Color(0xFFC99A2C)),
                              ),
                              IconButton(
                                onPressed: () => _hapus(j['id']),
                                icon: const Icon(Icons.delete_rounded,
                                    size: 20, color: Color(0xFFE55555)),
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