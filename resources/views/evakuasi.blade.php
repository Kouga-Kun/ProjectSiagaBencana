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
    <h2 style="margin-top: 0; color: #1e40af;">📍 Peta Evakuasi Kota Padang</h2>
    <p style="margin-bottom: 15px; color: #475569;">
        Titik hijau pada peta menunjukkan lokasi instansi resmi, rumah sakit, dan titik kumpul berdasarkan data dari instansi terkait.
    </p>
    @include('partials.evacuation-map')
</div>

<!-- STYLE KHUSUS UNTUK KARTU LANGKAH EVAKUASI -->
<style>
    .evac-steps-header { margin-top: 40px; margin-bottom: 24px; color: #123b63; border-bottom: 2px solid #e2e8f0; padding-bottom: 12px; text-align: center; }
    
    /* Menggunakan Flexbox agar sisa kartu di baris bawah otomatis ke tengah */
    .step-grid { display: flex; flex-wrap: wrap; justify-content: center; gap: 24px; margin-bottom: 40px; }
    
    /* Membatasi lebar agar muat 3 sejajar (layar besar), atau 2 sejajar (layar sedang) */
    .step-card { 
        flex: 0 1 calc(33.333% - 16px); 
        min-width: 320px; 
        display: flex; align-items: flex-start; gap: 16px; background: white; padding: 24px; border-radius: 12px; border: 1px solid #e2e8f0; box-shadow: 0 4px 6px rgba(0,0,0,0.02); transition: transform 0.2s ease, border-color 0.2s ease; 
    }
    .step-card:hover { transform: translateY(-4px); border-color: #93c5fd; box-shadow: 0 8px 15px rgba(0,0,0,0.05); }
    
    /* flex-shrink: 0 mencegah ikon menjadi lonjong/gepeng saat teks di sebelahnya panjang */
    .step-icon { flex-shrink: 0; width: 52px; height: 52px; background: #eff6ff; color: #1d4ed8; border-radius: 50%; display: flex; justify-content: center; align-items: center; font-weight: bold; font-size: 1.4rem; }
    .step-icon.danger { background: #fef2f2; color: #dc2626; }
    
    .step-content h4 { margin: 0 0 8px 0; color: #0f172a; font-size: 1.15rem; line-height: 1.4; }
    .step-content p { margin: 0; color: #475569; font-size: 1.05rem; line-height: 1.6; text-align: justify; }

    /* Jika dibuka di HP, otomatis susun ke bawah 1 kolom penuh */
    @media (max-width: 768px) {
        .step-card { flex: 1 1 100%; }
        .evac-steps-header { text-align: left; }
    }
</style>
<h2 class="evac-steps-header">Langkah Kritis Saat Evakuasi Darurat</h2>
<div class="step-grid">
    
    <div class="step-card">
        <div class="step-icon danger">⏱️</div>
        <div class="step-content">
            <h4>1. Kenali Tanda dan Segera Evakuasi</h4>
            <p>Jika merasakan guncangan kuat atau gempa yang terasa lemah tetapi berlangsung lama, segera lakukan evakuasi mandiri dari pantai tanpa menunggu peringatan atau perintah evakuasi.</p>
        </div>
    </div>

    <div class="step-card">
        <div class="step-icon">🎒</div>
        <div class="step-content">
            <h4>2. Bawa Tas Siaga Saja</h4>
            <p>Segera bawa Tas Siaga Bencana (dokumen penting, obat pribadi, senter, dan pakaian secukupnya). <b>Jangan membuang waktu</b> untuk menyelamatkan harta benda berat seperti kendaraan atau perabotan.</p>
        </div>
    </div>

    <div class="step-card">
        <div class="step-icon">🏃</div>
        <div class="step-content">
            <h4>3. Ikuti Arahan Evakuasi Resmi</h4>
            <p>Ikuti petunjuk petugas dan rambu evakuasi resmi setempat. Jika berada di pesisir dan merasakan tanda alami tsunami, segera menjauh dari pantai menuju tempat tinggi atau ke arah daratan. Hindari lembah dan alur sungai.</p>
        </div>
    </div>

    <div class="step-card">
        <div class="step-icon">🤝</div>
        <div class="step-content">
            <h4>4. Prioritaskan Kelompok Rentan</h4>
            <p>Bantu anak-anak, ibu hamil, lansia, dan penyandang disabilitas yang ada di sekitar Anda untuk bergerak bersama menuju titik kumpul evakuasi.</p>
        </div>
    </div>

    <div class="step-card">
        <div class="step-icon danger">🚫</div>
        <div class="step-content">
            <h4>5. Jangan Pernah Kembali Dulu</h4>
            <p>Meskipun air laut terlihat surut atau keadaan terasa sepi, <b>jangan pernah kembali</b> ke zona bahaya sebelum ada pengumuman resmi dari BMKG atau Pemerintah bahwa potensi tsunami benar-benar berakhir.</p>
        </div>
    </div>

</div>

@endsection
