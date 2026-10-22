
@extends('layouts.app')

@section('title', 'Beranda - SiagaBencana')

@section('content')
<style>
    .hero {
        background: linear-gradient(135deg, #123b63, #1769aa);
        color: white;
        padding: 32px;
        border-radius: 16px;
        margin-bottom: 24px;
    }

    .hero h1 {
        margin-top: 0;
        font-size: 30px;
    }

    .hero p {
        line-height: 1.7;
    }

    .hero-button {
        display: inline-block;
        background: white;
        color: #123b63;
        padding: 12px 18px;
        border-radius: 8px;
        text-decoration: none;
        font-weight: bold;
    }

    .hero-button:hover {
        background: #eaf3ff;
    }

    .section-title {
        color: #123b63;
        margin: 28px 0 16px;
    }

    .cards {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
        gap: 18px;
        align-items: stretch;
    }

    /* Kartu BMKG memakai satu baris penuh */
    .cards > .bmkg-card {
        grid-column: 1 / -1;
        width: 100%;
        box-sizing: border-box;
    }

    .card {
        background: white;
        padding: 22px;
        border-radius: 12px;
        box-shadow: 0 3px 12px #0000000a;
        min-width: 0;
    }

    .card h3 {
        margin-top: 0;
        color: #123b63;
    }

    .card p {
        line-height: 1.6;
        color: #475569;
    }

    .card a {
        color: #1769aa;
        text-decoration: none;
        font-weight: bold;
    }

    .card a:hover {
        text-decoration: underline;
    }

    .weather-value {
        font-size: 30px;
        font-weight: bold;
        color: #123b63;
        margin: 12px 0;
        overflow-wrap: anywhere;
    }

    .weather-icon {
        font-size: 34px;
        margin-bottom: 8px;
    }

    .weather-note,
    .status-message {
        font-size: 12px;
        color: #64748b;
        line-height: 1.6;
    }

    .news-card {
        display: flex;
        flex-direction: column;
        align-items: flex-start;
        gap: 8px;
    }

    .news-tag {
        background: #e0f2fe;
        color: #075985;
        padding: 5px 9px;
        border-radius: 6px;
        font-size: 12px;
        font-weight: bold;
    }

    .news-date {
        color: #64748b;
        font-size: 12px;
    }

    .news-card a {
        margin-top: auto;
        padding-top: 8px;
    }

    .map-container {
        background: white;
        padding: 16px;
        border-radius: 12px;
        box-shadow: 0 3px 12px #0000000a;
    }

    #map {
        height: 420px;
        width: 100%;
        border-radius: 10px;
        z-index: 1;
        background: #e5edf5;
    }

    .map-description {
        color: #64748b;
        font-size: 14px;
        line-height: 1.6;
    }

    .map-legend {
        display: flex;
        flex-wrap: wrap;
        gap: 16px;
        margin-top: 14px;
        font-size: 13px;
        color: #475569;
    }

    .legend-dot {
        display: inline-block;
        width: 10px;
        height: 10px;
        border-radius: 50%;
        margin-right: 5px;
    }

    .alert-info {
        background: #fff7ed;
        border-left: 4px solid #f59e0b;
        padding: 12px;
        border-radius: 8px;
        margin: 12px 0;
    }

    .alert-info strong {
        color: #9a3412;
    }

    @media (max-width: 600px) {
        .hero {
            padding: 24px;
        }

        .hero h1 {
            font-size: 24px;
        }

        #map {
            height: 320px;
        }

        .card {
            padding: 18px;
        }
    }
</style>

{{-- HERO --}}
<section class="hero">
    <h1>Selamat Datang di SiagaBencana</h1>

    <p>
        Platform informasi dan mitigasi bencana untuk membantu
        masyarakat Kota Padang mengenali risiko, memperoleh informasi,
        dan mempersiapkan diri menghadapi keadaan darurat.
    </p>

    <a href="{{ route('evakuasi') }}" class="hero-button">
        Lihat Informasi Evakuasi →
    </a>
</section>

