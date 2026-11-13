import 'package:flutter/material.dart';

import '../theme.dart';
import '../services/screening_service.dart';
import '../utils/penjelasan_migrain.dart';

/// Halaman hasil analisis AI skrining migrain
/// ✅ [REVISI DOSEN] tiap hasil diberi PENJELASAN makna + KESIMPULAN +
/// REKOMENDASI. Sumber data: lib/utils/penjelasan_migrain.dart
/// (dipakai bersama halaman Detail Skrining biar konsisten)
class HasilAnalisisPage extends StatelessWidget {
  const HasilAnalisisPage({super.key, required this.result});

  final ScreeningResult result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hasil Analisis AI',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Berdasarkan jawaban skrining Anda:',
                style: TextStyle(fontSize: 12.5, color: AppColors.textGrey),
              ),
              const SizedBox(height: 20),

              // ---------- KARTU HASIL UTAMA ----------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Tipe migrain Anda kemungkinan:',
                      style: TextStyle(
                          fontSize: 12.5, color: AppColors.textGrey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      result.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC9822E).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Keyakinan: ${(result.confidence * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFC9822E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ---------- ✅ [REVISI DOSEN] PENJELASAN HASIL ----------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.menu_book_rounded,
                            size: 18, color: Color(0xFFC9822E)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Apa itu ${result.label}?',
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      PenjelasanMigrain.penjelasan(result.label),
                      style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.6,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // ✅ [REVISI DOSEN] KESIMPULAN dari seluruh hasil
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC9822E).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.tips_and_updates_rounded,
                              size: 16, color: Color(0xFFC9822E)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Kesimpulan: ${PenjelasanMigrain.kesimpulan(result.label, confidence: result.confidence)}',
                              style: const TextStyle(
                                fontSize: 12,
                                height: 1.55,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ---------- ✅ [REVISI DOSEN] REKOMENDASI ----------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.volunteer_activism_rounded,
                            size: 18, color: Color(0xFFC9822E)),
                        SizedBox(width: 8),
                        Text(
                          'Rekomendasi untuk Anda',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...PenjelasanMigrain.rekomendasi(result.label).map(
                      (r) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                size: 15, color: Color(0xFF5BA97C)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                r,
                                style: const TextStyle(
                                  fontSize: 12,
                                  height: 1.5,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ---------- DISTRIBUSI SEMUA KELAS ----------
              const Text(
                'Distribusi Kemungkinan:',
                style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark),
              ),
              const SizedBox(height: 10),
              ...result.probabilities.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
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
                                    fontSize: 11.5,
                                    color: AppColors.textDark),
                              ),
                            ),
                            Text(
                              '${(e.value * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textGrey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: e.value,
                            minHeight: 6,
                            backgroundColor: const Color(0xFFE7DFD2),
                            color: const Color(0xFFC9822E),
                          ),
                        ),
                      ],
                    ),
                  )),

              const SizedBox(height: 12),
              const Text(
                '⚠️ Hasil ini bukan diagnosis medis. Konsultasikan '
                'dengan dokter untuk pemeriksaan lanjutan.',
                style: TextStyle(fontSize: 10.5, color: AppColors.textGrey),
              ),
              const SizedBox(height: 20),

              // ---------- TOMBOL KEMBALI ----------
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC9822E),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Selesai',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}