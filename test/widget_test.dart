// ========================================================================
//  MIGRACARE — Tes Dasar
//  File: test/widget_test.dart
//
//  Catatan: file ini awalnya berisi "Counter increments smoke test"
//  bawaan Flutter yang memanggil MyApp. Karena aplikasi kita sudah
//  menjadi MigracareApp (bukan aplikasi counter lagi), tes lama itu
//  tidak valid dan menimbulkan error "MyApp isn't a class".
//  File ini menggantinya dengan tes yang benar-benar relevan.
// ========================================================================

import 'package:flutter_test/flutter_test.dart';

import 'package:migracare/models/artikel.dart';

void main() {
  test('Data artikel populer tersedia dan lengkap', () {
    // Pastikan minimal ada 1 artikel
    expect(artikelPopuler, isNotEmpty);

    for (final artikel in artikelPopuler) {
      // Setiap artikel wajib punya judul, tanggal, dan isi
      expect(artikel.title, isNotEmpty);
      expect(artikel.date, isNotEmpty);
      expect(artikel.sections, isNotEmpty);

      for (final bagian in artikel.sections) {
        expect(bagian.heading, isNotEmpty);
        expect(bagian.paragraphs, isNotEmpty);
      }
    }
  });

  test('Judul artikel pertama sesuai yang diharapkan', () {
    expect(
      artikelPopuler.first.title,
      'Mengenal Migraine dan Cara Mengelolanya',
    );
  });
}