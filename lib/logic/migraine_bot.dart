// =======================================================================
//  MIGRACARE — Logika Bot Konsultasi Migrain
//  File: lib/logic/migraine_bot.dart
// =======================================================================

/// Menghasilkan balasan otomatis dari dokter berdasarkan input pesan pasien.
String getBalasanDokter(String teksInput) {
  final q = teksInput.toLowerCase();

  if (q.contains('obat') ||
      q.contains('paracetamol') ||
      q.contains('ibuprofen') ||
      q.contains('minum')) {
    return 'Untuk pereda nyeri fase akut, Anda bisa mengonsumsi Paracetamol atau Ibuprofen sesuai dosis anjuran, sebaiknya diminum di awal serangan muncul. Namun jika frekuensinya lebih dari 2-3 kali seminggu, konsultasikan ke dokter spesialis saraf untuk evaluasi obat profilaksis (pencegah). Hindari konsumsi obat pereda nyeri berlebihan agar tidak memicu medication overuse headache.';
  }

  if (q.contains('mual') || q.contains('muntah') || q.contains('lambung')) {
    return 'Gejala mual memang sering kali menyertai migrain karena perlambatan motilitas saluran cerna selama serangan. Anda bisa minum air hangat secara perlahan, hindari makanan berlemak atau beraroma tajam, dan istirahat berbaring di tempat yang sejuk dan tenang.';
  }

  if (q.contains('tidur') ||
      q.contains('begadang') ||
      q.contains('istirahat') ||
      q.contains('lelah')) {
    return 'Pola tidur yang tidak teratur, kurang tidur, atau tidur berlebih merupakan salah satu pemicu migrain yang sangat umum. Usahakan untuk tidur dan bangun di jam yang konsisten setiap hari, hindari paparan layar gadget 1 jam sebelum tidur, dan ciptakan suasana kamar yang gelap dan hening.';
  }

  if (q.contains('aura') ||
      q.contains('mata') ||
      q.contains('kabur') ||
      q.contains('kilatan') ||
      q.contains('silau')) {
    return 'Aura visual atau sensitivitas terhadap cahaya (fotofobia) merupakan ciri khas serangan migrain. Aura visual biasanya berlangsung sekitar 5–60 menit sebelum fase sakit kepala. Jika aura mulai terasa, segera beristirahat di ruangan yang redup dan hindari mengemudi atau aktivitas yang membutuhkan konsentrasi tinggi.';
  }

  if (q.contains('makanan') ||
      q.contains('kopi') ||
      q.contains('kafein') ||
      q.contains('pemicu') ||
      q.contains('pantangan')) {
    return 'Beberapa pemicu umum dari pola makan meliputi MSG, keju tua, cokelat, makanan berpengawet, dan konsumsi kafein yang fluktuatif. Anda dapat mencatat riwayat asupan dan aktivitas di fitur Skrining MigraCare untuk mengenali pola pemicu spesifik Anda secara akurat.';
  }

  if (q.contains('makasih') ||
      q.contains('terima kasih') ||
      q.contains('baik') ||
      q.contains('oke') ||
      q.contains('siap')) {
    return 'Sama-sama! Selalu jaga kesehatan, hindari pemicu migrain, dan jangan ragu berkonsultasi kembali jika ada gejala baru atau keluhan lain. Semoga lekas membaik! 😊';
  }

  return 'Terima kasih atas informasinya. Gejala yang Anda alami perlu terus dipantau. Pastikan mencukupi kebutuhan hidrasi air putih minimal 2 liter per hari, lakukan kompres dingin di area dahi atau tengkuk leher, dan catat riwayat keluhan di aplikasi MigraCare. Jika keluhan memberat atau disertai tanda bahaya, segera lakukan pemeriksaan langsung ke fasilitas kesehatan terdekat.';
}