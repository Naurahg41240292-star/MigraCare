/// ==========================================================================
///  MIGRACARE — Basis pengetahuan hasil skrining migrain
///  ✅ [REVISI DOSEN]
///   1. Penjelasan makna tiap tipe hasil (typical aura tanpa migrain,
///      hemiplegik, basilar, migrain tanpa aura, dll)
///   2. Kesimpulan (rangkuman hasil + catatan kalau keyakinan rendah)
///   3. Rekomendasi tindakan (daftar hal yang perlu dilakukan pasien)
///
///  Dipakai bersama oleh: halaman Hasil Analisis (skrining langsung)
///  dan halaman Detail Skrining (riwayat).
///
///  Tipe dicari pakai KATA KUNCI di label hasil — jadi tetap jalan
///  walau penamaan kelas di model berbeda tipis (Inggris / Indonesia).
///  Label yang tidak dikenal pun tetap dapat penjelasan (fallback).
/// ==========================================================================

class PenjelasanMigrain {
  PenjelasanMigrain._(); // util statis — tidak perlu diinstansiasi

  // ------------------------------------------------------------------
  //  1) PENJELASAN — apa maksud tipe hasil ini?
  // ------------------------------------------------------------------
  static String penjelasan(String label) {
    final l = label.toLowerCase();

    // a) Typical aura WITHOUT migraine — aura tanpa sakit kepala migrain
    if (l.contains('without migraine') || l.contains('tanpa migrain')) {
      return 'Typical aura without migraine (aura tanpa migrain) adalah '
          'kondisi ketika gejala aura MUNCUL, tetapi TIDAK diikuti sakit '
          'kepala migrain yang khas. Gejala auranya biasanya berupa '
          'gangguan penglihatan seperti melihat kilatan cahaya, garis '
          'zigzag, atau bintik-bintik buta; bisa juga berupa kesemutan '
          'di wajah atau tangan, serta bicara yang menjadi tidak jelas. '
          'Gejala ini berkembang perlahan dalam beberapa menit dan '
          'umumnya hilang sepenuhnya dalam waktu kurang dari satu jam.';
    }
    // b) Aura DENGAN migrain (typical aura with migraine / migraine with aura)
    if (l.contains('with migraine') ||
        l.contains('dengan migrain') ||
        l.contains('with aura') ||
        l.contains('dengan aura')) {
      return 'Migrain dengan aura (typical aura with migraine) adalah '
          'migrain yang didahului tanda peringatan sekitar 5 sampai 60 '
          'menit sebelum sakit kepala muncul. Aura paling sering berupa '
          'gangguan penglihatan: kilatan cahaya, garis zigzag, atau '
          'bintik buta; bisa juga kesemutan di wajah atau tangan. Setelah '
          'tanda-tanda itu hilang, barulah sakit kepala berdenyut '
          'dimulai — biasanya di satu sisi kepala, disertai mual atau '
          'tidak tahan cahaya dan suara.';
    }
    // c) Hemiplegik (familiar & sporadik)
    if (l.contains('hemiplegic') || l.contains('hemiplegik')) {
      if (l.contains('familial') || l.contains('familiar')) {
        return 'Migrain hemiplegik familiar adalah jenis migrain yang '
            'sangat jarang dan bersifat turunan — umumnya ada anggota '
            'keluarga dekat (orang tua atau saudara) dengan keluhan '
            'serupa. Ciri khasnya: aura disertai KELEMAHAN OTOT pada '
            'satu sisi tubuh, misalnya tangan atau kaki terasa lemas, '
            'kadang disertai kesemutan, gangguan penglihatan, atau '
            'bicara parau. Gejala ini bisa menyerupai serangan stroke, '
            'sehingga pemeriksaan dokter sangat penting untuk '
            'memastikannya.';
      }
      if (l.contains('sporadic') || l.contains('sporadik')) {
        return 'Migrain hemiplegik sporadik memiliki gejala yang sama '
            'dengan versi familiar — aura disertai kelemahan otot satu '
            'sisi tubuh — tetapi TIDAK ada riwayat keluarga yang punya '
            'keluhan serupa, alias muncul acak. Karena sangat jarang '
            'dan gejalanya mirip stroke, jenis ini wajib dikonfirmasi '
            'dokter melalui pemeriksaan yang lebih teliti.';
      }
      return 'Migrain hemiplegik adalah jenis migrain langka yang '
          'auranya disertai kelemahan otot pada satu sisi tubuh, kadang '
          'dengan kesemutan atau bicara parau. Gejalanya bisa menyerupai '
          'stroke sehingga wajib dikonfirmasi oleh dokter.';
    }
    // d) Basilar / brainstem aura
    if (l.contains('basilar') ||
        l.contains('brainstem') ||
        l.contains('batang otak')) {
      return 'Migrain dengan aura basilar (basilar-type aura) adalah '
          'jenis langka di mana auranya berasal dari batang otak. '
          'Gejala khasnya: pusing berputar hebat (vertigo), pandangan '
          'ganda, bicara menjadi parau, telinga berdenging, jalan goyah '
          'atau tidak stabil, hingga pingsan sebentar. Sakit kepalanya '
          'biasanya terasa di bagian belakang kepala. Gejala-gejala ini '
          'bisa menyerupai gangguan saraf lain, jadi perlu dipastikan '
          'oleh dokter.';
    }
    // e) Migrain tanpa aura
    if (l.contains('without aura') || l.contains('tanpa aura')) {
      return 'Migrain tanpa aura adalah jenis migrain yang paling umum '
          '(sekitar 70-80% dari semua kasus migrain). Ciri khasnya: '
          'sakit kepala berdenyut seperti terpukul berirama, biasanya '
          'di satu sisi kepala, disertai rasa mual, tidak tahan cahaya '
          'terang, atau tidak tahan suara bising. Disebut tanpa aura '
          'karena serangan datang langsung — tidak ada tanda '
          'peringatan seperti kilatan cahaya sebelum sakit kepala '
          'muncul.';
    }
    // f) Lainnya / bukan migrain
    if (l.contains('lainnya') ||
        l.contains('other') ||
        l.contains('bukan') ||
        l.contains('no migrain') ||
        l.contains('not migrain')) {
      return 'Keluhan yang kamu alami belum sepenuhnya cocok dengan '
          'tipe migrain klasik. Ini bisa berarti tipe migrain lain yang '
          'lebih jarang, sakit kepala non-migrain (misalnya sakit '
          'kepala tegang), atau kombinasi beberapa kondisi sekaligus.';
    }
    // g) Fallback — label di luar daftar tetap dapat penjelasan
    return 'Hasil ini menunjukkan bahwa pola keluhan yang kamu masukkan '
        'paling mirip dengan tipe $label. Setiap tipe sakit kepala '
        'memiliki ciri berbeda — mulai dari cara sakitnya, gejala '
        'penyerta, sampai pemicunya — jadi penjelasan detailnya '
        'sebaiknya dikonfirmasi langsung oleh dokter.';
  }

