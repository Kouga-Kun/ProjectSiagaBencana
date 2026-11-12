import 'education_models.dart';

class EducationSeedData {
  static const List<EducationMaterialItem> defaultMaterials = [
    // A. 12 MATERI GEMPA BUMI
    EducationMaterialItem(
      id: 1,
      category: 'Gempa Bumi',
      title: 'Pengertian Gempa Bumi',
      slug: 'pengertian-gempa-bumi',
      difficulty: 'Dasar',
      summary:
          'Gempa bumi adalah getaran atau guncangan di permukaan bumi akibat pelepasan energi secara tiba-tiba dari dalam kerak bumi.',
      content:
          'Gempa bumi terjadi ketika batuan di kerak bumi mengalami tekanan besar hingga akhirnya patah atau bergeser pada bidang patahan (sesar). Energi elastis yang terkumpul dilepaskan dalam bentuk gelombang seismik ke segala arah.\n\nTitik pusat pelepasan energi di dalam bumi disebut hiposentrum, sedangkan titik di permukaan bumi tepat di atasnya disebut episentrum. Gempa tidak dapat diprediksi kapan terjadinya secara pasti, sehingga kesiapsiagaan sebelum bencana menjadi kunci keselamatan.',
      keyPoints: [
        'Gempa bumi merupakan pelepasan energi gelombang seismik dari dalam bumi.',
        'Hiposentrum berada di bawah permukaan bumi, episentrum berada di permukaan.',
        'Waktu terjadinya gempa belum dapat diprediksi secara pasti oleh teknologi saat ini.',
      ],
      actionSteps: [
        'Kenali potensi risiko gempa bumi di wilayah tempat tinggal dan sekolah.',
        'Pelajari prosedur penyelamatan diri Drop, Cover, and Hold On.',
        'Pastikan seluruh anggota keluarga mengetahui titik kumpul darurat.',
      ],
      thingsToAvoid: [
        'Mempercayai kabar bohong (hoaks) prediksi jam dan tanggal pasti terjadinya gempa.',
        'Mengabaikan latihan simulasi evakuasi mandiri.',
      ],
      sourceReference: 'Buku Saku Tanggap Tangkas Tangguh Menghadapi Bencana BNPB & BMKG',
      sortOrder: 1,
    ),
    EducationMaterialItem(
      id: 2,
      category: 'Gempa Bumi',
      title: 'Penyebab Terjadinya Gempa Bumi',
      slug: 'penyebab-terjadinya-gempa-bumi',
      difficulty: 'Dasar',
      summary:
          'Pergerakan lempeng tektonik, aktivitas sesar aktif daratan, dan zona subduksi megathrust merupakan penyebab utama gempa bumi di Indonesia.',
      content:
          'Indonesia terletak pada pertemuan tiga lempeng tektonik besar dunia: Lempeng Indo-Australia, Lempeng Eurasia, dan Lempeng Pasifik. Tumbukan lempeng di lepas pantai barat Sumatera membentuk zona subduksi (megathrust), sedangkan di daratan terdapat jaringan sesar aktif seperti Sesar Besar Sumatera (Semangko).\n\nKetika dua lempeng saling menekan dan terkunci, energi regangan terus terakumulasi. Saat batas kekuatan batuan terlampaui, terjadilah pergeseran mendadak yang memicu gempa bumi.',
      keyPoints: [
        'Tumbukan Lempeng Indo-Australia dan Eurasia memicu gempa zona subduksi.',
        'Pergeseran patahan di daratan memicu gempa kerak dangkal (shallow crustal earthquake).',
        'Gempa dangkal di darat sering menimbulkan kerusakan bangunan yang kuat meskipun magnitudonya sedang.',
      ],
      actionSteps: [
        'Ketahui peta bahaya seismik wilayah Sumatera Barat dan sekitarnya.',
        'Perkuat struktur bangunan rumah sesuai standar bangunan tahan gempa.',
      ],
      thingsToAvoid: [
        'Membangun rumah tanpa tulangan kolom dan balok pengikat di zona rawan gempa.',
      ],
      sourceReference: 'Pusat Studi Gempa Nasional (PuSGeN) & BMKG',
      sortOrder: 2,
    ),
    EducationMaterialItem(
      id: 3,
      category: 'Gempa Bumi',
      title: 'Jenis dan Karakteristik Gempa Bumi',
      slug: 'jenis-dan-karakteristik-gempa-bumi',
      difficulty: 'Menengah',
      summary:
          'Mengenal jenis gempa berdasarkan penyebab (tektonik, vulkanik, runtuhan) dan kedalaman pusat gempa (dangkal, menengah, dalam).',
      content:
          'Berdasarkan penyebabnya, gempa bumi terbagi menjadi gempa tektonik (pergeseran lempeng/sesar), gempa vulkanik (aktivitas magma gunung api), dan gempa runtuhan. Gempa tektonik adalah yang paling berdampak luas.\n\nBerdasarkan kedalaman hiposentrumnya, gempa dibagi menjadi gempa dangkal (<60 km), menengah (60–300 km), dan dalam (>300 km). Ukuran kekuatan gempa dinyatakan dalam Magnitudo (M), sedangkan tingkat guncangan di permukaan diukur dengan skala MMI (Modified Mercalli Intensity).',
      keyPoints: [
        'Gempa tektonik menyumbang lebih dari 90% kejadian gempa merusak.',
        'Gempa dangkal (<60 km) menghasilkan guncangan permukaan yang paling terasa.',
        'Magnitudo mengukur energi di pusat gempa, skala MMI mengukur dampak getaran di lokasi.',
      ],
      actionSteps: [
        'Perhatikan kedalaman dan lokasi episentrum saat membaca informasi resmi BMKG.',
        'Waspadai potensi tsunami apabila gempa berkekuatan besar (M ≥ 7,0) berpusat di laut pada kedalaman dangkal.',
      ],
      thingsToAvoid: [
        'Menganggap semua gempa laut pasti memicu tsunami tanpa melihat parameter atau merasakan kuatnya guncangan.',
      ],
      sourceReference: 'Katalog Gempabumi Signifikan dan Merusak BMKG',
      sortOrder: 3,
    ),
    EducationMaterialItem(
      id: 4,
      category: 'Gempa Bumi',
      title: 'Mengenali Tanda dan Informasi Gempa',
      slug: 'mengenali-tanda-dan-informasi-gempa',
      difficulty: 'Dasar',
      summary:
          'Cara mengenali gelombang awal gempa serta membaca parameter resmi dari aplikasi InfoBMKG dan kanal resmi pemerintah.',
      content:
          'Saat gempa terjadi, gelombang primer (Gelombang P) tiba lebih dulu dengan getaran halus atau suara gemuruh, disusul gelombang sekunder (Gelombang S) yang membawa guncangan mengayun lebih kuat.\n\nSetelah guncangan berhenti, masyarakat perlu memantau informasi resmi dari BMKG yang mencantumkan waktu kejadian, koordinat lokasi, magnitudo, kedalaman, dan status potensi tsunami.',
      keyPoints: [
        'Gelombang P tiba pertama kali disusul Gelombang S yang lebih merusak.',
        'BMKG adalah satu-satunya instansi resmi penyedia informasi parameter gempa di Indonesia.',
        'Perhatikan keterangan resmi apakah gempa berpotensi tsunami atau tidak.',
      ],
      actionSteps: [
        'Segera berlindung begitu merasakan getaran awal tanpa menunggu pengumuman.',
        'Setelah kondisi aman, buka informasi resmi BMKG atau SiagaBencana untuk memverifikasi parameter gempa.',
      ],
      thingsToAvoid: [
        'Menyebarkan tangkapan layar info gempa yang belum jelas sumber dan tanggalnya.',
      ],
      sourceReference: 'Pedoman Layanan Informasi Gempabumi BMKG',
      sortOrder: 4,
    ),
    EducationMaterialItem(
      id: 5,
      category: 'Gempa Bumi',
      title: 'Persiapan Sebelum Terjadi Gempa',
      slug: 'persiapan-sebelum-terjadi-gempa',
      difficulty: 'Dasar',
      summary:
          'Langkah mitigasi struktural dan non-struktural di rumah sebelum gempa terjadi untuk meminimalkan risiko cedera.',
      content:
          'Sebagian besar cedera saat gempa bumi disebabkan oleh jatuhnya benda berat, pecahan kaca, atau lemari yang roboh, bukan semata-mata runtuhnya gedung.\n\nPersiapan sebelum gempa meliputi pengamanan perabotan tinggi ke dinding, penempatan barang berat di rak paling bawah, pemeriksaan instalasi listrik dan gas, serta penyusunan rencana darurat keluarga.',
      keyPoints: [
        'Rekatkan lemari tinggi dan rak buku ke dinding menggunakan siku penahan.',
        'Letakkan benda berat dan mudah pecah di bagian rak bawah.',
        'Kenali lokasi sakelar utama listrik dan katup tabung gas LPG di rumah.',
      ],
      actionSteps: [
        'Identifikasi sudut aman dan meja kokoh di setiap ruangan rumah.',
        'Pastikan lorong dan pintu keluar rumah bebas dari tumpukan barang penghalang.',
        'Lakukan latihan perlindungan diri bersama keluarga minimal 6 bulan sekali.',
      ],
      thingsToAvoid: [
        'Menggantung bingkai kaca besar atau benda berat tepat di atas tempat tidur.',
        'Mengunci pintu darurat secara permanen sehingga sulit dibuka dari dalam.',
      ],
      sourceReference: 'Panduan Kesiapsiagaan Keluarga Menghadapi Bencana BNPB',
      sortOrder: 5,
    ),
    EducationMaterialItem(
      id: 6,
      category: 'Gempa Bumi',
      title: 'Tindakan Saat Terjadi Gempa di Dalam Ruangan',
      slug: 'tindakan-saat-terjadi-gempa-di-dalam-ruangan',
      difficulty: 'Dasar',
      summary:
          'Panduan langkah emas Drop (Merunduk), Cover (Lindungi Kepala), dan Hold On (Bertahan) ketika guncangan gempa terjadi di dalam ruangan.',
      content:
          'Ketika gempa bumi mengguncang saat Anda berada di dalam ruangan, langkah paling aman adalah menerapkan prinsip Drop, Cover, and Hold On:\n1. DROP (Merunduk): Jatuhkan tubuh ke posisi tangan dan lutut agar tidak terjatuh oleh guncangan.\n2. COVER (Lindungi Kepala): Berlindung di bawah meja yang kokoh serta lindungi kepala dan leher.\n3. HOLD ON (Bertahan): Pegang kaki meja dengan kuat hingga guncangan berhenti sepenuhnya.',
      keyPoints: [
        'Terapkan prinsip Drop, Cover, and Hold On segera saat guncangan terasa.',
        'Jauhi jendela kaca, cermin, lemari tinggi, dan lampu gantung.',
        'Bila sedang memasak, segera matikan kompor sebelum berlindung jika terjangkau.',
      ],
      actionSteps: [
        'Merunduk dan masuk ke bawah meja yang kuat.',
        'Jika tidak ada meja, merunduk di dekat sudut dinding bagian dalam dan lindungi kepala dengan bantal atau lengan.',
        'Tunggu hingga guncangan benar-benar berhenti sebelum berjalan keluar secara tertib.',
      ],
      thingsToAvoid: [
        'Berlari panik ke luar ruangan saat lantai masih berguncang keras karena rawan tertimpa genteng atau pecahan kaca.',
      ],
      sourceReference: 'BNPB & UNESCO Earthquake Safety Guidelines',
      sortOrder: 6,
    ),
    EducationMaterialItem(
      id: 7,
      category: 'Gempa Bumi',
      title: 'Tindakan Saat Terjadi Gempa di Luar Ruangan',
      slug: 'tindakan-saat-terjadi-gempa-di-luar-ruangan',
      difficulty: 'Dasar',
      summary:
          'Cara menyelamatkan diri saat berada di area terbuka, jalan raya, atau di dalam kendaraan ketika terjadi gempa bumi.',
      content:
          'Jika Anda berada di luar ruangan saat gempa terjadi, tetaplah di luar dan segera cari area terbuka yang jauh dari bangunan tinggi, tiang listrik, papan reklame, pohon besar, dan dinding pagar.\n\nApabila sedang mengemudi kendaraan, kurangi kecepatan secara bertahap, menepi di tempat aman yang jauh dari jembatan atau jalan layang (flyover), tarik rem tangan, dan tetap berada di dalam mobil hingga guncangan berhenti.',
      keyPoints: [
        'Bergerak menuju area lapangan terbuka yang bebas dari benda tinggi.',
        'Pengendara wajib menepi jauh dari jembatan, pohon, dan tiang listrik.',
        'Waspadai potensi tanah longsor jika berada di dekat lereng bukit.',
      ],
      actionSteps: [
        'Merunduk di tempat terbuka sambil melindungi kepala.',
        'Jika berkendara, nyalakan lampu hazard, menepi perlahan, dan tunggu guncangan selesai.',
      ],
      thingsToAvoid: [
        'Berdiri tepat di bawah fasad gedung kaca, kabel listrik, atau papan baliho.',
        'Berhenti di atas atau tepat di bawah jembatan saat gempa berlangsung.',
      ],
      sourceReference: 'Buku Saku BNPB & Korlantas Keselamatan Darurat',
      sortOrder: 7,
    ),
    EducationMaterialItem(
      id: 8,
      category: 'Gempa Bumi',
      title: 'Tindakan Saat Terjadi Gempa di Sekolah',
      slug: 'tindakan-saat-terjadi-gempa-di-sekolah',
      difficulty: 'Dasar',
      summary:
          'Prosedur keselamatan siswa dan guru saat gempa terjadi di ruang kelas maupun lingkungan sekolah.',
      content:
          'Di ruang kelas, siswa harus segera berlindung di bawah meja belajar masing-masing dengan posisi merunduk, melindungi kepala menggunakan tas sekolah atau buku tebal, dan memegang kaki meja kuat-kuat.\n\nSetelah guncangan berhenti, guru memimpin evakuasi secara berbaris tertib menuju titik kumpul lapangan sekolah tanpa saling mendorong di tangga atau pintu kelas.',
      keyPoints: [
        'Gunakan meja belajar dan tas sekolah untuk melindungi kepala dari reruntuhan plafon.',
        'Ikuti aba-aba guru dan jangan berebut keluar pintu kelas saat guncangan masih berlangsung.',
        'Berkumpul di lapangan sekolah dan lakukan pengecekan jumlah siswa (absensi darurat).',
      ],
      actionSteps: [
        'Berlindung di bawah meja kelas saat gempa mengguncang.',
        'Setelah guncangan berhenti, keluar kelas dengan melindungi kepala menggunakan tas.',
        'Menuju titik kumpul sekolah dan tetap bersama rombongan kelas.',
      ],
      thingsToAvoid: [
        'Berdesak-desakan di lorong dan tangga sekolah.',
        'Kembali masuk ke ruang kelas untuk mengambil barang yang tertinggal.',
      ],
      sourceReference: 'Pedoman Satuan Pendidikan Aman Bencana (SPAB) Kemendikbud & BNPB',
      sortOrder: 8,
    ),
    EducationMaterialItem(
      id: 9,
      category: 'Gempa Bumi',
      title: 'Tindakan Saat Terjadi Gempa di Gedung Bertingkat',
      slug: 'tindakan-saat-terjadi-gempa-di-gedung-bertingkat',
      difficulty: 'Menengah',
      summary:
          'Prosedur keselamatan di perkantoran, apartemen, pusat perbelanjaan, atau hotel bertingkat saat gempa bumi.',
      content:
          'Saat berada di gedung bertingkat, guncangan gempa biasanya terasa lebih mengayun. Segera berlindung di bawah meja kerja atau di dekat pilar/kolom struktural utama, jauh dari dinding kaca luar.\n\nDilarang keras menggunakan lift saat dan setelah gempa karena risiko listrik padam atau macet. Gunakan tangga darurat setelah guncangan berhenti.',
      keyPoints: [
        'Jauhi kaca jendela fasad gedung dan partisi kaca.',
        'Jangan pernah menggunakan lift atau eskalator saat gempa terjadi.',
        'Gunakan tangga darurat dengan memegang pegangan tangga (handrail).',
      ],
      actionSteps: [
        'Merunduk dan lindungi kepala di bawah meja atau di samping kolom utama.',
        'Jika terlanjur berada di dalam lift, tekan semua tombol lantai dan segera keluar di lantai terdekat yang terbuka.',
        'Turun melalui tangga darurat setelah guncangan berhenti.',
      ],
      thingsToAvoid: [
        'Menggunakan lift untuk turun dari gedung bertingkat.',
        'Melompat dari jendela atau balkon lantai atas.',
      ],
      sourceReference: 'Pedoman Keselamatan Gedung Bertingkat BNPB & Basarnas',
      sortOrder: 9,
    ),
    EducationMaterialItem(
      id: 10,
      category: 'Gempa Bumi',
      title: 'Tindakan Setelah Gempa Bumi',
      slug: 'tindakan-setelah-gempa-bumi',
      difficulty: 'Menengah',
      summary:
          'Langkah pemeriksaan keselamatan diri, keluarga, kondisi bangunan, serta kesiapsiagaan menghadapi gempa susulan.',
      content:
          'Setelah guncangan utama berhenti, tetaplah tenang dan waspadai gempa susulan (aftershocks). Periksa kondisi diri sendiri terlebih dahulu, kemudian bantu anggota keluarga atau orang di sekitar yang membutuhkan pertolongan pertama.\n\nMatikan aliran listrik dan cabut regulator gas jika tercium bau gas bocor. Apabila berada di wilayah pesisir dan gempa terasa sangat kuat atau lama, segera evakuasi ke tempat tinggi untuk mengantisipasi tsunami.',
      keyPoints: [
        'Selalu siap menghadapi gempa susulan (aftershocks).',
        'Periksa kebocoran gas, kerusakan kabel listrik, dan keretakan struktur bangunan.',
        'Di wilayah pesisir, segera menjauh dari pantai jika gempa terasa kuat atau lama.',
      ],
      actionSteps: [
        'Periksa luka pada diri sendiri dan keluarga, berikan pertolongan pertama.',
        'Keluar dari bangunan apabila ditemukan retakan besar pada kolom atau dinding penyangga.',
        'Pantau informasi resmi dari BMKG, BNPB, dan BPBD setempat.',
      ],
      thingsToAvoid: [
        'Menyalakan korek api atau sakelar listrik ketika tercium bau gas di dalam rumah.',
        'Langsung masuk kembali ke rumah yang mengalami kerusakan struktur parah.',
      ],
      sourceReference: 'Panduan Pasca Bencana Gempa Bumi BNPB & BMKG',
      sortOrder: 10,
    ),
    EducationMaterialItem(
      id: 11,
      category: 'Gempa Bumi',
      title: 'Mengenali Potensi Bahaya Setelah Gempa',
      slug: 'mengenali-potensi-bahaya-setelah-gempa',
      difficulty: 'Lanjutan',
      summary:
          'Memahami bahaya ikutan (collateral hazards) pascagempa seperti kebakaran, likuefaksi, tanah longsor, dan tsunami.',
      content:
          'Gempa bumi besar sering diikuti bahaya ikutan yang tidak kalah mematikan, antara lain:\n1. Gempa susulan yang dapat meruntuhkan bangunan yang sudah retak.\n2. Kebakaran akibat korsleting listrik atau kebocoran pipa/tabung gas.\n3. Likuefaksi (peluluhan tanah berpasir jenuh air).\n4. Tanah longsor pada tebing curam.\n5. Gelombang tsunami di kawasan pesisir pantai.',
      keyPoints: [
        'Kebakaran pascagempa sering terjadi akibat korsleting listrik dan kebocoran gas.',
        'Likuefaksi dapat terjadi pada tanah berpasir jenuh air yang terguncang kuat.',
        'Tsunami adalah bahaya ikutan paling kritis bagi masyarakat wilayah pesisir.',
      ],
      actionSteps: [
        'Matikan MCB listrik utama dan lepaskan regulator LPG sebelum meninggalkan rumah.',
        'Jauhi lereng bukit curam dan tebing sungai yang rawan runtuh pascagempa.',
      ],
      thingsToAvoid: [
        'Mendekati gedung miring, tiang listrik roboh, atau kabel yang menjuntai ke tanah.',
      ],
      sourceReference: 'Kajian Risiko Bencana Nasional BNPB & Badan Geologi',
      sortOrder: 11,
    ),
    EducationMaterialItem(
      id: 12,
      category: 'Gempa Bumi',
      title: 'Tas Siaga Bencana untuk Gempa Bumi',
      slug: 'tas-siaga-bencana-untuk-gempa-bumi',
      difficulty: 'Dasar',
      summary:
          'Daftar perlengkapan wajib dalam Tas Siaga Bencana untuk bertahan hidup mandiri selama 72 jam pertama keadaan darurat.',
      content:
          'Tas Siaga Bencana adalah tas ransel tahan air berisi kebutuhan pokok darurat agar keluarga dapat bertahan secara mandiri minimal selama 3 hari (72 jam) pertama pascabencana.\n\nIsi utama Tas Siaga meliputi: dokumen penting dalam plastik kedap air, kotak P3K dan obat rutin pribadi, air minum dan makanan tahan lama, senter, peluit darurat, powerbank, radio portabel, pakaian ganti, serta perlengkapan kebersihan.',
      keyPoints: [
        'Tas Siaga dirancang untuk mencukupi kebutuhan darurat selama 72 jam pertama.',
        'Peluit sangat penting untuk memberi sinyal posisi jika terjebak atau saat malam hari.',
        'Letakkan Tas Siaga di dekat pintu keluar rumah yang mudah dijangkau.',
      ],
      actionSteps: [
        'Siapkan satu Tas Siaga Bencana yang mudah dibawa berlari.',
        'Simpan salinan KTP, KK, akta, dan dokumen penting dalam kantong kedap air.',
        'Periksa tanggal kedaluwarsa makanan, air, obat, dan baterai setiap 6 bulan.',
      ],
      thingsToAvoid: [
        'Memasukkan barang berat yang tidak esensial sehingga menyulitkan pergerakan evakuasi.',
      ],
      sourceReference: 'Pedoman Tas Siaga Bencana BNPB',
      sortOrder: 12,
    ),

    // B. 12 MATERI TSUNAMI
    EducationMaterialItem(
      id: 13,
      category: 'Tsunami',
      title: 'Pengertian Tsunami',
      slug: 'pengertian-tsunami',
      difficulty: 'Dasar',
      summary:
          'Tsunami adalah rangkaian gelombang laut berkecepatan tinggi akibat perpindahan massa air laut secara besar dan mendadak.',
      content:
          'Kata tsunami berasal dari bahasa Jepang ("tsu" berarti pelabuhan dan "nami" berarti gelombang). Tsunami bukan gelombang tunggal, melainkan serangkaian gelombang laut raksasa yang timbul akibat perubahan vertikal dasar laut secara tiba-tiba.\n\nDi laut dalam, kecepatan tsunami dapat mencapai 500–800 km/jam. Ketika mendekati pantai yang dangkal, kecepatannya menurun tetapi tinggi gelombangnya meningkat drastis dan menyapu daratan pesisir dengan energi sangat besar.',
      keyPoints: [
        'Tsunami terdiri dari serangkaian gelombang, bukan hanya satu gelombang.',
        'Gelombang kedua atau ketiga sering kali lebih tinggi dan lebih berbahaya daripada gelombang pertama.',
        'Kecepatan rambat tsunami di laut dalam setara pesawat jet.',
      ],
      actionSteps: [
        'Pahami bahwa tsunami dapat menjangkau daratan jauh melalui muara sungai dan pantai landai.',
        'Kenali peta zona bahaya tsunami di wilayah pesisir Kota Padang.',
      ],
      thingsToAvoid: [
        'Mengira bahaya tsunami sudah selesai setelah gelombang pertama surut.',
      ],
      sourceReference: 'Pedoman Pelayanan Peringatan Dini Tsunami InaTEWS BMKG & UNESCO-IOC',
      sortOrder: 1,
    ),
    EducationMaterialItem(
      id: 14,
      category: 'Tsunami',
      title: 'Penyebab Terjadinya Tsunami',
      slug: 'penyebab-terjadinya-tsunami',
      difficulty: 'Dasar',
      summary:
          'Mengenal faktor pemicu tsunami: gempa bumi tektonik bawah laut, longsoran bawah laut, dan aktivitas gunung api laut.',
      content:
          'Penyebab utama terjadinya tsunami (lebih dari 85% kejadian di dunia) adalah gempa bumi tektonik bawah laut yang mengakibatkan patahan naik atau turun secara vertikal pada lantai samudra.\n\nSelain gempa bawah laut, tsunami juga dapat dipicu oleh tanah longsor bawah laut (submarine landslide) maupun runtuhan kaldera gunung api di laut.',
      keyPoints: [
        'Gempa bumi tektonik di dasar laut merupakan pemicu utama tsunami di Indonesia.',
        'Longsoran bawah laut dapat memicu tsunami lokal yang tiba sangat cepat di pantai.',
      ],
      actionSteps: [
        'Waspadai setiap gempa kuat yang dirasakan di kawasan pesisir.',
        'Ikuti informasi peringatan dini resmi dari BMKG dan BPBD.',
      ],
      thingsToAvoid: [
        'Mengabaikan tanda-tanda anomali air laut meskipun tidak merasakan gempa yang sangat besar.',
      ],
      sourceReference: 'BMKG InaTEWS & Pusat Vulkanologi dan Mitigasi Bencana Geologi',
      sortOrder: 2,
    ),
    EducationMaterialItem(
      id: 15,
      category: 'Tsunami',
      title: 'Hubungan Gempa Bumi dengan Tsunami',
      slug: 'hubungan-gempa-bumi-dengan-tsunami',
      difficulty: 'Menengah',
      summary:
          'Tidak semua gempa menyebabkan tsunami: pelajari kriteria gempa bumi yang berpotensi memicu gelombang tsunami.',
      content:
          'Penting dipahami bahwa TIDAK SEMUA gempa bumi menyebabkan tsunami. Secara ilmiah, gempa bumi yang berpotensi memicu tsunami umumnya memenuhi kriteria berikut:\n1. Pusat gempa (episentrum) berada di dasar laut.\n2. Kedalaman pusat gempa tergolong dangkal (kurang dari 70 km).\n3. Kekuatan gempa cukup besar (umumnya Magnitudo ≥ 7,0).\n4. Mekanisme patahan berupa sesar naik atau turun vertikal yang menggerakkan kolom air laut.\n\nBagi warga pesisir, patokan paling praktis adalah prinsip 20-20-20: jika merasakan gempa selama ≥ 20 detik, Anda memiliki waktu sekitar 20 menit untuk segera evakuasi ke ketinggian ≥ 20 meter.',
      keyPoints: [
        'Tidak semua gempa bumi memicu tsunami; hanya gempa laut dangkal berkekuatan besar dengan deformasi vertikal.',
        'Gempa kuat (sulit berdiri) atau gempa berdurasi lama (≥20 detik) di pesisir adalah peringatan alami tsunami.',
        'Prinsip 20-20-20 menjadi pedoman emas penyelamatan diri di wilayah pantai.',
      ],
      actionSteps: [
        'Jika berada di pantai dan merasakan gempa kuat atau lama, segera evakuasi ke tempat tinggi begitu guncangan berhenti.',
        'Jangan menunggu sirine berbunyi jika gempa kuat sudah dirasakan langsung.',
      ],
      thingsToAvoid: [
        'Panik berlebihan saat terjadi gempa kecil di darat yang jelas tidak berpotensi tsunami.',
        'Menunggu pengumuman resmi di tepi pantai padahal baru saja merasakan gempa sangat kuat.',
      ],
      sourceReference: 'BMKG InaTEWS & BNPB Pedoman Mitigasi Tsunami',
      sortOrder: 3,
    ),
    EducationMaterialItem(
      id: 16,
      category: 'Tsunami',
      title: 'Mengenali Peringatan Dini Tsunami',
      slug: 'mengenali-peringatan-dini-tsunami',
      difficulty: 'Dasar',
      summary:
          'Memahami 3 tingkat status peringatan dini tsunami BMKG: AWAS, SIAGA, dan WASPADA beserta instruksi tindakannya.',
      content:
          'Sistem Peringatan Dini Tsunami Indonesia (InaTEWS) yang dikelola BMKG mengeluarkan tiga status peringatan berdasarkan estimasi tinggi gelombang di pantai:\n\n1. AWAS (Merah): Estimasi tinggi tsunami > 3 meter. Pemerintah daerah dan masyarakat wajib melakukan EVAKUASI MENYELURUH segera.\n2. SIAGA (Oranye): Estimasi tinggi tsunami 0,5 hingga 3 meter. Masyarakat wajib melakukan EVAKUASI segera menjauhi pantai dan sungai.\n3. WASPADA (Kuning): Estimasi tinggi tsunami < 0,5 meter. Masyarakat wajib MENJAUHI PANTAI dan tepian sungai.',
      keyPoints: [
        'Status AWAS dan SIAGA mewajibkan evakuasi segera ke tempat tinggi atau shelter.',
        'Status WASPADA mewajibkan warga menjauhi pantai, pelabuhan, dan muara sungai.',
        'Peringatan disampaikan melalui sirine tsunami, SMS blast, aplikasi InfoBMKG, dan media resmi.',
      ],
      actionSteps: [
        'Kenali suara sirine peringatan dini tsunami di wilayah pesisir Kota Padang.',
        'Segera bergerak mengikuti jalur evakuasi begitu mendengar sirine atau menerima peringatan resmi.',
      ],
      thingsToAvoid: [
        'Mengabaikan status WASPADA dan tetap beraktivitas di bibir pantai.',
      ],
      sourceReference: 'Standar Operasional Prosedur InaTEWS BMKG & BNPB',
      sortOrder: 4,
    ),
    EducationMaterialItem(
      id: 17,
      category: 'Tsunami',
      title: 'Tanda Alam yang Dapat Mengindikasikan Tsunami',
      slug: 'tanda-alam-yang-dapat-mengindikasikan-tsunami',
      difficulty: 'Dasar',
      summary:
          'Mengenali fenomena alam sebelum tsunami tiba: guncangan gempa kuat, air laut surut mendadak, dan suara gemuruh dari laut.',
      content:
          'Selain peringatan teknologi dari BMKG, alam memberikan tanda-tanda bahaya tsunami yang wajib dikenali setiap warga pesisir:\n1. Terasa guncangan gempa bumi yang kuat (membuat sulit berdiri) atau mengayun lama.\n2. Air laut tiba-tiba surut secara drastis dan tidak biasa hingga memperlihatkan dasar laut, terumbu karang, atau ikan yang menggelepar.\n3. Terdengar suara gemuruh keras dari arah laut menyerupai suara kereta api atau pesawat terbang.\n4. Gelombang di cakrawala tampak membentuk dinding putih atau hitam pekat yang mendekat cepat.',
      keyPoints: [
        'Surutnya air laut secara tiba-tiba setelah gempa adalah tanda bahaya tsunami sudah sangat dekat.',
        'Suara gemuruh keras dari tengah laut menandakan gelombang besar sedang bergerak menuju daratan.',
      ],
      actionSteps: [
        'Segera lari menuju tempat tinggi atau gedung shelter terdekat begitu melihat air laut surut tidak biasa.',
        'Teriakkan peringatan bahaya kepada warga sekitar sambil terus bergerak menjauhi pantai.',
      ],
      thingsToAvoid: [
        'Turun ke pantai untuk memungut ikan atau mengambil foto/video saat air laut surut mendadak.',
      ],
      sourceReference: 'UNESCO-IOC Tsunami Ready & BNPB',
      sortOrder: 5,
    ),
    EducationMaterialItem(
      id: 18,
      category: 'Tsunami',
      title: 'Wilayah yang Berpotensi Terdampak Tsunami',
      slug: 'wilayah-yang-berpotensi-terdampak-tsunami',
      difficulty: 'Menengah',
      summary:
          'Mengenali karakteristik kawasan rawan tsunami: pesisir pantai landai, teluk sempit, dan daerah aliran muara sungai.',
      content:
          'Wilayah yang paling berpotensi terdampak tsunami adalah kawasan pesisir pantai dengan dataran rendah, teluk berbentuk huruf V yang memfokuskan energi gelombang, serta kawasan di sepanjang muara dan aliran sungai yang bermuara ke laut.\n\nGelombang tsunami dapat masuk berkilometer-kilometer ke daratan melalui alur sungai. Oleh karena itu, menjauhi sungai sama pentingnya dengan menjauhi garis pantai.',
      keyPoints: [
        'Pantai landai dan teluk memicu amplifikasi tinggi gelombang tsunami.',
        'Aliran sungai menjadi jalur masuknya gelombang tsunami jauh ke arah daratan.',
      ],
      actionSteps: [
        'Periksa apakah rumah, sekolah, atau tempat kerja Anda berada di Zona Merah rawan tsunami pada Peta Evakuasi.',
        'Tentukan rute tercepat menuju Zona Hijau (daerah tinggi) atau Shelter Evakuasi Vertikal.',
      ],
      thingsToAvoid: [
        'Berlari menyusuri tepi sungai atau menyeberangi jembatan muara saat peringatan tsunami aktif.',
      ],
      sourceReference: 'Peta Bahaya Tsunami Kota Padang BPBD & BNPB',
      sortOrder: 6,
    ),
    EducationMaterialItem(
      id: 19,
      category: 'Tsunami',
      title: 'Persiapan Sebelum Tsunami',
      slug: 'persiapan-sebelum-tsunami',
      difficulty: 'Dasar',
      summary:
          'Menyiapkan rencana evakuasi keluarga, mengenali peta rute evakuasi, dan menentukan titik kumpul di dataran tinggi.',
      content:
          'Kesiapsiagaan sebelum tsunami terjadi sangat menentukan kecepatan penyelamatan diri karena waktu tiba gelombang tsunami lokal di pantai barat Sumatera berkisar antara 20 hingga 30 menit pascagempa.\n\nSetiap keluarga di wilayah pesisir wajib menyepakati jalur evakuasi utama dan jalur alternatif, mengenali lokasi TES (Tempat Evakuasi Sementara / Shelter Vertikal) terdekat, serta menyiapkan Tas Siaga Bencana.',
      keyPoints: [
        'Waktu emas (golden time) evakuasi tsunami lokal sangat singkat (20–30 menit).',
        'Rencana evakuasi keluarga mencegah anggota keluarga saling mencari ke arah zona bahaya.',
      ],
      actionSteps: [
        'Pelajari rambu jalur evakuasi tsunami di lingkungan tempat tinggal.',
        'Latih waktu tempuh berjalan cepat dari rumah menuju titik aman atau gedung shelter.',
        'Sepakati titik kumpul keluarga di zona aman.',
      ],
      thingsToAvoid: [
        'Belum pernah mencoba melewati jalur evakuasi sebelum bencana terjadi.',
      ],
      sourceReference: 'Pedoman Masyarakat Siaga Tsunami (Tsunami Ready) BMKG & UNESCO',
      sortOrder: 7,
    ),
    EducationMaterialItem(
      id: 20,
      category: 'Tsunami',
      title: 'Tindakan Saat Mendapat Peringatan Tsunami',
      slug: 'tindakan-saat-mendapat-peringatan-tsunami',
      difficulty: 'Dasar',
      summary:
          'Langkah cepat dan tepat ketika merasakan gempa kuat di pesisir atau mendengar sirine peringatan dini tsunami.',
      content:
          'Ketika Anda berada di wilayah pesisir dan merasakan gempa kuat (atau gempa yang berlangsung lama >20 detik), lindungi diri terlebih dahulu hingga guncangan berhenti. Begitu guncangan berhenti, JANGAN MENUNGGU SIRINE: segera lakukan evakuasi mandiri menjauhi pantai.\n\nJika sirine tsunami berbunyi atau pengumuman resmi dikeluarkan, tinggalkan aktivitas seketika, ambil Tas Siaga Bencana bila terjangkau, dan bergerak cepat menuju tempat tinggi.',
      keyPoints: [
        'Gempa kuat/lama di pesisir = Peringatan pertama untuk segera evakuasi mandiri.',
        'Keselamatan nyawa jauh lebih berharga daripada harta benda.',
      ],
      actionSteps: [
        'Lindungi kepala saat gempa masih mengguncang.',
        'Segera keluar bangunan setelah guncangan berhenti dan bergerak ke arah daratan tinggi.',
        'Bantu anak-anak, lansia, ibu hamil, dan penyandang disabilitas di sekitar Anda.',
      ],
      thingsToAvoid: [
        'Menunggu pengumuman resmi di pantai padahal gempa kuat sudah dirasakan.',
        'Menghabiskan waktu mengemas barang-barang rumah tangga yang berat.',
      ],
      sourceReference: 'BNPB, BMKG & BPBD Kota Padang',
      sortOrder: 8,
    ),
    EducationMaterialItem(
      id: 21,
      category: 'Tsunami',
      title: 'Cara Melakukan Evakuasi ke Tempat yang Lebih Tinggi atau Lokasi Aman',
      slug: 'cara-melakukan-evakuasi-ke-tempat-yang-lebih-tinggi-atau-lokasi-aman',
      difficulty: 'Menengah',
      summary:
          'Panduan evakuasi horizontal menuju bukit/zona hijau dan evakuasi vertikal ke gedung shelter tahan gempa minimal lantai 3–4.',
      content:
          'Evakuasi tsunami dapat dilakukan dengan dua cara sesuai kondisi lokasi:\n1. Evakuasi Horizontal: Bergerak menjauhi garis pantai menuju perbukitan atau dataran tinggi di luar zona bahaya tsunami (ketinggian minimal 20 meter di atas permukaan laut).\n2. Evakuasi Vertikal: Jika waktu sangat sempit atau jarak ke perbukitan terlalu jauh, naiklah ke lantai atas gedung bertingkat yang kokoh tahan gempa (minimal lantai 3 atau 4) atau Shelter Evakuasi Tsunami resmi yang telah ditetapkan pemerintah.\n\nUtamakan berjalan kaki cepat atau berlari agar tidak terjebak kemacetan lalu lintas.',
      keyPoints: [
        'Evakuasi dengan berjalan kaki sangat dianjurkan untuk menghindari kemacetan total di jalur evakuasi.',
        'Evakuasi vertikal dilakukan ke gedung beton bertulang yang tahan gempa minimal lantai 3–4.',
        'Jika berada di perahu di tengah laut dalam (>50 m), arahkan perahu lebih jauh ke laut lepas, jangan merapat ke pantai.',
      ],
      actionSteps: [
        'Ikuti rambu panah jalur evakuasi tsunami menuju titik kumpul resmi.',
        'Jika waktu tidak cukup mencapai bukit, segera naik ke Shelter Tsunami terdekat.',
      ],
      thingsToAvoid: [
        'Menggunakan mobil pribadi yang dapat mengunci pergerakan ribuan warga di jalan sempit.',
      ],
      sourceReference: 'Pedoman Evakuasi Vertikal Tsunami BNPB & Basarnas',
      sortOrder: 9,
    ),
    EducationMaterialItem(
      id: 22,
      category: 'Tsunami',
      title: 'Hal yang Tidak Boleh Dilakukan Saat Evakuasi Tsunami',
      slug: 'hal-yang-tidak-boleh-dilakukan-saat-evakuasi-tsunami',
      difficulty: 'Dasar',
      summary:
          'Daftar kesalahan fatal saat evakuasi tsunami yang membahayakan nyawa diri sendiri maupun masyarakat sekitar.',
      content:
          'Dalam kondisi darurat tsunami, beberapa tindakan keliru sering menyebabkan jatuhnya korban jiwa yang seharusnya dapat dicegah. Memahami pantangan saat evakuasi membantu masyarakat bertindak disiplin dan selamat.',
      keyPoints: [
        'Jangan pernah mendekati pantai untuk menonton gelombang atau memotret.',
        'Jangan kembali ke rumah di zona bahaya sebelum peringatan resmi diakhiri.',
        'Jangan menggunakan jembatan yang melintasi muara sungai ke arah pantai.',
      ],
      actionSteps: [
        'Fokus bergerak menjauhi pantai dan sungai secara tertib.',
        'Ingatkan warga lain yang masih berhenti atau menonton di dekat pantai.',
      ],
      thingsToAvoid: [
        'Mendekati pantai karena rasa penasaran saat air laut surut.',
        'Membawa kendaraan roda empat yang memicu kemacetan jalur evakuasi.',
        'Menyebarkan informasi kepanikan yang belum terverifikasi.',
      ],
      sourceReference: 'Buku Saku Kesiapsiagaan Tsunami BNPB & BMKG',
      sortOrder: 10,
    ),
    EducationMaterialItem(
      id: 23,
      category: 'Tsunami',
      title: 'Tindakan Setelah Tsunami',
      slug: 'tindakan-setelah-tsunami',
      difficulty: 'Menengah',
      summary:
          'Langkah bertahan di lokasi pengungsian, pertolongan pertama, serta kewaspadaan terhadap bahaya kesehatan dan listrik pascatsunami.',
      content:
          'Setelah gelombang tsunami terjadi, tetaplah berada di lokasi evakuasi yang aman. Gelombang tsunami susulan masih dapat datang dalam selang waktu beberapa menit hingga beberapa jam.\n\nDi tempat pengungsian, periksa kondisi keselamatan keluarga, bantu penanganan luka darurat, dan hindari mengonsumsi air atau makanan yang terkontaminasi genangan lumpur tsunami.',
      keyPoints: [
        'Tetap bertahan di tempat tinggi sampai BMKG menyatakan peringatan dini tsunami telah berakhir.',
        'Genangan air tsunami membawa puing tajam, limbah, dan bahaya sengatan listrik.',
      ],
      actionSteps: [
        'Laporkan kondisi darurat atau anggota keluarga yang terpisah kepada petugas posko BPBD/Basarnas.',
        'Gunakan fitur Bantuan Darurat (SOS) atau Laporan Bencana jika membutuhkan evakuasi medis.',
      ],
      thingsToAvoid: [
        'Berjalan tanpa alas kaki di area genangan dan puing-puing pascatsunami.',
        'Meminum air sumur terbuka yang telah tercemar air laut dan lumpur.',
      ],
      sourceReference: 'Pedoman Penanganan Darurat Pascabencana BNPB & Kemenkes',
      sortOrder: 11,
    ),
    EducationMaterialItem(
      id: 24,
      category: 'Tsunami',
      title: 'Kembali ke Wilayah Pesisir Setelah Peringatan Berakhir',
      slug: 'kembali-ke-wilayah-pesisir-setelah-peringatan-berakhir',
      difficulty: 'Lanjutan',
      summary:
          'Prosedur aman kembali ke rumah di kawasan pesisir hanya setelah pengumuman resmi pengakhiran peringatan tsunami dari BMKG/BPBD.',
      content:
          'Masyarakat HANYA BOLEH kembali ke wilayah pesisir setelah BMKG secara resmi mengumumkan "Peringatan Dini Tsunami Berakhir" dan petugas BPBD/aparat setempat menyatakan kondisi wilayah aman untuk dimasuki.\n\nSaat kembali ke rumah, periksa keutuhan struktur bangunan sebelum masuk, pastikan listrik dalam keadaan mati, dan waspadai endapan lumpur maupun benda berbahaya.',
      keyPoints: [
        'Tunggu pernyataan resmi "Peringatan Dini Tsunami Berakhir" dari BMKG.',
        'Jangan memasuki bangunan yang pondasi atau kolom utamanya rusak diterjang gelombang.',
      ],
      actionSteps: [
        'Pastikan informasi aman berasal dari kanal resmi BMKG, BNPB, atau BPBD.',
        'Masuki area rumah pada siang hari dengan menggunakan alas kaki tebal dan sarung tangan.',
      ],
      thingsToAvoid: [
        'Kembali ke pantai hanya karena melihat air laut tampak tenang sementara waktu.',
        'Menyalakan listrik di rumah yang masih tergenang air.',
      ],
      sourceReference: 'SOP Pengakhiran Peringatan Dini Tsunami InaTEWS BMKG & BNPB',
      sortOrder: 12,
    ),
  ];