{{-- CUACA, KUALITAS UDARA, PERINGATAN --}}
<h2 class="section-title">Informasi Kebencanaan</h2>

<style>
    /* Mengatur layout agar membelah jadi 2 kolom yang sama besar (simetris) */
    .info-grid {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        gap: 24px; /* Jarak antar kartu */
        width: 100%;
        margin-bottom: 24px;
    }
    
    /* Memastikan kartu tingginya sama rata meski isi teksnya beda panjang */
    .info-grid .card {
        height: 100%;
        display: flex;
        flex-direction: column;
    }
    
    /* Mendorong tautan BMKG agar selalu rapi berada di paling bawah kartu */
    .info-grid .card > a {
        margin-top: auto;
    }

    /* Responsif: Jika dibuka di HP (layar kecil), otomatis berubah jadi 1 kolom ke bawah */
    @media (max-width: 768px) {
        .info-grid {
            grid-template-columns: 1fr;
        }
    }
</style>

<div class="info-grid">

    {{-- CUACA --}}
    <div class="card">
        <div class="weather-icon" id="weather-icon">🌦️</div>
        <h3>Cuaca Kota Padang</h3>

        <div class="weather-value" id="weather-temperature">
            Memuat...
        </div>

        <p id="weather-condition">
            Mengambil data cuaca terbaru.
        </p>

        <p id="weather-detail">
            Suhu, kelembapan, dan kecepatan angin.
        </p>

        <p class="weather-note">
            Sumber: Open-Meteo. Data memerlukan koneksi internet.
        </p>

        <p class="status-message" id="weather-updated"></p>

        <a href="https://www.bmkg.go.id/"
           target="_blank"
           rel="noopener noreferrer">
             Informasi cuaca BMKG →
        </a>
    </div>

    {{-- KUALITAS UDARA --}}
    <div class="card">
        <div class="weather-icon">🌫️</div>
        <h3>Kualitas Udara Padang</h3>

        <div class="weather-value" id="air-aqi">
            Memuat...
        </div>

        <p id="air-category">
            Mengambil estimasi kualitas udara.
        </p>

        <p id="air-pm">
            PM2.5: -- µg/m³<br>
            PM10: -- µg/m³
        </p>

        <p class="weather-note">
            Sumber: Open-Meteo Air Quality API.
            Data merupakan estimasi model, bukan pengukuran sensor lokal.
        </p>

        <p class="status-message" id="air-updated"></p>

        <a href="https://iklim.bmkg.go.id/id/kualitas-udara-indonesia/"
           target="_blank"
           rel="noopener noreferrer">
             Informasi kualitas udara BMKG →
        </a>
    </div>

</div>




{{-- PERINGATAN BENCANA --}}
<div class="card bmkg-card">
    <div class="weather-icon">🔔</div>

    <h3>Peringatan Dini BMKG</h3>

    <div id="bmkg-status" class="bmkg-status">
        <strong>Memuat peringatan...</strong>
        <p>Sedang mengambil data peringatan dini dari BMKG.</p>
    </div>

    <div id="bmkg-alert-list" class="bmkg-alert-list">
        <p>Mohon tunggu, data sedang dimuat.</p>
    </div>

    <div class="bmkg-links">
        <a href="https://www.bmkg.go.id/alerts/nowcast/id"
           target="_blank"
           rel="noopener noreferrer">
            Lihat Peringatan Dini BMKG →
        </a>

        <a href="https://bnpb.go.id/"
           target="_blank"
           rel="noopener noreferrer">
            Kunjungi BNPB →
        </a>
    </div>

    <p id="bmkg-checked-at" class="bmkg-checked-at"></p>
</div>

</div> {{-- Penutup .cards informasi kebencanaan --}}

