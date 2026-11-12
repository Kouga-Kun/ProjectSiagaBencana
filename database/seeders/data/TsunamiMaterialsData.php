<?php

namespace Database\Seeders\Data;

class TsunamiMaterialsData
{
    /**
     * @return list<array<string, mixed>>
     */
    public static function get(): array
    {
        return [
            [
                'title' => 'Pengertian Tsunami',
                'slug' => 'pengertian-tsunami',
                'difficulty' => 'Dasar',
                'image_path' => 'illustrations/tsunami-waves.svg',
                'summary' => 'Tsunami adalah rangkaian gelombang laut berenergi besar akibat gangguan impulsif di dasar laut yang dapat menerjang wilayah pesisir.',
                'content' => "Kata tsunami berasal dari bahasa Jepang ('tsu' berarti pelabuhan dan 'nami' berarti gelombang). Secara ilmiah, tsunami adalah rangkaian gelombang laut yang mampu menjalar dengan kecepatan tinggi di laut lepas akibat adanya perubahan bentuk dasar laut secara tiba-tiba.\n\nDi laut dalam, tinggi gelombang tsunami bisa tampak kecil namun kecepatannya sangat tinggi. Ketika mendekati perairan dangkal di pantai, kecepatan gelombang menurun tetapi tingginya meningkat drastis dan membawa arus dorong yang sangat kuat ke daratan. Tsunami bukan hanya satu gelombang tunggal, melainkan rangkaian gelombang yang datang berulang kali.",
                'key_points' => [
                    'Tsunami adalah rangkaian beberapa gelombang laut berenergi sangat besar, bukan hanya satu gelombang.',
                    'Gelombang kedua atau ketiga sering kali bisa lebih besar daripada gelombang pertama.',
                    'Kecepatan gelombang tsunami di laut dalam sangat tinggi dan ketinggiannya membesar saat mencapai perairan dangkal pesisir.',
                ],
                'action_steps' => [
                    'Pahami perbedaan antara ombak pasang biasa dengan gelombang tsunami.',
                    'Sadari bahwa arus tsunami membawa material puing yang sangat berbahaya bagi keselamatan jiwa.',
                ],
                'things_to_avoid' => [
                    'Jangan menganggap tsunami sudah berakhir setelah gelombang pertama surut.',
                    'Jangan meremehkan gelombang tsunami meskipun tinggi awalnya terlihat tidak besar.',
                ],
                'source_reference' => 'BMKG, BNPB & UNESCO-IOC (InaTEWS)',
                'sort_order' => 1,
            ],
            [
                'title' => 'Penyebab Terjadinya Tsunami',
                'slug' => 'penyebab-terjadinya-tsunami',
                'difficulty' => 'Dasar',
                'image_path' => 'illustrations/tsunami-causes.svg',
                'summary' => 'Mengenal berbagai faktor pemicu tsunami, mulai dari gempa bumi bawah laut, longsoran dasar laut, hingga aktivitas vulkanik.',
                'content' => "Sebagian besar kejadian tsunami di dunia dan di Indonesia dipicu oleh gempa bumi tektonik di bawah laut yang menyebabkan pergerakan vertikal lantai samudra, sehingga kolom air laut di atasnya terdorong secara tiba-tiba.\n\nSelain gempa bumi bawah laut, tsunami juga dapat dipicu oleh tanah longsor di bawah laut (atau longsoran tebing besar yang jatuh ke laut), letusan gunung api bawah laut atau pulau gunung api, serta tumbukan benda langit di laut. Di pesisir barat Sumatera, ancaman utama tsunami berasal dari aktivitas zona subduksi Megathrust di Samudra Hindia.",
                'key_points' => [
                    'Gempa bumi tektonik di dasar laut dengan patahan vertikal adalah penyebab utama tsunami.',
                    'Longsoran bawah laut dan erupsi gunung api di laut juga dapat memicu tsunami.',
                    'Perubahan vertikal dasar laut mendorong seluruh kolom air dari dasar hingga permukaan laut.',
                ],
                'action_steps' => [
                    'Kenali bahwa wilayah pesisir yang berhadapan langsung dengan zona subduksi laut memiliki potensi risiko tsunami.',
                    'Ikuti edukasi kebencanaan resmi dari BPBD dan BMKG mengenai potensi sumber tsunami di wilayah Anda.',
                ],
                'things_to_avoid' => [
                    'Jangan menganggap tsunami hanya bisa terjadi jika ada suara letusan atau cuaca buruk.',
                    'Jangan mengarang informasi zona risiko tanpa rujukan peta resmi.',
                ],
                'source_reference' => 'BMKG, BNPB & UNESCO-IOC',
                'sort_order' => 2,
            ],
            [
                'title' => 'Hubungan Gempa Bumi dengan Tsunami',
                'slug' => 'hubungan-gempa-bumi-dengan-tsunami',
                'difficulty' => 'Menengah',
                'image_path' => 'illustrations/earthquake-tsunami-link.svg',
                'summary' => 'Memahami mengapa tidak semua gempa bumi menyebabkan tsunami dan kriteria gempa yang berpotensi memicu tsunami.',
                'content' => "Penting untuk dipahami bahwa TIDAK SEMUA gempa bumi akan menyebabkan tsunami. Gempa bumi yang berpotensi memicu tsunami umumnya memenuhi beberapa kriteria utama:\n1. Pusat gempa (episentrum) berada di laut atau dekat garis pantai.\n2. Kedalaman pusat gempa tergolong dangkal (umumnya kurang dari 70 km).\n3. Kekuatan gempa cukup besar (umumnya magnitudo di atas 7,0, meski dapat bervariasi).\n4. Mekanisme patahan berupa sesar naik atau turun yang menggerakkan dasar laut secara vertikal.\n\nMeskipun demikian, masyarakat di pesisir yang merasakan gempa kuat atau gempa yang berayun lama tetap wajib melakukan evakuasi mandiri sebagai langkah keselamatan utama.",
                'key_points' => [
                    'Tidak semua gempa bumi memicu tsunami; gempa di daratan jauh dari laut tidak memicu tsunami.',
                    'Gempa laut yang kuat, dangkal, dan bermekanisme patahan vertikal berpotensi tinggi menimbulkan tsunami.',
                    'Gempa kuat atau berlangsung lama di wilayah pesisir adalah peringatan alam pertama untuk segera evakuasi mandiri.',
                ],
                'action_steps' => [
                    'Gunakan prinsip keselamatan: jika berada di pantai/pesisir dan merasakan gempa kuat (sulit berdiri) atau lama, segera evakuasi ke tempat tinggi.',
                    'Periksa pembaruan status peringatan dini resmi dari BMKG setelah berada di jalur atau titik aman.',
                ],
                'things_to_avoid' => [
                    'Jangan menganggap setiap gempa kecil di darat pasti menimbulkan tsunami.',
                    'Sebaliknya, jangan menunggu sirene atau pengumuman resmi jika Anda berada di pesisir dan telah merasakan gempa yang kuat atau berlangsung lama.',
                ],
                'source_reference' => 'BMKG (InaTEWS) & UNESCO-IOC',
                'sort_order' => 3,
            ],
            [
                'title' => 'Mengenali Peringatan Dini Tsunami',
                'slug' => 'mengenali-peringatan-dini-tsunami',
                'difficulty' => 'Dasar',
                'image_path' => 'illustrations/early-warning.svg',
                'summary' => 'Mengenal sistem peringatan dini tsunami Indonesia (InaTEWS), tingkatan status peringatan BMKG, serta kanal informasi resmi.',
                'content' => "Indonesia memiliki Sistem Peringatan Dini Tsunami (InaTEWS) yang dioperasikan oleh BMKG bekerja sama dengan BNPB dan BPBD daerah. Dalam sistem peringatan dini tsunami BMKG, terdapat tingkatan status ancaman:\n\n1. AWAS: Potensi tsunami besar; masyarakat di wilayah pesisir terdampak harus segera melakukan evakuasi menyeluruh ke tempat tinggi/aman.\n2. SIAGA: Potensi tsunami signifikan; masyarakat pesisir harus segera menjauhi pantai dan menuju tempat evakuasi.\n3. WASPADA: Potensi tsunami kecil di pantai; masyarakat diminta menjauhi pantai dan tepian sungai.\n\nInformasi peringatan dini disampaikan melalui sirene tsunami resmi, aplikasi InfoBMKG, situs web resmi BMKG, televisi/radio, serta pengumuman petugas BPBD setempat.",
                'key_points' => [
                    'BMKG adalah lembaga resmi pemerintah yang berwenang mengeluarkan peringatan dini tsunami di Indonesia.',
                    'Tingkatan status peringatan dini tsunami meliputi AWAS, SIAGA, dan WASPADA.',
                    'Sirene tsunami, pengumuman petugas BPBD, dan kanal resmi BMKG harus dipatuhi segera.',
                ],
                'action_steps' => [
                    'Pasang dan pantau kanal resmi BMKG serta simpan kontak BPBD daerah.',
                    'Kenali bunyi sirene peringatan tsunami di lingkungan pesisir Anda.',
                    'Segera lakukan evakuasi saat mendengar sirene atau menerima peringatan dini resmi.',
                ],
                'things_to_avoid' => [
                    'Jangan hanya bergantung pada sirene apabila Anda sudah merasakan gempa kuat atau lama di pesisir (sebab listrik/jaringan bisa terdampak gempa).',
                    'Jangan mempercayai pesan suara atau tangkapan layar peringatan tsunami yang tidak berasal dari kanal resmi BMKG.',
                ],
                'source_reference' => 'BMKG (InaTEWS), BNPB & BPBD Kota Padang',
                'sort_order' => 4,
            ],
            [
                'title' => 'Tanda Alam yang Dapat Mengindikasikan Tsunami',
                'slug' => 'tanda-alam-yang-dapat-mengindikasikan-tsunami',
                'difficulty' => 'Dasar',
                'image_path' => 'illustrations/natural-signs-tsunami.svg',
                'summary' => 'Memahami tanda-tanda alam sebelum tsunami tiba agar masyarakat pesisir dapat melakukan evakuasi mandiri secepat mungkin.',
                'content' => "Alam memberikan tanda bahaya yang sangat penting sebelum gelombang tsunami mencapai garis pantai. Tanda alam utama yang wajib dikenali oleh setiap warga dan wisatawan di pesisir adalah:\n\n1. Gempa Bumi Kuat atau Lama (Feel): Guncangan gempa yang terasa kuat hingga membuat sulit berdiri, atau guncangan mengayun yang berlangsung lama.\n2. Perubahan Permukaan Air Laut (See): Air laut di pantai tiba-tiba surut secara cepat dan tidak biasa hingga memperlihatkan dasar laut atau terumbu karang, atau tampak gelombang gelap memanjang di cakrawala.\n3. Suara Gemuruh dari Arah Laut (Hear): Terdengar suara gemuruh keras dari arah laut menyerupai suara kereta api atau pesawat terbang.\n\nJika merasakan atau melihat SALAH SATU saja dari tanda alam tersebut, segera lari/bergerak ke tempat tinggi tanpa menunggu peringatan resmi!",
                'key_points' => [
                    'Tiga tanda alam utama: Gempa kuat/lama, air laut surut tiba-tiba secara tidak biasa, dan suara gemuruh dari arah laut.',
                    'Tanda alam adalah sinyal evakuasi mandiri paling cepat bagi warga di pesisir dekat sumber gempa.',
                    'Tidak semua tsunami diawali air surut; terkadang gelombang langsung naik dengan cepat.',
                ],
                'action_steps' => [
                    'Segera tinggalkan pantai begitu guncangan gempa kuat atau lama mereda.',
                    'Ajak orang-orang di sekitar pantai untuk langsung bergerak menjauhi laut menuju dataran tinggi atau gedung evakuasi vertikal.',
                ],
                'things_to_avoid' => [
                    'JANGAN PERNAH mendekati pantai untuk menonton, memotret, atau mengambil ikan saat air laut surut tiba-tiba.',
                    'Jangan menunggu sirene berbunyi apabila tanda alam tsunami sudah dirasakan atau terlihat.',
                ],
                'source_reference' => 'UNESCO-IOC, BMKG & BNPB',
                'sort_order' => 5,
            ],
            [
                'title' => 'Wilayah yang Berpotensi Terdampak Tsunami',
                'slug' => 'wilayah-yang-berpotensi-terdampak-tsunami',
                'difficulty' => 'Menengah',
                'image_path' => 'illustrations/coastal-zones.svg',
                'summary' => 'Mengenali karakteristik kawasan pesisir, muara sungai, dan teluk yang memiliki kerentanan terhadap limpasan gelombang tsunami.',
                'content' => "Wilayah yang paling berpotensi terdampak tsunami adalah kawasan pesisir pantai yang landai dan berhadapan dengan zona sumber gempa laut, serta area di sekitar muara sungai dan teluk.\n\nGelombang tsunami dapat masuk jauh ke daratan melalui alur sungai yang bermuara ke laut. Di Kota Padang, pemerintah daerah dan BPBD telah memetakan zona bahaya di kawasan pesisir barat, zona waspada di bagian tengah kota, serta zona aman di dataran tinggi dan koridor timur (Bypass), dilengkapi dengan rambu jalur evakuasi serta gedung shelter evakuasi vertikal.",
                'key_points' => [
                    'Pantai landai, teluk sempit, dan muara sungai memiliki risiko limpasan gelombang tsunami yang lebih tinggi.',
                    'Gelombang tsunami dapat merambat masuk melalui aliran sungai yang terhubung ke laut.',
                    'Penentuan zona bahaya, waspada, dan aman harus mengacu pada peta resmi BPBD dan instansi berwenang.',
                ],
                'action_steps' => [
                    'Periksa Peta Evakuasi di aplikasi SiagaBencana untuk mengenali zona risiko dan titik evakuasi terverifikasi di Kota Padang.',
                    'Perhatikan rambu jalur evakuasi tsunami saat beraktivitas atau berkunjung ke kawasan pantai.',
                ],
                'things_to_avoid' => [
                    'Jangan menyatakan suatu lokasi di dekat pantai aman tanpa dasar peta dan arahan resmi pihak berwenang.',
                    'Jangan berlari menyusuri tepian sungai atau jembatan muara saat evakuasi tsunami.',
                ],
                'source_reference' => 'BPBD Kota Padang, BNPB & BMKG',
                'sort_order' => 6,
            ],
            [
                'title' => 'Persiapan Sebelum Tsunami',
                'slug' => 'persiapan-sebelum-tsunami',
                'difficulty' => 'Menengah',
                'image_path' => 'illustrations/tsunami-prep.svg',
                'summary' => 'Rencana kesiapsiagaan keluarga dan komunitas di wilayah pesisir sebelum bencana tsunami terjadi.',
                'content' => "Masyarakat yang tinggal, bersekolah, atau bekerja di wilayah pesisir perlu memiliki rencana kesiapsiagaan tsunami yang jelas dan telah dilatihkan bersama keluarga.\n\nPersiapan meliputi: mengenali peta zona rawan tsunami, menghafal minimal dua rute jalur evakuasi menuju tempat tinggi atau shelter evakuasi vertikal (TES/TEA), menyiapkan Tas Siaga Bencana di dekat pintu keluar, serta menyepakati titik temu keluarga apabila anggota keluarga sedang berada di lokasi berbeda saat bencana terjadi.",
                'key_points' => [
                    'Kenali rute tercepat menuju dataran tinggi (Zona Aman) atau Gedung Evakuasi Vertikal yang ditetapkan pihak berwenang.',
                    'Latih waktu tempuh berjalan kaki atau berlari cepat dari rumah menuju titik evakuasi.',
                    'Siapkan Tas Siaga Bencana yang mudah dibawa saat evakuasi mandiri.',
                ],
                'action_steps' => [
                    'Diskusikan rencana evakuasi tsunami bersama seluruh anggota keluarga di rumah.',
                    'Pelajari rambu-rambu jalur evakuasi tsunami di lingkungan tempat tinggal dan sekolah.',
                    'Identifikasi anggota keluarga rentan (balita, lansia, disabilitas) dan tentukan siapa yang mendampingi mereka saat evakuasi.',
                ],
                'things_to_avoid' => [
                    'Jangan menunda menyusun rencana evakuasi keluarga.',
                    'Jangan merusak atau menghalangi rambu petunjuk jalur evakuasi di lingkungan masyarakat.',
                ],
                'source_reference' => 'BNPB, BPBD Kota Padang & UNESCO-IOC',
                'sort_order' => 7,
            ],
            [
                'title' => 'Tindakan Saat Mendapat Peringatan Tsunami',
                'slug' => 'tindakan-saat-mendapat-peringatan-tsunami',
                'difficulty' => 'Dasar',
                'image_path' => 'illustrations/tsunami-alert-action.svg',
                'summary' => 'Langkah cepat, tepat, dan terkoordinasi ketika merasakan tanda alam tsunami atau menerima peringatan dini resmi.',
                'content' => "Ketika Anda merasakan gempa kuat/lama di wilayah pesisir ATAU mendengar sirene serta peringatan dini resmi tsunami dari BMKG/BPBD, tindakan utama adalah SEGERA EVAKUASI.\n\nSetelah guncangan gempa berhenti (sehingga Anda bisa berjalan/berlari), langsung ambil Tas Siaga Bencana bila berada di dekat Anda, lalu bergerak cepat meninggalkan kawasan pantai menuju tempat yang lebih tinggi atau lokasi evakuasi yang telah ditetapkan. Beritahu tetangga di sekitar sambil terus bergerak menuju tempat aman.",
                'key_points' => [
                    'Waktu sangat berharga; lakukan evakuasi segera setelah guncangan gempa berhenti.',
                    'Utamakan keselamatan nyawa di atas harta benda.',
                    'Ikuti rambu jalur evakuasi dan instruksi petugas di lapangan.',
                ],
                'action_steps' => [
                    'Lindungi diri saat gempa berlangsung (Drop, Cover, Hold On), lalu segera keluar begitu guncangan mereda.',
                    'Bergerak cepat ke arah daratan yang lebih tinggi (di Kota Padang bergerak ke arah Timur menjauhi pantai) atau ke gedung evakuasi vertikal terdekat jika waktu sangat terbatas.',
                    'Bantu anak-anak, ibu hamil, lansia, dan penyandang disabilitas di sekitar Anda.',
                ],
                'things_to_avoid' => [
                    'Jangan menunggu pengumuman resmi apabila Anda berada di pesisir dan sudah merasakan gempa kuat atau melihat air laut surut.',
                    'Jangan menghabiskan waktu untuk mengemas barang-barang rumah tangga yang berat.',
                ],
                'source_reference' => 'BMKG, BNPB & Basarnas',
                'sort_order' => 8,
            ],
            [
                'title' => 'Cara Melakukan Evakuasi ke Tempat yang Lebih Tinggi atau Lokasi Aman',
                'slug' => 'cara-melakukan-evakuasi-ke-tempat-yang-lebih-tinggi-atau-lokasi-aman',
                'difficulty' => 'Dasar',
                'image_path' => 'illustrations/high-ground-evacuation.svg',
                'summary' => 'Panduan evakuasi horizontal menuju dataran tinggi dan evakuasi vertikal menuju gedung shelter resmi secara aman.',
                'content' => "Evakuasi tsunami dapat dilakukan dengan dua cara sesuai kondisi waktu dan lokasi:\n\n1. Evakuasi Horizontal: Bergerak menjauhi garis pantai menuju perbukitan, dataran tinggi, atau Zona Aman yang ditetapkan pemerintah daerah (misalnya ke arah Timur menuju kawasan Bypass/dataran tinggi di Kota Padang).\n2. Evakuasi Vertikal: Jika jarak ke dataran tinggi terlalu jauh dan waktu sangat sempit, naiklah ke lantai atas (minimal lantai 3 atau lebih tinggi) pada gedung kokoh tahan gempa atau Tempat Evakuasi Sementara (TES/Shelter Tsunami) yang telah ditetapkan oleh pihak berwenang.\n\nUtamakan berjalan cepat atau berlari (evakuasi jalan kaki) untuk menghindari kemacetan total akibat kendaraan bermotor di jalur evakuasi.",
                'key_points' => [
                    'Evakuasi jalan kaki sangat dianjurkan agar tidak terjebak kemacetan kendaraan di jalur evakuasi.',
                    'Evakuasi vertikal ke lantai atas gedung shelter kokoh adalah alternatif penyelamatan jiwa jika dataran tinggi tidak sempat dijangkau.',
                    'Jauhi alur sungai dan jembatan dekat muara saat bergerak menuju tempat tinggi.',
                ],
                'action_steps' => [
                    'Ikuti marka dan rambu jalur evakuasi tsunami menuju titik kumpul atau shelter resmi.',
                    'Jika berada di perahu/kapal di tengah laut dalam dan mendapat peringatan tsunami, arahkan kapal lebih jauh ke laut dalam dan jangan merapat ke pelabuhan pantai.',
                    'Tetap berada di lokasi evakuasi yang aman sampai ada pernyataan resmi kondisi aman.',
                ],
                'things_to_avoid' => [
                    'Jangan menggunakan mobil pribadi jika berpotensi menimbulkan kemacetan yang mengunci jalur evakuasi warga.',
                    'Jangan memilih bangunan tua atau bangunan yang sudah rusak akibat gempa sebagai tempat evakuasi vertikal.',
                ],
                'source_reference' => 'BNPB, BPBD Kota Padang & UNESCO-IOC',
                'sort_order' => 9,
            ],
            [
                'title' => 'Hal yang Tidak Boleh Dilakukan Saat Evakuasi Tsunami',
                'slug' => 'hal-yang-tidak-boleh-dilakukan-saat-evakuasi-tsunami',
                'difficulty' => 'Menengah',
                'image_path' => 'illustrations/tsunami-donts.svg',
                'summary' => 'Daftar kesalahan fatal yang wajib dihindari oleh masyarakat saat terjadi ancaman dan proses evakuasi tsunami.',
                'content' => "Pengalaman dari berbagai bencana tsunami menunjukkan bahwa banyak korban jiwa jatuh karena tindakan yang keliru saat waktu kritis evakuasi.\n\nMemahami hal-hal yang DILARANG keras dilakukan saat ancaman tsunami akan melindungi Anda dan keluarga dari bahaya fatal. Keselamatan jiwa adalah prioritas mutlak yang tidak boleh dikompromikan oleh rasa penasaran atau keinginan menyelamatkan harta benda.",
                'key_points' => [
                    'Rasa penasaran ingin melihat laut surut adalah salah satu penyebab korban jiwa paling fatal.',
                    'Kemacetan akibat penggunaan kendaraan secara panik dapat menghambat ribuan warga yang sedang evakuasi.',
                    'Kembali ke rumah sebelum peringatan dini resmi berakhir sangat berbahaya karena gelombang susulan.',
                ],
                'action_steps' => [
                    'Ingatkan anggota keluarga dan warga sekitar untuk langsung menjauhi pantai tanpa menoleh atau berhenti merekam video di tepi laut.',
                    'Patuhi arahan petugas BPBD, SAR, TNI/Polri, dan relawan kebencanaan di jalur evakuasi.',
                ],
                'things_to_avoid' => [
                    'DILARANG mendekati pantai untuk melihat air laut yang surut atau mengambil ikan.',
                    'DILARANG berhenti di tepi pantai atau jembatan muara sungai untuk mengambil foto/video.',
                    'DILARANG kembali ke rumah untuk mengambil harta benda saat peringatan tsunami masih aktif.',
                    'DILARANG menyebarkan kabar bohong atau berteriak memicu kepanikan tidak terarah.',
                ],
                'source_reference' => 'BNPB, BMKG & Basarnas',
                'sort_order' => 10,
            ],
            [
                'title' => 'Tindakan Setelah Tsunami',
                'slug' => 'tindakan-setelah-tsunami',
                'difficulty' => 'Lanjutan',
                'image_path' => 'illustrations/post-tsunami.svg',
                'summary' => 'Panduan keselamatan di lokasi pengungsian, penanganan kesehatan darurat, dan kewaspadaan bahaya lingkungan pascatsunami.',
                'content' => "Setelah gelombang tsunami terjadi, kondisi di wilayah terdampak sering kali dipenuhi genangan air bercampur lumpur, puing bangunan, pecahan kaca, kabel listrik yang terputus, dan potensi pencemaran air bersih.\n\nTetaplah berada di lokasi evakuasi yang aman dan ikuti koordinasi posko penanggulangan bencana (BPBD, Basarnas, PMI, dan tenaga medis). Periksa kondisi kesehatan keluarga, gunakan air bersih hanya dari sumber yang terjamin, dan bantu proses pendataan di posko pengungsian.",
                'key_points' => [
                    'Gelombang tsunami terdiri dari beberapa gelombang; tetap di tempat tinggi hingga otoritas resmi menyatakan ancaman berakhir.',
                    'Genangan air pascatsunami dapat menyembunyikan benda tajam, puing berbahaya, dan aliran listrik.',
                    'Kesehatan, air bersih, dan sanitasi di pengungsian harus dijaga bersama.',
                ],
                'action_steps' => [
                    'Pastikan seluruh anggota keluarga berada di titik pengungsian dan laporkan kepada petugas posko jika ada anggota keluarga yang terpisah.',
                    'Dapatkan perawatan medis di pos kesehatan jika mengalami luka terbuka agar tidak terjadi infeksi.',
                    'Ikuti arahan petugas terkait distribusi logistik, air bersih, dan informasi lanjutan.',
                ],
                'things_to_avoid' => [
                    'Jangan mengonsumsi makanan atau air yang telah tercemar genangan tsunami.',
                    'Jangan memasuki bangunan yang terendam atau rusak sebelum diperiksa kelayakan strukturnya oleh petugas.',
                ],
                'source_reference' => 'BNPB, Basarnas & Kementerian Kesehatan / PMI',
                'sort_order' => 11,
            ],
            [
                'title' => 'Kembali ke Wilayah Pesisir Setelah Peringatan Berakhir',
                'slug' => 'kembali-ke-wilayah-pesisir-setelah-peringatan-berakhir',
                'difficulty' => 'Lanjutan',
                'image_path' => 'illustrations/safe-return-coast.svg',
                'summary' => 'Prosedur resmi dan syarat keselamatan sebelum masyarakat diperbolehkan kembali dari tempat evakuasi menuju kawasan pesisir.',
                'content' => "Kapan masyarakat boleh turun dari bukit/tempat tinggi atau keluar dari shelter evakuasi vertikal untuk kembali ke wilayah pesisir? Jawabannya hanya satu: SETELAH ADA PENGUMUMAN RESMI PENGAKHIRAN PERINGATAN DINI TSUNAMI dari BMKG dan arahan aman dari BPBD/Pemerintah Daerah.\n\nJeda antara gelombang tsunami pertama dan gelombang berikutnya dapat berlangsung mulai dari beberapa menit hingga lebih dari satu jam. Oleh karena itu, meskipun laut terlihat tenang setelah gelombang pertama, bahaya belum tentu selesai sampai BMKG secara resmi menyatakan peringatan dini tsunami telah berakhir.",
                'key_points' => [
                    'Hanya BMKG dan otoritas resmi pemerintah/BPBD yang berwenang menyatakan peringatan dini tsunami telah berakhir.',
                    'Jeda antargelombang tsunami bisa cukup lama, sehingga kondisi laut yang tampak tenang sesaat dapat menipu.',
                    'Saat kembali ke rumah, tetap waspadai kerusakan bangunan, kabel listrik, dan kebocoran gas.',
                ],
                'action_steps' => [
                    'Tunggu pengumuman resmi "Peringatan Dini Tsunami dinyatakan telah berakhir" dari BMKG dan instruksi petugas di lapangan.',
                    'Kembalilah secara tertib pada siang hari atau saat penerangan memadai dengan menggunakan alas kaki pelindung.',
                    'Periksa lingkungan sekitar rumah dengan hati-hati dan laporkan temuan bahaya kepada petugas BPBD/SAR.',
                ],
                'things_to_avoid' => [
                    'Jangan pernah kembali ke wilayah pesisir hanya karena merasa waktu sudah cukup lama atau melihat orang lain turun lebih dulu tanpa pengumuman resmi.',
                    'Jangan langsung menyalakan listrik utama di rumah yang sempat terendam air sebelum instalasinya diperiksa.',
                ],
                'source_reference' => 'BMKG (InaTEWS), BNPB & BPBD Kota Padang',
                'sort_order' => 12,
            ],
        ];
    }
}