  static const List<SimulationItem> defaultSimulations = [
    // A. 6 SIMULASI GEMPA BUMI
    SimulationItem(
      id: 1,
      category: 'Gempa Bumi',
      title: 'Gempa Terjadi Saat Berada di Dalam Rumah',
      slug: 'simulasi-gempa-di-dalam-rumah',
      difficulty: 'Dasar',
      description: 'Simulasi pengambilan keputusan cepat ketika lantai rumah bergetar hebat.',
      scenarioContext:
          'Kamu sedang bersantai di ruang keluarga. Tiba-tiba lantai bergetar kuat, lampu gantung berayun keras, dan terdengar suara gemuruh.',
      safetyReference: 'Panduan Kesiapsiagaan Gempa Bumi BNPB & BMKG',
      steps: [
        SimulationStepItem(
          id: 101,
          stepNumber: 1,
          situationTitle: 'Guncangan Pertama di Ruang Keluarga',
          situationText:
              'Lantai dan perabotan di sekitarmu mulai bergetar keras. Di dekatmu ada meja makan kayu yang kokoh, lemari kaca tinggi, dan pintu keluar yang berjarak 12 meter. Apa yang harus kamu lakukan?',
          recommendedAction:
              'Lakukan Drop, Cover, and Hold On di bawah meja makan yang kokoh dan jauhi lemari kaca hingga guncangan berhenti.',
          choices: [
            SimulationChoiceItem(
              id: 1001,
              label: 'A',
              choiceText:
                  'Segera merunduk (Drop), masuk ke bawah meja makan yang kokoh (Cover), dan berpegangan pada kaki meja (Hold On).',
              isCorrect: true,
              score: 100,
              assessment: 'Tepat',
              feedback:
                  'Sangat tepat! Merunduk dan berlindung di bawah meja kokoh melindungi kepala serta tubuh dari jatuhan benda dan pecahan kaca.',
            ),
            SimulationChoiceItem(
              id: 1002,
              label: 'B',
              choiceText:
                  'Berlari sekuat tenaga melewati lemari kaca menuju pintu keluar saat lantai masih berguncang hebat.',
              isCorrect: false,
              score: 20,
              assessment: 'Berbahaya',
              feedback:
                  'Berlari saat guncangan kuat membuatmu mudah terjatuh dan berisiko tertimpa lemari kaca atau genteng di ambang pintu.',
            ),
            SimulationChoiceItem(
              id: 1003,
              label: 'C',
              choiceText: 'Berdiri menahan lemari kaca agar piring di dalamnya tidak jatuh.',
              isCorrect: false,
              score: 0,
              assessment: 'Sangat Berbahaya',
              feedback:
                  'Sangat berbahaya! Lemari berat dapat roboh menimpa tubuhmu dan kaca dapat pecah melukai kepala.',
            ),
          ],
        ),
      ],
    ),
    SimulationItem(
      id: 2,
      category: 'Gempa Bumi',
      title: 'Gempa Terjadi Saat Berada di Ruang Kelas',
      slug: 'simulasi-gempa-di-ruang-kelas',
      difficulty: 'Dasar',
      description: 'Latihan tindakan penyelamatan diri bagi pelajar dan guru ketika gempa mengguncang sekolah.',
      scenarioContext:
          'Kamu sedang belajar di kelas lantai 2. Tiba-tiba lantai dan benda-benda di sekitarmu mulai bergetar kuat.',
      safetyReference: 'Pedoman Satuan Pendidikan Aman Bencana (SPAB) BNPB',
      steps: [
        SimulationStepItem(
          id: 102,
          stepNumber: 1,
          situationTitle: 'Guncangan Saat Pelajaran Berlangsung',
          situationText:
              'Kamu sedang belajar di kelas. Tiba-tiba lantai dan benda-benda di sekitarmu mulai bergetar. Apa yang harus kamu lakukan?',
          recommendedAction:
              'Merunduk di bawah meja belajar, lindungi kepala dan leher dengan tas atau buku tebal, serta pegang kaki meja hingga guncangan berhenti.',
          choices: [
            SimulationChoiceItem(
              id: 1004,
              label: 'A',
              choiceText:
                  'Merunduk di bawah meja belajar, melindungi kepala dengan tas/buku, dan memegang kaki meja hingga guncangan berhenti.',
              isCorrect: true,
              score: 100,
              assessment: 'Tepat',
              feedback:
                  'Tepat sekali! Meja kelas dan tas melindungi kepalamu dari jatuhan lampu atau plafon kelas.',
            ),
            SimulationChoiceItem(
              id: 1005,
              label: 'B',
              choiceText: 'Berebut lari keluar pintu kelas dan menuruni tangga bersama teman-teman.',
              isCorrect: false,
              score: 10,
              assessment: 'Berbahaya',
              feedback:
                  'Berebut di pintu dan tangga saat gempa sedang mengguncang sangat berisiko menyebabkan siswa terjatuh dan terinjak.',
            ),
            SimulationChoiceItem(
              id: 1006,
              label: 'C',
              choiceText: 'Berdiri di dekat jendela kaca kelas untuk melihat keadaan halaman sekolah.',
              isCorrect: false,
              score: 0,
              assessment: 'Berbahaya',
              feedback: 'Kaca jendela dapat pecah akibat tekanan guncangan rangka bangunan.',
            ),
          ],
        ),
      ],
    ),
    SimulationItem(
      id: 3,
      category: 'Gempa Bumi',
      title: 'Gempa Terjadi Saat Berada di Gedung Bertingkat',
      slug: 'simulasi-gempa-di-gedung-bertingkat',
      difficulty: 'Menengah',
      description: 'Menguji keputusan evakuasi aman di gedung bertingkat tanpa menggunakan lift.',
      scenarioContext:
          'Kamu berada di lantai 6 sebuah gedung perkantoran ketika gempa bumi mengguncang dan membuat gedung terasa bergoyang.',
      safetyReference: 'Pedoman Keselamatan Gedung Bertingkat BNPB & Basarnas',
      steps: [
        SimulationStepItem(
          id: 103,
          stepNumber: 1,
          situationTitle: 'Memilih Cara Turun Setelah Guncangan Berhenti',
          situationText:
              'Setelah kamu berlindung di bawah meja hingga guncangan berhenti, petugas keamanan menginstruksikan evakuasi gedung. Di depanmu ada lift yang masih menyala dan pintu tangga darurat. Apa pilihanmu?',
          recommendedAction:
              'Gunakan tangga darurat dengan tertib sambil berpegangan pada handrail, dan jangan pernah menggunakan lift.',
          choices: [
            SimulationChoiceItem(
              id: 1007,
              label: 'A',
              choiceText: 'Turun menggunakan tangga darurat secara tertib sambil memegang pegangan tangga.',
              isCorrect: true,
              score: 100,
              assessment: 'Tepat',
              feedback:
                  'Benar! Tangga darurat dirancang khusus untuk evakuasi aman dan tidak bergantung pada aliran listrik.',
            ),
            SimulationChoiceItem(
              id: 1008,
              label: 'B',
              choiceText: 'Masuk ke dalam lift agar lebih cepat sampai di lantai dasar.',
              isCorrect: false,
              score: 0,
              assessment: 'Sangat Berbahaya',
              feedback:
                  'Dilarang keras menggunakan lift saat/setelah gempa karena listrik dapat padam mendadak atau rel lift bengkok akibat gempa susulan.',
            ),
          ],
        ),
      ],
    ),
    SimulationItem(
      id: 4,
      category: 'Gempa Bumi',
      title: 'Gempa Terjadi Saat Berada di Luar Ruangan',
      slug: 'simulasi-gempa-di-luar-ruangan',
      difficulty: 'Dasar',
      description: 'Menentukan posisi aman ketika gempa terjadi saat berjalan di trotoar kota.',
      scenarioContext:
          'Kamu sedang berjalan di trotoar jalan raya dekat deretan ruko bertingkat, tiang listrik, dan papan reklame besar ketika tanah berguncang.',
      safetyReference: 'Buku Saku Tanggap Tangkas Tangguh BNPB',
      steps: [
        SimulationStepItem(
          id: 104,
          stepNumber: 1,
          situationTitle: 'Menghindari Benda Jatuh di Area Terbuka',
          situationText:
              'Tiang listrik dan papan reklame di dekatmu bergoyang keras. Di seberang terdapat lapangan terbuka yang jauh dari bangunan. Apa tindakanmu?',
          recommendedAction:
              'Segera bergerak ke area lapangan terbuka yang jauh dari gedung, tiang listrik, pohon, dan reklame, lalu merunduk melindungi kepala.',
          choices: [
            SimulationChoiceItem(
              id: 1009,
              label: 'A',
              choiceText:
                  'Segera menjauh dari bangunan, tiang listrik, dan papan reklame menuju area terbuka, lalu merunduk melindungi kepala.',
              isCorrect: true,
              score: 100,
              assessment: 'Tepat',
              feedback: 'Tepat! Area terbuka menghindarkanmu dari runtuhan fasad gedung, kaca, dan kabel listrik.',
            ),
            SimulationChoiceItem(
              id: 1010,
              label: 'B',
              choiceText: 'Berdiri tepat di bawah kanopi kaca ruko agar terlindung dari panas.',
              isCorrect: false,
              score: 0,
              assessment: 'Berbahaya',
              feedback: 'Kanopi kaca dan dinding luar ruko sangat rawan runtuh menimpa orang di bawahnya.',
            ),
          ],
        ),
      ],
    ),
    SimulationItem(
      id: 5,
      category: 'Gempa Bumi',
      title: 'Gempa Terjadi Saat Sedang Berkendara',
      slug: 'simulasi-gempa-saat-berkendara',
      difficulty: 'Menengah',
      description: 'Cara mengendalikan kendaraan dengan aman saat jalan raya berguncang akibat gempa.',
      scenarioContext:
          'Kamu sedang mengendarai mobil di jalan raya mendekati jembatan layang ketika kemudi terasa oleng karena gempa bumi.',
      safetyReference: 'Panduan Keselamatan Berkendara Saat Darurat BNPB',
      steps: [
        SimulationStepItem(
          id: 105,
          stepNumber: 1,
          situationTitle: 'Menghentikan Kendaraan di Lokasi Aman',
          situationText:
              'Mobilmu terasa bergoyang dan pengendara lain mulai melambat. Di depanmu ada jembatan layang (flyover). Apa yang harus kamu lakukan?',
          recommendedAction:
              'Kurangi kecepatan secara bertahap, nyalakan lampu hazard, menepi di tempat terbuka sebelum jembatan layang, tarik rem tangan, dan tetap di dalam mobil hingga guncangan berhenti.',
          choices: [
            SimulationChoiceItem(
              id: 1011,
              label: 'A',
              choiceText:
                  'Nyalakan lampu hazard, menepi perlahan di tempat terbuka jauh dari jembatan/tiang, dan tetap di dalam mobil sampai gempa berhenti.',
              isCorrect: true,
              score: 100,
              assessment: 'Tepat',
              feedback:
                  'Tepat! Menepi jauh dari jembatan dan tetap di dalam kendaraan melindungimu dari jatuhan benda luar.',
            ),
            SimulationChoiceItem(
              id: 1012,
              label: 'B',
              choiceText: 'Menambah kecepatan untuk melintasi jembatan layang secepat mungkin.',
              isCorrect: false,
              score: 0,
              assessment: 'Berbahaya',
              feedback: 'Jembatan berisiko mengalami keretakan atau runtuh saat guncangan kuat.',
            ),
          ],
        ),
      ],
    ),
    SimulationItem(
      id: 6,
      category: 'Gempa Bumi',
      title: 'Gempa Terjadi Saat Berada di Tempat Umum',
      slug: 'simulasi-gempa-di-tempat-umum',
      difficulty: 'Menengah',
      description: 'Tindakan penyelamatan diri di pusat perbelanjaan atau pasar ramai saat gempa.',
      scenarioContext:
          'Kamu sedang berbelanja di lorong supermarket dengan rak-rak tinggi penuh barang ketika gempa bumi terjadi.',
      safetyReference: 'Panduan Kesiapsiagaan BNPB',
      steps: [
        SimulationStepItem(
          id: 106,
          stepNumber: 1,
          situationTitle: 'Menghindari Rak Barang Tinggi & Kepanikan Massa',
          situationText:
              'Barang-barang dari rak tinggi mulai berjatuhan dan pengunjung mulai berteriak. Apa tindakan paling tepat?',
          recommendedAction:
              'Menjauh dari lorong rak tinggi dan etalase kaca, merunduk di dekat pilar utama sambil melindungi kepala dengan keranjang belanja atau lengan, lalu ikuti jalur evakuasi setelah guncangan berhenti.',
          choices: [
            SimulationChoiceItem(
              id: 1013,
              label: 'A',
              choiceText:
                  'Menjauh dari rak tinggi ke area dekat pilar kokoh, merunduk sambil melindungi kepala, kemudian keluar mengikuti rambu jalur evakuasi setelah guncangan berhenti.',
              isCorrect: true,
              score: 100,
              assessment: 'Tepat',
              feedback: 'Sangat tepat! Menjauhi rak tinggi dan menghindari desak-desakan di pintu saat guncangan adalah kunci keselamatan.',
            ),
            SimulationChoiceItem(
              id: 1014,
              label: 'B',
              choiceText: 'Ikut mendorong kerumunan di pintu kaca utama saat gempa masih mengguncang.',
              isCorrect: false,
              score: 10,
              assessment: 'Berbahaya',
              feedback: 'Berdesakan di pintu kaca saat gempa berisiko memicu injak-injakan dan pecahan kaca.',
            ),
          ],
        ),
      ],
    ),

    // B. 6 SIMULASI TSUNAMI
    SimulationItem(
      id: 7,
      category: 'Tsunami',
      title: 'Gempa Kuat Dirasakan Ketika Berada di Wilayah Pesisir',
      slug: 'simulasi-gempa-kuat-di-wilayah-pesisir',
      difficulty: 'Dasar',
      description:
          'Latihan keputusan kritis evakuasi mandiri setelah merasakan gempa kuat dan lama di daerah pesisir pantai.',
      scenarioContext:
          'Kamu berada di rumah yang berjarak 400 meter dari Pantai Padang. Tiba-tiba terjadi gempa kuat selama 30 detik yang membuatmu sulit berdiri.',
      safetyReference: 'Prinsip 20-20-20 InaTEWS BMKG & BNPB',
      steps: [
        SimulationStepItem(
          id: 107,
          stepNumber: 1,
          situationTitle: 'Tindakan Segera Setelah Guncangan Gempa Kuat Berhenti',
          situationText:
              'Guncangan gempa yang sangat kuat dan lama baru saja berhenti. Listrik padam dan kamu belum mendengar bunyi sirine. Apa yang harus kamu lakukan?',
          recommendedAction:
              'Segera lakukan evakuasi mandiri bersama keluarga menuju tempat tinggi (>20 mdpl) atau Shelter Tsunami tanpa menunggu sirine resmi.',
          choices: [
            SimulationChoiceItem(
              id: 1015,
              label: 'A',
              choiceText:
                  'Segera membawa Tas Siaga dan mengevakuasi keluarga ke tempat tinggi / Shelter Evakuasi Tsunami TANPA menunggu sirine berbunyi.',
              isCorrect: true,
              score: 100,
              assessment: 'Tepat',
              feedback:
                  'Sangat tepat! Gempa kuat (sulit berdiri) atau lama (≥20 detik) di pesisir adalah peringatan alami tsunami. Jangan menunggu sirine!',
            ),
            SimulationChoiceItem(
              id: 1016,
              label: 'B',
              choiceText: 'Tetap tinggal di rumah sambil menunggu pengumuman televisi atau sirine berbunyi.',
              isCorrect: false,
              score: 0,
              assessment: 'Sangat Berbahaya',
              feedback:
                  'Menunggu sirine saat gempa kuat sudah dirasakan dapat menghabiskan waktu emas (20 menit) sebelum gelombang tiba.',
            ),
          ],
        ),
      ],
    ),
    SimulationItem(
      id: 8,
      category: 'Tsunami',
      title: 'Air Laut Tiba-tiba Surut Secara Tidak Biasa',
      slug: 'simulasi-air-laut-surut-tidak-biasa',
      difficulty: 'Dasar',
      description: 'Menguji respons terhadap tanda alam tsunami ketika air laut menyurut drastis.',
      scenarioContext:
          'Beberapa menit setelah gempa terasa di pesisir, kamu melihat air laut tiba-tiba surut jauh dari garis pantai hingga karang dan ikan terlihat.',
      safetyReference: 'UNESCO-IOC Tsunami Ready & BMKG',
      steps: [
        SimulationStepItem(
          id: 108,
          stepNumber: 1,
          situationTitle: 'Melihat Air Laut Surut Drastis',
          situationText:
              'Beberapa orang di sekitarmu tampak penasaran ingin turun ke pantai mengambil ikan dan memotret. Apa tindakan yang wajib kamu lakukan?',
          recommendedAction:
              'Segera berlari menjauhi pantai menuju tempat tinggi atau shelter vertikal terdekat sambil meneriakkan peringatan bahaya tsunami kepada warga sekitar.',
          choices: [
            SimulationChoiceItem(
              id: 1017,
              label: 'A',
              choiceText:
                  'Segera berlari menjauhi pantai ke tempat tinggi/shelter sambil berteriak memperingatkan warga sekitar bahwa tsunami akan datang.',
              isCorrect: true,
              score: 100,
              assessment: 'Tepat',
              feedback:
                  'Tepat! Surutnya air laut secara mendadak menandakan gelombang tsunami akan segera menerjang pantai dalam hitungan menit.',
            ),
            SimulationChoiceItem(
              id: 1018,
              label: 'B',
              choiceText: 'Ikut mendekati pantai untuk merekam video fenomena surutnya air laut.',
              isCorrect: false,
              score: 0,
              assessment: 'Sangat Berbahaya',
              feedback:
                  'Kesalahan fatal! Ketika gelombang tsunami terlihat di dekat pantai, kecepatannya terlalu tinggi untuk dihindari dengan berlari dari bibir pantai.',
            ),
          ],
        ),
      ],
    ),
    SimulationItem(
      id: 9,
      category: 'Tsunami',
      title: 'Mendapat Peringatan Dini Tsunami dari Sumber Resmi',
      slug: 'simulasi-mendapat-peringatan-dini-tsunami',
      difficulty: 'Dasar',
      description: 'Cara bertindak cepat saat sirine berbunyi dan BMKG menetapkan status AWAS/SIAGA.',
      scenarioContext:
          'Sirine tsunami di pesisir Kota Padang berbunyi keras dan ponselmu menerima peringatan dini BMKG berstatus AWAS.',
      safetyReference: 'SOP InaTEWS BMKG & BPBD Kota Padang',
      steps: [
        SimulationStepItem(
          id: 109,
          stepNumber: 1,
          situationTitle: 'Memilih Moda dan Rute Evakuasi Saat Sirine Berbunyi',
          situationText:
              'Jarak rumahmu ke Gedung Shelter Evakuasi Tsunami resmi adalah 600 meter dan jalanan mulai ramai. Bagaimana cara evakuasi terbaik?',
          recommendedAction:
              'Berjalan kaki cepat atau berlari mengikuti rambu jalur evakuasi menuju gedung shelter/tempat tinggi tanpa membawa mobil pribadi.',
          choices: [
            SimulationChoiceItem(
              id: 1019,
              label: 'A',
              choiceText:
                  'Berjalan cepat/berlari mengikuti rambu evakuasi menuju Gedung Shelter sambil membawa Tas Siaga Bencana.',
              isCorrect: true,
              score: 100,
              assessment: 'Tepat',
              feedback:
                  'Benar! Evakuasi berjalan kaki untuk jarak dekat mencegah terjebak kemacetan total kendaraan.',
            ),
            SimulationChoiceItem(
              id: 1020,
              label: 'B',
              choiceText: 'Mengeluarkan mobil dan mengemudi melewati jembatan muara sungai dekat pantai.',
              isCorrect: false,
              score: 0,
              assessment: 'Sangat Berbahaya',
              feedback:
                  'Mobil memicu kemacetan jalur evakuasi dan jembatan muara sungai adalah jalur masuk utama gelombang tsunami.',
            ),
          ],
        ),
      ],
    ),
    SimulationItem(
      id: 10,
      category: 'Tsunami',
      title: 'Sedang Berada di Pantai Ketika Terjadi Gempa',
      slug: 'simulasi-berada-di-pantai-saat-gempa',
      difficulty: 'Dasar',
      description: 'Skenario penyelamatan diri wisatawan atau warga yang sedang berada langsung di kawasan pantai.',
      scenarioContext:
          'Kamu sedang berada di kawasan pantai. Tiba-tiba terjadi gempa kuat yang membuatmu sulit berdiri.',
      safetyReference: 'Panduan Keselamatan Pesisir BNPB & BMKG',
      steps: [
        SimulationStepItem(
          id: 110,
          stepNumber: 1,
          situationTitle: 'Tindakan di Kawasan Pantai Saat & Setelah Guncangan',
          situationText:
              'Kamu sedang berada di kawasan pantai. Tiba-tiba terjadi gempa kuat yang membuatmu sulit berdiri. Apa yang harus kamu lakukan setelah guncangan berhenti?',
          recommendedAction:
              'Segera menjauhi pantai dan berlari menuju tempat yang lebih tinggi atau gedung shelter evakuasi yang telah ditetapkan tanpa menunggu peringatan resmi.',
          choices: [
            SimulationChoiceItem(
              id: 1021,
              label: 'A',
              choiceText:
                  'Segera menjauhi pantai dan menuju tempat yang lebih tinggi atau jalur evakuasi resmi tanpa menunggu peringatan sirine.',
              isCorrect: true,
              score: 100,
              assessment: 'Tepat',
              feedback:
                  'Sangat tepat! Di wilayah pantai, gempa kuat yang membuat sulit berdiri adalah tanda bahaya langsung untuk segera evakuasi mandiri.',
            ),
            SimulationChoiceItem(
              id: 1022,
              label: 'B',
              choiceText: 'Duduk di gazebo tepi pantai sambil menunggu informasi dari penjaga pantai.',
              isCorrect: false,
              score: 0,
              assessment: 'Sangat Berbahaya',
              feedback:
                  'Setiap detik sangat berharga di kawasan pantai. Menunda evakuasi sangat membahayakan keselamatan jiwa.',
            ),
          ],
        ),
      ],
    ),
    SimulationItem(
      id: 11,
      category: 'Tsunami',
      title: 'Melakukan Evakuasi Bersama Keluarga',
      slug: 'simulasi-evakuasi-tsunami-bersama-keluarga',
      difficulty: 'Menengah',
      description: 'Mengutamakan keselamatan kelompok rentan dan ketertiban saat evakuasi keluarga.',
      scenarioContext:
          'Kamu melakukan evakuasi tsunami bersama orang tua lansia dan adik kecil menuju tempat evakuasi.',
      safetyReference: 'Pedoman Evakuasi Inklusif BNPB',
      steps: [
        SimulationStepItem(
          id: 111,
          stepNumber: 1,
          situationTitle: 'Menentukan Prioritas Barang dan Bantuan Keluarga',
          situationText:
              'Saat hendak keluar rumah menuju shelter vertikal terdekat, anggota keluarga bingung antara membawa televisi atau fokus mendampingi lansia dan anak-anak. Apa keputusanmu?',
          recommendedAction:
              'Tinggalkan barang berat, bawa hanya Tas Siaga Bencana, dan prioritaskan mendampingi lansia serta anak-anak menuju shelter terdekat.',
          choices: [
            SimulationChoiceItem(
              id: 1023,
              label: 'A',
              choiceText:
                  'Tinggalkan barang elektronik/perabotan, bawa Tas Siaga saja, dan fokus menuntun lansia serta anak-anak ke shelter terdekat.',
              isCorrect: true,
              score: 100,
              assessment: 'Tepat',
              feedback:
                  'Tepat! Keselamatan nyawa anggota keluarga dan kelompok rentan adalah prioritas mutlak.',
            ),
            SimulationChoiceItem(
              id: 1024,
              label: 'B',
              choiceText: 'Meminta keluarga menunggu sementara kamu mengemasi barang-barang berharga di kamar.',
              isCorrect: false,
              score: 0,
              assessment: 'Berbahaya',
              feedback: 'Menunda waktu evakuasi demi harta benda sangat membahayakan seluruh keluarga.',
            ),
          ],
        ),
      ],
    ),
    SimulationItem(
      id: 12,
      category: 'Tsunami',
      title: 'Berada di Wilayah Pesisir Setelah Peringatan Tsunami Dikeluarkan',
      slug: 'simulasi-setelah-peringatan-tsunami-dikeluarkan',
      difficulty: 'Lanjutan',
      description: 'Disiplin bertahan di tempat aman hingga pengumuman resmi pengakhiran peringatan tsunami.',
      scenarioContext:
          'Kamu sudah berada di lantai 4 Gedung Shelter Tsunami. Gelombang pertama telah lewat 15 menit lalu dan air di bawah mulai tampak tenang, tetapi BMKG belum mencabut peringatan tsunami.',
      safetyReference: 'SOP Pengakhiran Peringatan Dini Tsunami BMKG',
      steps: [
        SimulationStepItem(
          id: 112,
          stepNumber: 1,
          situationTitle: 'Keputusan Sebelum Peringatan Resmi Berakhir',
          situationText:
              'Tetanggamu mengajak turun dari shelter untuk memeriksa kondisi rumah karena mengira tsunami hanya satu gelombang. Apa yang kamu lakukan?',
          recommendedAction:
              'Tetap bertahan di lantai atas shelter dan melarang warga turun sampai ada pengumuman resmi dari BMKG dan BPBD bahwa peringatan tsunami telah berakhir.',
          choices: [
            SimulationChoiceItem(
              id: 1025,
              label: 'A',
              choiceText:
                  'Tetap bertahan di shelter dan mengingatkan tetangga bahwa gelombang tsunami berikutnya bisa lebih besar hingga BMKG menyatakan peringatan berakhir.',
              isCorrect: true,
              score: 100,
              assessment: 'Tepat',
              feedback:
                  'Sangat tepat! Tsunami terdiri dari rangkaian gelombang dan gelombang susulan sering kali lebih tinggi.',
            ),
            SimulationChoiceItem(
              id: 1026,
              label: 'B',
              choiceText: 'Ikut turun ke rumah untuk menyelamatkan sepeda motor selagi air tampak tenang.',
              isCorrect: false,
              score: 0,
              assessment: 'Sangat Berbahaya',
              feedback:
                  'Turun sebelum peringatan resmi berakhir sangat berbahaya karena gelombang kedua atau ketiga dapat menerjang tiba-tiba.',
            ),
          ],
        ),
      ],
    ),
  ];

