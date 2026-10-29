<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title', 'SiagaBencana')</title>
    
    <!-- Pustaka Leaflet CSS untuk Peta -->
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css">
    
    <style>
        /* =========================================
           TEMA WARNA GLOBAL SIAGABENCANA
           ========================================= */
        :root {
            --primary-color: #1e3a8a; /* Navy Blue - Resmi & tenang */
            --primary-hover: #1e40af;
            
            --color-danger: #dc2626;  /* Merah Bata (Crimson) */
            --color-warning: #d97706; /* Kuning Kunyit (Amber) */
            --color-safe: #059669;    /* Hijau Zamrud (Emerald) */
            
            --bg-body: #f8fafc;       /* Abu-abu kebiruan terang */
            --bg-card: #ffffff;
            
            --text-dark: #0f172a;     /* Teks utama gelap */
            --text-muted: #64748b;    /* Teks deskripsi/sekunder */
            --border-color: #e2e8f0;
        }

        * { box-sizing: border-box; }

        body {
            margin: 0;
            font-family: 'Inter', Arial, sans-serif;
            background: var(--bg-body);
            color: var(--text-dark);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        /* -----------------------------------------
           NAVBAR ATAS (DESKTOP)
           ----------------------------------------- */
        .topbar {
            background: var(--primary-color);
            color: white;
            padding: 18px 6%;
            display: flex;
            align-items: center;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
            position: sticky;
            top: 0;
            z-index: 999;
        }

        .brand {
            font-size: 24px;
            font-weight: bold;
            display: flex;
            align-items: center;
            gap: 8px;
            white-space: nowrap;
        }

        .nav {
            flex: 1;
            display: flex;
            justify-content: center;
            gap: 28px;
            margin-right: 120px; 
        }

        .nav a {
            color: white;
            text-decoration: none;
            font-size: 15.5px;
            font-weight: 600;
            letter-spacing: 0.4px;
            opacity: 0.85;
            transition: all 0.2s ease;
            padding-bottom: 4px;
            border-bottom: 2px solid transparent;
            white-space: nowrap;
        }

        .nav a:hover { 
            opacity: 1;
            text-decoration: none; 
            border-bottom: 2px solid white;
        }

        /* -----------------------------------------
           KONTEN UTAMA
           ----------------------------------------- */
        .container {
            width: 88%;
            max-width: 1400px;
            margin: 0 auto;
            flex: 1;
        }

        .content { 
            padding-top: 28px; 
            padding-bottom: 40px; 
        }

        /* -----------------------------------------
           BOTTOM NAVIGATION (MOBILE)
           ----------------------------------------- */
        .bottom-nav {
            display: none;
            position: fixed;
            bottom: 0;
            left: 0;
            width: 100%;
            background-color: var(--bg-card);
            border-top: 1px solid var(--border-color);
            box-shadow: 0 -4px 12px rgba(0, 0, 0, 0.05);
            justify-content: space-around;
            padding: 8px 0 12px 0;
            z-index: 1000;
        }

        .bottom-nav-item {
            display: flex;
            flex-direction: column;
            align-items: center;
            color: var(--text-muted);
            text-decoration: none;
            font-size: 0.75rem;
            gap: 4px;
            transition: color 0.2s ease;
        }

        .bottom-nav-item .icon { font-size: 1.3rem; }

        .bottom-nav-item.active, 
        .bottom-nav-item:hover {
            color: var(--primary-color);
            font-weight: 600;
        }

        /* -----------------------------------------
           FOOTER & HELPER CLASSES
           ----------------------------------------- */
        footer {
            text-align: center;
            padding: 24px;
            background: #0f172a;
            color: #94a3b8;
            font-size: 13px;
            margin-top: auto;
        }

        .bg-danger { background-color: var(--color-danger) !important; color: white !important; }
        .text-danger { color: var(--color-danger) !important; }
        .border-danger { border-color: var(--color-danger) !important; }

        .bg-warning { background-color: var(--color-warning) !important; color: white !important; }
        .text-warning { color: var(--color-warning) !important; }
        .border-warning { border-color: var(--color-warning) !important; }

        .bg-safe { background-color: var(--color-safe) !important; color: white !important; }
        .text-safe { color: var(--color-safe) !important; }
        .border-safe { border-color: var(--color-safe) !important; }

        /* -----------------------------------------
           RESPONSIVE MOBILE RULES
           ----------------------------------------- */
        @media (max-width: 768px) {
            body { padding-bottom: 65px; }
            .topbar { padding: 16px 5%; justify-content: center; }
            .nav { display: none; }
            .bottom-nav { display: flex; }
            .container { width: 92%; }
            footer { padding-bottom: 90px; }
        }
    </style>
    @stack('styles')
    <style>
        p, li { font-weight: 500; }
    </style>
</head>
<body>

    <!-- NAVBAR ATAS (Hanya tampil di Desktop) -->
    <header class="topbar">
        <div class="brand">🛡️ SiagaBencana</div>
        <nav class="nav">
            <a href="{{ route('home') }}">Beranda</a>
            <a href="{{ route('evakuasi') }}">Evakuasi</a>
            <a href="{{ route('berita') }}">Berita</a>
            <a href="{{ route('mitigasi') }}">Mitigasi</a>
            <a href="{{ route('laporan') }}">Laporan</a>
            @auth
                @if (auth()->user()->isReportStaff())
                    <a href="{{ route('petugas.sos.index') }}">Dashboard SOS</a>
                    <a href="{{ route('petugas.berita.index') }}">Kelola Berita</a>
                @endif
                <a href="{{ route('profil') }}">Profil</a>
            @else
                <a href="{{ route('profil') }}">Profil</a>
            @endauth
        </nav>
    </header>

    <!-- KONTEN UTAMA -->
    <main class="container content">
        @yield('content')
    </main>

    <!-- FOOTER -->
    <footer>
        SiagaBencana · Informasi dan Mitigasi Bencana Kota Padang
    </footer>

    <!-- NAVBAR BAWAH (Hanya tampil di Mobile) -->
    <nav class="bottom-nav">
        <a href="{{ route('home') }}" class="bottom-nav-item {{ request()->routeIs('home') ? 'active' : '' }}">
            <span class="icon">🏠</span>
            <span>Beranda</span>
        </a>
        <a href="{{ route('evakuasi') }}" class="bottom-nav-item {{ request()->routeIs('evakuasi') ? 'active' : '' }}">
            <span class="icon">🏃</span>
            <span>Evakuasi</span>
        </a>
        <a href="{{ route('berita') }}" class="bottom-nav-item {{ request()->routeIs('berita*') ? 'active' : '' }}">
            <span class="icon">📰</span>
            <span>Berita</span>
        </a>
        <a href="{{ route('mitigasi') }}" class="bottom-nav-item {{ request()->routeIs('mitigasi') ? 'active' : '' }}">
            <span class="icon">🛡️</span>
            <span>Mitigasi</span>
        </a>
        <a href="{{ route('profil') }}" class="bottom-nav-item {{ request()->routeIs('profil') ? 'active' : '' }}">
            <span class="icon">👤</span>
            <span>Profil</span>
        </a>
    </nav>

    <!-- Pustaka Leaflet JS untuk Peta -->
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    @stack('scripts')
</body>
</html>
