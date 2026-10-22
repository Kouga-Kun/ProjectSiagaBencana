
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title', 'SiagaBencana')</title>
    <style>
        * { box-sizing: border-box; }

        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: #f4f7fb;
            color: #172033;
        }

        .topbar {
            background: #123b63;
            color: white;
            padding: 18px 6%;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 20px;
            flex-wrap: wrap;
        }

        .brand {
            font-size: 22px;
            font-weight: bold;
        }

        .nav {
            display: flex;
            flex-wrap: wrap;
            gap: 20px;
        }

        .nav a {
            color: white;
            text-decoration: none;
            font-size: 14px;
        }

        .nav a:hover { text-decoration: underline; }

        .container {
            width: 88%;
            max-width: 1400px;
            margin: 0 auto;
        }

        .content { padding-top: 28px; padding-bottom: 40px; }

        .bottom-nav { display: none; }

        footer {
            text-align: center;
            padding: 20px;
            background: #102d49;
            color: white;
            font-size: 13px;
        }

        @media (max-width: 650px) {
            .topbar { padding: 16px 5%; }
            .nav { gap: 12px; }
            .container { width: 92%; }
        }
    </style>
    @stack('styles')

    
    <link
        rel="stylesheet"
        href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"
    >
</head>
<body>
    <header class="topbar">
        <div class="brand">🛡️ SiagaBencana</div>

        <nav class="nav">
            <a href="{{ route('home') }}">Beranda</a>
            <a href="{{ route('evakuasi') }}">Evakuasi</a>
            <a href="{{ route('berita') }}">Berita</a>
            <a href="{{ route('mitigasi') }}">Mitigasi</a>
            <a href="{{ route('laporan') }}">Laporan Riwayat</a>
            <a href="{{ route('profil') }}">Profil</a>
        </nav>
    </header>

    <main class="container content">
        @yield('content')
    </main>


    <footer>
        SiagaBencana · Informasi dan Mitigasi Bencana Kota Padang
    </footer>

       <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    @stack('scripts')
</body>
</html>