  static const List<QuizItem> defaultQuizzes = [
    QuizItem(
      id: 1,
      category: 'Gempa Bumi',
      topic: 'Pengetahuan Dasar & Persiapan Sebelum Gempa',
      title: 'Kuis Gempa Bumi: Dasar & Kesiapsiagaan Rumah',
      slug: 'kuis-gempa-bumi-dasar-dan-kesiapsiagaan',
      difficulty: 'Dasar',
      description:
          'Uji pemahamanmu mengenai pengetahuan dasar gempa bumi, persiapan sebelum gempa, dan perlengkapan Tas Siaga Bencana.',
      questions: [
        QuizQuestionItem(
          id: 201,
          questionNumber: 1,
          subtopic: 'Pengetahuan dasar gempa',
          questionText:
              'Titik di permukaan bumi yang berada tepat di atas pusat pelepasan energi gempa di dalam bumi disebut...',
          explanation:
              'Hiposentrum adalah titik pusat gempa di kedalaman bumi, sedangkan titik proyeksinya di permukaan bumi disebut episentrum.',
          recommendedMaterialSlug: 'pengertian-gempa-bumi',
          options: [
            QuizOptionItem(id: 2001, optionLabel: 'A', optionText: 'Episentrum', isCorrect: true),
            QuizOptionItem(id: 2002, optionLabel: 'B', optionText: 'Hiposentrum'),
            QuizOptionItem(id: 2003, optionLabel: 'C', optionText: 'Litosfer'),
            QuizOptionItem(id: 2004, optionLabel: 'D', optionText: 'Kaldera'),
          ],
        ),
        QuizQuestionItem(
          id: 202,
          questionNumber: 2,
          subtopic: 'Persiapan sebelum gempa',
          questionText:
              'Bagaimana cara menata perabotan di rumah yang benar untuk mengurangi risiko cedera saat terjadi gempa bumi?',
          explanation:
              'Lemari tinggi perlu diikat ke dinding dan barang berat ditempatkan di rak paling bawah agar tidak jatuh menimpa kepala.',
          recommendedMaterialSlug: 'persiapan-sebelum-terjadi-gempa',
          options: [
            QuizOptionItem(
              id: 2005,
              optionLabel: 'A',
              optionText: 'Menempatkan benda berat di rak paling bawah dan mengikat lemari tinggi ke dinding',
              isCorrect: true,
            ),
            QuizOptionItem(
              id: 2006,
              optionLabel: 'B',
              optionText: 'Meletakkan barang pecah belah di atas lemari tinggi',
            ),
            QuizOptionItem(
              id: 2007,
              optionLabel: 'C',
              optionText: 'Menggantung cermin besar tepat di atas kepala tempat tidur',
            ),
            QuizOptionItem(
              id: 2008,
              optionLabel: 'D',
              optionText: 'Menumpuk kardus di sepanjang jalur pintu keluar rumah',
            ),
          ],
        ),
        QuizQuestionItem(
          id: 203,
          questionNumber: 3,
          subtopic: 'Tindakan saat gempa',
          questionText:
              'Apa urutan tindakan perlindungan diri yang benar sesuai panduan keselamatan internasional saat gempa terjadi di dalam ruangan?',
          explanation:
              'Drop (Merunduk), Cover (Lindungi kepala di bawah meja kokoh), dan Hold On (Bertahan memegang kaki meja hingga guncangan berhenti).',
          recommendedMaterialSlug: 'tindakan-saat-terjadi-gempa-di-dalam-ruangan',
          options: [
            QuizOptionItem(
              id: 2009,
              optionLabel: 'A',
              optionText: 'Drop (Merunduk), Cover (Lindungi Kepala), and Hold On (Bertahan)',
              isCorrect: true,
            ),
            QuizOptionItem(
              id: 2010,
              optionLabel: 'B',
              optionText: 'Langsung melompat keluar jendela saat lantai berguncang',
            ),
            QuizOptionItem(
              id: 2011,
              optionLabel: 'C',
              optionText: 'Turun menggunakan lift secepat mungkin',
            ),
            QuizOptionItem(
              id: 2012,
              optionLabel: 'D',
              optionText: 'Berdiri di dekat lemari kaca untuk menahannya',
            ),
          ],
        ),
        QuizQuestionItem(
          id: 204,
          questionNumber: 4,
          subtopic: 'Tindakan setelah gempa',
          questionText:
              'Mengapa kita dilarang menyalakan korek api atau sakelar listrik sesaat setelah gempa besar terjadi di dalam rumah?',
          explanation:
              'Percikan api dari korek atau sakelar listrik dapat memicu ledakan kebakaran jika terdapat kebocoran gas LPG akibat guncangan.',
          recommendedMaterialSlug: 'tindakan-setelah-gempa-bumi',
          options: [
            QuizOptionItem(
              id: 2013,
              optionLabel: 'A',
              optionText: 'Karena percikan api dapat memicu kebakaran hebat jika ada kebocoran gas',
              isCorrect: true,
            ),
            QuizOptionItem(
              id: 2014,
              optionLabel: 'B',
              optionText: 'Karena cahaya lampu mengundang gempa susulan',
            ),
            QuizOptionItem(
              id: 2015,
              optionLabel: 'C',
              optionText: 'Agar tagihan listrik rumah tidak meningkat',
            ),
            QuizOptionItem(
              id: 2016,
              optionLabel: 'D',
              optionText: 'Supaya baterai senter cepat habis',
            ),
          ],
        ),
      ],
    ),
    QuizItem(
      id: 2,
      category: 'Gempa Bumi',
      topic: 'Tindakan Saat & Setelah Gempa di Berbagai Lokasi',
      title: 'Kuis Gempa Bumi: Tanggap di Sekolah, Gedung & Jalan Raya',
      slug: 'kuis-gempa-bumi-tindakan-saat-dan-setelah',
      difficulty: 'Menengah',
      description: 'Evaluasi ketepatan tindakan saat menghadapi gempa di sekolah, gedung bertingkat, dan kendaraan.',
      questions: [
        QuizQuestionItem(
          id: 205,
          questionNumber: 1,
          subtopic: 'Tindakan saat gempa',
          questionText: 'Mengapa dilarang menggunakan lift ketika terjadi gempa bumi di gedung bertingkat?',
          explanation:
              'Saat gempa, aliran listrik dapat terputus dan rel penyangga lift dapat berubah bentuk sehingga penumpang terjebak.',
          recommendedMaterialSlug: 'tindakan-saat-terjadi-gempa-di-gedung-bertingkat',
          options: [
            QuizOptionItem(
              id: 2017,
              optionLabel: 'A',
              optionText: 'Listrik dapat padam mendadak dan struktur rel lift berisiko macet',
              isCorrect: true,
            ),
            QuizOptionItem(id: 2018, optionLabel: 'B', optionText: 'Karena pintu lift terbuat dari logam'),
            QuizOptionItem(id: 2019, optionLabel: 'C', optionText: 'Karena lift hanya untuk barang'),
            QuizOptionItem(id: 2020, optionLabel: 'D', optionText: 'Karena tangga darurat lebih gelap'),
          ],
        ),
        QuizQuestionItem(
          id: 206,
          questionNumber: 2,
          subtopic: 'Tindakan saat gempa',
          questionText: 'Apa yang harus dilakukan pengemudi mobil ketika merasakan guncangan gempa bumi di jalan raya?',
          explanation:
              'Kurangi kecepatan, menepi di tempat terbuka yang jauh dari jembatan, pohon, dan tiang listrik, lalu tunggu hingga guncangan berhenti.',
          recommendedMaterialSlug: 'tindakan-saat-terjadi-gempa-di-luar-ruangan',
          options: [
            QuizOptionItem(
              id: 2021,
              optionLabel: 'A',
              optionText: 'Menepi perlahan di area terbuka yang jauh dari jembatan dan tiang listrik',
              isCorrect: true,
            ),
            QuizOptionItem(
              id: 2022,
              optionLabel: 'B',
              optionText: 'Berhenti tepat di bawah jembatan penyeberangan',
            ),
            QuizOptionItem(
              id: 2023,
              optionLabel: 'C',
              optionText: 'Memacu kendaraan dengan kecepatan maksimal',
            ),
            QuizOptionItem(
              id: 2024,
              optionLabel: 'D',
              optionText: 'Meninggalkan mobil di tengah jalur cepat',
            ),
          ],
        ),
      ],
    ),
    QuizItem(
      id: 3,
      category: 'Tsunami',
      topic: 'Pengetahuan Dasar, Tanda Bahaya & Peringatan Dini Tsunami',
      title: 'Kuis Tsunami: Mengenali Tanda Alam & Peringatan Dini',
      slug: 'kuis-tsunami-tanda-alam-dan-peringatan-dini',
      difficulty: 'Dasar',
      description:
          'Uji pengetahuanmu mengenai hubungan gempa dengan tsunami, tanda alam tsunami, dan status peringatan dini BMKG.',
      questions: [
        QuizQuestionItem(
          id: 207,
          questionNumber: 1,
          subtopic: 'Pengetahuan dasar tsunami',
          questionText: 'Manakah karakteristik gempa bumi yang paling berpotensi memicu terjadinya tsunami?',
          explanation:
              'Tidak semua gempa memicu tsunami. Gempa pemicu tsunami umumnya berpusat di laut, berkedalaman dangkal (<70 km), dan berkekuatan besar (M ≥ 7,0) dengan patahan vertikal.',
          recommendedMaterialSlug: 'hubungan-gempa-bumi-dengan-tsunami',
          options: [
            QuizOptionItem(
              id: 2025,
              optionLabel: 'A',
              optionText: 'Gempa tektonik berkekuatan besar (M ≥ 7,0) di dasar laut dengan kedalaman dangkal',
              isCorrect: true,
            ),
            QuizOptionItem(
              id: 2026,
              optionLabel: 'B',
              optionText: 'Semua gempa kecil yang berpusat di pegunungan daratan',
            ),
            QuizOptionItem(
              id: 2027,
              optionLabel: 'C',
              optionText: 'Gempa sangat dalam (>500 km) dengan magnitudo M 3,0',
            ),
            QuizOptionItem(
              id: 2028,
              optionLabel: 'D',
              optionText: 'Getaran akibat kendaraan berat di jalan raya pantai',
            ),
          ],
        ),
        QuizQuestionItem(
          id: 208,
          questionNumber: 2,
          subtopic: 'Tanda bahaya tsunami',
          questionText:
              'Apa tindakan yang wajib dilakukan masyarakat di wilayah pesisir jika merasakan gempa kuat (sulit berdiri) atau berlangsung lama?',
          explanation:
              'Gempa kuat atau lama di wilayah pesisir adalah peringatan alami tsunami. Masyarakat wajib segera menjauhi pantai menuju tempat tinggi tanpa menunggu peringatan resmi.',
          recommendedMaterialSlug: 'tindakan-saat-mendapat-peringatan-tsunami',
          options: [
            QuizOptionItem(
              id: 2029,
              optionLabel: 'A',
              optionText:
                  'Segera menjauhi pantai dan evakuasi ke tempat tinggi tanpa menunggu sirine peringatan resmi',
              isCorrect: true,
            ),
            QuizOptionItem(
              id: 2030,
              optionLabel: 'B',
              optionText: 'Menunggu di bibir pantai sampai melihat gelombang datang',
            ),
            QuizOptionItem(
              id: 2031,
              optionLabel: 'C',
              optionText: 'Turun ke pantai untuk memungut ikan saat air laut surut',
            ),
            QuizOptionItem(
              id: 2032,
              optionLabel: 'D',
              optionText: 'Tetap di dalam rumah tepi pantai sampai ada petugas mengetuk pintu',
            ),
          ],
        ),
        QuizQuestionItem(
          id: 209,
          questionNumber: 3,
          subtopic: 'Peringatan dini',
          questionText:
              'Dalam sistem peringatan dini tsunami BMKG (InaTEWS), status tertinggi yang mengharuskan evakuasi menyeluruh dengan estimasi tinggi gelombang > 3 meter adalah...',
          explanation:
              'Urutan tingkat peringatan dini tsunami BMKG dari terendah ke tertinggi adalah Waspada, Siaga, dan Awas.',
          recommendedMaterialSlug: 'mengenali-peringatan-dini-tsunami',
          options: [
            QuizOptionItem(id: 2033, optionLabel: 'A', optionText: 'AWAS', isCorrect: true),
            QuizOptionItem(id: 2034, optionLabel: 'B', optionText: 'NORMAL'),
            QuizOptionItem(id: 2035, optionLabel: 'C', optionText: 'AMAN'),
            QuizOptionItem(id: 2036, optionLabel: 'D', optionText: 'TENANG'),
          ],
        ),
      ],
    ),
    QuizItem(
      id: 4,
      category: 'Tsunami',
      topic: 'Jalur Evakuasi & Tindakan Setelah Tsunami',
      title: 'Kuis Tsunami: Strategi Evakuasi & Keselamatan Pascatsunami',
      slug: 'kuis-tsunami-jalur-evakuasi-dan-pascatsunami',
      difficulty: 'Menengah',
      description: 'Evaluasi pemahamanmu tentang evakuasi vertikal/horizontal dan kapan waktu aman kembali ke pesisir.',
      questions: [
        QuizQuestionItem(
          id: 210,
          questionNumber: 1,
          subtopic: 'Jalur dan tindakan evakuasi',
          questionText:
              'Mengapa warga dianjurkan melakukan evakuasi tsunami dengan berjalan kaki cepat dibandingkan menggunakan mobil pribadi?',
          explanation:
              'Penggunaan mobil pribadi secara bersamaan menyebabkan kemacetan total di jalur evakuasi sehingga warga terjebak di zona bahaya.',
          recommendedMaterialSlug: 'cara-melakukan-evakuasi-ke-tempat-yang-lebih-tinggi-atau-lokasi-aman',
          options: [
            QuizOptionItem(
              id: 2037,
              optionLabel: 'A',
              optionText: 'Untuk menghindari kemacetan total yang dapat menjebak warga di jalur evakuasi',
              isCorrect: true,
            ),
            QuizOptionItem(id: 2038, optionLabel: 'B', optionText: 'Karena jalan raya ditutup untuk pejalan kaki'),
            QuizOptionItem(id: 2039, optionLabel: 'C', optionText: 'Agar bisa berhenti memotret di jembatan'),
            QuizOptionItem(id: 2040, optionLabel: 'D', optionText: 'Karena mobil tidak memiliki klakson'),
          ],
        ),
        QuizQuestionItem(
          id: 211,
          questionNumber: 2,
          subtopic: 'Tindakan setelah tsunami',
          questionText: 'Kapan masyarakat diperbolehkan kembali ke wilayah pesisir setelah terjadi tsunami?',
          explanation:
              'Tsunami terdiri dari banyak gelombang. Warga hanya boleh kembali setelah BMKG dan pihak berwenang resmi menyatakan peringatan dini tsunami telah berakhir.',
          recommendedMaterialSlug: 'kembali-ke-wilayah-pesisir-setelah-peringatan-berakhir',
          options: [
            QuizOptionItem(
              id: 2041,
              optionLabel: 'A',
              optionText:
                  'Hanya setelah BMKG dan otoritas resmi mengumumkan bahwa peringatan dini tsunami telah berakhir',
              isCorrect: true,
            ),
            QuizOptionItem(
              id: 2042,
              optionLabel: 'B',
              optionText: 'Segera setelah gelombang pertama surut',
            ),
            QuizOptionItem(
              id: 2043,
              optionLabel: 'C',
              optionText: 'Saat air laut terlihat tenang selama 5 menit',
            ),
            QuizOptionItem(
              id: 2044,
              optionLabel: 'D',
              optionText: 'Ketika melihat ada warga lain yang nekat turun ke pantai',
            ),
          ],
        ),
      ],
    ),
  ];

