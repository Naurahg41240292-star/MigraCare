/// =======================================================================
///  MIGRACARE — Model & Data Artikel
///  File: lib/models/artikel.dart
/// =======================================================================

/// Satu artikel lengkap (dipakai di Beranda & halaman Detail)
class Artikel {
  const Artikel({
    required this.category,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.imageUrl,
    required this.sections,
  });

  final String category;
  final String title;
  final String subtitle;
  final String date;
  final String imageUrl;
  final List<ArtikelSection> sections;
}

/// Satu bagian isi artikel (judul bagian + paragraf + catatan opsional)
class ArtikelSection {
  const ArtikelSection({
    required this.heading,
    required this.paragraphs,
    this.note,
  });

  final String heading;
  final List<String> paragraphs;
  final String? note;
}

/// -------------------------------------------------------------------------
/// DATA DUMMY — nanti tinggal diganti hasil dari API/Firebase
/// -------------------------------------------------------------------------
const List<Artikel> artikelPopuler = [
  Artikel(
    category: 'Edukasi',
    title: 'Mengenal Migraine dan Cara Mengelolanya',
    subtitle:
        'Pelajari apa itu migrain, gejalanya, pemicunya, dan cara mengelola agar aktivitas sehari-sehari lebih nyaman',
    date: '29 Agustus 2026',
    imageUrl:
        'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?auto=format&fit=crop&w=600&q=60',
    sections: [
      ArtikelSection(
        heading: 'Mengenal Migrain',
        paragraphs: [
          'Migrain bukan sekadar sakit kepala biasa. Migrain merupakan gangguan neurologis yang dapat menyebabkan nyeri kepala berdenyut dengan intensitas sedang hingga berat. Nyeri sering terasa pada satu sisi kepala dan dapat disertai mual, muntah, serta sensitivitas terhadap cahaya dan suara. Serangan migrain dapat berlangsung selama beberapa hari.',
          'Pada sebagian orang, migrain disertai aura, yaitu gejala neurologis sementara yang biasanya muncul sebelum atau bersamaan dengan sakit kepala. Aura dapat berupa gangguan penglihatan, seperti melihat kilatan cahaya atau pola tertentu, kesemutan di tangan atau wajah. Tidak semua orang dengan migrain mengalami aura.',
        ],
        note:
            'Migrain berbeda dengan sakit kepala biasa. Intensitas dan gejala dapat mengganggu aktivitas sehari-hari.',
      ),
      ArtikelSection(
        heading: 'Gejala yang Perlu Diwaspadai',
        paragraphs: [
          'Gejala migrain bisa berbeda pada setiap orang, namun beberapa tanda yang paling umum meliputi nyeri kepala berdenyut di satu sisi, mual hingga ingin muntah, serta menjadi sangat sensitif terhadap cahaya, suara, atau bau tertentu.',
          'Sebagian penderita juga mengalami penglihatan kabur, pusing saat bergerak, serta kelelahan berat yang bertahan setelah serangan berlalu.',
        ],
      ),
      ArtikelSection(
        heading: 'Pemicu yang Sering Terjadi',
        paragraphs: [
          'Migrain dapat dipicu oleh banyak hal yang berbeda pada tiap orang. Pemicu yang paling sering dilaporkan antara lain stres, kurang tidur atau tidur berlebihan, melewatkan waktu makan, dehidrasi, serta perubahan hormon.',
          'Faktor lingkungan seperti cuaca ekstrem, cahaya silau, bau menyengat, dan paparan layar gadget terlalu lama juga dapat memicu serangan. Makanan tertentu seperti kafein berlebih, keju tua, atau MSG juga dilaporkan menjadi pemicu pada sebagian orang.',
        ],
      ),
      ArtikelSection(
        heading: 'Cara Mengelola Migrain',
        paragraphs: [
          'Langkah pertama mengelola migrain adalah mengenali pemicu pribadi Anda. Catat kapan serangan terjadi, apa yang Anda makan, dan aktivitas sebelumnya dalam jurnal migrain. Pola yang teratur akan membantu Anda menghindari pemicu.',
          'Terapkan pola hidup teratur: tidur dan bangun di jam yang sama, minum air yang cukup, tidak melewatkan waktu makan, olahraga ringan secara rutin, serta kelola stres dengan latihan pernapasan atau meditasi.',
          'Saat serangan datang, istirahatlah di ruangan yang gelap dan tenang, lalu gunakan kompres dingin pada dahi atau leher. Jika nyeri sering terjadi atau semakin berat, segera konsultasikan ke dokter dan gunakan obat sesuai resep.',
        ],
        note:
            'Jika migrain muncul lebih dari 4 kali dalam sebulan atau semakin mengganggu, segera konsultasikan ke dokter.',
      ),
    ],
  ),
  Artikel(
    category: 'Pemicu',
    title: 'Kenali pemicu migrain yang sering terjadi',
    subtitle: 'Tujuh faktor umum yang dapat memicu serangan migrain Anda',
    date: '2 September 2026',
    imageUrl:
        'https://images.unsplash.com/photo-1544027993-37dbfe43562a?auto=format&fit=crop&w=600&q=60',
    sections: [
      ArtikelSection(
        heading: 'Apa Itu Pemicu Migrain?',
        paragraphs: [
          'Pemicu (trigger) adalah faktor yang meningkatkan kemungkinan terjadinya serangan migrain. Pemicu bisa berbeda-beda pada setiap orang, bahkan pada orang yang sama dapat berubah dari waktu ke waktu.',
        ],
      ),
      ArtikelSection(
        heading: 'Pemicu Paling Umum',
        paragraphs: [
          'Stres dan kelelahan, perubahan pola tidur, melewatkan waktu makan, dehidrasi, perubahan cuaca, paparan cahaya terang atau suara bising, serta konsumsi makanan tertentu termasuk pemicu yang paling sering dilaporkan.',
        ],
        note:
            'Mencatat pemicu pribadi Anda adalah langkah pertama yang paling efektif untuk mengurangi frekuensi serangan.',
      ),
      ArtikelSection(
        heading: 'Cara Menghindari Pemicu',
        paragraphs: [
          'Tidur dan bangunlah di jam yang sama setiap hari, jangan tunda waktu makan, dan sediakan air minum selalu di dekat Anda.',
          'Batasi waktu menatap layar dengan aturan 20-20-20: setiap 20 menit, alihkan pandangan ke benda berjarak sekitar 6 meter selama 20 detik.',
        ],
      ),
    ],
  ),
];