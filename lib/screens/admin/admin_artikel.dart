import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// =====================================================================
// WARNA — disalin PERSIS dari admin_layanan.dart biar seragam semua
// =====================================================================
abstract class _W {
  static const bg = Color(0xFFFAF4EA);
  static const gold = Color(0xFFC08A2B);
  static const textDark = Color(0xFF33261A);
  static const textGrey = Color(0xFF9C948A);
  static const outline = Color(0xFFE5DCCB);
}

// Warna tombol Tambah & Simpan — sama dengan tombol di admin_layanan.dart
const kAmber = Color(0xFFC9822E);

// Alias nama lama — dipertahankan supaya file lain yang memakai tidak error
const kBg = _W.bg;
const kOrange = kAmber;
const kBrown = _W.textDark;

const kKategoriArtikel = ['Edukasi', 'Gaya Hidup', 'Pengobatan', 'Berita'];
const kBulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

String formatTanggal(DateTime t) => '${t.day} ${kBulan[t.month - 1]} ${t.year}';

DateTime? tanggalDariDoc(Map<String, dynamic> d) {
  for (final k in const ['dibuatPada', 'createdAt', 'tanggal', 'diubahPada']) {
    final v = d[k];
    if (v is Timestamp) return v.toDate();
    if (v is String) return DateTime.tryParse(v);
  }
  return null;
}

// ================= HALAMAN LIST ARTIKEL =================
class AdminArtikelPage extends StatefulWidget {
  const AdminArtikelPage({super.key});

  @override
  State<AdminArtikelPage> createState() => _AdminArtikelPageState();
}

class _AdminArtikelPageState extends State<AdminArtikelPage> {
  String _filter = 'semua'; // semua | published | draft
  String _cari = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        foregroundColor: _W.textDark,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Artikel',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: _W.textDark)),
            Text('Kelola artikel kesehatan migraine',
                style: TextStyle(fontSize: 11.5, color: _W.textGrey)),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('artikel').snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text('Gagal memuat: ${snap.error}'));
          }
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data?.docs ?? const [];
          docs.sort((a, b) {
            final ta = tanggalDariDoc(a.data());
            final tb = tanggalDariDoc(b.data());
            if (ta == null && tb == null) return 0;
            if (ta == null) return 1;
            if (tb == null) return -1;
            return tb.compareTo(ta);
          });
          final hasil = docs.where((d) {
            final data = d.data();
            final status = (data['status'] ?? 'published').toString();
            if (_filter != 'semua' && status != _filter) return false;
            final q = _cari.toLowerCase().trim();
            if (q.isEmpty) return true;
            return (data['judul'] ?? '').toString().toLowerCase().contains(q);
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (v) => setState(() => _cari = v),
                        decoration: InputDecoration(
                          hintText: 'Cari judul artikel...',
                          prefixIcon:
                              const Icon(Icons.search, color: _W.textGrey),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 0),
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
                        backgroundColor: kAmber,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 15),
                      ),
                      onPressed: () => _bukaForm(null, null),
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('Tambah'),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                child: Row(
                  children: [
                    _chip('semua', 'Semua'),
                    const SizedBox(width: 8),
                    _chip('published', 'Published'),
                    const SizedBox(width: 8),
                    _chip('draft', 'Draft'),
                  ],
                ),
              ),
              Expanded(
                child: hasil.isEmpty
                    ? _kosong()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: hasil.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) =>
                            _kartu(hasil[i].data(), docId: hasil[i].id),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _chip(String nilai, String label) {
    final terpilih = _filter == nilai;
    return ChoiceChip(
      label: Text(label),
      selected: terpilih,
      onSelected: (_) => setState(() => _filter = nilai),
      selectedColor: kAmber,
      showCheckmark: false,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: terpilih ? Colors.white : _W.textDark,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _kosong() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.article_outlined, size: 64, color: Colors.black26),
            SizedBox(height: 12),
            Text('Belum ada artikel', style: TextStyle(color: Colors.black45)),
          ],
        ),
      );

  Widget _labelKecil(String teks, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Text(teks,
            style: TextStyle(
                fontSize: 11, color: fg, fontWeight: FontWeight.w600)),
      );

  Widget _thumbKosong() => Container(
        width: 64,
        height: 64,
        color: kBg,
        child: const Icon(Icons.image_outlined, color: _W.gold),
      );

  Widget _kartu(Map<String, dynamic> data, {required String docId}) {
    final status = (data['status'] ?? 'published').toString();
    final published = status == 'published';
    final tgl = tanggalDariDoc(data);
    final gambar = (data['gambarUrl'] ?? '').toString();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _W.outline),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: gambar.isNotEmpty
                ? Image.network(gambar,
                    width: 64, height: 64, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _thumbKosong())
                : _thumbKosong(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text((data['judul'] ?? '').toString(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _W.textDark)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _labelKecil((data['kategori'] ?? 'Umum').toString(), kBg,
                        _W.gold),
                    const SizedBox(width: 6),
                    _labelKecil(
                        published ? 'Published' : 'Draft',
                        published
                            ? const Color(0xFFE3F4E5)
                            : const Color(0xFFFDF3D7),
                        published
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFC9822E)),
                    const Spacer(),
                    Text(tgl == null ? '' : formatTanggal(tgl),
                        style:
                            const TextStyle(fontSize: 11, color: _W.textGrey)),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'edit') _bukaForm(docId, data);
              if (v == 'hapus') _hapus(docId, (data['judul'] ?? '').toString());
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

  void _bukaForm(String? docId, Map<String, dynamic>? dataLama) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => FormAdminArtikel(docId: docId, dataLama: dataLama)),
    );
    setState(() {});
  }

  Future<void> _hapus(String docId, String judul) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus artikel?'),
        content: Text('"$judul" akan dihapus permanen.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Hapus')),
        ],
      ),
    );
    if (yakin != true) return;
    await FirebaseFirestore.instance.collection('artikel').doc(docId).delete();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Artikel dihapus')));
  }
}

