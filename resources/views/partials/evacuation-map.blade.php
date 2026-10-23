@once
    @push('styles')
        <style>
            .evacuation-map { height: 450px; width: 100%; border-radius: 8px; border: 2px solid #cbd5e1; margin-top: 15px; z-index: 1; }
        </style>
    @endpush

    @push('scripts')
        <script>
            document.addEventListener('DOMContentLoaded', function () {
                const mapElement = document.getElementById('evacuationMap');
                if (!mapElement || typeof L === 'undefined') return;

                const map = L.map('evacuationMap').setView([-0.9300, 100.3800], 13);

                L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                    maxZoom: 19,
                    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
                }).addTo(map);

                const boundsDanger = [[-0.9700, 100.3400], [-0.8900, 100.3600]];
                L.rectangle(boundsDanger, {
                    color: '#dc2626', fillColor: '#dc2626', fillOpacity: 0.15, weight: 2
                }).addTo(map).bindPopup('<b>🔴 Zona Bahaya</b><br>Area pesisir pantai. Risiko tinggi hantaman gelombang. Segera evakuasi dari sini!');

                const boundsWarning = [[-0.9700, 100.3600], [-0.8900, 100.3850]];
                L.rectangle(boundsWarning, {
                    color: '#eab308', fillColor: '#eab308', fillOpacity: 0.15, weight: 2
                }).addTo(map).bindPopup('<b>🟡 Zona Waspada</b><br>Area tengah kota. Tetap waspada dan ikuti jalur evakuasi ke arah Timur.');

                const boundsSafe = [[-0.9700, 100.3850], [-0.8900, 100.4300]];
                L.rectangle(boundsSafe, {
                    color: '#16a34a', fillColor: '#16a34a', fillOpacity: 0.15, weight: 2
                }).addTo(map).bindPopup('<b>🟢 Zona Aman</b><br>Area Bypass dan dataran tinggi. Lokasi pengungsian akhir.');

                const routeStyle = { color: 'red', weight: 4, dashArray: '8, 8', opacity: 0.8 };
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
            });
        </script>
    @endpush
@endonce

<div id="evacuationMap" class="evacuation-map" role="application" aria-label="Peta zonasi dan evakuasi Kota Padang"></div>
