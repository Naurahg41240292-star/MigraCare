import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

abstract class _W {
  static const bg = Color(0xFFFAF4EA);
  static const gold = Color(0xFFC08A2B);
  static const textDark = Color(0xFF33261A);
  static const textGrey = Color(0xFF9C948A);
  static const outline = Color(0xFFE5DCCB);
}

const _jenisLayanan = ['RS', 'Klinik', 'Puskesmas', 'Apotek', 'Laboratorium'];

IconData _ikonJenis(String jenis) {
  switch (jenis) {
    case 'RS':
      return Icons.local_hospital_rounded;
    case 'Klinik':
      return Icons.medical_services_rounded;
    case 'Puskesmas':
      return Icons.house_rounded;
    case 'Apotek':
      return Icons.medication_rounded;
    default:
      return Icons.science_rounded;
  }
}

// ==================== HALAMAN LIST LAYANAN ====================
class AdminLayananPage extends StatefulWidget {
  const AdminLayananPage({super.key});

  @override
  State<AdminLayananPage> createState() => _AdminLayananPageState();
}

class _AdminLayananPageState extends State<AdminLayananPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _W.bg,
      appBar: AppBar(
        backgroundColor: _W.bg,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Informasi Layanan',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: _W.textDark)),
            Text('RS, klinik & fasilitas kesehatan',
                style: TextStyle(fontSize: 11.5, color: _W.textGrey)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFC9822E),
        foregroundColor: Colors.white,
        onPressed: () => _bukaForm(null, null),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Layanan'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('layanan').snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text('Gagal memuat: ${snap.error}'));
          }
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data?.docs ?? const [];
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.local_hospital_outlined,
                      size: 64, color: Colors.black26),
                  SizedBox(height: 12),
                  Text('Belum ada layanan',
                      style: TextStyle(color: Colors.black45)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) => _kartu(docs[i]),
          );
        },
      ),
    );
  }

  void _bukaForm(String? docId, Map<String, dynamic>? dataLama) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) =>
              FormAdminLayanan(docId: docId, dataLama: dataLama)),
    );
  }

  Future<void> _hubungi(String no) async {
    try {
      await launchUrl(Uri(scheme: 'tel', path: no));
    } catch (_) {}
  }

  Future<void> _hapus(String docId, String nama) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus layanan?'),
        content: Text('"$nama" akan dihapus permanen.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (yakin != true) return;
    await FirebaseFirestore.instance.collection('layanan').doc(docId).delete();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Layanan dihapus')));
  }

  Widget _kartu(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final nama = (data['nama'] ?? '').toString();
    final jenis = (data['jenis'] ?? 'Layanan').toString();
    final alamat = (data['alamat'] ?? '').toString();
    final telepon = (data['telepon'] ?? '').toString();
    final jam = (data['jamBuka'] ?? '').toString();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _W.outline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
                color: Color(0xFFFDF3D7), shape: BoxShape.circle),
            child: Icon(_ikonJenis(jenis),
                color: const Color(0xFFC99A2C), size: 24),
          ),
          const SizedBox(width: 12),
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
                        color: _W.textDark)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _W.bg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(jenis,
                          style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: _W.gold)),
                    ),
                    if (jam.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.schedule_rounded,
                          size: 13, color: _W.textGrey),
                      const SizedBox(width: 3),
                      Text(jam,
                          style: const TextStyle(
                              fontSize: 11, color: _W.textGrey)),
                    ],
                  ],
                ),
                if (alamat.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(alamat,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 11.5, color: _W.textGrey)),
                ],
                if (telepon.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => _hubungi(telepon),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.call_rounded,
                            size: 13, color: Color(0xFF2E7D32)),
                        const SizedBox(width: 4),
                        Text(telepon,
                            style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF2E7D32),
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'edit') _bukaForm(doc.id, data);
              if (v == 'hapus') _hapus(doc.id, nama);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'hapus', child: Text('Hapus')),
            ],
          ),
        ],
      ),
    );
  }
}

// ==================== FORM TAMBAH / EDIT LAYANAN ====================
class FormAdminLayanan extends StatefulWidget {
  final String? docId;
  final Map<String, dynamic>? dataLama;
  const FormAdminLayanan({super.key, this.docId, this.dataLama});

  @override
  State<FormAdminLayanan> createState() => _FormAdminLayananState();
}