// ================= FORM TAMBAH / EDIT ARTIKEL =================
class FormAdminArtikel extends StatefulWidget {
  final String? docId;
  final Map<String, dynamic>? dataLama;
  const FormAdminArtikel({super.key, this.docId, this.dataLama});

  @override
  State<FormAdminArtikel> createState() => _FormAdminArtikelState();
}

class _FormAdminArtikelState extends State<FormAdminArtikel> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _judul;
  late final TextEditingController _ringkasan;
  late final TextEditingController _isi;
  String _kategori = kKategoriArtikel.first;
  String _status = 'published';
  File? _file;
  bool _sedangSimpan = false;

  bool get _isEdit => widget.docId != null;
  String get _urlLama => (widget.dataLama?['gambarUrl'] ?? '').toString();

  @override
  void initState() {
    super.initState();
    final d = widget.dataLama;
    _judul = TextEditingController(text: (d?['judul'] ?? '').toString());
    _ringkasan = TextEditingController(text: (d?['ringkasan'] ?? '').toString());
    _isi = TextEditingController(text: (d?['isi'] ?? '').toString());
    final k = (d?['kategori'] ?? '').toString();
    if (kKategoriArtikel.contains(k)) _kategori = k;
    final s = (d?['status'] ?? '').toString();
    if (s == 'draft') _status = 'draft';
  }

  @override
  void dispose() {
    _judul.dispose();
    _ringkasan.dispose();
    _isi.dispose();
    super.dispose();
  }

  Future<void> _pilihGambar() async {
    final x = await ImagePicker().pickImage(
        source: ImageSource.gallery, imageQuality: 80, maxWidth: 1080);
    if (x != null) setState(() => _file = File(x.path));
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sedangSimpan = true);
    final msg = ScaffoldMessenger.of(context);
    try {
      String gambarUrl = _urlLama;
      if (_file != null) {
        final ref = FirebaseStorage.instance
            .ref('artikel/${DateTime.now().millisecondsSinceEpoch}.jpg');
        final task = await ref.putFile(_file!);
        gambarUrl = await task.ref.getDownloadURL();
      }
      final data = <String, dynamic>{
        'judul': _judul.text.trim(),
        'kategori': _kategori,
        'ringkasan': _ringkasan.text.trim(),
        'isi': _isi.text.trim(),
        'status': _status,
        'gambarUrl': gambarUrl,
        'diubahPada': FieldValue.serverTimestamp(),
      };
      final koleksi = FirebaseFirestore.instance.collection('artikel');
      if (_isEdit) {
        await koleksi.doc(widget.docId).update(data);
      } else {
        data['dibuatPada'] = FieldValue.serverTimestamp();
        await koleksi.add(data);
      }
      if (!mounted) return;
      Navigator.pop(context);
      msg.showSnackBar(
          const SnackBar(content: Text('Artikel berhasil disimpan')));
    } catch (e) {
      msg.showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
    } finally {
      if (mounted) setState(() => _sedangSimpan = false);
    }
  }

  Widget _label(String teks, {bool wajib = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Text(teks, style: const TextStyle(fontWeight: FontWeight.w600)),
            if (wajib) const Text(' *', style: TextStyle(color: Colors.red)),
          ],
        ),
      );

  InputDecoration _dekor([String? hint, int maxLines = 1]) => InputDecoration(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        foregroundColor: _W.textDark,
        title: Text(_isEdit ? 'Edit Artikel' : 'Tambah Artikel',
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _label('Judul Artikel', wajib: true),
            TextFormField(
              controller: _judul,
              decoration: _dekor('Masukkan judul artikel'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Judul wajib diisi' : null,
            ),
            const SizedBox(height: 14),
            _label('Kategori', wajib: true),
            DropdownButtonFormField<String>(
              value: _kategori,
              items: kKategoriArtikel
                  .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                  .toList(),
              onChanged: (v) => setState(() => _kategori = v!),
              decoration: _dekor('Pilih kategori'),
            ),
            const SizedBox(height: 14),
            _label('Ringkasan'),
            TextFormField(
              controller: _ringkasan,
              maxLines: 2,
              decoration: _dekor('Tulis ringkasan singkat artikel...'),
            ),
            const SizedBox(height: 14),
            _label('Konten Artikel', wajib: true),
            TextFormField(
              controller: _isi,
              maxLines: 8,
              decoration: _dekor('Tulis konten artikel di sini...'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Konten wajib diisi' : null,
            ),
            const SizedBox(height: 14),
            _label('Status'),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('Published'),
                  selected: _status == 'published',
                  onSelected: (_) => setState(() => _status = 'published'),
                  selectedColor: const Color(0xFF2E7D32),
                  showCheckmark: false,
                  labelStyle: TextStyle(
                      color:
                          _status == 'published' ? Colors.white : _W.textDark),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Draft'),
                  selected: _status == 'draft',
                  onSelected: (_) => setState(() => _status = 'draft'),
                  selectedColor: kAmber,
                  showCheckmark: false,
                  labelStyle: TextStyle(
                      color: _status == 'draft' ? Colors.white : _W.textDark),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _label('Gambar Cover'),
            GestureDetector(
              onTap: _pilihGambar,
              child: Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _W.outline),
                ),
                child: _file != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(_file!,
                            fit: BoxFit.cover, width: double.infinity))
                    : _urlLama.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(_urlLama,
                                fit: BoxFit.cover, width: double.infinity,
                                errorBuilder: (_, __, ___) =>
                                    _placeholderUpload()))
                        : _placeholderUpload(),
              ),
            ),
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
                        backgroundColor: kAmber,
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

  Widget _placeholderUpload() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.cloud_upload_outlined, size: 40, color: _W.gold),
          SizedBox(height: 6),
          Text('Unggah gambar cover',
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: _W.textDark)),
          SizedBox(height: 2),
          Text('Format: JPG, PNG (Max 2MB)',
              style: TextStyle(fontSize: 11, color: _W.textGrey)),
        ],
      );
}