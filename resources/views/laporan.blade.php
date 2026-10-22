
@extends('layouts.app')

@section('title', 'Laporan Riwayat Bencana - SiagaBencana')

@section('content')
<style>
    .page-title { color: #123b63; margin-bottom: 8px; }
    .description { color: #64748b; margin-bottom: 24px; }
    .stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 18px; margin-bottom: 24px; }
    .stat-card { background: white; padding: 22px; border-radius: 12px; box-shadow: 0 3px 12px #0000000a; }
    .stat-card p { color: #64748b; margin-bottom: 8px; }
    .stat-value { font-size: 24px; font-weight: bold; color: #123b63; }
    .info-panel { background: white; padding: 22px; border-radius: 12px; margin-bottom: 20px; }
    .table-wrap { overflow-x: auto; }
    table { width: 100%; border-collapse: collapse; }
    th, td { padding: 13px; border-bottom: 1px solid #e2e8f0; text-align: left; }
    th { background: #f4f7fb; }
</style>

<h1 class="page-title">Laporan dan Riwayat Bencana</h1>
<p class="description">
    Halaman untuk melihat ringkasan statistik dan riwayat kejadian
    bencana di wilayah Kota Padang.
</p>

<div class="stats">
    <div class="stat-card">
        <p>Total kejadian</p>
        <div class="stat-value">—</div>
        <small>Menunggu data terverifikasi</small>
    </div>

    <div class="stat-card">
        <p>Jenis bencana</p>
        <div class="stat-value">—</div>
        <small>Menunggu data terverifikasi</small>
    </div>

    <div class="stat-card">
        <p>Wilayah terdampak</p>
        <div class="stat-value">—</div>
        <small>Menunggu data terverifikasi</small>
    </div>
</div>

<section class="info-panel">
    <h2>Ringkasan Riwayat</h2>
    <p>
        Grafik tren kejadian bencana berdasarkan periode, jenis bencana,
        dan wilayah akan ditampilkan di bagian ini setelah data historis
        tersedia.
    </p>
    <p><strong>Status:</strong> Data statistik belum terhubung.</p>
</section>

<section class="info-panel">
    <h2>Daftar Riwayat Bencana</h2>
    <div class="table-wrap">
        <table>
            <thead>
                <tr>
                    <th>Tanggal</th>
                    <th>Jenis Bencana</th>
                    <th>Wilayah</th>
                    <th>Status Data</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td colspan="4">
                        Belum ada data riwayat yang dimuat.
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
</section>

@endsection