<style>
    .bmkg-card { min-width: 0; width: 100%; box-sizing: border-box; overflow-wrap: anywhere; }
    .bmkg-status { padding: 14px; margin-top: 12px; border-left: 4px solid #f59e0b; border-radius: 8px; background: #fff7ed; color: #7c2d12; }
    .bmkg-status p { margin: 8px 0 0; line-height: 1.6; }
    .bmkg-alert-list { display: grid; grid-template-columns: minmax(0, 1fr); gap: 12px; margin-top: 14px; }
    .bmkg-alert-item { min-width: 0; padding: 14px; border: 1px solid #fed7aa; border-radius: 8px; background: #fffaf5; overflow-wrap: anywhere; }
    .bmkg-alert-item h4 { margin: 0 0 8px; color: #9a3412; }
    .bmkg-alert-item p { margin: 0 0 8px; line-height: 1.6; white-space: pre-line; }
    .bmkg-alert-item small { display: block; color: #64748b; line-height: 1.5; }
    .bmkg-alert-item a { display: inline-block; margin-top: 8px; }
    .bmkg-links { display: flex; flex-wrap: wrap; gap: 10px 18px; margin-top: 16px; }
    .bmkg-checked-at { margin-top: 12px; color: #64748b; font-size: 12px; }
    @media (max-width: 600px) {
        .bmkg-card { padding: 18px; }
        .bmkg-links { flex-direction: column; align-items: flex-start; }
    }
</style>

<script>
document.addEventListener('DOMContentLoaded', function () {
    const status = document.getElementById('bmkg-status');
    const list = document.getElementById('bmkg-alert-list');
    const checkedAt = document.getElementById('bmkg-checked-at');

    async function loadBMKGAlerts() {
        try {
            const response = await fetch(
                '{{ route("api.peringatan") }}',
                {
                    headers: {
                        'Accept': 'application/json'
                    }
                }
            );

            const data = await response.json();

            if (!response.ok || !data.success) {
                throw new Error('Data BMKG gagal dimuat.');
            }

            list.replaceChildren();
            status.replaceChildren();

            if (!Array.isArray(data.alerts) || data.alerts.length === 0) {
                const title = document.createElement('strong');
                title.textContent = 'Tidak ada hasil yang cocok';

                const message = document.createElement('p');
                message.textContent =
                    'Tidak ada peringatan yang cocok dengan filter saat ini. Ini bukan jaminan bahwa Padang aman. Silakan periksa sumber resmi BMKG.';

                status.append(title, message);
                status.style.borderLeftColor = '#64748b';
                status.style.background = '#f1f5f9';
                status.style.color = '#334155';
            } else {
                const title = document.createElement('strong');
                title.textContent =
                    '⚠️ ' + data.alerts.length +
                    ' informasi peringatan ditemukan';

                const message = document.createElement('p');
                message.textContent =
                    'Periksa wilayah terdampak dan waktu berlaku pada detail resmi BMKG.';

                status.append(title, message);
                status.style.borderLeftColor = '#dc2626';
                status.style.background = '#fef2f2';
                status.style.color = '#991b1b';

                data.alerts.forEach(function (alert) {
                    const item = document.createElement('article');
                    item.className = 'bmkg-alert-item';

                    const heading = document.createElement('h4');
                    heading.textContent =
                        alert.title || 'Peringatan dini cuaca';

                    const description = document.createElement('p');
                    description.textContent =
                        alert.description || 'Deskripsi tidak tersedia.';

                    item.append(heading, description);

                    if (alert.published) {
                        const date = document.createElement('small');
                        date.textContent =
                            'Waktu publikasi: ' + alert.published;

                        item.appendChild(date);
                    }

                    if (alert.link) {
                        const link = document.createElement('a');
                        link.href = alert.link;
                        link.target = '_blank';
                        link.rel = 'noopener noreferrer';
                        link.textContent = 'Lihat detail peringatan →';

                        item.appendChild(link);
                    }

                    list.appendChild(item);
                });
            }

            checkedAt.textContent = data.checked_at
                ? 'Data diperiksa: ' +
                  new Date(data.checked_at).toLocaleString('id-ID')
                : '';
        } catch (error) {
            status.replaceChildren();

            const title = document.createElement('strong');
            title.textContent = 'Data peringatan belum tersedia';

            const message = document.createElement('p');
            message.textContent =
                'Periksa koneksi atau kunjungi situs resmi BMKG. Jangan menganggap kondisi aman karena data tidak tersedia.';

            status.append(title, message);
            list.replaceChildren();
            checkedAt.textContent = '';

            console.error('Kesalahan mengambil peringatan BMKG:', error);
        }
    }

    loadBMKGAlerts();
    setInterval(loadBMKGAlerts, 5 * 60 * 1000);
});
</script>




{{-- PETA --}}
<h2 class="section-title">Peta Informasi Bencana</h2>

<div class="map-container">
    <h3 style="margin-top:4px; color:#123b63;">
        📍 Peta Kota Padang
    </h3>

    <p class="map-description">
        Geser peta untuk melihat wilayah sekitar dan klik penanda
        untuk melihat informasi lokasinya.
    </p>

    <div id="map"></div>

    <div class="map-legend">
        <span>
            <span class="legend-dot"
                  style="background:#2563eb;"></span>
            Pusat peta
        </span>

        <span>
            <span class="legend-dot"
                  style="background:#16a34a;"></span>
            Contoh penanda lokasi
        </span>
    </div>

    <p class="map-description">
        Peta menggunakan OpenStreetMap. Penanda dan lingkaran
        merupakan ilustrasi, bukan data kejadian bencana, batas
        zona bahaya, atau lokasi evakuasi resmi.
    </p>
</div>

{{-- BERITA EDUKASI --}}
<h2 class="section-title">📰 Berita dan Informasi Terbaru</h2>

<p class="map-description">
    Materi edukasi berikut merupakan konten contoh SiagaBencana,
    bukan berita kejadian terkini dari media.
</p>

<div class="cards">
    <div class="card news-card">
        <span class="news-tag">Kesiapsiagaan</span>
        <h3>Kenali Jalur Evakuasi</h3>

        <p>
            Kenali jalur menuju tempat aman dan tentukan titik kumpul
            keluarga sebelum keadaan darurat terjadi.
        </p>

        <span class="news-date">Materi edukasi</span>

        <a href="{{ route('evakuasi') }}">
            Pelajari evakuasi →
        </a>
    </div>

    <div class="card news-card">
        <span class="news-tag">Cuaca</span>
        <h3>Pantau Prakiraan Cuaca</h3>

        <p>
            Periksa prakiraan dan peringatan cuaca resmi,
            terutama saat hujan lebat atau angin kencang.
        </p>

        <span class="news-date">Sumber eksternal</span>

        <a href="https://www.bmkg.go.id/"
           target="_blank"
           rel="noopener noreferrer">
            Buka situs BMKG →
        </a>
    </div>

    <div class="card news-card">
        <span class="news-tag">Mitigasi</span>
        <h3>Persiapkan Tas Siaga Bencana</h3>

        <p>
            Siapkan air minum, makanan tahan lama, senter,
            obat pribadi, dokumen penting, dan perlengkapan darurat.
        </p>

        <span class="news-date">Materi edukasi</span>

        <a href="{{ route('mitigasi') }}">
            Baca panduan mitigasi →
        </a>
    </div>
</div>

{{-- NAVIGASI --}}
<h2 class="section-title">Jelajahi SiagaBencana</h2>

<div class="cards">
    <div class="card">
        <h3>🧭 Evakuasi</h3>
        <p>
            Pelajari zona risiko, jalur evakuasi, dan panduan menuju
            tempat aman.
        </p>
        <a href="{{ route('evakuasi') }}">Buka Evakuasi →</a>
    </div>

    <div class="card">
        <h3>📰 Berita</h3>
        <p>
            Baca informasi dan edukasi kesiapsiagaan bencana.
        </p>
        <a href="{{ route('berita') }}">Buka Berita →</a>
    </div>

    <div class="card">
        <h3>🛡️ Mitigasi</h3>
        <p>
            Pelajari prosedur keselamatan dan persiapan tas siaga.
        </p>
        <a href="{{ route('mitigasi') }}">Buka Mitigasi →</a>
    </div>

    <div class="card">
        <h3>📊 Riwayat Bencana</h3>
        <p>
            Lihat halaman statistik dan riwayat kejadian bencana.
        </p>
        <a href="{{ route('laporan') }}">Buka Laporan →</a>
    </div>

    <div class="card">
        <h3>👤 Profil</h3>
        <p>
            Lihat halaman profil dan pengaturan pengguna.
        </p>
        <a href="{{ route('profil') }}">Buka Profil →</a>
    </div>
</div>
@endsection

@push('scripts')
<script>
document.addEventListener('DOMContentLoaded', function () {

    // =====================================
    // PETA INTERAKTIF LEAFLET
    // =====================================
    const mapElement = document.getElementById('map');

    if (mapElement && typeof L !== 'undefined') {
        const padang = [-0.9471, 100.4172];

        const map = L.map('map').setView(padang, 12);

        L.tileLayer(
            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            {
                attribution: '&copy; OpenStreetMap contributors',
                maxZoom: 19
            }
        ).addTo(map);

        L.marker(padang)
            .addTo(map)
            .bindPopup(
                '<b>Kota Padang</b><br>Pusat tampilan peta.'
            );

        L.circle(padang, {
            radius: 1000,
            color: '#2563eb',
            fillColor: '#60a5fa',
            fillOpacity: 0.15
        })
        .addTo(map)
        .bindPopup(
            'Lingkaran ilustrasi, bukan zona bahaya resmi.'
        );

        L.marker([-0.9200, 100.3600])
            .addTo(map)
            .bindPopup(
                '<b>Contoh penanda lokasi</b><br>' +
                'Belum diverifikasi sebagai tempat evakuasi.'
            );

        setTimeout(function () {
            map.invalidateSize();
        }, 200);
    } else if (mapElement) {
        mapElement.innerHTML =
            '<p style="padding:20px;">Peta gagal dimuat. ' +
            'Periksa koneksi internet dan pustaka Leaflet.</p>';
    }

    // =====================================
    // CUACA KOTA PADANG - OPEN-METEO
    // =====================================
    async function loadWeather() {
        const temperature = document.getElementById(
            'weather-temperature'
        );
        const condition = document.getElementById(
            'weather-condition'
        );
        const detail = document.getElementById(
            'weather-detail'
        );
        const icon = document.getElementById('weather-icon');
        const updated = document.getElementById('weather-updated');

        const url =
            'https://api.open-meteo.com/v1/forecast' +
            '?latitude=-0.9471&longitude=100.4172' +
            '&current=temperature_2m,relative_humidity_2m,' +
            'apparent_temperature,wind_speed_10m,weather_code' +
            '&timezone=Asia%2FJakarta';

        const descriptions = {
            0: ['Cerah', '☀️'],
            1: ['Cerah sebagian', '🌤️'],
            2: ['Berawan sebagian', '⛅'],
            3: ['Berawan', '☁️'],
            45: ['Berkabut', '🌫️'],
            48: ['Kabut tebal', '🌫️'],
            51: ['Gerimis ringan', '🌦️'],
            53: ['Gerimis', '🌦️'],
            55: ['Gerimis lebat', '🌧️'],
            61: ['Hujan ringan', '🌧️'],
            63: ['Hujan sedang', '🌧️'],
            65: ['Hujan lebat', '🌧️'],
            80: ['Hujan lokal ringan', '🌦️'],
            81: ['Hujan lokal sedang', '🌧️'],
            82: ['Hujan lokal lebat', '⛈️'],
            95: ['Badai petir', '⛈️'],
            96: ['Badai petir dengan hujan es', '⛈️'],
            99: ['Badai petir kuat dengan hujan es', '⛈️']
        };

        try {
            const response = await fetch(url);

            if (!response.ok) {
                throw new Error('Permintaan cuaca gagal.');
            }

            const data = await response.json();
            const current = data.current;

            if (!current || current.temperature_2m == null) {
                throw new Error('Data cuaca tidak tersedia.');
            }

            const info = descriptions[current.weather_code]
                || ['Kondisi cuaca bervariasi', '🌦️'];

            temperature.textContent = `${current.temperature_2m}°C`;
            condition.textContent = info[0];
            icon.textContent = info[1];

            detail.textContent =
                `Terasa ${current.apparent_temperature}°C · ` +
                `Kelembapan ${current.relative_humidity_2m}% · ` +
                `Angin ${current.wind_speed_10m} km/jam`;

            if (updated && current.time) {
                updated.textContent =
                    'Waktu data: ' +
                    current.time.replace('T', ' ') + ' (WIB)';
            }
        } catch (error) {
            temperature.textContent = 'Tidak tersedia';
            condition.textContent = 'Data cuaca gagal dimuat.';
            detail.textContent =
                'Periksa koneksi internet lalu muat ulang halaman.';
            console.error('Kesalahan cuaca:', error);
        }
    }

    // =====================================
    // =====================================
    // KUALITAS UDARA - OPEN-METEO
    // =====================================
    async function loadAirQuality() {
        const aqiElement = document.getElementById('air-aqi');
        const categoryElement = document.getElementById('air-category');
        const pmElement = document.getElementById('air-pm');
        const updatedElement = document.getElementById('air-updated');

        if (!aqiElement || !categoryElement || !pmElement) return;

        const url =
            'https://air-quality-api.open-meteo.com/v1/air-quality' +
            '?latitude=-0.9471&longitude=100.4172' +
            '&current=us_aqi,pm2_5,pm10' +
            '&timezone=Asia%2FJakarta';

        // Modifikasi: Menambahkan keterangan risiko kesehatan agar mudah dipahami
        function getAqiDetails(aqi) {
            if (aqi <= 50) return { label: 'Baik', risk: 'Udara aman dan sehat untuk semua aktivitas luar ruangan.' };
            if (aqi <= 100) return { label: 'Sedang', risk: 'Kelompok sangat sensitif (misal: penderita asma) sebaiknya membatasi aktivitas berat di luar.' };
            if (aqi <= 150) return { label: 'Tidak Sehat bagi Kelompok Sensitif', risk: 'Anak-anak, lansia, dan penderita penyakit pernapasan harus mengurangi aktivitas luar.' };
            if (aqi <= 200) return { label: 'Tidak Sehat', risk: 'Masyarakat umum mulai merasakan dampak kesehatan. Kurangi aktivitas di luar ruangan.' };
            if (aqi <= 300) return { label: 'Sangat Tidak Sehat', risk: 'Kondisi darurat. Seluruh warga disarankan tetap berada di dalam ruangan.' };
            return { label: 'Berbahaya', risk: 'Peringatan kesehatan serius! Hindari semua aktivitas fisik di luar ruangan.' };
        }

        try {
            const response = await fetch(url);

            if (!response.ok) {
                throw new Error('Permintaan kualitas udara gagal.');
            }

            const data = await response.json();
            const current = data.current;

            if (!current || current.us_aqi == null) {
                throw new Error('Data AQI tidak tersedia.');
            }

            const aqiDetails = getAqiDetails(current.us_aqi);

            aqiElement.textContent = `AQI ${current.us_aqi}`;
            
            // Menggunakan innerHTML untuk merender teks label dan risiko secara bertingkat
            categoryElement.innerHTML = `<strong>${aqiDetails.label}</strong><br><span style="font-size: 0.85em; opacity: 0.9;">${aqiDetails.risk}</span>`;

            // Menampilkan data PM tanpa disclaimer
            pmElement.innerHTML = 
                `PM2.5: ${current.pm2_5 ?? '--'} µg/m³ | PM10: ${current.pm10 ?? '--'} µg/m³`;

            if (updatedElement && current.time) {
                updatedElement.textContent =
                    'Waktu data: ' +
                    current.time.replace('T', ' ') + ' (WIB)';
            }
        } catch (error) {
            aqiElement.textContent = 'Tidak tersedia';
            categoryElement.textContent = 'Data kualitas udara gagal dimuat.';
            pmElement.textContent = 'Periksa koneksi internet lalu coba kembali.';

            console.error('Kesalahan kualitas udara:', error);
        }
    }

    loadWeather();
    loadAirQuality();
});
</script>
@endpush
