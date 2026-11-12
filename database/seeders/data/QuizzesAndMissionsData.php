<?php

namespace Database\Seeders\Data;

class QuizzesAndMissionsData
{
    /**
     * @return list<array<string, mixed>>
     */
    public static function quizzes(): array
    {
        return [
            [
                'category' => 'Gempa Bumi',
                'topic' => 'Pengetahuan Dasar & Persiapan Sebelum Gempa',
                'title' => 'Kuis Kesiapsiagaan Gempa Bumi Dasar',
                'slug' => 'kuis-kesiapsiagaan-gempa-bumi-dasar',
                'difficulty' => 'Dasar',
                'description' => 'Uji pemahamanmu mengenai pengetahuan dasar gempa bumi, persiapan rumah aman, dan perlengkapan Tas Siaga Bencana.',
                'sort_order' => 1,
                'questions' => [
                    [
                        'question_number' => 1,
                        'subtopic' => 'Pengetahuan dasar gempa',
                        'question_text' => 'Apa yang dimaksud dengan episentrum pada kejadian gempa bumi?',
                        'explanation' => 'Episentrum adalah titik di permukaan bumi yang berada tepat tegak lurus di atas hiposentrum (pusat gempa di dalam bumi).',
                        'recommended_material_slug' => 'pengertian-gempa-bumi',
                        'options' => [
                            ['label' => 'A', 'text' => 'Titik di permukaan bumi tepat di atas pusat gempa di dalam bumi', 'is_correct' => true],
                            ['label' => 'B', 'text' => 'Alat pengukur kecepatan angin saat cuaca buruk', 'is_correct' => false],
                            ['label' => 'C', 'text' => 'Gelombang pasang air laut akibat angin kencang', 'is_correct' => false],
                            ['label' => 'D', 'text' => 'Batas wilayah administrasi kelurahan', 'is_correct' => false],
                        ],
                    ],
                    [
                        'question_number' => 2,
                        'subtopic' => 'Persiapan sebelum gempa',
                        'question_text' => 'Bagaimana cara menata perabot rumah tangga yang tepat untuk mengurangi risiko cedera saat gempa bumi?',
                        'explanation' => 'Lemari tinggi perlu dikaitkan ke dinding dan benda berat/pecah belah diletakkan di bagian bawah agar tidak jatuh menimpa penghuni rumah saat terjadi guncangan.',
                        'recommended_material_slug' => 'persiapan-sebelum-terjadi-gempa',
                        'options' => [
                            ['label' => 'A', 'text' => 'Menaruh benda-benda paling berat di atas lemari pakaian', 'is_correct' => false],
                            ['label' => 'B', 'text' => 'Mengaitkan lemari tinggi ke dinding dan menyimpan barang berat di rak bagian bawah', 'is_correct' => true],
                            ['label' => 'C', 'text' => 'Meletakkan lemari kaca tepat di samping pintu keluar agar jalan menjadi sempit', 'is_correct' => false],
                            ['label' => 'D', 'text' => 'Menggantung cermin besar tepat di atas kepala tempat tidur', 'is_correct' => false],
                        ],
                    ],
                    [
                        'question_number' => 3,
                        'subtopic' => 'Tindakan saat gempa',
                        'question_text' => 'Apa langkah utama penyelamatan diri (Drop, Cover, and Hold On) saat gempa terjadi ketika kamu berada di dalam ruangan?',
                        'explanation' => 'Saat gempa terjadi di dalam ruangan, segera merunduk (Drop), berlindung di bawah meja yang kokoh untuk melindungi kepala dan leher (Cover), serta berpegangan pada kaki meja hingga guncangan berhenti (Hold On).',
                        'recommended_material_slug' => 'tindakan-saat-terjadi-gempa-di-dalam-ruangan',
                        'options' => [
                            ['label' => 'A', 'text' => 'Merunduk, berlindung di bawah meja yang kokoh sambil melindungi kepala, dan berpegangan hingga guncangan berhenti', 'is_correct' => true],
                            ['label' => 'B', 'text' => 'Berdiri di dekat jendela kaca untuk melihat keluar', 'is_correct' => false],
                            ['label' => 'C', 'text' => 'Menggunakan lift untuk turun secepat mungkin', 'is_correct' => false],
                            ['label' => 'D', 'text' => 'Menyalakan kompor dan lilin di dapur', 'is_correct' => false],
                        ],
                    ],
                    [
                        'question_number' => 4,
                        'subtopic' => 'Persiapan sebelum gempa',
                        'question_text' => 'Tas Siaga Bencana disiapkan untuk mencukupi kebutuhan dasar bertahan hidup mandiri selama berapa lama pada masa darurat awal?',
                        'explanation' => 'Menurut panduan BNPB, Tas Siaga Bencana dirancang untuk memenuhi kebutuhan bertahan hidup mandiri minimal selama 3 hari (72 jam pertama) saat darurat bencana.',
                        'recommended_material_slug' => 'tas-siaga-bencana-untuk-gempa-bumi',
                        'options' => [
                            ['label' => 'A', 'text' => 'Minimal 3 hari (72 jam pertama)', 'is_correct' => true],
                            ['label' => 'B', 'text' => 'Hanya untuk 1 jam pertama', 'is_correct' => false],
                            ['label' => 'C', 'text' => 'Untuk penyimpanan barang mewah selama 1 tahun', 'is_correct' => false],
                            ['label' => 'D', 'text' => 'Tidak perlu diisi air minum dan P3K', 'is_correct' => false],
                        ],
                    ],
                ],
            ],
            [
                'category' => 'Gempa Bumi',
                'topic' => 'Tindakan Saat & Setelah Gempa Bumi',
                'title' => 'Kuis Tanggap Darurat & Pascagempa',
                'slug' => 'kuis-tanggap-darurat-dan-pascagempa',
                'difficulty' => 'Menengah',
                'description' => 'Evaluasi ketepatan tindakanmu saat menghadapi gempa di sekolah, gedung bertingkat, luar ruangan, serta penanganan bahaya setelah gempa.',
                'sort_order' => 2,
                'questions' => [
                    [
                        'question_number' => 1,
                        'subtopic' => 'Tindakan saat gempa',
                        'question_text' => 'Mengapa penggunaan lift dilarang keras saat dan sesaat setelah terjadi gempa bumi di gedung bertingkat?',
                        'explanation' => 'Saat gempa bumi, aliran listrik dapat padam tiba-tiba atau struktur jalur rel lift mengalami pergeseran sehingga pengguna lift berisiko terjebak.',
                        'recommended_material_slug' => 'tindakan-saat-terjadi-gempa-di-gedung-bertingkat',
                        'options' => [
                            ['label' => 'A', 'text' => 'Karena lift berisiko macet akibat listrik padam atau kerusakan rel akibat guncangan', 'is_correct' => true],
                            ['label' => 'B', 'text' => 'Karena lift hanya boleh digunakan untuk mengangkut perabot berat saat gempa', 'is_correct' => false],
                            ['label' => 'C', 'text' => 'Karena tangga darurat tidak boleh dilewati penghuni gedung', 'is_correct' => false],
                            ['label' => 'D', 'text' => 'Karena lift bergerak terlalu lambat pada hari libur', 'is_correct' => false],
                        ],
                    ],
                    [
                        'question_number' => 2,
                        'subtopic' => 'Tindakan saat gempa',
                        'question_text' => 'Apa yang harus dilakukan siswa di ruang kelas setelah guncangan gempa bumi benar-benar berhenti?',
                        'explanation' => 'Setelah guncangan berhenti, siswa harus keluar kelas secara berbaris dan tertib mengikuti arahan guru sambil melindungi kepala dengan tas menuju titik kumpul di lapangan terbuka.',
                        'recommended_material_slug' => 'tindakan-saat-terjadi-gempa-di-sekolah',
                        'options' => [
                            ['label' => 'A', 'text' => 'Berdesak-desakan dan saling mendorong di pintu kelas', 'is_correct' => false],
                            ['label' => 'B', 'text' => 'Keluar secara tertib mengikuti arahan guru sambil melindungi kepala menuju titik kumpul lapangan', 'is_correct' => true],
                            ['label' => 'C', 'text' => 'Mengunci diri di dalam ruang laboratorium', 'is_correct' => false],
                            ['label' => 'D', 'text' => 'Berdiri di bawah kaca jendela lantai dua', 'is_correct' => false],
                        ],
                    ],
                    [
                        'question_number' => 3,
                        'subtopic' => 'Tindakan setelah gempa',
                        'question_text' => 'Bahaya ikutan apa yang perlu diwaspadai dan diperiksa sebelum meninggalkan rumah setelah gempa berhenti?',
                        'explanation' => 'Kebocoran tabung/pipa gas dan hubungan arus pendek listrik dapat memicu kebakaran pascagempa. Pastikan mematikan MCB listrik dan melepas regulator gas bila aman.',
                        'recommended_material_slug' => 'mengenali-potensi-bahaya-setelah-gempa',
                        'options' => [
                            ['label' => 'A', 'text' => 'Kebocoran gas dan korsleting listrik yang dapat memicu kebakaran serta keretakan struktur bangunan', 'is_correct' => true],
                            ['label' => 'B', 'text' => 'Perubahan warna cat pagar halaman rumah', 'is_correct' => false],
                            ['label' => 'C', 'text' => 'Susunan buku di meja belajar', 'is_correct' => false],
                            ['label' => 'D', 'text' => 'Menyalakan lilin saat tercium bau gas menyengat', 'is_correct' => false],
                        ],
                    ],
                    [
                        'question_number' => 4,
                        'subtopic' => 'Tindakan setelah gempa',
                        'question_text' => 'Mengapa disarankan menggunakan pesan singkat (SMS/chat) dibandingkan panggilan suara biasa sesaat setelah gempa besar?',
                        'explanation' => 'Penggunaan pesan singkat menghemat baterai ponsel dan mencegah kepadatan jaringan telekomunikasi sehingga saluran panggilan darurat tetap berfungsi bagi petugas penyelamat.',
                        'recommended_material_slug' => 'tindakan-setelah-gempa-bumi',
                        'options' => [
                            ['label' => 'A', 'text' => 'Untuk menghemat jaringan komunikasi agar tidak padat dan menghemat daya baterai ponsel', 'is_correct' => true],
                            ['label' => 'B', 'text' => 'Karena telepon suara dilarang oleh operator seluler selamanya', 'is_correct' => false],
                            ['label' => 'C', 'text' => 'Untuk menyebarkan berita yang belum jelas sumbernya', 'is_correct' => false],
                            ['label' => 'D', 'text' => 'Agar ponsel menjadi lebih berat', 'is_correct' => false],
                        ],
                    ],
                ],
            ],
            [
                'category' => 'Tsunami',
                'topic' => 'Pengetahuan Dasar, Tanda Bahaya & Peringatan Dini Tsunami',
                'title' => 'Kuis Kesiapsiagaan & Tanda Bahaya Tsunami',
                'slug' => 'kuis-kesiapsiagaan-dan-tanda-bahaya-tsunami',
                'difficulty' => 'Dasar',
                'description' => 'Uji pengetahuanmu tentang penyebab tsunami, hubungan gempa dengan tsunami, tanda alam, serta sistem peringatan dini resmi.',
                'sort_order' => 3,
                'questions' => [
                    [
                        'question_number' => 1,
                        'subtopic' => 'Pengetahuan dasar tsunami',
                        'question_text' => 'Pernyataan manakah yang paling tepat mengenai hubungan antara gempa bumi dan tsunami?',
                        'explanation' => 'Tidak semua gempa bumi menyebabkan tsunami. Tsunami umumnya dipicu oleh gempa tektonik kuat dan dangkal di bawah laut yang menyebabkan perubahan vertikal dasar laut.',
                        'recommended_material_slug' => 'hubungan-gempa-bumi-dengan-tsunami',
                        'options' => [
                            ['label' => 'A', 'text' => 'Semua gempa bumi kecil di pegunungan daratan pasti menimbulkan tsunami', 'is_correct' => false],
                            ['label' => 'B', 'text' => 'Tidak semua gempa menyebabkan tsunami; tsunami umumnya dipicu gempa kuat dan dangkal di bawah laut dengan patahan vertikal', 'is_correct' => true],
                            ['label' => 'C', 'text' => 'Tsunami hanya terjadi karena hujan gerimis di tepi pantai', 'is_correct' => false],
                            ['label' => 'D', 'text' => 'Tsunami selalu terdiri dari satu gelombang kecil saja', 'is_correct' => false],
                        ],
                    ],
                    [
                        'question_number' => 2,
                        'subtopic' => 'Tanda bahaya tsunami',
                        'question_text' => 'Apa yang harus segera dilakukan masyarakat di wilayah pesisir jika merasakan gempa kuat (hingga sulit berdiri) atau guncangan yang berlangsung lama?',
                        'explanation' => 'Gempa kuat atau lama di wilayah pesisir adalah tanda alam bahaya tsunami. Masyarakat wajib segera melakukan evakuasi mandiri menuju tempat tinggi atau shelter resmi tanpa menunggu sirene atau notifikasi resmi.',
                        'recommended_material_slug' => 'tanda-alam-yang-dapat-mengindikasikan-tsunami',
                        'options' => [
                            ['label' => 'A', 'text' => 'Segera menjauhi pantai menuju tempat lebih tinggi atau shelter evakuasi resmi tanpa menunggu sirene berbunyi', 'is_correct' => true],
                            ['label' => 'B', 'text' => 'Menunggu di tepi pantai sampai ada petugas yang datang menjemput satu per satu', 'is_correct' => false],
                            ['label' => 'C', 'text' => 'Mendekati bibir pantai untuk melihat apakah air laut surut', 'is_correct' => false],
                            ['label' => 'D', 'text' => 'Tetap berada di dalam rumah tepi pantai sambil tidur', 'is_correct' => false],
                        ],
                    ],
                    [
                        'question_number' => 3,
                        'subtopic' => 'Tanda bahaya tsunami',
                        'question_text' => 'Manakah di bawah ini yang merupakan tanda alam yang dapat mengindikasikan bahaya tsunami?',
                        'explanation' => 'Tiga tanda alam utama tsunami adalah: gempa kuat atau berlangsung lama di pesisir, air laut tiba-tiba surut secara tidak biasa, dan terdengar suara gemuruh keras dari arah laut.',
                        'recommended_material_slug' => 'tanda-alam-yang-dapat-mengindikasikan-tsunami',
                        'options' => [
                            ['label' => 'A', 'text' => 'Air laut tiba-tiba surut jauh secara tidak biasa disertai suara gemuruh dari arah laut setelah gempa', 'is_correct' => true],
                            ['label' => 'B', 'text' => 'Cuaca cerah berawan pada pagi hari biasa', 'is_correct' => false],
                            ['label' => 'C', 'text' => 'Embusan angin sepoi-sepoi di taman kota', 'is_correct' => false],
                            ['label' => 'D', 'text' => 'Daun pepohonan berguguran saat musim kemarau', 'is_correct' => false],
                        ],
                    ],
                    [
                        'question_number' => 4,
                        'subtopic' => 'Peringatan dini',
                        'question_text' => 'Lembaga resmi pemerintah di Indonesia yang berwenang mengeluarkan informasi gempa bumi dan peringatan dini tsunami (InaTEWS) adalah...',
                        'explanation' => 'BMKG (Badan Meteorologi, Klimatologi, dan Geofisika) adalah lembaga resmi yang mengoperasikan InaTEWS untuk memberikan informasi gempa bumi dan peringatan dini tsunami di Indonesia, bersinergi dengan BNPB dan BPBD.',
                        'recommended_material_slug' => 'mengenali-peringatan-dini-tsunami',
                        'options' => [
                            ['label' => 'A', 'text' => 'BMKG (bersinergi dengan BNPB dan BPBD setempat)', 'is_correct' => true],
                            ['label' => 'B', 'text' => 'Akun media sosial anonim yang tidak terverifikasi', 'is_correct' => false],
                            ['label' => 'C', 'text' => 'Pesan berantai tanpa sumber di grup percakapan', 'is_correct' => false],
                            ['label' => 'D', 'text' => 'Komunitas peramal cuaca tidak resmi', 'is_correct' => false],
                        ],
                    ],
                ],
            ],
            [
                'category' => 'Tsunami',
                'topic' => 'Jalur Evakuasi, Larangan & Tindakan Setelah Tsunami',
                'title' => 'Kuis Evakuasi & Keselamatan Pascatsunami',
                'slug' => 'kuis-evakuasi-dan-keselamatan-pascatsunami',
                'difficulty' => 'Menengah',
                'description' => 'Uji pemahamanmu mengenai prosedur evakuasi menuju tempat tinggi/shelter vertikal, hal yang dilarang saat evakuasi, dan kapan waktu aman kembali ke pesisir.',
                'sort_order' => 4,
                'questions' => [
                    [
                        'question_number' => 1,
                        'subtopic' => 'Jalur dan tindakan evakuasi',
                        'question_text' => 'Apa yang dimaksud dengan evakuasi vertikal saat terjadi ancaman tsunami?',
                        'explanation' => 'Evakuasi vertikal adalah tindakan menyelamatkan diri dengan naik ke lantai atas (minimal lantai 3 atau lebih tinggi) pada gedung kokoh tahan gempa atau Gedung Shelter Evakuasi Tsunami resmi jika waktu menuju dataran tinggi tidak mencukupi.',
                        'recommended_material_slug' => 'cara-melakukan-evakuasi-ke-tempat-yang-lebih-tinggi-atau-lokasi-aman',
                        'options' => [
                            ['label' => 'A', 'text' => 'Naik ke lantai atas gedung shelter kokoh yang telah ditetapkan pihak berwenang apabila dataran tinggi tidak sempat dijangkau', 'is_correct' => true],
                            ['label' => 'B', 'text' => 'Berlari menyusuri bibir pantai dari utara ke selatan', 'is_correct' => false],
                            ['label' => 'C', 'text' => 'Bersembunyi di ruang bawah tanah di tepi pantai', 'is_correct' => false],
                            ['label' => 'D', 'text' => 'Menyeberangi sungai menggunakan rakit ke arah muara laut', 'is_correct' => false],
                        ],
                    ],
                    [
                        'question_number' => 2,
                        'subtopic' => 'Jalur dan tindakan evakuasi',
                        'question_text' => 'Mengapa masyarakat sangat dianjurkan melakukan evakuasi tsunami dengan berjalan kaki cepat/berlari dibandingkan membawa mobil pribadi?',
                        'explanation' => 'Penggunaan kendaraan bermotor secara bersamaan saat darurat berisiko tinggi menimbulkan kemacetan total yang mengunci jalur evakuasi dan membahayakan warga.',
                        'recommended_material_slug' => 'hal-yang-tidak-boleh-dilakukan-saat-evakuasi-tsunami',
                        'options' => [
                            ['label' => 'A', 'text' => 'Untuk mencegah kemacetan lalu lintas di jalur evakuasi yang dapat menghambat penyelamatan warga', 'is_correct' => true],
                            ['label' => 'B', 'text' => 'Karena jalan raya hanya boleh dilewati saat malam hari', 'is_correct' => false],
                            ['label' => 'C', 'text' => 'Agar warga bisa berhenti lama di tepi pantai', 'is_correct' => false],
                            ['label' => 'D', 'text' => 'Karena rambu evakuasi hanya berlaku bagi wisatawan', 'is_correct' => false],
                        ],
                    ],
                    [
                        'question_number' => 3,
                        'subtopic' => 'Tindakan setelah tsunami',
                        'question_text' => 'Kapan masyarakat yang berada di lokasi pengungsian/tempat tinggi diperbolehkan kembali ke wilayah pesisir?',
                        'explanation' => 'Masyarakat hanya boleh kembali setelah BMKG dan pihak berwenang secara resmi mengumumkan bahwa Peringatan Dini Tsunami telah berakhir dan kondisi dinyatakan aman.',
                        'recommended_material_slug' => 'kembali-ke-wilayah-pesisir-setelah-peringatan-berakhir',
                        'options' => [
                            ['label' => 'A', 'text' => 'Segera setelah gelombang pertama surut meskipun belum ada pengumuman resmi', 'is_correct' => false],
                            ['label' => 'B', 'text' => 'Hanya setelah ada pengumuman resmi dari BMKG dan pihak berwenang bahwa peringatan dini tsunami telah berakhir', 'is_correct' => true],
                            ['label' => 'C', 'text' => 'Saat melihat satu orang warga nekat turun ke pantai', 'is_correct' => false],
                            ['label' => 'D', 'text' => 'Lima menit setelah gempa berhenti tanpa memeriksa informasi resmi', 'is_correct' => false],
                        ],
                    ],
                    [
                        'question_number' => 4,
                        'subtopic' => 'Tindakan setelah tsunami',
                        'question_text' => 'Mengapa gelombang tsunami pertama yang sudah surut belum menandakan keadaan sudah aman?',
                        'explanation' => 'Tsunami merupakan rangkaian beberapa gelombang. Gelombang kedua atau ketiga dapat datang beberapa menit hingga lebih dari satu jam kemudian dengan ketinggian yang bisa lebih besar.',
                        'recommended_material_slug' => 'pengertian-tsunami',
                        'options' => [
                            ['label' => 'A', 'text' => 'Karena tsunami terdiri dari rangkaian gelombang dan gelombang berikutnya dapat datang menyusul dengan kekuatan lebih besar', 'is_correct' => true],
                            ['label' => 'B', 'text' => 'Karena air laut tidak pernah bergerak lagi setelah gelombang pertama', 'is_correct' => false],
                            ['label' => 'C', 'text' => 'Karena gelombang kedua hanya terjadi pada tahun berikutnya', 'is_correct' => false],
                            ['label' => 'D', 'text' => 'Karena petugas sedang beristirahat', 'is_correct' => false],
                        ],
                    ],
                ],
            ],
        ];
    }

