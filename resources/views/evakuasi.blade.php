
@extends('layouts.app')

@section('title', 'Evakuasi - SiagaBencana')

@section('content')
<style>
    .page-title { color: #123b63; margin-bottom: 8px; }
    .description { color: #64748b; margin-bottom: 24px; }
    .cards { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 18px; }
    .card { background: white; padding: 22px; border-radius: 12px; box-shadow: 0 3px 12px #0000000a; }
    .card h3 { margin-top: 0; }
    .safe { border-left: 5px solid #16a34a; }
    .warning { border-left: 5px solid #eab308; }
    .danger { border-left: 5px solid #dc2626; }
    .info-box { background: #eaf3fb; padding: 20px; border-radius: 12px; margin-top: 24px; }
</style>

<h1 class="page-title">Peta dan Informasi Evakuasi</h1>
<p class="description">
    Kenali zona risiko, lokasi pengungsian, dan langkah yang perlu dilakukan
    untuk menyelamatkan diri saat terjadi bencana.
</p>

<div class="cards">
    <div class="card safe">
        <h3>🟢 Zona Aman</h3>
        <p>Area yang ditetapkan sebagai tempat aman berdasarkan informasi
        dan arahan pihak berwenang.</p>
    </div>

    <div class="card warning">
        <h3>🟡 Zona Waspada</h3>
        <p>Area yang memerlukan kewaspadaan. Pantau informasi resmi
        dan siapkan rencana evakuasi.</p>
    </div>

    <div class="card danger">
        <h3>🔴 Zona Bahaya</h3>
        <p>Area berisiko tinggi. Ikuti peringatan resmi dan segera
        lakukan evakuasi apabila diperintahkan.</p>
    </div>
</div>

<div class="info-box">
    <h2>📍 Peta Evakuasi</h2>
    <p>
        Peta interaktif, jalur evakuasi, dan lokasi tempat pengungsian
        akan ditampilkan di bagian ini setelah data lokasi tersedia.
    </p>
    <p><strong>Catatan:</strong> Zona dan jalur resmi harus diverifikasi
    melalui BPBD atau instansi berwenang. Informasi pada halaman ini
    belum merupakan peta evakuasi resmi.</p>
</div>

<div class="card" style="margin-top: 24px;">
    <h2>Langkah Saat Harus Mengungsi</h2>
    <ol>
        <li>Tetap tenang dan pantau informasi resmi.</li>
        <li>Ikuti jalur evakuasi yang ditetapkan petugas.</li>
        <li>Bawa tas siaga dan dokumen penting jika memungkinkan.</li>
        <li>Bantu anak-anak, lansia, dan penyandang disabilitas.</li>
        <li>Jangan kembali ke zona bahaya sebelum dinyatakan aman.</li>
    </ol>
</div>
@endsection