  // ------------------------------------------------------------------
  //  2) KESIMPULAN — rangkuman dari seluruh hasil
  // ------------------------------------------------------------------
  static String kesimpulan(String label, {double confidence = -1}) {
    var teks = _kesimpulanDasar(label);

    // ✅ Catatan jujur kalau keyakinan rendah (semua tipe berimbang)
    if (confidence >= 0 && confidence < 0.35) {
      teks += ' Catatan penting: tingkat keyakinan sistem kali ini '
          'tergolong rendah (${(confidence * 100).toStringAsFixed(1)}%) '
          '— nilai antar tipe hampir berimbang, jadi hasil teratas '
          'bukan kepastian. Anggap ini petunjuk awal, bukan diagnosis.';
    }
    return teks;
  }

  static String _kesimpulanDasar(String label) {
    final l = label.toLowerCase();

    if (l.contains('without migraine') || l.contains('tanpa migrain')) {
      return 'Penglihatan atau tubuhmu menunjukkan tanda aura, tetapi '
          'tidak diikuti sakit kepala migrain. Kondisi ini tidak boleh '
          'diabaikan begitu saja — gejala serupa bisa muncul pada '
          'masalah saraf lain, jadi pastikan untuk diperiksa dokter.';
    }
    if (l.contains('with migraine') ||
        l.contains('dengan migrain') ||
        l.contains('with aura') ||
        l.contains('dengan aura')) {
      return 'Aura bisa dijadikan alarm awal — saat tanda peringatan '
          'muncul, kamu punya beberapa menit waktu untuk bersiap '
          'sebelum sakit kepala datang.';
    }
    if (l.contains('hemiplegic') || l.contains('hemiplegik')) {
      if (l.contains('familial') || l.contains('familiar')) {
        return 'Hasil mengarah ke migrain langka yang ditandai '
            'kelemahan satu sisi tubuh dengan riwayat keluarga. Jenis '
            'ini perlu ditangani dokter saraf, bukan dikelola sendiri '
            'di rumah.';
      }
      if (l.contains('sporadic') || l.contains('sporadik')) {
        return 'Kelemahan satu sisi tubuh tanpa riwayat keluarga — '
            'kondisi langka yang wajib dikonfirmasi dokter saraf '
            'karena gejalanya mirip stroke.';
      }
      return 'Auramu disertai kelemahan otot — jenis migrain langka '
          'yang wajib dikonfirmasi dokter saraf.';
    }
    if (l.contains('basilar') ||
        l.contains('brainstem') ||
        l.contains('batang otak')) {
      return 'Gejala auramu menunjukkan keterlibatan batang otak '
          '(pusing berputar, pandang ganda, bicara parau) — jenis '
          'langka yang perlu dikonfirmasi dokter saraf.';
    }
    if (l.contains('without aura') || l.contains('tanpa aura')) {
      return 'Serangan migrainmu kemungkinan datang langsung tanpa '
          'tanda peringatan. Catat pemicunya — kurang tidur, stres, '
          'makanan tertentu, atau haid — supaya lebih mudah dihindari.';
    }
    if (l.contains('lainnya') ||
        l.contains('other') ||
        l.contains('bukan') ||
        l.contains('no migrain') ||
        l.contains('not migrain')) {
      return 'Hasilnya belum spesifik ke satu tipe migrain. Tetap '
          'berguna sebagai bahan awal percakapan dengan dokter.';
    }
    return 'Sistem mengestimasi keluhanmu paling dekat dengan tipe '
        'ini. Gunakan hasilnya sebagai bahan awal untuk berbicara '
        'dengan dokter.';
  }