    /**
     * @return list<array<string, mixed>>
     */
    public static function missions(): array
    {
        return [
            // 7 MISI GEMPA BUMI
            [
                'category' => 'Gempa Bumi',
                'title' => 'Kenali Tempat Berlindung yang Aman di Rumah',
                'slug' => 'kenali-tempat-berlindung-yang-aman-di-rumah',
                'description' => 'Identifikasi titik paling aman di setiap ruangan rumah untuk melakukan perlindungan diri saat guncangan gempa bumi terjadi.',
                'illustration' => 'safe_spot_home',
                'instructions' => [
                    'Periksa ruang keluarga, kamar tidur, dan ruang belajar di rumahmu.',
                    'Tentukan meja yang kokoh atau sudut dinding bagian dalam yang jauh dari jendela kaca dan lemari tinggi.',
                    'Pastikan kolong meja tidak dipenuhi tumpukan barang agar bisa langsung digunakan berlindung.',
                    'Beri tahu seluruh anggota keluarga mengenai titik berlindung aman di setiap ruangan.',
                ],
                'difficulty' => 'Dasar',
                'points' => 50,
                'sort_order' => 1,
            ],
            [
                'category' => 'Gempa Bumi',
                'title' => 'Identifikasi Benda Berat yang Perlu Diamankan',
                'slug' => 'identifikasi-benda-berat-yang-perlu-diamankan',
                'description' => 'Periksa dan amankan lemari tinggi, rak, atau benda gantung di rumah agar tidak roboh atau jatuh saat terjadi gempa.',
                'illustration' => 'secure_furniture',
                'instructions' => [
                    'Periksa lemari pakaian, rak buku, atau bufet tinggi di rumah.',
                    'Pindahkan barang-barang berat dan benda pecah belah dari rak bagian atas ke rak bagian bawah.',
                    'Pasang siku pengait atau penahan pada lemari tinggi ke dinding jika memungkinkan.',
                    'Pastikan tidak ada bingkai kaca berat atau benda keras tergantung tepat di atas tempat tidur.',
                ],
                'difficulty' => 'Menengah',
                'points' => 60,
                'sort_order' => 2,
            ],
            [
                'category' => 'Gempa Bumi',
                'title' => 'Kenali Jalur Keluar Rumah',
                'slug' => 'kenali-jalur-keluar-rumah',
                'description' => 'Pastikan seluruh jalur keluar rumah dan pintu darurat bebas dari hambatan sehingga mudah dilalui saat evakuasi pascagempa.',
                'illustration' => 'home_exit_route',
                'instructions' => [
                    'Telusuri jalur dari setiap kamar tidur menuju pintu keluar utama dan pintu belakang rumah.',
                    'Singkirkan barang, sepatu, atau perabot yang menghalangi lorong dan bukaan pintu.',
                    'Simpan kunci pintu rumah di tempat tetap yang mudah dijangkau semua anggota keluarga dalam kondisi gelap.',
                ],
                'difficulty' => 'Dasar',
                'points' => 50,
                'sort_order' => 3,
            ],
            [
                'category' => 'Gempa Bumi',
                'title' => 'Siapkan Tas Siaga Bencana',
                'slug' => 'siapkan-tas-siaga-bencana',
                'description' => 'Susun perlengkapan darurat keluarga di dalam satu tas ransel yang siap dibawa kapan saja untuk kebutuhan 72 jam pertama.',
                'illustration' => 'emergency_bag',
                'instructions' => [
                    'Siapkan tas ransel yang kuat dan mudah dibawa.',
                    'Masukkan air minum, makanan tahan lama, kotak P3K, obat pribadi, senter, peluit, dan powerbank.',
                    'Masukkan salinan dokumen penting dalam plastik kedap air, pakaian ganti, dan uang tunai secukupnya.',
                    'Letakkan Tas Siaga Bencana di dekat pintu keluar rumah.',
                ],
                'difficulty' => 'Menengah',
                'points' => 80,
                'sort_order' => 4,
            ],
            [
                'category' => 'Gempa Bumi',
                'title' => 'Tentukan Titik Kumpul Keluarga',
                'slug' => 'tentukan-titik-kumpul-keluarga',
                'description' => 'Sepakati lokasi titik kumpul terbuka yang aman di sekitar rumah apabila anggota keluarga harus keluar saat terjadi gempa bumi.',
                'illustration' => 'family_assembly_point',
                'instructions' => [
                    'Pilih area terbuka di dekat rumah yang jauh dari bangunan tinggi, pagar tembok tua, dan tiang listrik.',
                    'Tentukan juga titik kumpul kedua di lingkungan sekitar apabila area sekitar rumah tidak dapat diakses.',
                    'Pastikan seluruh anggota keluarga termasuk anak-anak mengetahui lokasi titik kumpul tersebut.',
                ],
                'difficulty' => 'Dasar',
                'points' => 50,
                'sort_order' => 5,
            ],
            [
                'category' => 'Gempa Bumi',
                'title' => 'Diskusikan Rencana Komunikasi Keluarga',
                'slug' => 'diskusikan-rencana-komunikasi-keluarga',
                'description' => 'Buat kesepakatan cara berkomunikasi dan daftar nomor darurat apabila gempa terjadi saat anggota keluarga berada di tempat terpisah.',
                'illustration' => 'family_communication',
                'instructions' => [
                    'Catat nomor telepon seluruh anggota keluarga dan satu kerabat di luar kota sebagai kontak penghubung.',
                    'Catat nomor darurat resmi Kota Padang (BPBD 0751-778775, SAR 0751-484534, Damkar 113, Polisi 110, RS M. Djamil 0751-37030).',
                    'Sepakati penggunaan pesan singkat (SMS/chat) untuk menghemat baterai dan jaringan saat darurat.',
                ],
                'difficulty' => 'Menengah',
                'points' => 60,
                'sort_order' => 6,
            ],
            [
                'category' => 'Gempa Bumi',
                'title' => 'Pelajari Langkah Drop, Cover, and Hold On Sesuai Panduan Keselamatan',
                'slug' => 'pelajari-langkah-drop-cover-and-hold-on',
                'description' => 'Praktikkan gerakan Merunduk (Drop), Berlindung (Cover), dan Berpegangan (Hold On) bersama anggota keluarga atau teman.',
                'illustration' => 'drop_cover_hold_on',
                'instructions' => [
                    'Pelajari posisi DROP: jatuhkan tubuh ke posisi tangan dan lutut agar tidak terjatuh oleh guncangan.',
                    'Pelajari posisi COVER: lindungi kepala dan leher dengan masuk ke kolong meja yang kokoh.',
                    'Pelajari posisi HOLD ON: pegang erat kaki meja dengan satu tangan dan lindungi kepala/leher dengan tangan lainnya selama 30 detik.',
                ],
                'difficulty' => 'Dasar',
                'points' => 70,
                'sort_order' => 7,
            ],

            // 7 MISI TSUNAMI
            [
                'category' => 'Tsunami',
                'title' => 'Kenali Apakah Tempat Tinggal Berada di Wilayah Rawan Tsunami',
                'slug' => 'kenali-apakah-tempat-tinggal-berada-di-wilayah-rawan-tsunami',
                'description' => 'Periksa status zona risiko lokasi rumah, sekolah, atau tempat kerjamu melalui Peta Evakuasi resmi SiagaBencana.',
                'illustration' => 'tsunami_hazard_zone',
                'instructions' => [
                    'Buka menu Peta Evakuasi di aplikasi SiagaBencana.',
                    'Gunakan fitur Cek Lokasi atau cari alamat tempat tinggal dan sekolahmu.',
                    'Perhatikan apakah lokasimu berada di Zona Bahaya (Merah), Zona Waspada (Kuning), atau Zona Aman (Hijau).',
                ],
                'difficulty' => 'Dasar',
                'points' => 60,
                'sort_order' => 8,
            ],
            [
                'category' => 'Tsunami',
                'title' => 'Pelajari Jalur Evakuasi Tsunami di Lingkungan Sekitar',
                'slug' => 'pelajari-jalur-evakuasi-tsunami-di-lingkungan-sekitar',
                'description' => 'Kenali rambu dan rute jalan utama dari lingkunganmu menuju arah daratan tinggi atau Zona Aman tsunami.',
                'illustration' => 'tsunami_evacuation_route',
                'instructions' => [
                    'Amati rambu petunjuk arah Jalur Evakuasi Tsunami di sekitar lingkungan rumah atau sekolah.',
                    'Kenali rute jalan utama ke arah Timur/dataran tinggi yang menjauhi garis pantai dan muara sungai.',
                    'Siapkan minimal satu rute alternatif jika jalan utama mengalami hambatan.',
                ],
                'difficulty' => 'Menengah',
                'points' => 70,
                'sort_order' => 9,
            ],
            [
                'category' => 'Tsunami',
                'title' => 'Kenali Lokasi Evakuasi yang Telah Ditetapkan oleh Pihak Berwenang',
                'slug' => 'kenali-lokasi-evakuasi-yang-telah-ditetapkan-oleh-pihak-berwenang',
                'description' => 'Identifikasi titik kumpul resmi, posko utama BPBD, atau gedung shelter evakuasi vertikal terdekat dari lokasimu.',
                'illustration' => 'official_shelter',
                'instructions' => [
                    'Periksa daftar titik evakuasi dan instansi darurat pada Peta Evakuasi SiagaBencana.',
                    'Kenali lokasi Gedung Evakuasi Vertikal (Shelter Tsunami) atau dataran tinggi terdekat dari tempat beraktivitas.',
                    'Catat perkiraan waktu tempuh berjalan cepat menuju lokasi evakuasi tersebut.',
                ],
                'difficulty' => 'Menengah',
                'points' => 70,
                'sort_order' => 10,
            ],
            [
                'category' => 'Tsunami',
                'title' => 'Diskusikan Rencana Evakuasi Keluarga',
                'slug' => 'diskusikan-rencana-evakuasi-keluarga',
                'description' => 'Susun kesepakatan tindakan evakuasi mandiri bersama keluarga jika terjadi gempa kuat atau peringatan dini tsunami.',
                'illustration' => 'family_tsunami_plan',
                'instructions' => [
                    'Sepakati bahwa seluruh anggota keluarga di pesisir akan langsung evakuasi mandiri jika merasakan gempa kuat/lama tanpa menunggu sirene.',
                    'Tentukan pembagian tugas siapa yang membawa Tas Siaga dan siapa yang mendampingi anak-anak atau lansia.',
                    'Tentukan lokasi titik temu di Zona Aman apabila anggota keluarga sedang berada di lokasi berbeda.',
                ],
                'difficulty' => 'Menengah',
                'points' => 80,
                'sort_order' => 11,
            ],
            [
                'category' => 'Tsunami',
                'title' => 'Catat Informasi Peringatan Dini dari Sumber Resmi',
                'slug' => 'catat-informasi-peringatan-dini-dari-sumber-resmi',
                'description' => 'Pastikan kamu dan keluarga mengetahui kanal resmi BMKG, BNPB, dan BPBD untuk memantau peringatan dini tsunami.',
                'illustration' => 'official_warning_channels',
                'instructions' => [
                    'Kenali kanal informasi resmi BMKG (situs resmi bmkg.go.id dan aplikasi InfoBMKG) serta fitur Peringatan Dini BMKG di Beranda SiagaBencana.',
                    'Pahami arti tingkatan status peringatan dini tsunami: Awas, Siaga, dan Waspada.',
                    'Komitmen untuk selalu memeriksa kebenaran informasi sebelum membagikannya kepada orang lain.',
                ],
                'difficulty' => 'Dasar',
                'points' => 50,
                'sort_order' => 12,
            ],
            [
                'category' => 'Tsunami',
                'title' => 'Pelajari Tanda Alam yang Dapat Mengindikasikan Tsunami',
                'slug' => 'pelajari-tanda-alam-yang-dapat-mengindikasikan-tsunami',
                'description' => 'Kuasai tiga tanda alam utama tsunami (Feel, See, Hear) agar dapat mengambil keputusan evakuasi mandiri dengan cepat.',
                'illustration' => 'natural_tsunami_signs',
                'instructions' => [
                    'Pahami tanda FEEL: merasakan gempa bumi kuat (sulit berdiri) atau guncangan mengayun yang berlangsung lama di pesisir.',
                    'Pahami tanda SEE: melihat air laut tiba-tiba surut secara tidak biasa dari garis pantai.',
                    'Pahami tanda HEAR: mendengar suara gemuruh keras dari arah laut.',
                    'Ingat aturan keselamatan: segera menjauhi pantai begitu mengenali salah satu tanda alam tersebut.',
                ],
                'difficulty' => 'Dasar',
                'points' => 60,
                'sort_order' => 13,
            ],
            [
                'category' => 'Tsunami',
                'title' => 'Ketahui Cara Menuju Tempat yang Lebih Tinggi',
                'slug' => 'ketahui-cara-menuju-tempat-yang-lebih-tinggi',
                'description' => 'Latih langkah evakuasi menuju tempat tinggi atau shelter vertikal dengan mengutamakan keselamatan dan menghindari area berbahaya.',
                'illustration' => 'high_ground_route',
                'instructions' => [
                    'Utamakan evakuasi dengan berjalan kaki cepat/berlari agar tidak terjebak kemacetan kendaraan.',
                    'Hindari berjalan menyusuri tepian sungai atau menyeberangi jembatan muara dekat pantai.',
                    'Ingat untuk tetap bertahan di tempat tinggi dan tidak kembali ke pesisir sebelum pengumuman resmi peringatan berakhir dari BMKG.',
                ],
                'difficulty' => 'Lanjutan',
                'points' => 80,
                'sort_order' => 14,
            ],
        ];
    }

