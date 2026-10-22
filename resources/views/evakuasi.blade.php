@extends('layouts.app')

@section('title', 'Evakuasi - SiagaBencana')

@section('content')
<!-- Tambahkan pustaka CSS Leaflet untuk styling peta -->
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY=" crossorigin=""/>

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
    
    /* Styling kontainer peta */
    #evacuationMap { height: 450px; border-radius: 8px; border: 2px solid #cbd5e1; margin-top: 15px; z-index: 1; }
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
    
    <!-- Area tempat peta Leaflet akan muncul -->
    <div id="evacuationMap"></div>
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
            <h4>1. Kenali Tanda & Aturan 20 Menit</h4>
            <p>Jika gempa terasa sangat kuat (hingga sulit berdiri) atau bergetar terus-menerus <b>lebih dari 60 detik</b>, waspada potensi tsunami. Waktu emas untuk menyelamatkan diri hanya sekitar 20 menit.</p>
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
            <h4>3. Ikuti Jalur & Hindari Sungai</h4>
            <p>Bergegaslah menuju Zona Aman atau dataran tinggi mengikuti rambu panah hijau. <b>Sangat penting:</b> Hindari berlari atau berkendara menyusuri pinggiran sungai karena arus tsunami bisa masuk melaluinya.</p>
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

<!-- Tambahkan pustaka JS Leaflet -->
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo=" crossorigin=""></script>

<script>
    document.addEventListener("DOMContentLoaded", function () {
        // 1. Inisialisasi peta (Fokus agak ke tengah agar semua zona terlihat)
        var map = L.map('evacuationMap').setView([-0.9300, 100.3800], 13);

        // 2. Tambahkan lapisan peta dari OpenStreetMap
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            maxZoom: 19,
            attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
        }).addTo(map);

        // ==========================================
        // A. MEMBUAT ZONA RISIKO (MERAH, KUNING, HIJAU)
        // ==========================================
        
        // ZONA BAHAYA (Merah) - Area Pesisir Pantai (Barat)
        var boundsDanger = [[-0.9700, 100.3400], [-0.8900, 100.3600]];
        L.rectangle(boundsDanger, {
            color: '#dc2626', fillColor: '#dc2626', fillOpacity: 0.15, weight: 2
        }).addTo(map).bindPopup('<b>🔴 Zona Bahaya</b><br>Area pesisir pantai. Risiko tinggi hantaman gelombang. Segera evakuasi dari sini!');

        // ZONA WASPADA (Kuning) - Area Tengah kota
        var boundsWarning = [[-0.9700, 100.3600], [-0.8900, 100.3850]];
        L.rectangle(boundsWarning, {
            color: '#eab308', fillColor: '#eab308', fillOpacity: 0.15, weight: 2
        }).addTo(map).bindPopup('<b>🟡 Zona Waspada</b><br>Area tengah kota. Tetap waspada dan ikuti jalur evakuasi ke arah Timur.');

        // ZONA AMAN (Hijau) - Area Timur (Bypass / Dataran Tinggi)
        var boundsSafe = [[-0.9700, 100.3850], [-0.8900, 100.4300]];
        L.rectangle(boundsSafe, {
            color: '#16a34a', fillColor: '#16a34a', fillOpacity: 0.15, weight: 2
        }).addTo(map).bindPopup('<b>🟢 Zona Aman</b><br>Area Bypass dan dataran tinggi. Lokasi pengungsian akhir.');


        // ==========================================
        // B. MEMBUAT JALUR EVAKUASI (GARIS MERAH)
        // ==========================================
        // Mengikuti instruksi PDF: "Segera Menuju Garis Merah" menjauhi pantai
        
        var routeStyle = { color: 'red', weight: 4, dashArray: '8, 8', opacity: 0.8 };

        // Jalur 1: Dari Pantai Taplau menuju Bypass (Arah Khatib Sulaiman / Gn. Pangilun)
        var route1 = [ [-0.9250, 100.3520], [-0.9250, 100.3680], [-0.9168, 100.4113] ];
        L.polyline(route1, routeStyle).addTo(map)
         .bindPopup('<b>Jalur Evakuasi Utara</b><br>Mengarah ke Posko Utama BPBD Bypass.');

        // Jalur 2: Dari area Purus/Veteran menuju arah Timur (Kampus/Bypass)
        var route2 = [ [-0.9450, 100.3550], [-0.9450, 100.3750], [-0.9450, 100.4100] ];
        L.polyline(route2, routeStyle).addTo(map)
         .bindPopup('<b>Jalur Evakuasi Tengah</b><br>Ikuti jalan utama ke arah Timur menjauhi garis pantai.');


        // ==========================================
        // C. MENAMBAHKAN TITIK KOORDINAT (MARKER)
        // ==========================================
        
        var safeIcon = L.icon({
            iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-green.png',
            shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/0.7.7/images/marker-shadow.png',
            iconSize: [25, 41], iconAnchor: [12, 41], popupAnchor: [1, -34], shadowSize: [41, 41]
        });

        var evacuationPoints = [
            { name: "Kantor BPBD Kota Padang", lat: -0.9168, lng: 100.4113, desc: "Pusat Komando (Zona Aman)" },
            { name: "RSUP Dr. M. Djamil", lat: -0.9429, lng: 100.3621, desc: "Layanan Medis Darurat (Zona Waspada)" },
            { name: "Kantor Gubernur Sumbar", lat: -0.9238, lng: 100.3624, desc: "Titik Kumpul Sementara" },
            { name: "Polresta Padang", lat: -0.9483, lng: 100.3636, desc: "Pusat Keamanan" }
        ];

        evacuationPoints.forEach(function(point) {
            var marker = L.marker([point.lat, point.lng], {icon: safeIcon}).addTo(map);
            marker.bindPopup(`<strong>${point.name}</strong><br>${point.desc}`);
        });
    });
</script>
@endsection