class _FormAdminLayananState extends State<FormAdminLayanan> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nama;
  late final TextEditingController _alamat;
  late final TextEditingController _telepon;
  late final TextEditingController _jam;
  late final TextEditingController _deskripsi;
  String _jenis = _jenisLayanan.first;
  LatLng? _titik;
  bool _sedangSimpan = false;

  bool get _isEdit => widget.docId != null;

  @override
  void initState() {
    super.initState();
    final d = widget.dataLama;
    _nama = TextEditingController(text: (d?['nama'] ?? '').toString());
    _alamat = TextEditingController(text: (d?['alamat'] ?? '').toString());
    _telepon = TextEditingController(text: (d?['telepon'] ?? '').toString());
    _jam = TextEditingController(text: (d?['jamBuka'] ?? '').toString());
    _deskripsi =
        TextEditingController(text: (d?['deskripsi'] ?? '').toString());
    final k = (d?['jenis'] ?? '').toString();
    if (_jenisLayanan.contains(k)) _jenis = k;
    final lat = d?['lat'];
    final lng = d?['lng'];
    if (lat is num && lng is num) {
      _titik = LatLng(lat.toDouble(), lng.toDouble());
    }
  }

  @override
  void dispose() {
    _nama.dispose();
    _alamat.dispose();
    _telepon.dispose();
    _jam.dispose();
    _deskripsi.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sedangSimpan = true);
    final msg = ScaffoldMessenger.of(context);
    try {
      final data = <String, dynamic>{
        'nama': _nama.text.trim(),
        'jenis': _jenis,
        'alamat': _alamat.text.trim(),
        'telepon': _telepon.text.trim(),
        'jamBuka': _jam.text.trim(),
        'deskripsi': _deskripsi.text.trim(),
        'lat': _titik?.latitude,
        'lng': _titik?.longitude,
        'diubahPada': FieldValue.serverTimestamp(),
      };
      final koleksi = FirebaseFirestore.instance.collection('layanan');
      if (_isEdit) {
        await koleksi.doc(widget.docId).update(data);
      } else {
        data['dibuatPada'] = FieldValue.serverTimestamp();
        await koleksi.add(data);
      }
      if (!mounted) return;
      Navigator.pop(context);
      msg.showSnackBar(
          const SnackBar(content: Text('Layanan berhasil disimpan')));
    } catch (e) {
      msg.showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
    } finally {
      if (mounted) setState(() => _sedangSimpan = false);
    }
  }

  InputDecoration _dekor(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      );

  Widget _label(String teks, {bool wajib = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Text(teks,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            if (wajib) const Text(' *', style: TextStyle(color: Colors.red)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _W.bg,
      appBar: AppBar(
        backgroundColor: _W.bg,
        elevation: 0,
        foregroundColor: _W.textDark,
        title: Text(_isEdit ? 'Edit Layanan' : 'Tambah Layanan',
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _label('Nama Layanan', wajib: true),
            TextFormField(
              controller: _nama,
              decoration: _dekor('Masukkan nama layanan'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
            ),
            const SizedBox(height: 14),
            _label('Jenis', wajib: true),
            DropdownButtonFormField<String>(
              value: _jenis,
              items: _jenisLayanan
                  .map((j) => DropdownMenuItem(value: j, child: Text(j)))
                  .toList(),
              onChanged: (v) => setState(() => _jenis = v!),
              decoration: _dekor('Pilih jenis layanan'),
            ),
            const SizedBox(height: 14),
            _label('Alamat'),
            TextFormField(
              controller: _alamat,
              maxLines: 2,
              decoration: _dekor('Masukkan alamat lengkap'),
            ),
            const SizedBox(height: 14),
            _label('No. Telepon'),
            TextFormField(
              controller: _telepon,
              keyboardType: TextInputType.phone,
              maxLength: 13,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration:
                  _dekor('Contoh: 081234567890').copyWith(counterText: ''),
            ),
            const SizedBox(height: 14),
            _label('Jam Buka'),
            TextFormField(
              controller: _jam,
              decoration: _dekor('Contoh: 08.00 - 16.00'),
            ),
            const SizedBox(height: 14),
            _label('Deskripsi'),
            TextFormField(
              controller: _deskripsi,
              maxLines: 3,
              decoration: _dekor('Jelaskan detail layanan...'),
            ),
            const SizedBox(height: 14),
            _label('Lokasi di Peta'),
            _peta(),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _sedangSimpan ? null : _simpan,
                    style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFC9822E),
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: _sedangSimpan
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Simpan'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _peta() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 200,
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: _titik ?? const LatLng(-8.1728, 113.6983),
                initialZoom: 13,
                onTap: (_, titik) => setState(() => _titik = titik),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.migracare',
                ),
                MarkerLayer(
                  markers: [
                    if (_titik != null)
                      Marker(
                        point: _titik!,
                        width: 46,
                        height: 46,
                        child: const Icon(Icons.location_on_rounded,
                            color: Colors.redAccent, size: 40),
                      ),
                  ],
                ),
              ],
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _titik == null
                      ? 'Ketuk peta untuk menandai lokasi'
                      : 'Lokasi: ${_titik!.latitude.toStringAsFixed(5)}, ${_titik!.longitude.toStringAsFixed(5)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}