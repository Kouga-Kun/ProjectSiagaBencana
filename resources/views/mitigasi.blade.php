
@extends('layouts.app')

@section('title', 'Mitigasi Bencana - SiagaBencana')

@section('content')
<style>
    .page-title { color: #123b63; margin-bottom: 8px; }
    .description { color: #64748b; margin-bottom: 24px; }
    .mitigation-card { background: white; padding: 22px; border-radius: 12px; margin-bottom: 20px; box-shadow: 0 3px 12px #0000000a; }
    .mitigation-card h2 { color: #123b63; margin-top: 0; }
    .checklist { display: grid; grid-template-columns: repeat(auto-fit, minmax(230px, 1fr)); gap: 12px; }
    .check-item { background: #f4f7fb; padding: 12px; border-radius: 8px; }
</style>

<h1 class="page-title">Edukasi dan Mitigasi Bencana</h1>
<p class="description">
    Pelajari langkah mengurangi risiko dan mempersiapkan diri
    sebelum, saat, dan setelah bencana.
</p>

<section class="mitigation-card">
    <h2>🌊 Kenali Risiko Tsunami</h2>
    <p>
        Kota Padang merupakan wilayah pesisir yang perlu memperhatikan
        risiko gempa bumi dan tsunami.
    </p>
    <ul>
        <li>Kenali tanda peringatan dini dan jalur evakuasi tsunami.</li>
        <li>Jika merasakan gempa kuat atau lama di wilayah pesisir,
        segera menuju tempat tinggi atau lokasi evakuasi sesuai panduan resmi.</li>
        <li>Jangan menunggu air laut surut atau menunggu konfirmasi
        jika tanda alam mengharuskan evakuasi segera.</li>
        <li>Jangan kembali ke pantai sebelum dinyatakan aman oleh petugas.</li>
    </ul>
</section>

<section class="mitigation-card">
    <h2>🛡️ Prosedur Keselamatan</h2>
    <h3>Sebelum bencana</h3>
    <ul>
        <li>Diskusikan rencana darurat bersama keluarga.</li>
        <li>Kenali titik kumpul dan jalur evakuasi.</li>
        <li>Simpan nomor kontak darurat.</li>
    </ul>

    <h3>Saat bencana</h3>
    <ul>
        <li>Utamakan keselamatan diri dan keluarga.</li>
        <li>Ikuti instruksi petugas dan peringatan resmi.</li>
        <li>Hindari bangunan atau area yang berpotensi membahayakan.</li>
    </ul>

    <h3>Setelah bencana</h3>
    <ul>
        <li>Waspadai bahaya susulan.</li>
        <li>Periksa kondisi diri dan orang di sekitar jika aman dilakukan.</li>
        <li>Ikuti informasi resmi sebelum kembali ke rumah.</li>
    </ul>
</section>

<section class="mitigation-card">
    <h2>🎒 Checklist Tas Siaga</h2>
    <p>Centang barang yang sudah kamu siapkan.</p>

    <div class="checklist">
        <label class="check-item"><input type="checkbox"> Air minum</label>
        <label class="check-item"><input type="checkbox"> Makanan tahan lama</label>
        <label class="check-item"><input type="checkbox"> Kotak P3K dan obat pribadi</label>
        <label class="check-item"><input type="checkbox"> Senter dan baterai cadangan</label>
        <label class="check-item"><input type="checkbox"> Dokumen penting dalam wadah tahan air</label>
        <label class="check-item"><input type="checkbox"> Ponsel dan pengisi daya</label>
        <label class="check-item"><input type="checkbox"> Pakaian dan perlengkapan kebersihan</label>
        <label class="check-item"><input type="checkbox"> Peluit dan uang tunai</label>
    </div>
</section>
@endsection
