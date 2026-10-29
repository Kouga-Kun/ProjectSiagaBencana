@extends('layouts.app')

@section('title', 'Kelola Berita Petugas - SiagaBencana')

@section('content')
<style>
    .news-admin-page { --na-primary: #123b63; --na-muted: #64748b; color: #0f172a; }
    .news-admin-header { display: flex; flex-wrap: wrap; align-items: flex-end; justify-content: space-between; gap: 16px; margin-bottom: 24px; }
    .news-admin-title { color: var(--na-primary); margin: 0 0 8px; font-size: clamp(26px, 3vw, 34px); }
    .news-admin-desc { color: var(--na-muted); line-height: 1.7; margin: 0; max-width: 760px; }
    .news-admin-stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(190px, 1fr)); gap: 16px; margin-bottom: 24px; }
    .news-admin-stat, .news-admin-panel { background: #fff; border: 1px solid #dce6f2; border-radius: 16px; box-shadow: 0 8px 24px rgba(18, 59, 99, .06); }
    .news-admin-stat { padding: 20px; }
    .news-admin-stat p { color: var(--na-muted); font-weight: 600; margin: 0 0 8px; }
    .news-admin-stat-value { font-size: 28px; font-weight: 750; color: var(--na-primary); }
    .news-admin-panel { padding: 22px; margin-bottom: 20px; }
    .news-admin-panel h2 { color: var(--na-primary); font-size: 20px; margin: 0 0 16px; }
    .news-admin-grid { display: grid; grid-template-columns: 1fr 1.35fr; gap: 20px; align-items: start; }
    .na-form-group { margin-bottom: 14px; }
    .na-form-group label { display: block; font-size: 13px; font-weight: 700; color: #334155; margin-bottom: 6px; }
    .na-input, .na-select, .na-textarea { width: 100%; border: 1px solid #cbd5e1; border-radius: 10px; padding: 10px 12px; font: inherit; font-size: 14px; background: #fff; color: #0f172a; }
    .na-textarea { resize: vertical; min-height: 90px; }
    .na-btn { display: inline-flex; align-items: center; justify-content: center; border: 0; border-radius: 9px; padding: 9px 14px; background: #1e40af; color: #fff; font: inherit; font-weight: 700; text-decoration: none; cursor: pointer; font-size: 13.5px; }
    .na-btn:hover { opacity: 0.94; }
    .na-btn.secondary { background: #eaf1fa; color: #123b63; }
    .na-btn.warning { background: #d97706; color: #fff; }
    .na-btn.success { background: #059669; color: #fff; }
    .na-btn.danger { background: #dc2626; color: #fff; }
    .na-alert { padding: 12px 15px; border-radius: 10px; margin-bottom: 16px; background: #ecfdf5; color: #065f46; }
    .na-error { padding: 12px 15px; border-radius: 10px; margin-bottom: 16px; background: #fef2f2; color: #991b1b; }
    .na-badge { display: inline-flex; border-radius: 999px; padding: 4px 10px; font-size: 11.5px; font-weight: 700; white-space: nowrap; }
    .na-badge-published { background: #ecfdf5; color: #065f46; }
    .na-badge-draft { background: #fff7ed; color: #9a3412; }
    .na-badge-featured { background: #eff6ff; color: #1e40af; }
    .na-table-wrap { overflow-x: auto; }
    .na-table { width: 100%; min-width: 780px; border-collapse: collapse; }
    .na-table th, .na-table td { padding: 12px; border-bottom: 1px solid #e2e8f0; text-align: left; vertical-align: top; }
    .na-table th { background: #f4f7fb; color: #334155; font-size: 13px; }
    @media (max-width: 980px) {
        .news-admin-grid { grid-template-columns: 1fr; }
    }
</style>

<div class="news-admin-page">
    <header class="news-admin-header">
        <div>
            <h1 class="news-admin-title">📰 Dashboard Pengelolaan Berita</h1>
            <p class="news-admin-desc">Tambah, perbarui, publikasikan, atau hapus artikel berita kebencanaan, peringatan dini, dan edukasi kesiapsiagaan.</p>
        </div>
        <div style="display: flex; gap: 10px; flex-wrap: wrap;">
            <a class="na-btn secondary" href="{{ route('berita') }}">Lihat Halaman Berita Publik →</a>
            <a class="na-btn secondary" href="{{ route('laporan') }}">Halaman Laporan</a>
        </div>
    </header>

    @if (session('status'))
        <div class="na-alert" role="status">{{ session('status') }}</div>
    @endif

    @if ($errors->any())
        <div class="na-error" role="alert">
            <strong>Periksa kembali input berita:</strong>
            <ul style="margin: 6px 0 0; padding-left: 18px;">
                @foreach ($errors->all() as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
        </div>
    @endif

    <section class="news-admin-stats" aria-label="Statistik Berita">
        <article class="news-admin-stat">
            <p>Total Berita</p>
            <div class="news-admin-stat-value">{{ number_format($totalNews, 0, ',', '.') }}</div>
            <small>Seluruh artikel tersimpan</small>
        </article>
        <article class="news-admin-stat">
            <p>Dipublikasikan</p>
            <div class="news-admin-stat-value" style="color: #059669;">{{ number_format($publishedNews, 0, ',', '.') }}</div>
            <small>Tampil kepada masyarakat</small>
        </article>
        <article class="news-admin-stat">
            <p>Draf</p>
            <div class="news-admin-stat-value" style="color: #d97706;">{{ number_format($draftNews, 0, ',', '.') }}</div>
            <small>Belum dipublikasikan</small>
        </article>
        <article class="news-admin-stat">
            <p>Berita Utama</p>
            <div class="news-admin-stat-value" style="color: #1e40af;">{{ number_format($featuredNews, 0, ',', '.') }}</div>
            <small>Ditandai sebagai headline</small>
        </article>
    </section>

    <div class="news-admin-grid">
        <section class="news-admin-panel">
            <h2>{{ $editingArticle ? '✏️ Edit Berita #'.$editingArticle->id : '➕ Tambah Berita Baru' }}</h2>

            <form
                method="POST"
                action="{{ $editingArticle ? route('petugas.berita.update', $editingArticle) : route('petugas.berita.store') }}"
                enctype="multipart/form-data"
            >
                @csrf
                @if ($editingArticle)
                    @method('PATCH')
                @endif

                <div class="na-form-group">
                    <label for="title">Judul Berita *</label>
                    <input
                        id="title"
                        name="title"
                        type="text"
                        class="na-input"
                        required
                        value="{{ old('title', $editingArticle?->title) }}"
                        placeholder="Masukkan judul berita..."
                    >
                </div>

                <div class="na-form-group">
                    <label for="slug">Slug URL (Opsional, otomatis dari judul bila dikosongkan)</label>
                    <input
                        id="slug"
                        name="slug"
                        type="text"
                        class="na-input"
                        value="{{ old('slug', $editingArticle?->slug) }}"
                        placeholder="contoh-judul-berita"
                    >
                </div>

                <div class="na-form-group">
                    <label for="category">Kategori Berita *</label>
                    <select id="category" name="category" class="na-select" required>
                        @foreach ($categories as $category)
                            <option
                                value="{{ $category }}"
                                @selected(old('category', $editingArticle?->category) === $category)
                            >
                                {{ $category }}
                            </option>
                        @endforeach
                    </select>
                </div>

                <div class="na-form-group">
                    <label for="source">Sumber Berita *</label>
                    <input
                        id="source"
                        name="source"
                        type="text"
                        class="na-input"
                        required
                        value="{{ old('source', $editingArticle?->source) }}"
                        placeholder="Contoh: BPBD Kota Padang / BMKG Sumatera Barat"
                    >
                </div>

                <div class="na-form-group">
                    <label for="summary">Ringkasan Berita *</label>
                    <textarea
                        id="summary"
                        name="summary"
                        class="na-textarea"
                        required
                        placeholder="Ringkasan singkat yang ditampilkan pada kartu berita..."
                    >{{ old('summary', $editingArticle?->summary) }}</textarea>
                </div>

                <div class="na-form-group">
                    <label for="content">Isi Berita Lengkap *</label>
                    <textarea
                        id="content"
                        name="content"
                        class="na-textarea"
                        style="min-height: 170px;"
                        required
                        placeholder="Tuliskan isi berita lengkap..."
                    >{{ old('content', $editingArticle?->content) }}</textarea>
                </div>

                <div class="na-form-group">
                    <label for="image">Unggah Gambar Berita (JPG/PNG/WEBP, maks. 4MB)</label>
                    <input id="image" name="image" type="file" class="na-input" accept="image/jpeg,image/png,image/webp">
                </div>

                <div class="na-form-group">
                    <label for="image_url">Atau URL Gambar Eksternal (Opsional)</label>
                    <input
                        id="image_url"
                        name="image_url"
                        type="url"
                        class="na-input"
                        value="{{ old('image_url', ($editingArticle && str_starts_with((string) $editingArticle->image_path, 'http')) ? $editingArticle->image_path : '') }}"
                        placeholder="https://..."
                    >
                </div>

                <div class="na-form-group">
                    <label for="published_at">Tanggal Publikasi (Opsional)</label>
                    <input
                        id="published_at"
                        name="published_at"
                        type="datetime-local"
                        class="na-input"
                        value="{{ old('published_at', $editingArticle?->published_at?->timezone('Asia/Jakarta')->format('Y-m-d\TH:i')) }}"
                    >
                </div>

                <div class="na-form-group">
                    <label for="status">Status Publikasi *</label>
                    <select id="status" name="status" class="na-select" required>
                        <option value="published" @selected(old('status', $editingArticle?->status ?? 'published') === 'published')>
                            Dipublikasikan
                        </option>
                        <option value="draft" @selected(old('status', $editingArticle?->status) === 'draft')>
                            Draf (Belum Ditampilkan ke Publik)
                        </option>
                    </select>
                </div>

                <div class="na-form-group" style="display: flex; align-items: center; gap: 8px;">
                    <input
                        id="is_featured"
                        name="is_featured"
                        type="checkbox"
                        value="1"
                        @checked(old('is_featured', $editingArticle?->is_featured))
                    >
                    <label for="is_featured" style="margin: 0; cursor: pointer;">
                        Tampilkan sebagai Berita Utama (Featured News)
                    </label>
                </div>

                <div style="display: flex; gap: 10px; flex-wrap: wrap; margin-top: 16px;">
                    <button type="submit" class="na-btn">
                        {{ $editingArticle ? 'Simpan Perubahan' : 'Simpan Berita' }}
                    </button>
                    @if ($editingArticle)
                        <a href="{{ route('petugas.berita.index') }}" class="na-btn secondary">Batal Edit</a>
                    @endif
                </div>
            </form>
        </section>

        <section class="news-admin-panel">
            <h2>📋 Daftar Berita</h2>

            <form method="GET" action="{{ route('petugas.berita.index') }}" style="display: flex; gap: 10px; flex-wrap: wrap; margin-bottom: 16px;">
                <input
                    type="text"
                    name="search"
                    value="{{ $filters['search'] }}"
                    placeholder="Cari judul berita..."
                    class="na-input"
                    style="flex: 1; min-width: 180px;"
                >
                <select name="category" class="na-select" style="width: auto; min-width: 170px;">
                    <option value="">Semua Kategori</option>
                    @foreach ($categories as $category)
                        <option value="{{ $category }}" @selected($filters['category'] === $category)>{{ $category }}</option>
                    @endforeach
                </select>
                <select name="status" class="na-select" style="width: auto; min-width: 140px;">
                    <option value="">Semua Status</option>
                    <option value="published" @selected($filters['status'] === 'published')>Dipublikasikan</option>
                    <option value="draft" @selected($filters['status'] === 'draft')>Draf</option>
                </select>
                <button type="submit" class="na-btn">Filter</button>
                <a href="{{ route('petugas.berita.index') }}" class="na-btn secondary">Reset</a>
            </form>

            <div class="na-table-wrap">
                <table class="na-table">
                    <thead>
                        <tr>
                            <th>Judul & Ringkasan</th>
                            <th>Kategori & Sumber</th>
                            <th>Status & Tanggal</th>
                            <th>Aksi</th>
                        </tr>
                    </thead>
                    <tbody>
                        @forelse ($articles as $item)
                            <tr>
                                <td>
                                    <strong style="display: block; color: #0f172a; margin-bottom: 4px;">{{ $item->title }}</strong>
                                    <small style="color: #64748b; display: block; margin-bottom: 4px;">Slug: {{ $item->slug }}</small>
                                    <span style="font-size: 13px; color: #475569;">{{ \Illuminate\Support\Str::limit($item->summary, 110) }}</span>
                                </td>
                                <td>
                                    <strong>{{ $item->category }}</strong>
                                    <br>
                                    <small style="color: #64748b;">Sumber: {{ $item->source }}</small>
                                </td>
                                <td>
                                    <div style="display: flex; flex-direction: column; gap: 6px; align-items: flex-start;">
                                        <span class="na-badge {{ $item->isPublished() ? 'na-badge-published' : 'na-badge-draft' }}">
                                            {{ $item->statusLabel() }}
                                        </span>
                                        @if ($item->is_featured)
                                            <span class="na-badge na-badge-featured">Berita Utama</span>
                                        @endif
                                        <small style="color: #64748b;">
                                            {{ \App\Http\Controllers\NewsArticleController::formatPublishedDate($item->published_at ?? $item->created_at) }}
                                        </small>
                                    </div>
                                </td>
                                <td>
                                    <div style="display: flex; gap: 6px; flex-wrap: wrap;">
                                        <a href="{{ route('petugas.berita.index', array_merge($filters, ['edit' => $item->id])) }}" class="na-btn secondary">
                                            Edit
                                        </a>
                                        <form method="POST" action="{{ route('petugas.berita.publish', $item) }}" style="margin: 0;">
                                            @csrf
                                            @method('PATCH')
                                            <button type="submit" class="na-btn {{ $item->isPublished() ? 'warning' : 'success' }}">
                                                {{ $item->isPublished() ? 'Jadikan Draf' : 'Publikasikan' }}
                                            </button>
                                        </form>
                                        <form
                                            method="POST"
                                            action="{{ route('petugas.berita.destroy', $item) }}"
                                            style="margin: 0;"
                                            onsubmit="return confirm('Hapus berita ini secara permanen?');"
                                        >
                                            @csrf
                                            @method('DELETE')
                                            <button type="submit" class="na-btn danger">Hapus</button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="4" style="text-align: center; padding: 28px; color: #64748b;">
                                    Belum ada data berita. Gunakan formulir di samping untuk menambahkan berita baru.
                                </td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>

            @if ($articles->hasPages())
                <div style="margin-top: 16px;">
                    {{ $articles->links() }}
                </div>
            @endif
        </section>
    </div>
</div>
@endsection