    /**
     * @return list<array<string, mixed>>
     */
    public static function badges(): array
    {
        return [
            [
                'code' => 'siaga-gempa',
                'name' => 'Siaga Gempa',
                'description' => 'Penghargaan bagi pengguna yang telah mempelajari materi mitigasi gempa bumi, menyelesaikan simulasi skenario gempa, dan lulus kuis gempa bumi.',
                'criteria_description' => 'Menyelesaikan minimal 3 materi Gempa Bumi, 1 simulasi Gempa Bumi, dan 1 kuis Gempa Bumi.',
                'icon' => 'shield_earthquake',
                'category' => 'Gempa Bumi',
                'points_reward' => 100,
            ],
            [
                'code' => 'siaga-tsunami',
                'name' => 'Siaga Tsunami',
                'description' => 'Penghargaan bagi pengguna yang menguasai tanda bahaya tsunami, peringatan dini, serta prosedur evakuasi melalui materi, simulasi, dan kuis tsunami.',
                'criteria_description' => 'Menyelesaikan minimal 3 materi Tsunami, 1 simulasi Tsunami, dan 1 kuis Tsunami.',
                'icon' => 'waves_tsunami',
                'category' => 'Tsunami',
                'points_reward' => 100,
            ],
            [
                'code' => 'ahli-evakuasi',
                'name' => 'Ahli Evakuasi',
                'description' => 'Penghargaan atas ketepatan mengambil keputusan penyelamatan diri dan evakuasi darurat dengan skor tinggi pada simulasi skenario.',
                'criteria_description' => 'Menyelesaikan minimal 2 simulasi skenario dengan nilai minimal 80 poin.',
                'icon' => 'directions_run',
                'category' => 'Evakuasi',
                'points_reward' => 120,
            ],
            [
                'code' => 'pembelajar-aktif',
                'name' => 'Pembelajar Aktif',
                'description' => 'Penghargaan bagi pembelajar tekun yang aktif menuntaskan materi edukasi dan menguji pemahaman melalui kuis kesiapsiagaan.',
                'criteria_description' => 'Menyelesaikan minimal 6 materi pembelajaran dan minimal 2 kuis.',
                'icon' => 'school',
                'category' => 'Umum',
                'points_reward' => 150,
            ],
            [
                'code' => 'keluarga-siaga',
                'name' => 'Keluarga Siaga',
                'description' => 'Penghargaan bagi pengguna yang menerapkan kesiapsiagaan nyata bersama keluarga melalui penyelesaian Misi Siaga.',
                'criteria_description' => 'Menyelesaikan minimal 3 Misi Siaga kesiapsiagaan gempa bumi dan tsunami.',
                'icon' => 'family_restroom',
                'category' => 'Misi Siaga',
                'points_reward' => 150,
            ],
        ];
    }
}

