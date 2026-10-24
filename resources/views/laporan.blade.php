@extends('layouts.app')

@section('title', 'Laporan Riwayat Bencana - SiagaBencana')

@section('content')
<style>
    .reports-page { --report-primary: #123b63; --report-muted: #64748b; color: #0f172a; }
    .reports-header { display: flex; flex-wrap: wrap; align-items: flex-end; justify-content: space-between; gap: 16px; margin-bottom: 24px; }
    .page-title { color: var(--report-primary); margin: 0 0 8px; font-size: clamp(26px, 3vw, 34px); }
    .description { color: var(--report-muted); line-height: 1.7; margin: 0; max-width: 760px; }
    .stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(190px, 1fr)); gap: 16px; margin-bottom: 24px; }
    .stat-card, .info-panel { background: #fff; border: 1px solid #dce6f2; border-radius: 16px; box-shadow: 0 8px 24px rgba(18, 59, 99, .06); }
    .stat-card { padding: 20px; }
    .stat-card p { color: var(--report-muted); font-weight: 600; margin: 0 0 8px; }
    .stat-value { font-size: 28px; font-weight: 750; color: var(--report-primary); }
    .stat-card small { color: var(--report-muted); line-height: 1.5; }
    .info-panel { padding: 22px; margin-bottom: 20px; }
    .info-panel h2 { color: var(--report-primary); font-size: 21px; margin: 0 0 18px; }
    .filter-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 14px; }
    .filter-field { display: grid; gap: 6px; color: #334155; font-size: 14px; font-weight: 600; }
    .filter-field input, .filter-field select, .report-form input, .report-form select, .report-form textarea { width: 100%; border: 1px solid #cbd5e1; border-radius: 9px; padding: 10px 12px; color: #0f172a; background: #fff; font: inherit; }
    .filter-actions, .report-actions { display: flex; flex-wrap: wrap; gap: 10px; align-items: center; margin-top: 16px; }
    .report-button { display: inline-flex; align-items: center; justify-content: center; border: 0; border-radius: 9px; padding: 10px 15px; background: #1e40af; color: #fff; font: inherit; font-weight: 700; text-decoration: none; cursor: pointer; }
    .report-button:hover { background: #1d4ed8; }
    .report-button.secondary { background: #eaf1fa; color: #123b63; }
    .report-button.danger { background: #dc2626; }
    .report-button.success { background: #059669; }
    .report-alert { padding: 12px 15px; border-radius: 10px; margin-bottom: 16px; background: #ecfdf5; color: #065f46; }
    .report-errors { padding: 12px 15px; border-radius: 10px; margin-bottom: 16px; background: #fef2f2; color: #991b1b; }
    .report-table-wrap { overflow-x: auto; }
    .report-table { width: 100%; min-width: 920px; border-collapse: collapse; }
    .report-table th, .report-table td { padding: 13px; border-bottom: 1px solid #e2e8f0; text-align: left; vertical-align: top; }
    .report-table th { background: #f4f7fb; color: #334155; font-size: 13px; }
    .report-table td { color: #475569; line-height: 1.6; }
    .report-table tr:last-child td { border-bottom: 0; }
    .status-badge { display: inline-flex; border-radius: 999px; padding: 5px 10px; font-size: 12px; font-weight: 700; white-space: nowrap; }
    .status-pending { background: #fff7ed; color: #9a3412; }
    .status-verified { background: #ecfdf5; color: #065f46; }
    .status-rejected { background: #fef2f2; color: #991b1b; }
    .source-link { display: block; color: #1d4ed8; overflow-wrap: anywhere; margin-top: 5px; }
    .empty-state { padding: 28px 16px !important; text-align: center !important; color: var(--report-muted) !important; }
    .report-form-grid { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 14px; }
    .report-form .wide { grid-column: 1 / -1; }
    .report-form label { display: grid; gap: 6px; color: #334155; font-weight: 600; }
    .report-form textarea { min-height: 110px; resize: vertical; }
    .field-error { color: #b91c1c; font-size: 13px; }
    .record-actions { display: grid; gap: 8px; min-width: 160px; }
    .record-actions form { display: flex; flex-wrap: wrap; gap: 6px; }
    .record-actions .report-button { padding: 7px 9px; font-size: 12px; }
    .pagination { margin-top: 18px; }
    .pagination nav { display: flex; justify-content: space-between; gap: 10px; }
    @media (max-width: 640px) {
        .info-panel { padding: 17px; }
        .report-form-grid { grid-template-columns: 1fr; }
        .report-form .wide { grid-column: auto; }
        .reports-header { align-items: stretch; }
        .reports-header > .report-button { align-self: flex-start; }
    }
</style>

<div class="reports-page">
    <header class="reports-header">
        <div>
            <h1 class="page-title">Laporan dan Riwayat Bencana</h1>
            <p class="description">Lihat laporan kejadian beserta sumber dan status verifikasinya. Laporan yang belum terverifikasi belum dapat dianggap sebagai kejadian terkonfirmasi.</p>
        </div>
        @auth
            <a class="report-button" href="{{ route('laporan.create') }}">+ Buat laporan</a>
        @else
            <a class="report-button secondary" href="{{ route('laporan.create') }}">Login untuk membuat laporan</a>
        @endif
    </header>

    @if (session('status'))
        <div class="report-alert" role="status">{{ session('status') }}</div>
    @endif

    @if ($errors->any())
        <div class="report-errors" role="alert">
            <strong>Periksa kembali data yang dimasukkan.</strong>
            <ul>@foreach ($errors->all() as $error)<li>{{ $error }}</li>@endforeach</ul>
        </div>
    @endif

    <section class="stats" aria-label="Statistik laporan">
        <article class="stat-card"><p>Total laporan</p><div class="stat-value">{{ number_format($totalReports, 0, ',', '.') }}</div><small>Semua status verifikasi</small></article>
        <article class="stat-card"><p>Jenis bencana</p><div class="stat-value">{{ number_format($disasterTypeCount, 0, ',', '.') }}</div><small>Jenis berbeda dalam data</small></article>
        <article class="stat-card"><p>Wilayah terdampak</p><div class="stat-value">{{ number_format($affectedAreaCount, 0, ',', '.') }}</div><small>Wilayah berbeda yang tercatat</small></article>
        <article class="stat-card"><p>Menunggu verifikasi</p><div class="stat-value">{{ number_format($pendingReports, 0, ',', '.') }}</div><small>Belum dikonfirmasi petugas</small></article>
    </section>

    @if (request()->routeIs('laporan.create') || ($isReportStaff && $editingReport))
        <section class="info-panel" aria-labelledby="report-form-title">
            <h2 id="report-form-title">{{ $editingReport ? 'Perbarui laporan' : 'Buat laporan bencana' }}</h2>
            @unless ($editingReport)
                <p class="description">Isi informasi yang kamu ketahui. Semua bagian boleh dikosongkan kecuali minimal satu informasi kejadian.</p>
            @endunless
            <form class="report-form" method="POST" action="{{ $editingReport ? route('laporan.update', $editingReport) : route('laporan.store') }}">
                @csrf
                @if ($editingReport) @method('PATCH') @endif
                <div class="report-form-grid">
                    <label>Jenis bencana (opsional) <input name="disaster_type" value="{{ old('disaster_type', $editingReport?->disaster_type) }}" maxlength="100">@error('disaster_type')<span class="field-error">{{ $message }}</span>@enderror</label>
                    <label>Tanggal dan waktu kejadian <input type="datetime-local" name="occurred_at" value="{{ old('occurred_at', $editingReport?->occurred_at?->format('Y-m-d\TH:i')) }}">@error('occurred_at')<span class="field-error">{{ $message }}</span>@enderror</label>
                    <label>Provinsi <input name="province" value="{{ old('province', $editingReport?->province) }}" maxlength="120"></label>
                    <label>Kota/kabupaten <input name="city_district" value="{{ old('city_district', $editingReport?->city_district) }}" maxlength="120"></label>
                    <label>Kecamatan <input name="district" value="{{ old('district', $editingReport?->district) }}" maxlength="120"></label>
                    <label>Lokasi/wilayah terdampak <input name="affected_area" value="{{ old('affected_area', $editingReport?->affected_area) }}" maxlength="180"></label>
                    @if ($editingReport)
                        <label>Sumber data
                            <select name="source_type" required>
                                <option value="staff" @selected(old('source_type', $editingReport->source_type) === 'staff')>Input petugas</option>
                                <option value="official" @selected(old('source_type', $editingReport->source_type) === 'official')>Sumber resmi</option>
                                <option value="community" @selected(old('source_type', $editingReport->source_type) === 'community')>Laporan pengguna</option>
                            </select>
                        </label>
                        <label>Nama petugas/instansi sumber <input name="source_name" value="{{ old('source_name', $editingReport->source_name) }}" maxlength="255" required></label>
                        <label class="wide">URL sumber resmi (opsional) <input type="url" name="source_url" value="{{ old('source_url', $editingReport->source_url) }}" maxlength="2048" placeholder="https://"></label>
                    @endif
                    <label class="wide">Deskripsi kejadian (opsional) <textarea name="description" maxlength="10000">{{ old('description', $editingReport?->description) }}</textarea>@error('description')<span class="field-error">{{ $message }}</span>@enderror</label>
                </div>
                <p class="description">Laporan baru dan laporan yang diubah akan berstatus menunggu verifikasi.</p>
                <div class="report-actions"><button class="report-button" type="submit">Simpan laporan</button><a class="report-button secondary" href="{{ route('laporan') }}">Batal</a></div>
            </form>
        </section>
    @endif

    <section class="info-panel" aria-labelledby="filter-title">
        <h2 id="filter-title">Filter riwayat</h2>
        <form method="GET" action="{{ route('laporan') }}">
            <div class="filter-grid">
                <label class="filter-field">Jenis bencana<select name="disaster_type"><option value="">Semua jenis</option>@foreach ($disasterTypes as $type)<option value="{{ $type }}" @selected(($filters['disaster_type'] ?? '') === $type)>{{ $type }}</option>@endforeach</select></label>
                <label class="filter-field">Status verifikasi<select name="verification_status"><option value="">Semua status</option><option value="pending" @selected(($filters['verification_status'] ?? '') === 'pending')>Menunggu verifikasi</option><option value="verified" @selected(($filters['verification_status'] ?? '') === 'verified')>Terverifikasi</option><option value="rejected" @selected(($filters['verification_status'] ?? '') === 'rejected')>Ditolak</option></select></label>
                <label class="filter-field">Sumber data<select name="source_type"><option value="">Semua sumber</option><option value="staff" @selected(($filters['source_type'] ?? '') === 'staff')>Input petugas</option><option value="official" @selected(($filters['source_type'] ?? '') === 'official')>Sumber resmi</option><option value="community" @selected(($filters['source_type'] ?? '') === 'community')>Laporan pengguna</option></select></label>
                <label class="filter-field">Provinsi<select name="province"><option value="">Semua provinsi</option>@foreach ($provinces as $province)<option value="{{ $province }}" @selected(($filters['province'] ?? '') === $province)>{{ $province }}</option>@endforeach</select></label>
                <label class="filter-field">Kota/kabupaten<select name="city_district"><option value="">Semua kota/kabupaten</option>@foreach ($cities as $city)<option value="{{ $city }}" @selected(($filters['city_district'] ?? '') === $city)>{{ $city }}</option>@endforeach</select></label>
                <label class="filter-field">Kecamatan<select name="district"><option value="">Semua kecamatan</option>@foreach ($districts as $district)<option value="{{ $district }}" @selected(($filters['district'] ?? '') === $district)>{{ $district }}</option>@endforeach</select></label>
                <label class="filter-field">Dari tanggal<input type="date" name="start_date" value="{{ $filters['start_date'] ?? '' }}"></label>
                <label class="filter-field">Sampai tanggal<input type="date" name="end_date" value="{{ $filters['end_date'] ?? '' }}"></label>
            </div>
            <div class="filter-actions"><button class="report-button" type="submit">Terapkan filter</button><a class="report-button secondary" href="{{ route('laporan') }}">Reset</a></div>
        </form>
    </section>

    <section class="info-panel" aria-labelledby="history-title">
        <h2 id="history-title">Riwayat laporan</h2>
        <div class="report-table-wrap">
            <table class="report-table">
                <thead><tr><th>Tanggal kejadian</th><th>Jenis bencana</th><th>Wilayah</th><th>Sumber</th><th>Status verifikasi</th><th>Deskripsi</th>@if ($isReportStaff)<th>Aksi petugas</th>@endif</tr></thead>
                <tbody>
                    @forelse ($reports as $report)
                        <tr>
                            <td>{{ $report->occurred_at?->format('d M Y, H:i') ?? 'Waktu belum tersedia' }}</td>
                            <td>{{ $report->disaster_type ?: 'Belum diketahui' }}</td>
                            <td>{{ collect([$report->affected_area, $report->district, $report->city_district, $report->province])->filter()->join(', ') ?: 'Wilayah belum tersedia' }}</td>
                            <td>{{ ['official' => 'Sumber resmi', 'community' => 'Laporan pengguna', 'staff' => 'Input petugas'][$report->source_type] ?? 'Sumber tidak diketahui' }}<br>{{ $report->source_name }}@if (is_string($report->source_url) && (str_starts_with(strtolower($report->source_url), 'https://') || str_starts_with(strtolower($report->source_url), 'http://')))<a class="source-link" href="{{ $report->source_url }}" target="_blank" rel="noopener noreferrer">Lihat sumber</a>@endif</td>
                            <td><span class="status-badge status-{{ $report->verification_status }}">{{ ['pending' => 'Menunggu verifikasi', 'verified' => 'Terverifikasi', 'rejected' => 'Ditolak'][$report->verification_status] ?? 'Status tidak diketahui' }}</span>@if ($report->verified_at)<br><small>{{ $report->verified_at->format('d M Y, H:i') }}@if ($report->verifier) · {{ $report->verifier->name }}@endif</small>@endif</td>
                            <td>{{ $report->description ? \Illuminate\Support\Str::limit($report->description, 240) : 'Belum ada deskripsi.' }}</td>
                            @if ($isReportStaff)
                                <td><div class="record-actions"><a class="report-button secondary" href="{{ route('laporan.edit', $report) }}">Edit</a><form method="POST" action="{{ route('laporan.verify', $report) }}">@csrf @method('PATCH')<button class="report-button success" type="submit" name="verification_status" value="verified">Verifikasi</button><button class="report-button danger" type="submit" name="verification_status" value="rejected">Tolak</button></form></div></td>
                            @endif
                        </tr>
                    @empty
                        <tr><td class="empty-state" colspan="{{ $isReportStaff ? 7 : 6 }}">@if (count($filters))Tidak ada laporan yang cocok dengan filter ini. <a href="{{ route('laporan') }}">Hapus filter</a>.@else Belum ada data laporan. Buat laporan setelah login; tidak ada kejadian contoh yang ditambahkan.@endif</td></tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        @if ($reports->hasPages())<div class="pagination">{{ $reports->links() }}</div>@endif
    </section>

    @if ($isReportStaff)
        <form method="POST" action="{{ route('report-staff.logout') }}">@csrf<button class="report-button secondary" type="submit">Keluar dari akun petugas</button></form>
    @endif
</div>
@endsection
