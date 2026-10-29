@extends('layouts.app')

@section('title', 'Dashboard SOS Petugas - SiagaBencana')

@section('content')
<style>
    .sos-admin-page { --sos-primary: #123b63; --sos-muted: #64748b; color: #0f172a; }
    .sos-header { display: flex; flex-wrap: wrap; align-items: flex-end; justify-content: space-between; gap: 16px; margin-bottom: 24px; }
    .sos-title { color: #991b1b; margin: 0 0 8px; font-size: clamp(26px, 3vw, 34px); }
    .sos-desc { color: var(--sos-muted); line-height: 1.7; margin: 0; max-width: 760px; }
    .sos-stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(190px, 1fr)); gap: 16px; margin-bottom: 24px; }
    .sos-stat-card, .sos-panel { background: #fff; border: 1px solid #dce6f2; border-radius: 16px; box-shadow: 0 8px 24px rgba(18, 59, 99, .06); }
    .sos-stat-card { padding: 20px; }
    .sos-stat-card p { color: var(--sos-muted); font-weight: 600; margin: 0 0 8px; }
    .sos-stat-value { font-size: 28px; font-weight: 750; color: var(--sos-primary); }
    .sos-panel { padding: 22px; margin-bottom: 20px; }
    .sos-panel h2 { color: var(--sos-primary); font-size: 20px; margin: 0 0 16px; }
    .sos-layout-grid { display: grid; grid-template-columns: 1.3fr 1fr; gap: 20px; margin-bottom: 20px; }
    .sos-button { display: inline-flex; align-items: center; justify-content: center; border: 0; border-radius: 9px; padding: 9px 14px; background: #1e40af; color: #fff; font: inherit; font-weight: 700; text-decoration: none; cursor: pointer; font-size: 13.5px; }
    .sos-button:hover { opacity: 0.94; }
    .sos-button.secondary { background: #eaf1fa; color: #123b63; }
    .sos-button.warning { background: #d97706; color: #fff; }
    .sos-button.success { background: #059669; color: #fff; }
    .sos-button.danger { background: #dc2626; color: #fff; }
    .sos-alert { padding: 12px 15px; border-radius: 10px; margin-bottom: 16px; background: #ecfdf5; color: #065f46; }
    .sos-badge { display: inline-flex; border-radius: 999px; padding: 5px 11px; font-size: 12px; font-weight: 700; white-space: nowrap; }
    .sos-badge-menunggu { background: #fef2f2; color: #991b1b; }
    .sos-badge-diproses { background: #fff7ed; color: #9a3412; }
    .sos-badge-selesai { background: #ecfdf5; color: #065f46; }
    .sos-detail-list { display: grid; gap: 12px; }
    .sos-detail-item { padding: 12px 14px; background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 10px; }
    .sos-detail-item small { display: block; color: var(--sos-muted); font-size: 12px; font-weight: 600; margin-bottom: 4px; }
    .sos-detail-item strong { color: #0f172a; font-size: 14.5px; }
    .sos-table-wrap { overflow-x: auto; }
    .sos-table { width: 100%; min-width: 900px; border-collapse: collapse; }
    .sos-table th, .sos-table td { padding: 13px; border-bottom: 1px solid #e2e8f0; text-align: left; vertical-align: top; }
    .sos-table th { background: #f4f7fb; color: #334155; font-size: 13px; }
    .sos-table tr.selected-row td { background: #eff6ff; }
    @media (max-width: 900px) {
        .sos-layout-grid { grid-template-columns: 1fr; }
    }
</style>

<div class="sos-admin-page">
    <header class="sos-header">
        <div>
            <h1 class="sos-title">🆘 Dashboard Permintaan Bantuan Darurat (SOS)</h1>
            <p class="sos-desc">Kelola permintaan bantuan darurat yang dikirim pengguna, pantau koordinat lokasi pada peta, dan perbarui status penanganan.</p>
        </div>
        <div style="display: flex; gap: 10px; flex-wrap: wrap;">
            <a class="sos-button secondary" href="{{ route('laporan') }}">← Kembali ke Halaman Laporan</a>
        </div>
    </header>

    @if (session('status'))
        <div class="sos-alert" role="status">{{ session('status') }}</div>
    @endif

    <section class="sos-stats" aria-label="Statistik SOS">
        <article class="sos-stat-card">
            <p>Total Permintaan SOS</p>
            <div class="sos-stat-value">{{ number_format($totalSos, 0, ',', '.') }}</div>
            <small>Seluruh riwayat masuk</small>
        </article>
        <article class="sos-stat-card">
            <p>Menunggu</p>
            <div class="sos-stat-value" style="color: #dc2626;">{{ number_format($waitingSos, 0, ',', '.') }}</div>
            <small>Permintaan baru belum ditangani</small>
        </article>
        <article class="sos-stat-card">
            <p>Diproses</p>
            <div class="sos-stat-value" style="color: #d97706;">{{ number_format($processingSos, 0, ',', '.') }}</div>
            <small>Sedang ditindaklanjuti petugas</small>
        </article>
        <article class="sos-stat-card">
            <p>Selesai</p>
            <div class="sos-stat-value" style="color: #059669;">{{ number_format($completedSos, 0, ',', '.') }}</div>
            <small>Penanganan telah selesai</small>
        </article>
    </section>

    <div class="sos-layout-grid">
        <section class="sos-panel">
            <h2>🗺️ Peta Lokasi Pengguna SOS</h2>
            <div id="sos-admin-map" style="height: 410px; width: 100%; border-radius: 12px; border: 1px solid #cbd5e1; z-index: 1;"></div>
        </section>

        <section class="sos-panel">
            <h2>📋 Detail Permintaan SOS</h2>
            @if ($selectedSos)
                <div class="sos-detail-list">
                    <div class="sos-detail-item">
                        <small>ID Permintaan & Status</small>
                        <div style="display: flex; align-items: center; justify-content: space-between; gap: 10px;">
                            <strong>SOS #{{ $selectedSos->id }} (ID Pengguna: {{ $selectedSos->user_id }})</strong>
                            <span class="sos-badge sos-badge-{{ $selectedSos->status }}">{{ $selectedSos->statusLabel() }}</span>
                        </div>
                    </div>
                    <div class="sos-detail-item">
                        <small>Nama Pengguna</small>
                        <strong>{{ $selectedSos->user_name }}</strong>
                    </div>
                    <div class="sos-detail-item">
                        <small>Nomor Telepon Pengguna</small>
                        <strong>{{ $selectedSos->user_phone ?: 'Belum dilengkapi pada profil' }}</strong>
                    </div>
                    <div class="sos-detail-item">
                        <small>Waktu Permintaan SOS</small>
                        <strong>{{ $selectedSos->created_at?->format('d F Y, H:i:s') ?? '-' }}</strong>
                    </div>
                    <div class="sos-detail-item">
                        <small>Koordinat Lokasi (Latitude, Longitude)</small>
                        <strong>{{ number_format((float) $selectedSos->latitude, 6, '.', '') }}, {{ number_format((float) $selectedSos->longitude, 6, '.', '') }}</strong>
                    </div>
                    <div class="sos-detail-item">
                        <small>Alamat / Keterangan Lokasi</small>
                        <strong>{{ $selectedSos->address ?: 'Tidak ada keterangan alamat tambahan' }}</strong>
                    </div>
                    @if ($selectedSos->handled_at)
                        <div class="sos-detail-item">
                            <small>Terakhir Diperbarui Oleh Petugas</small>
                            <strong>{{ $selectedSos->handler?->name ?? 'Petugas' }} · {{ $selectedSos->handled_at->format('d M Y, H:i') }}</strong>
                        </div>
                    @endif
                </div>

                <div style="margin-top: 16px; display: flex; flex-wrap: wrap; gap: 10px;">
                    <form method="POST" action="{{ route('petugas.sos.status', $selectedSos) }}" style="display: flex; gap: 8px; flex-wrap: wrap;">
                        @csrf
                        @method('PATCH')
                        <button class="sos-button warning" type="submit" name="status" value="diproses">Tandai Diproses</button>
                        <button class="sos-button success" type="submit" name="status" value="selesai">Tandai Selesai</button>
                    </form>
                </div>
            @else
                <p style="color: var(--sos-muted);">Pilih salah satu permintaan SOS dari daftar di bawah untuk melihat detail lengkapnya.</p>
            @endif
        </section>
    </div>

    <section class="sos-panel">
        <div style="display: flex; flex-wrap: wrap; justify-content: space-between; align-items: center; gap: 12px; margin-bottom: 16px;">
            <h2 style="margin: 0;">Daftar Permintaan SOS Masuk</h2>
            <form method="GET" action="{{ route('petugas.sos.index') }}" style="display: flex; gap: 8px; align-items: center; flex-wrap: wrap;">
                <select name="status" style="border: 1px solid #cbd5e1; border-radius: 8px; padding: 8px 12px; font: inherit;">
                    <option value="">Semua Status</option>
                    <option value="menunggu" @selected(($filters['status'] ?? '') === 'menunggu')>Menunggu</option>
                    <option value="diproses" @selected(($filters['status'] ?? '') === 'diproses')>Diproses</option>
                    <option value="selesai" @selected(($filters['status'] ?? '') === 'selesai')>Selesai</option>
                </select>
                <button class="sos-button" type="submit">Filter</button>
                <a class="sos-button secondary" href="{{ route('petugas.sos.index') }}">Reset</a>
            </form>
        </div>

        <div class="sos-table-wrap">
            <table class="sos-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Waktu</th>
                        <th>Nama Pengguna</th>
                        <th>Nomor Telepon</th>
                        <th>Koordinat (Lat, Lng) & Lokasi</th>
                        <th>Status</th>
                        <th>Aksi Petugas</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse ($sosRequests as $sos)
                        <tr class="{{ $selectedSos && $selectedSos->id === $sos->id ? 'selected-row' : '' }}">
                            <td><strong>#{{ $sos->id }}</strong></td>
                            <td>{{ $sos->created_at?->format('d M Y, H:i:s') ?? '-' }}</td>
                            <td><strong>{{ $sos->user_name }}</strong></td>
                            <td>{{ $sos->user_phone ?: 'Belum diatur' }}</td>
                            <td>
                                <code>{{ number_format((float) $sos->latitude, 6, '.', '') }}, {{ number_format((float) $sos->longitude, 6, '.', '') }}</code>
                                @if ($sos->address)
                                    <br><small>{{ $sos->address }}</small>
                                @endif
                            </td>
                            <td>
                                <span class="sos-badge sos-badge-{{ $sos->status }}">{{ $sos->statusLabel() }}</span>
                            </td>
                            <td>
                                <div style="display: flex; flex-wrap: wrap; gap: 6px;">
                                    <a class="sos-button secondary" href="{{ route('petugas.sos.index', array_merge(request()->query(), ['selected' => $sos->id])) }}">Detail & Peta</a>
                                    <form method="POST" action="{{ route('petugas.sos.status', $sos) }}" style="display: inline-flex; gap: 6px;">
                                        @csrf
                                        @method('PATCH')
                                        <button class="sos-button warning" type="submit" name="status" value="diproses">Diproses</button>
                                        <button class="sos-button success" type="submit" name="status" value="selesai">Selesai</button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="7" style="text-align: center; padding: 26px; color: var(--sos-muted);">Belum ada permintaan bantuan darurat SOS yang ditemukan.</td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        @if ($sosRequests->hasPages())
            <div style="margin-top: 16px;">{{ $sosRequests->links() }}</div>
        @endif
    </section>
</div>

@php
    $sosMapItems = $allSosForMap->map(fn ($item) => [
        'id' => $item->id,
        'user_name' => $item->user_name,
        'user_phone' => $item->user_phone ?: 'Belum diatur',
        'latitude' => (float) $item->latitude,
        'longitude' => (float) $item->longitude,
        'address' => $item->address ?: '-',
        'status_label' => $item->statusLabel(),
        'created_at' => $item->created_at?->format('d M Y, H:i:s') ?? '-',
    ])->values();
    $selectedSosId = $selectedSos?->id;
@endphp

@push('scripts')
<script>
    document.addEventListener('DOMContentLoaded', function () {
        const mapContainer = document.getElementById('sos-admin-map');
        if (!mapContainer || typeof L === 'undefined') return;

        const mapItems = @json($sosMapItems);
        const selectedId = @json($selectedSosId);
        const selectedItem = mapItems.find(item => item.id === selectedId) || mapItems[0];
        const initialCenter = selectedItem
            ? [selectedItem.latitude, selectedItem.longitude]
            : [-0.9471, 100.4172];

        const map = L.map('sos-admin-map').setView(initialCenter, selectedItem ? 15 : 13);
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            maxZoom: 19,
            attribution: '&copy; OpenStreetMap contributors'
        }).addTo(map);

        mapItems.forEach(function (item) {
            const marker = L.marker([item.latitude, item.longitude]).addTo(map);
            marker.bindPopup(
                '<strong>SOS #' + item.id + ' - ' + item.user_name + '</strong><br>' +
                'Telepon: ' + item.user_phone + '<br>' +
                'Koordinat: ' + item.latitude.toFixed(6) + ', ' + item.longitude.toFixed(6) + '<br>' +
                'Lokasi: ' + item.address + '<br>' +
                'Waktu: ' + item.created_at + '<br>' +
                'Status: <strong>' + item.status_label + '</strong>'
            );
            if (selectedId && item.id === selectedId) {
                marker.openPopup();
            }
        });
    });
</script>
@endpush
@endsection
