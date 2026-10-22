
@extends('layouts.app')

@section('title', 'Berita - SiagaBencana')

@section('content')
<style>
    .page-title { color: #123b63; margin-bottom: 8px; }
    .description { color: #64748b; margin-bottom: 24px; }
    .news-list { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; }
    .news-card { background: white; padding: 22px; border-radius: 12px; box-shadow: 0 3px 12px #0000000a; }
    .tag { display: inline-block; background: #eaf3fb; color: #123b63; padding: 5px 10px; border-radius: 20px; font-size: 12px; }
    .news-card h3 { color: #172033; line-height: 1.5; }
    .news-card p { color: #64748b; line-height: 1.7; }
</style>

<h1 class="page-title">Berita dan Informasi</h1>
<p class="description">
    Dapatkan informasi kebencanaan, edukasi keselamatan, dan pembaruan
    yang relevan bagi masyarakat Kota Padang.
</p>

<div class="news-list">
    <article class="news-card">
        <span class="tag">Kesiapsiagaan</span>
        <h3>Pentingnya Menyiapkan Tas Siaga Bencana</h3>
        <p>
            Tas siaga membantu keluarga membawa kebutuhan penting
            ketika harus meninggalkan rumah dalam keadaan darurat.
        </p>
        <p><small>Konten contoh · Belum dipublikasikan</small></p>
    </article>

    <article class="news-card">
        <span class="tag">Edukasi</span>
        <h3>Mengenali Jalur Evakuasi di Lingkungan Sekitar</h3>
        <p>
            Kenali rute evakuasi dan titik kumpul sebelum bencana terjadi.
            Pastikan seluruh anggota keluarga mengetahui rencana tersebut.
        </p>
        <p><small>Konten contoh · Belum dipublikasikan</small></p>
    </article>

    <article class="news-card">
        <span class="tag">Informasi</span>
        <h3>Pentingnya Memantau Peringatan Bencana Resmi</h3>
        <p>
            Gunakan informasi dari instansi resmi dan hindari menyebarkan
            kabar yang belum terverifikasi.
        </p>
        <p><small>Konten contoh · Belum dipublikasikan</small></p>
    </article>
</div>

<div style="background: white; padding: 22px; border-radius: 12px; margin-top: 24px;">
    <h2>Sumber Informasi Resmi</h2>
    <p>
        Untuk pembaruan bencana, cuaca, dan peringatan dini, periksa
        informasi dari BPBD, BMKG, serta instansi pemerintah terkait.
    </p>
    <p>
        Berita aktual dan fitur pencarian akan ditambahkan setelah
        sistem pengelolaan berita tersedia.
    </p>
</div>
@endsection
