@once
    @push('styles')
        <style>
            .evac-map-controls-bar {
                display: flex;
                flex-wrap: wrap;
                gap: 10px;
                margin-bottom: 12px;
                align-items: center;
            }
            .evac-search-input {
                flex: 1;
                min-width: 220px;
                padding: 10px 14px;
                border: 1px solid #cbd5e1;
                border-radius: 10px;
                font: inherit;
                font-size: 14px;
                background: #fff;
            }
            .evac-btn {
                display: inline-flex;
                align-items: center;
                gap: 6px;
                padding: 10px 15px;
                border-radius: 10px;
                border: 0;
                background: #1e40af;
                color: #fff;
                font: inherit;
                font-size: 13.5px;
                font-weight: 700;
                cursor: pointer;
            }
            .evac-btn.secondary {
                background: #fff;
                color: #1e3a8a;
                border: 1px solid #cbd5e1;
            }
            .evac-search-results {
                background: #fff;
                border: 1px solid #cbd5e1;
                border-radius: 10px;
                margin-bottom: 12px;
                max-height: 220px;
                overflow-y: auto;
                display: none;
            }
            .evac-search-item {
                padding: 10px 14px;
                border-bottom: 1px solid #e2e8f0;
                cursor: pointer;
                font-size: 13.5px;
            }
            .evac-search-item:hover { background: #eff6ff; }
            .evac-status-banner {
                display: none;
                padding: 12px 16px;
                border-radius: 10px;
                margin-bottom: 12px;
                font-size: 14px;
                font-weight: 600;
            }
            .evacuation-map {
                height: 480px;
                width: 100%;
                border-radius: 10px;
                border: 2px solid #cbd5e1;
                z-index: 1;
            }
        </style>
    @endpush

    @push('scripts')
        <script>
            document.addEventListener('DOMContentLoaded', function () {
                const mapElement = document.getElementById('evacuationMap');
                if (!mapElement || typeof L === 'undefined') return;

                const map = L.map('evacuationMap').setView([-0.9300, 100.3800], 13);

                const streetLayer = L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                    maxZoom: 19,
                    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
                });
                const voyagerLayer = L.tileLayer('https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png', {
                    maxZoom: 19,
                    attribution: '&copy; OpenStreetMap &copy; CARTO'
                });
                const satelliteLayer = L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', {
                    maxZoom: 19,
                    attribution: 'Tiles &copy; Esri'
                });

                streetLayer.addTo(map);
                L.control.layers({
                    'Peta Jalan (Standar)': streetLayer,
                    'Peta Detail Kota (Voyager)': voyagerLayer,
                    'Citra Satelit': satelliteLayer
                }).addTo(map);

                const zones = [
                    {
                        id: 'danger',
                        title: 'Zona Bahaya',
                        areaName: 'Wilayah Pesisir Pantai Kota Padang',
                        disasterType: 'Tsunami & Gelombang Pasang Pesisir',
                        riskLevel: 'Tinggi',
                        color: '#dc2626',
                        bounds: [[-0.9700, 100.3400], [-0.8900, 100.3600]],
                        desc: 'Area pesisir pantai. Risiko tinggi hantaman gelombang. Segera evakuasi dari sini!'
                    },
                    {
                        id: 'warning',
                        title: 'Zona Waspada',
                        areaName: 'Wilayah Tengah Kota Padang',
                        disasterType: 'Dampak Gempa Bumi & Limpasan Tsunami',
                        riskLevel: 'Sedang',
                        color: '#eab308',
                        bounds: [[-0.9700, 100.3600], [-0.8900, 100.3850]],
                        desc: 'Area tengah kota. Tetap waspada dan ikuti jalur evakuasi ke arah Timur.'
                    },
                    {
                        id: 'safe',
                        title: 'Zona Aman',
                        areaName: 'Wilayah Bypass & Dataran Tinggi Kota Padang',
                        disasterType: 'Zona Pengungsian & Titik Aman Tsunami',
                        riskLevel: 'Rendah (Zona Aman)',
                        color: '#16a34a',
                        bounds: [[-0.9700, 100.3850], [-0.8900, 100.4300]],
                        desc: 'Area Bypass dan dataran tinggi. Lokasi pengungsian akhir.'
                    }
                ];

                zones.forEach(function (z) {
                    L.rectangle(z.bounds, {
                        color: z.color, fillColor: z.color, fillOpacity: 0.16, weight: 2
                    }).addTo(map).bindPopup(
                        `<b>${z.title}</b><br>Wilayah: ${z.areaName}<br>Bencana: ${z.disasterType}<br>Risiko: <b>${z.riskLevel}</b><br>${z.desc}`
                    );
                });

                const routeStyle = { color: '#dc2626', weight: 4, dashArray: '8, 8', opacity: 0.85 };
                const route1 = [ [-0.9250, 100.3520], [-0.9250, 100.3680], [-0.9168, 100.4113] ];
                L.polyline(route1, routeStyle).addTo(map)
                    .bindPopup('<b>Jalur Evakuasi Utara</b><br>Mengarah ke Posko Utama BPBD Bypass.');

                const route2 = [ [-0.9450, 100.3550], [-0.9450, 100.3750], [-0.9450, 100.4100] ];
                L.polyline(route2, routeStyle).addTo(map)
                    .bindPopup('<b>Jalur Evakuasi Tengah</b><br>Ikuti jalan utama ke arah Timur menjauhi garis pantai.');

                const safeIcon = L.icon({
                    iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-green.png',
                    shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/0.7.7/images/marker-shadow.png',
                    iconSize: [25, 41], iconAnchor: [12, 41], popupAnchor: [1, -34], shadowSize: [41, 41]
                });

                const evacuationPoints = [
                    { name: 'Kantor BPBD Kota Padang', lat: -0.9168, lng: 100.4113, desc: 'Pusat Komando (Zona Aman)' },
                    { name: 'RSUP Dr. M. Djamil', lat: -0.9429, lng: 100.3621, desc: 'Layanan Medis Darurat (Zona Waspada)' },
                    { name: 'Kantor Gubernur Sumbar', lat: -0.9238, lng: 100.3624, desc: 'Titik Kumpul Sementara' },
                    { name: 'Polresta Padang', lat: -0.9483, lng: 100.3636, desc: 'Pusat Keamanan' }
                ];

                evacuationPoints.forEach(function (point) {
                    const marker = L.marker([point.lat, point.lng], { icon: safeIcon }).addTo(map);
                    marker.bindPopup(`<strong>${point.name}</strong><br>${point.desc}`);
                });

                let activeMarker = null;
                const statusBanner = document.getElementById('evacStatusBanner');

                function evaluateZone(lat, lng, label) {
                    let matched = null;
                    for (const z of zones) {
                        if (lat >= z.bounds[0][0] && lat <= z.bounds[1][0] && lng >= z.bounds[0][1] && lng <= z.bounds[1][1]) {
                            matched = z;
                            break;
                        }
                    }
                    if (!statusBanner) return;
                    statusBanner.style.display = 'block';
                    if (matched) {
                        statusBanner.style.background = matched.id === 'danger' ? '#fef2f2' : (matched.id === 'warning' ? '#fffbeb' : '#ecfdf5');
                        statusBanner.style.color = matched.id === 'danger' ? '#991b1b' : (matched.id === 'warning' ? '#92400e' : '#065f46');
                        statusBanner.style.border = `1px solid ${matched.color}`;
                        statusBanner.textContent = `${label} berada di ${matched.title} (${matched.disasterType} - Risiko ${matched.riskLevel}). ${matched.desc}`;
                    } else {
                        statusBanner.style.background = '#f1f5f9';
                        statusBanner.style.color = '#334155';
                        statusBanner.style.border = '1px solid #cbd5e1';
                        statusBanner.textContent = `${label}: Zona risiko belum tersedia untuk lokasi tersebut (di luar area pemetaan zona).`;
                    }
                }

                const searchBtn = document.getElementById('evacSearchBtn');
                const searchInput = document.getElementById('evacSearchInput');
                const resultsBox = document.getElementById('evacSearchResults');

                async function runLocationSearch() {
                    const query = (searchInput?.value || '').trim();
                    if (!query || !resultsBox) return;
                    resultsBox.style.display = 'block';
                    resultsBox.innerHTML = '<div class="evac-search-item">Mencari lokasi...</div>';
                    try {
                        const url = `https://nominatim.openstreetmap.org/search?format=json&limit=5&countrycodes=id&q=${encodeURIComponent(query)}`;
                        const res = await fetch(url, { headers: { 'Accept': 'application/json' } });
                        const items = await res.json();
                        if (!Array.isArray(items) || items.length === 0) {
                            resultsBox.innerHTML = '<div class="evac-search-item">Lokasi tidak ditemukan.</div>';
                            return;
                        }
                        resultsBox.innerHTML = '';
                        items.forEach(function (item) {
                            const div = document.createElement('div');
                            div.className = 'evac-search-item';
                            div.textContent = item.display_name;
                            div.addEventListener('click', function () {
                                const lat = parseFloat(item.lat);
                                const lng = parseFloat(item.lon);
                                resultsBox.style.display = 'none';
                                if (activeMarker) map.removeLayer(activeMarker);
                                activeMarker = L.marker([lat, lng]).addTo(map)
                                    .bindPopup(`<b>Lokasi Pencarian</b><br>${item.display_name}`).openPopup();
                                map.setView([lat, lng], 15);
                                evaluateZone(lat, lng, 'Lokasi pilihan Anda');
                            });
                            resultsBox.appendChild(div);
                        });
                    } catch (e) {
                        resultsBox.innerHTML = '<div class="evac-search-item">Gagal memuat pencarian lokasi.</div>';
                    }
                }

                searchBtn?.addEventListener('click', runLocationSearch);
                searchInput?.addEventListener('keydown', function (e) {
                    if (e.key === 'Enter') {
                        e.preventDefault();
                        runLocationSearch();
                    }
                });

                const myLocBtn = document.getElementById('evacMyLocationBtn');
                myLocBtn?.addEventListener('click', function () {
                    if (!navigator.geolocation) {
                        if (statusBanner) {
                            statusBanner.style.display = 'block';
                            statusBanner.textContent = 'Browser Anda tidak mendukung fitur geolokasi.';
                        }
                        return;
                    }
                    navigator.geolocation.getCurrentPosition(
                        function (pos) {
                            const lat = pos.coords.latitude;
                            const lng = pos.coords.longitude;
                            if (activeMarker) map.removeLayer(activeMarker);
                            activeMarker = L.marker([lat, lng]).addTo(map)
                                .bindPopup(`<b>Lokasi Saya</b><br>Koordinat: ${lat.toFixed(5)}, ${lng.toFixed(5)}`).openPopup();
                            map.setView([lat, lng], 15);
                            evaluateZone(lat, lng, 'Lokasi Anda');
                        },
                        function (err) {
                            if (!statusBanner) return;
                            statusBanner.style.display = 'block';
                            statusBanner.style.background = '#fef2f2';
                            statusBanner.style.color = '#991b1b';
                            statusBanner.style.border = '1px solid #dc2626';
                            statusBanner.textContent = err.code === 1
                                ? 'Izin akses lokasi ditolak oleh pengguna. Aktifkan izin lokasi pada browser untuk memeriksa zona bencana di posisi Anda.'
                                : 'Gagal mengambil koordinat lokasi perangkat saat ini.';
                        },
                        { enableHighAccuracy: true, timeout: 10000 }
                    );
                });
            });
        </script>
    @endpush
@endonce

<div class="evac-map-controls-bar">
    <input
        id="evacSearchInput"
        type="text"
        class="evac-search-input"
        placeholder="Cari jalan, kelurahan, kecamatan, atau nama tempat..."
    >
    <button id="evacSearchBtn" type="button" class="evac-btn">🔍 Cari Lokasi</button>
    <button id="evacMyLocationBtn" type="button" class="evac-btn secondary">📍 Lokasi Saya</button>
</div>
<div id="evacSearchResults" class="evac-search-results"></div>
<div id="evacStatusBanner" class="evac-status-banner" role="status"></div>
<div id="evacuationMap" class="evacuation-map" role="application" aria-label="Peta zonasi dan evakuasi Kota Padang"></div>