  static const List<MissionItem> defaultMissions = [
    // 7 MISI GEMPA BUMI
    MissionItem(
      id: 1,
      category: 'Gempa Bumi',
      title: 'Kenali Tempat Berlindung yang Aman di Rumah',
      slug: 'misi-kenali-tempat-berlindung-aman-di-rumah',
      description: 'Identifikasi meja kokoh dan sudut kolom aman di setiap ruangan rumah untuk tempat berlindung saat gempa.',
      illustration: 'table_shelter',
      instructions: [
        'Periksa ruang keluarga, kamar tidur, dan ruang belajar.',
        'Tentukan meja kokoh atau sudut dinding dalam yang jauh dari kaca.',
        'Beritahukan lokasi aman tersebut kepada seluruh anggota keluarga.',
      ],
      difficulty: 'Dasar',
      points: 40,
    ),
    MissionItem(
      id: 2,
      category: 'Gempa Bumi',
      title: 'Identifikasi Benda Berat yang Perlu Diamankan',
      slug: 'misi-identifikasi-benda-berat-di-rumah',
      description: 'Periksa lemari tinggi, rak buku, dan benda gantung yang berisiko jatuh saat guncangan gempa.',
      illustration: 'cabinet_safety',
      instructions: [
        'Pindahkan barang berat dari atas lemari ke rak bagian bawah.',
        'Pastikan tidak ada bingkai kaca berat tepat di atas tempat tidur.',
        'Pasang penahan siku pada lemari tinggi bila memungkinkan.',
      ],
      difficulty: 'Menengah',
      points: 50,
    ),
    MissionItem(
      id: 3,
      category: 'Gempa Bumi',
      title: 'Kenali Jalur Keluar Rumah Tanpa Hambatan',
      slug: 'misi-kenali-jalur-keluar-rumah',
      description: 'Pastikan koridor dan pintu keluar rumah bebas dari tumpukan barang yang menghalangi evakuasi.',
      illustration: 'exit_route',
      instructions: [
        'Bersihkan lorong pintu depan dan pintu belakang dari barang penghalang.',
        'Pastikan kunci pintu darurat disimpan di tempat yang mudah dijangkau semua penghuni rumah.',
      ],
      difficulty: 'Dasar',
      points: 40,
    ),
    MissionItem(
      id: 4,
      category: 'Gempa Bumi',
      title: 'Siapkan Tas Siaga Bencana Keluarga',
      slug: 'misi-siapkan-tas-siaga-bencana',
      description: 'Susun satu tas ransel darurat berisi perlengkapan bertahan hidup untuk 72 jam pertama.',
      illustration: 'emergency_bag',
      instructions: [
        'Masukkan salinan dokumen penting dalam plastik kedap air.',
        'Siapkan kotak P3K, obat pribadi, senter, peluit, air minum, dan makanan tahan lama.',
        'Letakkan Tas Siaga di dekat pintu keluar utama rumah.',
      ],
      difficulty: 'Menengah',
      points: 60,
    ),
    MissionItem(
      id: 5,
      category: 'Gempa Bumi',
      title: 'Tentukan Titik Kumpul Keluarga',
      slug: 'misi-tentukan-titik-kumpul-keluarga',
      description: 'Sepakati lokasi terbuka yang aman di luar rumah sebagai tempat berkumpul setelah gempa.',
      illustration: 'assembly_point',
      instructions: [
        'Pilih halaman terbuka atau lapangan terdekat yang jauh dari gedung tinggi dan tiang listrik.',
        'Pastikan semua anggota keluarga menghafal lokasi titik kumpul tersebut.',
      ],
      difficulty: 'Dasar',
      points: 40,
    ),
    MissionItem(
      id: 6,
      category: 'Gempa Bumi',
      title: 'Diskusikan Rencana Komunikasi Keluarga',
      slug: 'misi-diskusikan-rencana-komunikasi-keluarga',
      description: 'Buat daftar nomor darurat dan kontak kerabat di luar kota jika anggota keluarga terpisah.',
      illustration: 'family_comm',
      instructions: [
        'Catat nomor BPBD Kota Padang (0751-778775), Basarnas, dan PMI di buku saku keluarga.',
        'Tentukan satu nomor kerabat penghubung apabila jaringan telepon lokal padat.',
      ],
      difficulty: 'Dasar',
      points: 45,
    ),
    MissionItem(
      id: 7,
      category: 'Gempa Bumi',
      title: 'Pelajari Langkah Drop, Cover, and Hold On',
      slug: 'misi-pelajari-langkah-drop-cover-hold-on',
      description: 'Praktikkan gerakan merunduk, melindungi kepala, dan berpegangan bersama anggota keluarga.',
      illustration: 'drop_cover_hold',
      instructions: [
        'Lakukan simulasi singkat selama 1 menit bersama keluarga atau teman.',
        'Pastikan anak-anak maupun lansia memahami cara melindungi kepala dan leher.',
      ],
      difficulty: 'Dasar',
      points: 50,
    ),

    // 7 MISI TSUNAMI
    MissionItem(
      id: 8,
      category: 'Tsunami',
      title: 'Kenali Apakah Tempat Tinggal Berada di Wilayah Rawan Tsunami',
      slug: 'misi-kenali-zona-rawan-tsunami-tempat-tinggal',
      description: 'Periksa status zona bahaya tsunami lingkungan rumah atau sekolah pada Peta Evakuasi SiagaBencana.',
      illustration: 'tsunami_zone',
      instructions: [
        'Buka menu Peta Evakuasi pada aplikasi SiagaBencana.',
        'Cek apakah lokasi tempat tinggal berada di Zona Bahaya (Merah), Waspada (Kuning), atau Aman (Hijau).',
      ],
      difficulty: 'Dasar',
      points: 45,
    ),
    MissionItem(
      id: 9,
      category: 'Tsunami',
      title: 'Pelajari Jalur Evakuasi Tsunami di Lingkungan Sekitar',
      slug: 'misi-pelajari-jalur-evakuasi-tsunami',
      description: 'Amati rambu jalur evakuasi tsunami resmi menuju dataran tinggi atau shelter terdekat.',
      illustration: 'evac_sign',
      instructions: [
        'Perhatikan plang rambu arah jalur evakuasi tsunami di sepanjang jalan lingkungan.',
        'Kenali rute alternatif yang tidak melewati jembatan muara sungai.',
      ],
      difficulty: 'Dasar',
      points: 50,
    ),
    MissionItem(
      id: 10,
      category: 'Tsunami',
      title: 'Kenali Lokasi Evakuasi yang Telah Ditetapkan Pihak Berwenang',
      slug: 'misi-kenali-lokasi-evakuasi-resmi',
      description: 'Catat lokasi Shelter Evakuasi Vertikal (TES) atau titik kumpul bukit resmi terdekat dari rumah.',
      illustration: 'shelter_building',
      instructions: [
        'Lihat daftar titik evakuasi resmi pada halaman Peta Evakuasi.',
        'Ketahui nama gedung shelter atau bukit evakuasi terdekat beserta jarak tempuhnya.',
      ],
      difficulty: 'Dasar',
      points: 50,
    ),
    MissionItem(
      id: 11,
      category: 'Tsunami',
      title: 'Diskusikan Rencana Evakuasi Tsunami Keluarga',
      slug: 'misi-diskusikan-rencana-evakuasi-tsunami-keluarga',
      description: 'Sepakati pembagian tugas keluarga untuk mendampingi anak-anak dan lansia saat evakuasi tsunami.',
      illustration: 'family_evac',
      instructions: [
        'Tentukan siapa yang membawa Tas Siaga dan siapa yang mendampingi anggota keluarga rentan.',
        'Sepakati titik temu di lokasi shelter/zona hijau jika anggota keluarga sedang berada di tempat berbeda.',
      ],
      difficulty: 'Menengah',
      points: 55,
    ),
    MissionItem(
      id: 12,
      category: 'Tsunami',
      title: 'Catat Informasi Peringatan Dini dari Sumber Resmi',
      slug: 'misi-catat-sumber-resmi-peringatan-dini',
      description: 'Pastikan keluarga hanya memantau kanal resmi BMKG, BNPB, dan BPBD untuk informasi tsunami.',
      illustration: 'official_alert',
      instructions: [
        'Kenali perbedaan arti status Waspada, Siaga, dan Awas dari BMKG.',
        'komitmen untuk tidak menyebarkan pesan berantai yang tidak memiliki sumber resmi.',
      ],
      difficulty: 'Dasar',
      points: 40,
    ),
    MissionItem(
      id: 13,
      category: 'Tsunami',
      title: 'Pelajari Tanda Alam yang Dapat Mengindikasikan Tsunami',
      slug: 'misi-pelajari-tanda-alam-tsunami',
      description: 'Pahami tiga tanda alam utama tsunami agar siap evakuasi mandiri meski tanpa sirine.',
      illustration: 'natural_sign',
      instructions: [
        'Ingat tanda alam: gempa kuat/lama di pesisir, air laut surut mendadak, dan suara gemuruh dari laut.',
        'Bagikan pengetahuan ini kepada minimal 2 orang anggota keluarga atau teman.',
      ],
      difficulty: 'Dasar',
      points: 45,
    ),
    MissionItem(
      id: 14,
      category: 'Tsunami',
      title: 'Ketahui Cara Menuju Tempat yang Lebih Tinggi',
      slug: 'misi-ketahui-cara-menuju-tempat-tinggi',
      description: 'Uji waktu tempuh berjalan kaki cepat dari lokasi Anda menuju dataran tinggi atau lantai atas shelter.',
      illustration: 'high_ground',
      instructions: [
        'Perkirakan waktu tempuh berjalan kaki cepat agar berada di bawah batas waktu emas 20 menit.',
        'Utamakan evakuasi berjalan kaki agar tidak memicu kemacetan jalan.',
      ],
      difficulty: 'Menengah',
      points: 60,
    ),
  ];

