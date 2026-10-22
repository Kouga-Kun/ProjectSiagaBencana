@extends('layouts.app')

@section('title', 'Berita - SiagaBencana')

@section('content')
<style>
    .page-header { margin-bottom: 24px; }
    .page-title { color: var(--primary-color); margin-bottom: 8px; font-size: 28px; }
    .page-desc { color: var(--text-muted); font-size: 16px; line-height: 1.6; max-width: 650px; }

    /* =========================================
       KARTU HEADLINE UTAMA
       ========================================= */
    .headline-card {
        background: var(--bg-card);
        border-radius: 12px;
        overflow: hidden;
        box-shadow: 0 4px 12px rgba(0,0,0,0.04);
        border: 1px solid var(--border-color);
        margin-bottom: 40px;
        display: flex;
        flex-direction: column;
        transition: transform 0.2s ease, box-shadow 0.2s ease;
    }
    .headline-card:hover { 
        transform: translateY(-4px); 
        box-shadow: 0 12px 20px rgba(0,0,0,0.08); 
    }
    
    .headline-img {
        width: 100%;
        height: 250px;
        /* Menggunakan gambar placeholder dari Unsplash bertema badai laut */
        background-image: url('https://images.unsplash.com/photo-1527482797697-8795b05a13fe?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80'); 
        background-size: cover;
        background-position: center;
        position: relative;
    }
    
    .headline-badge {
        position: absolute;
        top: 16px;
        left: 16px;
        background: var(--color-danger);
        color: white;
        padding: 6px 14px;
        border-radius: 6px;
        font-weight: bold;
        font-size: 14px;
        letter-spacing: 0.5px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.2);
    }
    
    .headline-content { padding: 24px; }
    .headline-title { margin: 0 0 12px 0; font-size: 24px; color: var(--text-dark); line-height: 1.3; }
    .headline-date { font-size: 14px; color: var(--text-muted); margin-bottom: 12px; display: block; font-weight: 500; }
    .headline-excerpt { color: var(--text-muted); line-height: 1.6; margin-bottom: 24px; }
    
    .btn-read { 
        display: inline-block; padding: 10px 20px; 
        background: var(--primary-color); color: white; 
        border-radius: 6px; text-decoration: none; 
        font-weight: 600; transition: background 0.2s; 
    }
    .btn-read:hover { background: var(--primary-hover); color: white; text-decoration: none; }

    /* =========================================
       GRID BERITA TERKINI
       ========================================= */
    .news-section-title { 
        font-size: 20px; color: var(--text-dark); 
        margin-bottom: 20px; border-bottom: 2px solid var(--border-color); 
        padding-bottom: 12px; 
    }
    .news-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
        gap: 24px;
    }
    .news-card {
        background: var(--bg-card);
        border-radius: 10px;
        border: 1px solid var(--border-color);
        overflow: hidden;
        display: flex;
        flex-direction: column;
        transition: box-shadow 0.2s ease, transform 0.2s ease;
    }
    .news-card:hover { 
        box-shadow: 0 8px 15px rgba(0,0,0,0.06); 
        transform: translateY(-3px);
    }
    .news-img { height: 180px; background-color: #e2e8f0; background-size: cover; background-position: center; }
    .news-content { padding: 20px; flex: 1; display: flex; flex-direction: column; }
    .news-category { font-size: 12px; font-weight: bold; color: var(--color-warning); text-transform: uppercase; margin-bottom: 8px; }
    .news-title { font-size: 17px; margin: 0 0 12px 0; color: var(--text-dark); line-height: 1.4; }
    .news-date { font-size: 13px; color: var(--text-muted); margin-top: auto; }
    
    /* Layout Desktop: Headline memanjang ke samping */
    @media (min-width: 768px) {
        .headline-card { flex-direction: row; }
        .headline-img { width: 55%; height: auto; min-height: 320px; }
        .headline-content { width: 45%; padding: 40px; display: flex; flex-direction: column; justify-content: center; }
    }
</style>

<div class="page-header">
    <h1 class="page-title">Berita & Info Terkini</h1>
    <p class="page-desc">Dapatkan pembaruan terbaru mengenai peringatan cuaca, kondisi darurat, dan langkah penanganan bencana dari instansi resmi di wilayah Sumatera Barat.</p>
</div>

<!-- HEADLINE SECTION -->
<article class="headline-card">
    <div class="headline-img">
        <span class="headline-badge">HEADLINE</span>
    </div>
    <div class="headline-content">
        <span class="headline-date">23 Oktober 2026 • 14:30 WIB</span>
        <h2 class="headline-title">Peringatan Dini Cuaca Ekstrem di Pesisir Pantai Padang</h2>
        <p class="headline-excerpt">BMKG merilis peringatan dini terkait potensi angin kencang dan gelombang pasang yang diperkirakan melanda pesisir barat Sumatera. Nelayan dan warga pesisir diimbau untuk tidak beraktivitas di laut hingga kondisi dinyatakan aman.</p>
        <div>
            <a href="#" class="btn-read">Baca Selengkapnya →</a>
        </div>
    </div>
</article>

<!-- INFO TERKINI SECTION -->
<h3 class="news-section-title">Info Terkini</h3>
<div class="news-grid">
    
    <!-- Berita 1 -->
    <article class="news-card">
        <div class="news-img" style="background-image: url('https://images.unsplash.com/photo-1605814511995-10332822a106?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80');"></div>
        <div class="news-content">
            <span class="news-category" style="color: var(--color-danger);">INFO GEMPA</span>
            <h4 class="news-title">Update Penanganan Dampak Gempa Bumi di Sektor 1 Padang</h4>
            <span class="news-date">23 Oktober 2026 • 10:15 WIB</span>
        </div>
    </article>

    <!-- Berita 2 -->
    <article class="news-card">
        <div class="news-img" style="background-image: url('https://images.unsplash.com/photo-1542838321-419b4b0ed183?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80');"></div>
        <div class="news-content">
            <span class="news-category" style="color: var(--color-danger);">INFO GEMPA</span>
            <h4 class="news-title">Update Penanganan Dampak Gempa Bumi di Sektor 2 Padang</h4>
            <span class="news-date">22 Oktober 2026 • 18:40 WIB</span>
        </div>
    </article>

    <!-- Berita 3 -->
    <article class="news-card">
        <div class="news-img" style="background-image: url('https://images.unsplash.com/photo-1603597384797-15206016e78f?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80');"></div>
        <div class="news-content">
            <span class="news-category" style="color: var(--color-warning);">WASPADA</span>
            <h4 class="news-title">Erupsi Gunung Marapi, Warga Sumatera Barat Diharapkan Waspada</h4>
            <span class="news-date">21 Oktober 2026 • 09:00 WIB</span>
        </div>
    </article>

    <!-- Berita 4 -->
    <article class="news-card">
        <div class="news-img" style="background-image: url('https://images.unsplash.com/photo-1542099981-b51fb0d31ff2?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80');"></div>
        <div class="news-content">
            <span class="news-category" style="color: var(--primary-color);">INFO BANJIR</span>
            <h4 class="news-title">Banjir Bandang di Pesisir Selatan, Akses Jalan Lintas Sumatera Terputus</h4>
            <span class="news-date">20 Oktober 2026 • 14:20 WIB</span>
        </div>
    </article>

    <!-- Berita 5 -->
    <article class="news-card">
        <div class="news-img" style="background-image: url('https://images.unsplash.com/photo-1534274988757-a28bf1a57c17?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80');"></div>
        <div class="news-content">
            <span class="news-category" style="color: var(--color-warning);">CUACA BURUK</span>
            <h4 class="news-title">BMKG Prediksi Hujan Lebat Disertai Petir di Wilayah Padang Pariaman</h4>
            <span class="news-date">19 Oktober 2026 • 07:30 WIB</span>
        </div>
    </article>

    <!-- Berita 6 -->
    <article class="news-card">
        <div class="news-img" style="background-image: url('https://images.unsplash.com/photo-1593113630400-ea4288922497?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80');"></div>
        <div class="news-content">
            <span class="news-category" style="color: var(--color-safe);">BANTUAN SOSIAL</span>
            <h4 class="news-title">Distribusi Logistik dan Obat-obatan Tiba di Posko Pengungsian Bypass</h4>
            <span class="news-date">18 Oktober 2026 • 16:45 WIB</span>
        </div>
    </article>

    <!-- Berita 7 -->
    <article class="news-card">
        <div class="news-img" style="background-image: url('https://images.unsplash.com/photo-1623080775986-13a893049f50?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80');"></div>
        <div class="news-content">
            <span class="news-category" style="color: var(--color-danger);">LALU LINTAS</span>
            <h4 class="news-title">Tanah Longsor di Sitinjau Lauik, Sistem Buka Tutup Jalur Diberlakukan</h4>
            <span class="news-date">17 Oktober 2026 • 11:10 WIB</span>
        </div>
    </article>

    <!-- Berita 8 -->
    <article class="news-card">
        <div class="news-img" style="background-image: url('https://images.unsplash.com/photo-1584285422896-1b5e5233c06d?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80');"></div>
        <div class="news-content">
            <span class="news-category" style="color: var(--primary-color);">INFO RESMI</span>
            <h4 class="news-title">Status Siaga Darurat Bencana Hidrometeorologi Ditetapkan di Sumbar</h4>
            <span class="news-date">16 Oktober 2026 • 09:00 WIB</span>
        </div>
    </article>

</div>
@endsection