// =======================================================================
//  MIGRACARE — Model & Data Artikel
//  File: lib/models/artikel.dart
// =======================================================================

/// Satu artikel lengkap (dipakai di Beranda, Daftar Artikel & Detail)
class Artikel {
  const Artikel({
    required this.category,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.imageUrl,
    required this.sections,
    this.readMinutes,
  });

  final String category;
  final String title;
  final String subtitle;
  final String date;
  final String imageUrl;
  final List<ArtikelSection> sections;

  /// Estimasi waktu baca (menit) — opsional
  final int? readMinutes;
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

// -------------------------------------------------------------------------
// DATA DUMMY — nanti tinggal diganti hasil dari API/Firebase
// -------------------------------------------------------------------------
const List<Artikel> artikelPopuler = [
  Artikel(
    category: 'Edukasi',
    title: 'Mengenal Migraine dan Cara Mengelolanya',
    subtitle:
        'Pelajari apa itu migrain, gejalanya, pemicunya, dan cara mengelola agar aktivitas sehari-sehari lebih nyaman',
    date: '29 Agustus 2026',
    readMinutes: 5,
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
    readMinutes: 4,
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
  Artikel(
    category: 'Tips',
    title: 'Pola hidup sehat untuk membantu mengurangi migrain',
    subtitle:
        'Simak pola hidup sehat yang dapat membantu mengurangi frekuensi migrain Anda.',
    date: '8 September 2026',
    readMinutes: 4,
    imageUrl:
        'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?auto=format&fit=crop&w=600&q=60',
    sections: [
      ArtikelSection(
        heading: 'Tidur yang Cukup dan Teratur',
        paragraphs: [
          'Tidur yang tidak teratur merupakan salah satu pemicu migrain yang paling umum. Usahakan untuk tidur dan bangun di jam yang sama setiap hari, termasuk pada akhir pekan, agar ritme tubuh tetap stabil.',
          'Orang dewasa umumnya membutuhkan 7–9 jam tidur per malam. Hindari begadang, dan jangan pula tidur berlebihan pada akhir pekan karena keduanya dapat memicu serangan migrain.',
        ],
        note:
            'Ciptakan kamar tidur yang gelap, sejuk, dan tenang untuk meningkatkan kualitas tidur Anda.',
      ),
      ArtikelSection(
        heading: 'Asupan Air dan Nutrisi yang Terjaga',
        paragraphs: [
          'Dehidrasi adalah pemicu migrain yang sering diabaikan. Biasakan minum air sekitar 8 gelas sehari, atau lebih saat cuaca panas dan setelah beraktivitas fisik.',
          'Jangan melewatkan waktu makan. Melewatkan makan dapat menurunkan kadar gula darah dan memicu timbulnya migrain. Pilih makanan bergizi seimbang dengan sayur, buah, protein, dan karbohidrat kompleks.',
        ],
      ),
      ArtikelSection(
        heading: 'Olahraga Rutin dan Kelola Stres',
        paragraphs: [
          'Olahraga ringan secara teratur seperti berjalan kaki, berenang, atau bersepeda santai dapat membantu mengurangi frekuensi migrain. Mulailah secara bertahap, karena olahraga intensitas tinggi yang mendadak justru dapat memicu serangan pada sebagian orang.',
          'Kelola stres dengan latihan pernapasan, meditasi, yoga, atau aktivitas yang Anda sukai. Teknik relaksasi terbukti membantu menurunkan ketegangan otot dan frekuensi serangan migrain.',
        ],
      ),
    ],
  ),
  Artikel(
    category: 'Penanganan',
    title: 'Apa yang harus dilakukan saat migrain menyerang?',
    subtitle:
        'Ketahui langkah-langkah yang bisa kamu lakukan saat migrain datang.',
    date: '12 September 2026',
    readMinutes: 3,
    imageUrl:
        'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?auto=format&fit=crop&w=600&q=60',
    sections: [
      ArtikelSection(
        heading: 'Langkah Pertama Saat Serangan Datang',
        paragraphs: [
          'Begitu tanda migrain muncul, segeralah berhenti dari aktivitas yang sedang dilakukan. Temukan ruangan yang gelap, sejuk, dan tenang untuk beristirahat. Cahaya dan suara yang terlalu terang atau bising dapat memperberat gejala.',
          'Gunakan kompres dingin pada dahi atau bagian belakang leher untuk membantu menenangkan nyeri berdenyut. Berbaringlah santai sambil menutup mata dan mengatur pernapasan secara perlahan.',
        ],
      ),
      ArtikelSection(
        heading: 'Obat Pereda Nyeri',
        paragraphs: [
          'Obat pereda nyeri yang dijual bebas seperti parasetamol atau ibuprofen dapat membantu bila diminum segera pada awal serangan. Minumlah air yang cukup agar tubuh tidak dehidrasi.',
          'Hindari menggunakan obat terlalu sering. Penggunaan obat pereda nyeri lebih dari 2–3 kali seminggu dalam jangka panjang dapat menyebabkan sakit kepala akibat pemakaian obat berlebihan (medication overuse headache).',
        ],
        note:
            'Jika serangan tidak membaik setelah 72 jam, atau nyeri semakin berat, segera periksakan diri ke dokter.',
      ),
    ],
  ),
  Artikel(
    category: 'Edukasi',
    title: 'Makanan dan minuman yang dapat memicu migrain',
    subtitle: 'Beberapa makanan dan minuman bisa memicu migrain, yuk kenali!',
    date: '15 September 2026',
    readMinutes: 4,
    imageUrl:
        'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=600&q=60',
    sections: [
      ArtikelSection(
        heading: 'Makanan yang Sering Jadi Pemicu',
        paragraphs: [
          'Beberapa makanan dilaporkan lebih sering memicu migrain, antara lain keju yang mengandung tiramin (seperti keju tua), makanan olahan seperti sosis dan nugget yang mengandung nitrit, serta makanan yang mengandung MSG dalam jumlah banyak.',
          'Cokelat, buah-buahan asam seperti sitrus, dan makanan hasil fermentasi juga menjadi pemicu pada sebagian orang. Perlu diingat, pemicu dapat berbeda pada setiap orang.',
        ],
      ),
      ArtikelSection(
        heading: 'Minuman yang Perlu Dibatasi',
        paragraphs: [
          'Kafein dalam kopi, teh, dan minuman berenergi dapat memicu migrain bila dikonsumsi berlebihan. Sebaliknya, pada sebagian orang kafein justru membantu meredakan serangan. Kuncinya adalah membatasi jumlah dan menjaga pola konsumsi yang konsisten.',
          'Alkohol, terutama anggur merah dan bir, merupakan pemicu migrain yang cukup umum dilaporkan. Minuman manis dengan pemanis buatan juga perlu diwaspadai.',
        ],
      ),
      ArtikelSection(
        heading: 'Cara Mengetahui Pemicu Anda',
        paragraphs: [
          'Buatlah jurnal makan selama beberapa minggu. Catat makanan dan minuman yang dikonsumsi beserta waktu munculnya migrain. Dari pola tersebut, Anda dapat mengenali makanan yang paling berpotensi menjadi pemicu pribadi Anda.',
          'Jangan mengeluarkan terlalu banyak makanan sekaligus tanpa dasar pencatatan, karena dapat menyebabkan kekurangan gizi. Bila memungkinkan, konsultasikan hasil jurnal Anda dengan dokter atau ahli gizi.',
        ],
        note:
            'Pemicu berdasarkan makanan lebih akurat dikenali melalui pencatatan, bukan sekadar menghindari semua makanan "dilarang".',
      ),
    ],
  ),
  Artikel(
    category: 'Edukasi',
    title: 'Kapan migrain perlu diperiksa ke dokter?',
    subtitle:
        'Waspadai tanda dan gejala migrain yang membutuhkan penanganan lanjut!',
    date: '19 September 2026',
    readMinutes: 3,
    imageUrl:
        'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?auto=format&fit=crop&w=600&q=60',
    sections: [
      ArtikelSection(
        heading: 'Saatnya ke Dokter Bila…',
        paragraphs: [
          'Segera konsultasikan ke dokter bila sakit kepala Anda muncul lebih dari 4 kali dalam sebulan, semakin sering dan semakin berat, atau tidak membaik meskipun sudah istirahat dan minum obat pereda nyeri yang dijual bebas.',
          'Migrain yang mengganggu pekerjaan, sekolah, atau aktivitas sehari-hari juga merupakan alasan yang tepat untuk memeriksakan diri. Dokter dapat membantu menyusun rencana pengobatan pencegahan yang sesuai dengan kondisi Anda.',
        ],
      ),
      ArtikelSection(
        heading: 'Tanda Bahaya yang Wajib Waspada',
        paragraphs: [
          'Segera ke unit gawat darurat bila Anda mengalami sakit kepala yang datang mendadak dan sangat hebat seperti disambar petir, sakit kepala disertai demam dan kekakuan leher, kebingungan, kelemahan atau mati rasa pada satu sisi tubuh, gangguan bicara, maupun gangguan penglihatan yang tidak biasa.',
          'Sakit kepala yang muncul setelah cedera kepala, atau sakit kepala baru yang muncul pada usia di atas 50 tahun juga perlu dievaluasi segera untuk memastikan tidak ada penyakit lain yang lebih serius.',
        ],
        note:
            'Tanda-tanda di atas dapat menunjukkan kondisi medis lain yang serius dan memerlukan penanganan segera.',
      ),
    ],
  ),
];