  static const List<BadgeItem> defaultBadges = [
    BadgeItem(
      code: 'siaga-gempa',
      name: 'Siaga Gempa',
      description: 'Menyelesaikan pembelajaran, simulasi, dan kuis mitigasi gempa bumi.',
      criteriaDescription: 'Selesaikan minimal 3 Materi Gempa Bumi, 1 Simulasi Gempa, dan 1 Kuis Gempa.',
      category: 'Gempa Bumi',
      pointsReward: 100,
    ),
    BadgeItem(
      code: 'siaga-tsunami',
      name: 'Siaga Tsunami',
      description: 'Menyelesaikan pembelajaran, simulasi, dan kuis mitigasi serta evakuasi tsunami.',
      criteriaDescription: 'Selesaikan minimal 3 Materi Tsunami, 1 Simulasi Tsunami, dan 1 Kuis Tsunami.',
      category: 'Tsunami',
      pointsReward: 100,
    ),
    BadgeItem(
      code: 'ahli-evakuasi',
      name: 'Ahli Evakuasi',
      description: 'Mengambil keputusan penyelamatan diri yang tepat dengan skor tinggi pada simulasi skenario.',
      criteriaDescription: 'Raih nilai minimal 80 pada minimal 2 skenario Simulasi Gempa Bumi atau Tsunami.',
      category: 'Simulasi',
      pointsReward: 120,
    ),
    BadgeItem(
      code: 'pembelajar-aktif',
      name: 'Pembelajar Aktif',
      description: 'Aktif mempelajari materi edukasi dan mengerjakan evaluasi kuis kesiapsiagaan.',
      criteriaDescription: 'Selesaikan minimal 6 Materi Belajar dan 2 Paket Kuis.',
      category: 'Belajar',
      pointsReward: 150,
    ),
    BadgeItem(
      code: 'keluarga-siaga',
      name: 'Keluarga Siaga',
      description: 'Menuntaskan tantangan kesiapsiagaan keluarga pada fitur Misi Siaga.',
      criteriaDescription: 'Selesaikan minimal 3 tantangan Misi Siaga Gempa Bumi atau Tsunami.',
      category: 'Misi Siaga',
      pointsReward: 150,
    ),
  ];
}
