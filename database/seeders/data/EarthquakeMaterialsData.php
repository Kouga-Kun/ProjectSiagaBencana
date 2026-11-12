<?php

namespace Database\Seeders\Data;

class EarthquakeMaterialsData
{
    /**
     * @return list<array<string, mixed>>
     */
    public static function get(): array
    {
        return [
            [
                'title' => 'Pengertian Gempa Bumi',
                'slug' => 'pengertian-gempa-bumi',
                'difficulty' => 'Dasar',
                'image_path' => 'illustrations/earthquake-basics.svg',
                'summary' => 'Gempa bumi adalah getaran atau guncangan yang terjadi di permukaan bumi akibat pelepasan energi dari dalam bumi secara tiba-tiba.',
                'content' => "Gempa bumi merupakan peristiwa bergetarnya lapisan kulit bumi akibat pelepasan energi secara tiba-tiba di dalam kerak bumi yang menciptakan gelombang seismik.\n\nTitik pusat pelepasan energi di dalam bumi disebut hiposentrum, sedangkan titik di permukaan bumi tepat di atas hiposentrum disebut episentrum. Kekuatan gempa bumi diukur menggunakan skala magnitudo (M), sedangkan dampak guncangan yang dirasakan di permukaan diukur dengan skala intensitas Modified Mercalli Intensity (MMI).\n\nWilayah Indonesia, termasuk Sumatera Barat dan Kota Padang, berada pada pertemuan lempeng tektonik aktif sehingga penting bagi seluruh lapisan masyarakat—mulai dari siswa SD, SMP, remaja, hingga orang dewasa—untuk memahami apa itu gempa bumi secara ilmiah dan tetap tenang saat menghadapinya.",
                'key_points' => [
                    'Gempa bumi terjadi karena pelepasan energi tiba-tiba dari dalam kerak bumi.',
                    'Hiposentrum adalah titik pusat gempa di bawah permukaan bumi, sedangkan episentrum berada di permukaan bumi.',
                    'Kekuatan gempa dinyatakan dalam Magnitudo (M) dan dampak guncangan dalam skala MMI.',
                    'Gempa bumi tidak dapat diprediksi waktu persis terjadinya, sehingga kesiapsiagaan adalah kunci utama.',
                ],
                'action_steps' => [
                    'Pahami perbedaan antara magnitudo (kekuatan gempa) dan kedalaman gempa pada informasi resmi BMKG.',
                    'Kenali bahwa Kota Padang berada di kawasan aktif tektonik sehingga budaya sadar bencana perlu diterapkan setiap hari.',
                    'Bagikan pengetahuan dasar tentang gempa bumi kepada anggota keluarga di rumah.',
                ],
                'things_to_avoid' => [
                    'Jangan mempercayai ramalan waktu terjadinya gempa bumi dari sumber yang tidak resmi.',
                    'Jangan menganggap semua gempa bumi pasti memicu tsunami tanpa memeriksa parameter dan tanda bahaya.',
                ],
                'source_reference' => 'BMKG & BNPB (Buku Saku Tanggap Tangkas Tangguh Menghadapi Bencana)',
                'sort_order' => 1,
            ],
            [
                'title' => 'Penyebab Terjadinya Gempa Bumi',
                'slug' => 'penyebab-terjadinya-gempa-bumi',
                'difficulty' => 'Dasar',
                'image_path' => 'illustrations/tectonic-plates.svg',
                'summary' => 'Memahami proses pergeseran lempeng tektonik, patahan aktif, dan aktivitas alam yang memicu terjadinya gempa bumi.',
                'content' => "Sebagian besar gempa bumi yang berdampak luas disebabkan oleh pergerakan lempeng tektonik bumi. Kulit bumi tersusun atas lempeng-lempeng besar yang terus bergerak perlahan. Ketika dua lempeng saling bertumbukan, bergesekan, atau menjauh, energi tekanan terkumpul pada batuan hingga akhirnya patah dan melepaskan getaran kuat.\n\nDi wilayah Sumatera Barat, sumber utama gempa bumi berasal dari zona subduksi Megathrust Mentawai di Samudra Hindia serta jalur Patahan Besar Sumatera (Sesar Semangko) di daratan. Selain faktor tektonik, gempa bumi juga dapat dipicu oleh aktivitas gunung api (gempa vulkanik) atau runtuhan gua bawah tanah (gempa runtuhan).",
                'key_points' => [
                    'Tumbukan dan pergeseran lempeng tektonik merupakan penyebab utama gempa bumi.',
                    'Zona subduksi di lepas pantai barat Sumatera dan sesar aktif daratan menjadi sumber gempa utama.',
                    'Besarnya guncangan di permukaan dipengaruhi oleh magnitudo, kedalaman pusat gempa, jarak episentrum, dan kondisi tanah setempat.',
                ],
                'action_steps' => [
                    'Pelajari potensi sumber gempa di lingkungan tempat tinggal melalui peta bahaya resmi BPBD atau BMKG.',
                    'Pastikan konstruksi bangunan rumah memperhatikan standar bangunan tahan gempa.',
                ],
                'things_to_avoid' => [
                    'Jangan menyebarkan mitos yang tidak berdasar ilmiah mengenai penyebab gempa bumi.',
                    'Jangan mengabaikan potensi gempa dari patahan darat maupun zona subduksi laut.',
                ],
                'source_reference' => 'BMKG, PVMBG & BNPB',
                'sort_order' => 2,
            ],
            [
                'title' => 'Jenis dan Karakteristik Gempa Bumi',
                'slug' => 'jenis-dan-karakteristik-gempa-bumi',
                'difficulty' => 'Dasar',
                'image_path' => 'illustrations/earthquake-types.svg',
                'summary' => 'Mengenal klasifikasi gempa bumi berdasarkan penyebab, kedalaman hiposentrum, dan karakteristik getarannya.',
                'content' => "Gempa bumi diklasifikasikan berdasarkan faktor penyebab dan kedalamannya:\n\n1. Berdasarkan Penyebab: Gempa Tektonik (pergeseran lempeng/sesar), Gempa Vulkanik (aktivitas magma gunung api), dan Gempa Runtuhan/Terban.\n2. Berdasarkan Kedalaman Hiposentrum:\n- Gempa Dangkal (kurang dari 60 km): biasanya menimbulkan guncangan yang paling terasa kuat di permukaan.\n- Gempa Menengah (60–300 km).\n- Gempa Dalam (lebih dari 300 km).\n\nMemahami karakteristik ini membantu masyarakat mengerti mengapa gempa bermagnitudo sedang namun sangat dangkal dapat menyebabkan kerusakan bangunan yang signifikan.",
                'key_points' => [
                    'Gempa tektonik memiliki cakupan dampak paling luas dibandingkan jenis gempa lainnya.',
                    'Gempa dangkal (< 60 km) umumnya menghasilkan guncangan permukaan yang lebih kuat.',
                    'Gempa laut yang kuat dan dangkal dengan mekanisme patahan naik berpotensi memicu tsunami, namun tidak semua gempa memicu tsunami.',
                ],
                'action_steps' => [
                    'Perhatikan kedalaman dan lokasi pusat gempa saat membaca info resmi dari BMKG.',
                    'Kenali perbedaan guncangan mengayun yang berlangsung lama dan guncangan menghentak yang kuat.',
                ],
                'things_to_avoid' => [
                    'Jangan panik berlebihan ketika mendengar istilah gempa tektonik.',
                    'Jangan mengabaikan gempa yang terasa lemah tetapi berlangsung lama terutama saat berada di pesisir.',
                ],
                'source_reference' => 'BMKG & BNPB',
                'sort_order' => 3,
            ],
            [
                'title' => 'Mengenali Tanda dan Informasi Gempa',
                'slug' => 'mengenali-tanda-dan-informasi-gempa',
                'difficulty' => 'Dasar',
                'image_path' => 'illustrations/bmkg-info.svg',
                'summary' => 'Cara mengenali gejala awal guncangan gempa bumi dan membaca parameter informasi resmi dari BMKG secara akurat.',
                'content' => "Saat gempa bumi terjadi, tanda yang langsung dapat dikenali adalah bergetarnya lantai, bergoyangnya lampu gantung atau perabotan, hingga suara gemuruh dari struktur bangunan.\n\nSetelah guncangan mereda, BMKG akan mengeluarkan informasi parameter gempa yang mencakup: Waktu kejadian, Magnitudo, Kedalaman, Koordinat lokasi episentrum (darat atau laut), serta keterangan apakah gempa tersebut berpotensi tsunami atau tidak.\n\nPastikan seluruh anggota keluarga hanya merujuk pada kanal resmi BMKG, BNPB, dan BPBD setempat untuk memverifikasi informasi gempa.",
                'key_points' => [
                    'Lampu gantung bergoyang, kaca bergetar, dan lantai terasa berguncang adalah tanda langsung terjadinya gempa.',
                    'Informasi resmi BMKG memuat magnitudo, kedalaman, lokasi pusat gempa, dan status potensi tsunami.',
                    'Waspadai berita bohong (hoaks) yang sering beredar di media sosial sesaat setelah gempa.',
                ],
                'action_steps' => [
                    'Segera berlindung saat merasakan tanda getaran pertama tanpa menunggu informasi di ponsel.',
                    'Periksa informasi resmi BMKG setelah berada di tempat aman dan guncangan telah berhenti.',
                    'Perhatikan keterangan potensi tsunami pada pengumuman resmi BMKG.',
                ],
                'things_to_avoid' => [
                    'Jangan sibuk membuka ponsel untuk mengecek berita saat guncangan masih berlangsung.',
                    'Jangan meneruskan pesan berantai yang tidak mencantumkan sumber resmi BMKG/BPBD.',
                ],
                'source_reference' => 'BMKG & BNPB',
                'sort_order' => 4,
            ],
            [
                'title' => 'Persiapan Sebelum Terjadi Gempa',
                'slug' => 'persiapan-sebelum-terjadi-gempa',
                'difficulty' => 'Menengah',
                'image_path' => 'illustrations/earthquake-prep.svg',
                'summary' => 'Langkah antisipasi di rumah dan lingkungan keluarga sebelum gempa terjadi untuk meminimalkan risiko cedera dan kerusakan.',
                'content' => "Kesiapsiagaan sebelum bencana menentukan keselamatan saat darurat. Banyak cedera saat gempa bukan disebabkan oleh runtuhnya gedung secara langsung, melainkan tertimpa perabotan berat, pecahan kaca, atau benda jatuh.\n\nLakukan penataan ruang yang aman di rumah: kencangkan lemari tinggi ke dinding, letakkan benda berat di rak bagian bawah, kenali sudut atau kolong meja yang kokoh untuk berlindung, pastikan jalur keluar rumah bebas hambatan, serta sepakati titik kumpul dan rencana komunikasi keluarga.",
                'key_points' => [
                    'Amankan perabot berat seperti lemari, rak buku, dan pemanas air agar tidak mudah roboh.',
                    'Simpan benda pecah belah dan barang berat di bagian bawah lemari.',
                    'Tentukan tempat berlindung yang aman di setiap ruangan dan jalur keluar darurat.',
                    'Latih seluruh anggota keluarga melakukan simulasi Drop, Cover, and Hold On secara berkala.',
                ],
                'action_steps' => [
                    'Periksa dan pasang pengait pada lemari tinggi di rumah.',
                    'Jauhkan tempat tidur dari kaca jendela besar atau lemari berat yang belum dikaitkan.',
                    'Catat nomor telepon darurat penting (BPBD, SAR, Pemadam, Rumah Sakit) dan tempel di tempat yang mudah terlihat.',
                    'Tetapkan titik kumpul keluarga di area terbuka yang aman.',
                ],
                'things_to_avoid' => [
                    'Jangan menaruh benda berat atau kaca di atas kepala tempat tidur.',
                    'Jangan menghalangi pintu keluar dan lorong rumah dengan tumpukan barang.',
                ],
                'source_reference' => 'BNPB & BPBD Kota Padang',
                'sort_order' => 5,
            ],
            [
                'title' => 'Tindakan Saat Terjadi Gempa di Dalam Ruangan',
                'slug' => 'tindakan-saat-terjadi-gempa-di-dalam-ruangan',
                'difficulty' => 'Dasar',
                'image_path' => 'illustrations/drop-cover-hold.svg',
                'summary' => 'Panduan langkah penyelamatan diri Drop, Cover, and Hold On (Merunduk, Berlindung, dan Berpegangan) ketika berada di dalam ruangan.',
                'content' => "Ketika merasakan guncangan gempa saat berada di dalam rumah atau ruangan, tetap tenang dan segera terapkan prinsip keselamatan utama: DROP (Merunduk), COVER (Lindungi Kepala/Berlindung), dan HOLD ON (Berpegangan).\n\nMerunduklah ke lantai agar tidak terjatuh oleh guncangan, masuk ke kolong meja yang kokoh untuk melindungi kepala dan leher dari reruntuhan plafon atau benda jatuh, lalu berpegangan pada kaki meja hingga guncangan berhenti. Jika tidak ada meja, merunduklah di dekat dinding bagian dalam yang jauh dari jendela kaca dan lindungi kepala dengan kedua tangan atau bantal.",
                'key_points' => [
                    'DROP: Merunduk posisi tangan dan lutut sebelum guncangan menjatuhkan Anda.',
                    'COVER: Berlindung di bawah meja kokoh serta lindungi kepala dan leher.',
                    'HOLD ON: Berpegangan erat pada pelindung hingga guncangan benar-benar berhenti.',
                    'Jika sedang memasak, segera matikan kompor apabila terjangkau dengan cepat sebelum berlindung.',
                ],
                'action_steps' => [
                    'Segera merunduk dan masuk ke kolong meja yang kuat.',
                    'Jauhi jendela kaca, cermin, lampu gantung, dan lemari tinggi.',
                    'Tunggu hingga guncangan berhenti, lalu keluar dengan tertib menuju ruang terbuka sambil melindungi kepala.',
                ],
                'things_to_avoid' => [
                    'Jangan berlari panik saat guncangan kuat sedang berlangsung karena risiko terjatuh dan tertimpa benda sangat tinggi.',
                    'Jangan berdiri di dekat kaca jendela atau lemari kaca.',
                ],
                'source_reference' => 'BNPB, BMKG & Basarnas',
                'sort_order' => 6,
            ],
            [
                'title' => 'Tindakan Saat Terjadi Gempa di Luar Ruangan',
                'slug' => 'tindakan-saat-terjadi-gempa-di-luar-ruangan',
                'difficulty' => 'Dasar',
                'image_path' => 'illustrations/outdoor-earthquake.svg',
                'summary' => 'Cara melindungi diri di area terbuka dan menghindari bahaya runtuhan bangunan, tiang listrik, atau papan reklame.',
                'content' => "Apabila gempa bumi terjadi ketika Anda berada di luar ruangan, bahaya terbesar berasal dari pecahan kaca gedung, runtuhan tembok pagar, papan reklame, pohon besar, dan tiang atau kabel listrik.\n\nSegera bergerak menuju area terbuka yang jauh dari bangunan tinggi, tiang listrik, pohon, dan lereng curam. Jika sedang mengemudi kendaraan, kurangi kecepatan secara bertahap, menepi di tempat yang aman (jauh dari jembatan, jalan layang, atau baliho), aktifkan rem tangan, dan tetap berada di dalam kendaraan sampai guncangan berhenti.",
                'key_points' => [
                    'Carilah area terbuka yang jauh dari gedung, tiang listrik, papan reklame, dan pepohonan.',
                    'Waspadai retakan tanah atau potensi longsor jika berada di dekat tebing/lereng.',
                    'Jika berkendara, menepi dengan aman jauh dari jembatan, pohon, dan kabel listrik.',
                ],
                'action_steps' => [
                    'Melangkah cepat ke lapangan atau ruang terbuka terdekat.',
                    'Merunduk dan lindungi kepala jika masih berada di sekitar area padat.',
                    'Apabila berada di kawasan pantai dan merasakan gempa kuat atau lama, segera jauhi pantai menuju tempat lebih tinggi setelah guncangan mereda.',
                ],
                'things_to_avoid' => [
                    'Jangan berlari masuk ke dalam bangunan saat gempa sedang berlangsung.',
                    'Jangan berhenti di bawah jembatan, jalan layang, atau di dekat tiang listrik.',
                ],
                'source_reference' => 'BNPB & BPBD',
                'sort_order' => 7,
            ],
            [
                'title' => 'Tindakan Saat Terjadi Gempa di Sekolah',
                'slug' => 'tindakan-saat-terjadi-gempa-di-sekolah',
                'difficulty' => 'Menengah',
                'image_path' => 'illustrations/school-earthquake.svg',
                'summary' => 'Prosedur keselamatan khusus bagi siswa SD, SMP, SMA, dan guru saat gempa terjadi ketika kegiatan belajar mengajar berlangsung.',
                'content' => "Sekolah merupakan tempat berkumpulnya banyak siswa sehingga ketertiban saat gempa sangat menentukan keselamatan bersama. Ketika guncangan terjadi di ruang kelas, siswa dan guru harus segera berlindung di bawah meja belajar masing-masing sambil berpegangan pada kaki meja dan melindungi kepala serta leher dengan tas sekolah atau buku tebal.\n\nSetelah guncangan berhenti, ikuti instruksi guru untuk keluar kelas secara tertib tanpa saling mendorong menuju lapangan sekolah (titik kumpul). Guru bertugas memeriksa kehadiran siswa dan memastikan tidak ada siswa yang tertinggal di kelas atau toilet.",
                'key_points' => [
                    'Berlindung di bawah meja kelas dan lindungi kepala menggunakan tas atau buku.',
                    'Jauhi jendela kaca ruang kelas dan rak buku/alat laboratorium.',
                    'Keluar kelas secara berbaris dan tertib setelah guncangan berhenti menuju titik kumpul lapangan.',
                ],
                'action_steps' => [
                    'Merunduk di kolong meja belajar begitu merasakan getaran gempa.',
                    'Dengarkan aba-aba guru dan jangan berteriak atau mendorong teman di pintu kelas.',
                    'Gunakan tangga darurat dengan memegang pegangan tangga jika kelas berada di lantai atas.',
                    'Berkumpul di lapangan terbuka sekolah dan lapor kepada guru wali kelas.',
                ],
                'things_to_avoid' => [
                    'Jangan berebut keluar pintu kelas saat gempa masih mengguncang.',
                    'Jangan kembali ke dalam kelas untuk mengambil barang yang tertinggal sebelum diizinkan petugas.',
                ],
                'source_reference' => 'BNPB (Satuan Pendidikan Aman Bencana / SPAB)',
                'sort_order' => 8,
            ],
            [
                'title' => 'Tindakan Saat Terjadi Gempa di Gedung Bertingkat',
                'slug' => 'tindakan-saat-terjadi-gempa-di-gedung-bertingkat',
                'difficulty' => 'Menengah',
                'image_path' => 'illustrations/highrise-earthquake.svg',
                'summary' => 'Panduan penyelamatan diri dan penggunaan jalur tangga darurat saat gempa terjadi di gedung bertingkat, perkantoran, atau pusat perbelanjaan.',
                'content' => "Guncangan di lantai atas gedung bertingkat sering terasa lebih mengayun dibandingkan di lantai dasar. Saat gempa terjadi, segera merunduk, berlindung di bawah meja kerja yang kokoh atau di dekat pilar/dinding bagian dalam gedung, serta jauhi dinding kaca luar.\n\nHal paling penting di gedung bertingkat adalah DILARANG menggunakan lift saat dan setelah gempa karena risiko listrik padam atau macetnya jalur lift. Setelah guncangan berhenti, ikuti rambu jalur evakuasi hijau menuju tangga darurat dan turun dengan tertib menuju titik kumpul di luar gedung.",
                'key_points' => [
                    'Dilarang keras menggunakan lift saat terjadi gempa bumi; selalu gunakan tangga darurat.',
                    'Berlindung di bawah meja kokoh atau di dekat struktur kolom/dinding dalam, jauh dari kaca fasad gedung.',
                    'Ikuti rambu jalur evakuasi (EXIT) dan arahan petugas keselamatan gedung (floor warden).',
                ],
                'action_steps' => [
                    'Lakukan Drop, Cover, and Hold On hingga guncangan berhenti.',
                    'Jika berada di dalam lift saat gempa mulai terasa, tekan semua tombol lantai dan segera keluar di lantai terdekat yang terbuka.',
                    'Turun melalui tangga darurat dengan tertib, berpegangan pada railing, dan bantu lansia atau anak-anak.',
                ],
                'things_to_avoid' => [
                    'Jangan menggunakan lift atau eskalator untuk turun.',
                    'Jangan berlari atau mendorong orang lain di tangga darurat.',
                    'Jangan melompat dari jendela atau balkon lantai atas.',
                ],
                'source_reference' => 'BNPB, Basarnas & Panduan Keselamatan Gedung',
                'sort_order' => 9,
            ],
            [
                'title' => 'Tindakan Setelah Gempa Bumi',
                'slug' => 'tindakan-setelah-gempa-bumi',
                'difficulty' => 'Menengah',
                'image_path' => 'illustrations/post-earthquake.svg',
                'summary' => 'Langkah pemeriksaan keselamatan diri, keluarga, lingkungan sekitar, serta antisipasi gempa susulan setelah guncangan utama berhenti.',
                'content' => "Setelah guncangan utama gempa berhenti, tetap waspada karena gempa susulan (aftershock) sangat mungkin terjadi. Periksa kondisi diri sendiri terlebih dahulu, kemudian periksa anggota keluarga atau orang di sekitar apakah ada yang mengalami luka.\n\nKeluar dari bangunan dengan hati-hati dan berkumpul di titik aman terbuka. Apabila Anda berada di wilayah pesisir dan gempa yang terjadi terasa kuat atau berlangsung lama, segera lakukan evakuasi menuju tempat tinggi atau zona aman tsunami tanpa menunggu sirene resmi.",
                'key_points' => [
                    'Waspadai gempa susulan yang dapat terjadi beberapa menit hingga jam setelah gempa utama.',
                    'Periksa luka pada diri sendiri dan berikan pertolongan pertama kepada orang di sekitar bila aman.',
                    'Gunakan pesan singkat (SMS/chat) untuk komunikasi darurat guna menghindari kepadatan jaringan telepon.',
                ],
                'action_steps' => [
                    'Pastikan kondisi sekitar aman dari pecahan kaca dan reruntuhan sebelum melangkah.',
                    'Gunakan alas kaki (sepatu/sandal tebal) untuk menghindari luka akibat pecahan kaca.',
                    'Pantau pengumuman resmi dari BMKG dan BPBD mengenai status gempa dan potensi tsunami.',
                    'Bantu tetangga yang membutuhkan bantuan khusus seperti lansia, ibu hamil, anak-anak, dan penyandang disabilitas.',
                ],
                'things_to_avoid' => [
                    'Jangan langsung masuk kembali ke dalam rumah yang mengalami retakan struktur.',
                    'Jangan menggunakan saluran telepon secara berlebihan kecuali untuk panggilan darurat.',
                ],
                'source_reference' => 'BNPB, BMKG & Basarnas',
                'sort_order' => 10,
            ],
            [
                'title' => 'Mengenali Potensi Bahaya Setelah Gempa',
                'slug' => 'mengenali-potensi-bahaya-setelah-gempa',
                'difficulty' => 'Lanjutan',
                'image_path' => 'illustrations/secondary-hazards.svg',
                'summary' => 'Mengidentifikasi bahaya ikutan pascagempa seperti kebocoran gas, korsleting listrik, kebakaran, keruntuhan susulan, hingga potensi tsunami.',
                'content' => "Gempa bumi sering diikuti oleh bahaya sekunder (ikutan) yang tidak kalah berbahaya. Guncangan dapat merusak pipa gas atau selang tabung LPG, memutus kabel listrik, meretakkan dinding penahan tanah, serta melemahkan struktur bangunan sehingga rawan runtuh saat gempa susulan.\n\nOleh karena itu, sebelum meninggalkan rumah (jika situasi memungkinkan dan aman), matikan aliran listrik dari panel utama (MCB) dan lepaskan regulator gas. Jika mencium bau gas menyengat, segera buka jendela, jangan menyalakan api atau sakelar listrik, dan segera keluar dari bangunan.",
                'key_points' => [
                    'Kebocoran gas dan hubungan arus pendek listrik adalah pemicu utama kebakaran pascagempa.',
                    'Bangunan yang tampak masih berdiri tetapi kolom utamanya retak berisiko roboh saat gempa susulan.',
                    'Di wilayah pesisir, bahaya ikutan paling kritis dari gempa kuat di laut adalah potensi gelombang tsunami.',
                ],
                'action_steps' => [
                    'Matikan aliran listrik utama (MCB) dan cabut peralatan elektronik bila kondisi aman.',
                    'Periksa kebocoran tabung gas dari baunya; buka ventilasi jika tercium bau gas.',
                    'Jauhi kabel listrik yang menjuntai ke tanah atau genangan air.',
                    'Periksa keretakan tiang dan dinding rumah dari jarak aman sebelum memutuskan masuk kembali.',
                ],
                'things_to_avoid' => [
                    'Jangan menyalakan korek api, lilin, atau menekan sakelar lampu jika mencium bau gas.',
                    'Jangan menyentuh kabel listrik yang jatuh atau tiang besi di sekitarnya.',
                    'Jangan berada di dekat tebing curam yang berpotensi longsor akibat guncangan.',
                ],
                'source_reference' => 'BNPB & Pemadam Kebakaran / BPBD',
                'sort_order' => 11,
            ],
            [
                'title' => 'Tas Siaga Bencana untuk Gempa Bumi',
                'slug' => 'tas-siaga-bencana-untuk-gempa-bumi',
                'difficulty' => 'Dasar',
                'image_path' => 'illustrations/emergency-bag.svg',
                'summary' => 'Panduan menyusun perlengkapan Tas Siaga Bencana untuk memenuhi kebutuhan bertahan hidup mandiri selama 72 jam pertama.',
                'content' => "Tas Siaga Bencana adalah tas ransel tahan air yang berisi kebutuhan pokok untuk bertahan hidup selama minimal 3 hari (72 jam pertama) saat kondisi darurat bencana sebelum bantuan tiba.\n\nLetakkan Tas Siaga Bencana di tempat yang mudah dijangkau dekat jalur keluar rumah sehingga dapat langsung dibawa saat evakuasi. Periksa isi tas secara rutin setiap 6 bulan untuk memastikan makanan, air minum, obat-obatan, dan baterai cadangan belum kedaluwarsa.",
                'key_points' => [
                    'Dirancang untuk mencukupi kebutuhan dasar selama 72 jam pertama keadaan darurat.',
                    'Harus disimpan di lokasi yang diketahui seluruh anggota keluarga dan mudah diambil saat evakuasi.',
                    'Dokumen penting wajib dibungkus plastik kedap air di dalam tas.',
                ],
                'action_steps' => [
                    'Siapkan air minum (minimal 3 liter per orang) dan makanan tahan lama siap saji.',
                    'Masukkan kotak P3K, obat-obatan pribadi rutin, masker, dan perlengkapan kebersihan.',
                    'Siapkan senter, baterai cadangan, peluit darurat, ponsel beserta powerbank, dan radio portabel.',
                    'Simpan salinan dokumen penting (KTP, KK, akta, ijazah, surat berharga) dalam wadah kedap air serta uang tunai secukupnya.',
                    'Siapkan pakaian ganti, jaket/selimut darurat, dan jas hujan.',
                ],
                'things_to_avoid' => [
                    'Jangan mengisi tas terlalu berat dengan barang yang tidak esensial sehingga menghambat gerak evakuasi.',
                    'Jangan menyimpan makanan yang mudah basi atau memerlukan proses memasak rumit.',
                ],
                'source_reference' => 'BNPB & BPBD Kota Padang',
                'sort_order' => 12,
            ],
        ];
    }
}

