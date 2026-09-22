import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/riwayat_service.dart';

class DetailRiwayatSkriningPage extends StatelessWidget {
  const DetailRiwayatSkriningPage({super.key, required this.item});

  final RiwayatItem item;

  String _formatWaktuLengkap(DateTime d) {
    const bulan = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final jam = d.hour.toString().padLeft(2, '0');
    final menit = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${bulan[d.month - 1]} ${d.year}, $jam:$menit WIB';
  }

  Color _badgeColor(String intensitas) {
    switch (intensitas) {
      case 'Berat':
        return Colors.red.shade400;
      case 'Sedang':
        return const Color(0xFFDD9438);
      case 'Ringan':
        return Colors.green.shade500;
      default:
        return Colors.grey;
    }
  }

  Future<void> _konfirmasiHapus(BuildContext context) async {
    final setuju = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Riwayat?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        content: const Text(
          'Apakah Anda yakin ingin menghapus data riwayat skrining ini?',
          style: TextStyle(fontSize: 13, color: AppColors.textGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal', style: TextStyle(color: AppColors.textGrey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (setuju == true) {
      await RiwayatService.instance.hapus(item.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Riwayat berhasil dihapus'),
            backgroundColor: AppColors.darkBrown,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = item.detailJawaban;

    // Ambil probabilitas yang tersimpan dan urutkan dari tertinggi ke terendah
    final sortedProbs = item.probabilities.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Detail Skrining',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            tooltip: 'Hapus Riwayat',
            onPressed: () => _konfirmasiHapus(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------- KARTU WAKTU & STATUS ----------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outline),
                  boxShadow: AppShadows.card,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC9822E).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.history_edu_rounded,
                          color: Color(0xFFC9822E), size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Waktu Pemeriksaan',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatWaktuLengkap(item.waktu),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _badgeColor(item.intensitas).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.intensitas,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _badgeColor(item.intensitas),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ---------- KARTU HASIL UTAMA AI ----------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outline),
                  boxShadow: AppShadows.card,
                ),
                child: Column(
                  children: [
                    const Text(
                      'Kemungkinan Tipe Migrain:',
                      style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.hasil,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC9822E).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Tingkat Keyakinan: ${(item.confidence * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFC9822E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (sortedProbs.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text(
                  'Distribusi Kemungkinan Kelas:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Column(
                    children: sortedProbs.map((e) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    e.key,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textDark,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${(e.value * 100).toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textGrey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: e.value,
                                minHeight: 6,
                                backgroundColor: const Color(0xFFE7DFD2),
                                color: const Color(0xFFC9822E),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // ---------- RINCIAN JAWABAN SAAT SKRINING ----------
              const Text(
                'Rincian Jawaban Skrining:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outline),
                ),
                child: detail.isEmpty
                    ? const Text(
                        'Rincian data jawaban tidak tersedia.',
                        style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (detail['tanggalLahir'] != null || detail['umur'] != null)
                            _itemRincian(
                              'Usia & Tanggal Lahir',
                              '${detail['tanggalLahir'] ?? '-'} (${detail['umur'] ?? '-'} tahun)',
                            ),
                          _itemRincian('Intensitas Nyeri', item.intensitas),
                          if (detail['durasi'] != null)
                            _itemRincian('Durasi Serangan', detail['durasi'].toString()),
                          if (detail['frekuensi'] != null)
                            _itemRincian('Frekuensi', detail['frekuensi'].toString()),
                          if (detail['karakter'] != null)
                            _itemRincian('Karakter Rasa Sakit', detail['karakter'].toString()),
                          if (detail['lokasi'] != null)
                            _itemRincian('Lokasi Nyeri', detail['lokasi'].toString()),
                          if (detail['gejala'] != null)
                            _itemRincianList('Gejala Tambahan', detail['gejala']),
                          if (detail['visualAura'] != null)
                            _itemRincianList('Aura Visual', detail['visualAura']),
                          if (detail['sensory'] != null)
                            _itemRincian('Gejala Sensorik', detail['sensory'].toString()),
                          if (detail['pemicu'] != null)
                            _itemRincianList('Faktor Pemicu', detail['pemicu']),
                          if (detail['neuro'] != null)
                            _itemRincianList('Gejala Neurologis', detail['neuro']),
                          if (detail['riwayatKeluarga'] != null)
                            _itemRincian('Riwayat Keluarga (Genetik)',
                                detail['riwayatKeluarga'].toString()),
                        ],
                      ),
              ),

              const SizedBox(height: 16),

              // ---------- DISCLAIMER ----------
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7DBB0).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF2C230).withValues(alpha: 0.5)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded,
                        color: Color(0xFFB07E1F), size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Hasil ini merupakan analisis kecerdasan buatan dan bukan merupakan pengganti diagnosis medis resmi. Konsultasikan dengan dokter spesialis saraf untuk penanganan medis tepat.',
                        style: TextStyle(fontSize: 11, color: AppColors.textDark),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ---------- TOMBOL KEMBALI ----------
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFFC9822E)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Kembali ke Riwayat',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFC9822E),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _itemRincian(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemRincianList(String label, dynamic list) {
    final items = (list is List) ? list.map((e) => e.toString()).toList() : <String>[];
    final display = items.isEmpty ? 'Tidak ada / Tidak dipilih' : items.join(', ');
    return _itemRincian(label, display);
  }
}