  // ------------------------------------------------------------------
  //  3) REKOMENDASI — tindakan yang disarankan
  // ------------------------------------------------------------------
  static List<String> rekomendasi(String label) {
    final l = label.toLowerCase();
    final r = <String>[];

    if (l.contains('without migraine') || l.contains('tanpa migrain')) {
      r.addAll([
        'Catat detail setiap aura: apa yang kamu lihat atau rasakan, jam berapa, dan berapa lama',
        'Jangan mengemudi atau mengoperasikan alat berisiko selama aura berlangsung',
        'Periksakan dirimu ke dokter — gangguan penglihatan atau kesemutan mendadak perlu dipastikan penyebabnya',
      ]);
    } else if (l.contains('with migraine') ||
        l.contains('dengan migrain') ||
        l.contains('with aura') ||
        l.contains('dengan aura')) {
      r.addAll([
        'Saat aura muncul: segera cari tempat tenang, minum air, dan siapkan obat bila dokter sudah meresepkan',
        'Hindari mengemudi selama aura masih terasa',
        'Catat pemicunya lewat diary migrain: kurang tidur, stres, makanan tertentu, atau haid',
      ]);
    } else if (l.contains('hemiplegic') || l.contains('hemiplegik')) {
      if (l.contains('familial') || l.contains('familiar')) {
        r.addAll([
          'Periksa ke dokter saraf (neurolog) — jenis ini butuh penanganan khusus',
          'Petakan riwayat kesehatan keluarga: siapa yang punya keluhan migrain atau kelemahan serupa',
          'Segera ke IGD bila kelemahan tubuh muncul tiba-tiba dan berat — perlu dipastikan bukan stroke',
        ]);
      } else if (l.contains('sporadic') || l.contains('sporadik')) {
        r.addAll([
          'Periksa ke dokter saraf (neurolog) untuk pemeriksaan yang teliti',
          'Segera ke IGD bila kelemahan tubuh muncul tiba-tiba dan berat — perlu dipastikan bukan stroke',
          'Catat setiap episode: kapan mulai, berapa lama, dan seberapa berat kelemahannya',
        ]);
      } else {
        r.addAll([
          'Periksa ke dokter saraf (neurolog) — jenis ini butuh penanganan khusus',
          'Segera ke IGD bila kelemahan tubuh muncul tiba-tiba dan berat',
          'Catat setiap episode beserta riwayat kesehatan keluarga',
        ]);
      }
    } else if (l.contains('basilar') ||
        l.contains('brainstem') ||
        l.contains('batang otak')) {
      r.addAll([
        'Hindari aktivitas berisiko saat aura: mengemudi, renang sendirian, atau bekerja di ketinggian',
        'Periksa ke dokter saraf untuk memastikan penyebab gejala batang otak ini',
        'Catat gejala yang muncul: pandang ganda, pusing berputar, berdenging, atau jalan goyah',
      ]);
    } else if (l.contains('without aura') || l.contains('tanpa aura')) {
      r.addAll([
        'Catat pemicu serangan lewat diary migrain: tidur, stres, makanan, atau haid',
        'Jaga pola tidur teratur, cukup minum air, dan jangan melewatkan makan',
        'Konsultasikan ke dokter bila serangan makin sering atau makin berat',
      ]);
    } else if (l.contains('lainnya') ||
        l.contains('other') ||
        l.contains('bukan') ||
        l.contains('no migrain') ||
        l.contains('not migrain')) {
      r.addAll([
        'Lakukan skrining ulang saat keluhan sedang kambuh agar datanya lebih akurat',
        'Konsultasikan ke dokter untuk pemeriksaan yang lebih teliti',
        'Jaga pola tidur, hidrasi, dan kelola stres',
      ]);
    } else {
      r.addAll([
        'Bawa catatan keluhanmu saat berbicara dengan dokter',
        'Catat kapan keluhan muncul dan apa pemicunya',
        'Konsultasikan ke dokter bila keluhan berlanjut',
      ]);
    }

    // 🎯 Rekomendasi umum — selalu ditambahkan di bagian akhir
    r.add('Bawa hasil skrining ini saat konsultasi supaya dokter lebih mudah menilai kondisimu');
    r.add('Kamu bisa langsung booking konsultasi dokter lewat menu Konsultasi di MigraCare');
    return r;
  }
}