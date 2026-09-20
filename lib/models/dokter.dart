import 'package:flutter/material.dart';

/// =======================================================================
///  MIGRACARE — Model & Data Dokter & Riwayat Konsultasi
///  File: lib/models/dokter.dart
/// =======================================================================

class Dokter {
  final String id;
  final String nama;
  final String spesialis;
  final bool isSpesialis;
  final double rating;
  final int jumlahUlasan;
  final String pengalaman;
  final String jamPraktik;
  final String lokasi;
  final Color warnaAvatar;
  final String? foto;

  const Dokter({
    required this.id,
    required this.nama,
    required this.spesialis,
    required this.isSpesialis,
    required this.rating,
    required this.jumlahUlasan,
    required this.pengalaman,
    required this.jamPraktik,
    required this.lokasi,
    required this.warnaAvatar,
    this.foto,
  });
}

class RiwayatKonsultasi {
  final String dokterId;
  final String topik;
  final String tanggal;
  final String status;

  const RiwayatKonsultasi({
    required this.dokterId,
    required this.topik,
    required this.tanggal,
    required this.status,
  });
}

/// -------------------------------------------------------------------------
/// DATA DUMMY DOKTER
/// -------------------------------------------------------------------------
const List<Dokter> daftarDokter = [
  Dokter(
    id: 'd1',
    nama: 'dr. Siti Rahmawati, Sp.N',
    spesialis: 'Spesialis Neurologi (Saraf)',
    isSpesialis: true,
    rating: 4.9,
    jumlahUlasan: 142,
    pengalaman: '8 Tahun',
    jamPraktik: '08.00 - 14.00 WIB',
    lokasi: 'RSUD dr. Soebandi, Jember',
    warnaAvatar: Color(0xFFFBE8D3),
    foto: null,
  ),
  Dokter(
    id: 'd2',
    nama: 'dr. Budi Santoso, Sp.S',
    spesialis: 'Spesialis Saraf & Nyeri Kepala',
    isSpesialis: true,
    rating: 4.8,
    jumlahUlasan: 98,
    pengalaman: '6 Tahun',
    jamPraktik: '13.00 - 18.00 WIB',
    lokasi: 'RS Jember Klinik',
    warnaAvatar: Color(0xFFE2EDF8),
    foto: null,
  ),
  Dokter(
    id: 'd3',
    nama: 'dr. Farah Diba',
    spesialis: 'Dokter Umum',
    isSpesialis: false,
    rating: 4.9,
    jumlahUlasan: 85,
    pengalaman: '4 Tahun',
    jamPraktik: '09.00 - 16.00 WIB',
    lokasi: 'Klinik Pratama Rawat Inap',
    warnaAvatar: Color(0xFFE6F4EA),
    foto: null,
  ),
  Dokter(
    id: 'd4',
    nama: 'dr. Ahmad Fauzi',
    spesialis: 'Dokter Umum',
    isSpesialis: false,
    rating: 4.7,
    jumlahUlasan: 64,
    pengalaman: '5 Tahun',
    jamPraktik: '10.00 - 15.00 WIB',
    lokasi: 'Puskesmas Kaliwates',
    warnaAvatar: Color(0xFFFCE8E6),
    foto: null,
  ),
  Dokter(
    id: 'd5',
    nama: 'dr. Dian Kusuma, Sp.N',
    spesialis: 'Spesialis Neurologi',
    isSpesialis: true,
    rating: 4.9,
    jumlahUlasan: 110,
    pengalaman: '9 Tahun',
    jamPraktik: '08.00 - 12.00 WIB',
    lokasi: 'RS Citra Husada Jember',
    warnaAvatar: Color(0xFFF3E5F5),
    foto: null,
  ),
];

/// -------------------------------------------------------------------------
/// DATA DUMMY RIWAYAT KONSULTASI
/// -------------------------------------------------------------------------
const List<RiwayatKonsultasi> daftarRiwayat = [
  RiwayatKonsultasi(
    dokterId: 'd1',
    topik: 'Migrain Tanpa Aura',
    tanggal: '18 Sep 2026',
    status: 'Selesai',
  ),
  RiwayatKonsultasi(
    dokterId: 'd3',
    topik: 'Konsultasi Nyeri Kepala',
    tanggal: '12 Sep 2026',
    status: 'Selesai',
  ),
];