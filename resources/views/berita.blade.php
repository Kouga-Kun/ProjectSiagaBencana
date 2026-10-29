@extends('layouts.app')

@section('title', 'Berita - SiagaBencana')

@section('content')
<style>
    .page-header { display: flex; flex-wrap: wrap; align-items: flex-end; justify-content: space-between; gap: 16px; margin-bottom: 24px; }
    .page-title { color: var(--primary-color); margin: 0 0 8px; font-size: 28px; }
    .page-desc { color: var(--text-muted); font-size: 16px; line-height: 1.6; max-width: 680px; margin: 0; }
    .filter-bar { background: var(--bg-card); border: 1px solid var(--border-color); border-radius: 14px; padding: 18px; margin-bottom: 28px; box-shadow: 0 4px 12px rgba(0,0,0,0.03); }
    .filter-form { display: flex; flex-wrap: wrap; gap: 12px; align-items: center; }
    .filter-input { flex: 1; min-width: 220px; padding: 11px 14px; border: 1px solid var(--border-color); border-radius: 10px; font: inherit; font-size: 14px; }
    .category-pills { display: flex; flex-wrap: wrap; gap: 8px; margin-top: 14px; }
    .category-pill { display: inline-flex; align-items: center; padding: 8px 14px; border-radius: 999px; font-size: 13px; font-weight: 700; text-decoration: none; border: 1px solid var(--border-color); color: var(--text-dark); background: #f8fafc; transition: all 0.2s; }
    .category-pill.active, .category-pill:hover { background: var(--primary-color); color: white; border-color: var(--primary-color); }

    .headline-card {
        background: var(--bg-card);
        border-radius: 14px;
        overflow: hidden;
        box-shadow: 0 4px 12px rgba(0,0,0,0.04);
        border: 1px solid var(--border-color);
        margin-bottom: 36px;
        display: flex;
        flex-direction: column;
        transition: transform 0.2s ease, box-shadow 0.2s ease;
    }
    .headline-card:hover {
        transform: translateY(-3px);
        box-shadow: 0 12px 20px rgba(0,0,0,0.08);
    }
    .headline-img {
        width: 100%;
        height: 250px;
        background-color: #dbeafe;
        background-size: cover;
        background-position: center;
        position: relative;
        display: flex;
        align-items: center;
        justify-content: center;
        color: var(--primary-color);
        font-size: 48px;
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
        font-size: 13px;
        letter-spacing: 0.5px;
    }
    .headline-content { padding: 26px; }
    .headline-meta { font-size: 13.5px; color: var(--text-muted); margin-bottom: 10px; display: block; font-weight: 600; }
    .headline-title { margin: 0 0 12px; font-size: 24px; color: var(--text-dark); line-height: 1.3; }
    .headline-excerpt { color: var(--text-muted); line-height: 1.65; margin-bottom: 22px; }
    .btn-read {
        display: inline-block; padding: 10px 18px;
        background: var(--primary-color); color: white;
        border-radius: 8px; text-decoration: none;
        font-weight: 700; transition: background 0.2s;
        border: 0; cursor: pointer; font-size: 14px;
    }
    .btn-read:hover { background: var(--primary-hover); color: white; text-decoration: none; }

    .news-section-title {
        font-size: 20px; color: var(--text-dark);
        margin-bottom: 20px; border-bottom: 2px solid var(--border-color);
        padding-bottom: 12px;
    }
    .news-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(290px, 1fr));
        gap: 24px;
    }
    .news-card {
        background: var(--bg-card);
        border-radius: 12px;
        border: 1px solid var(--border-color);
        overflow: hidden;
        display: flex;
        flex-direction: column;
        text-decoration: none;
        color: inherit;
        transition: box-shadow 0.2s ease, transform 0.2s ease;
    }
    .news-card:hover {
        box-shadow: 0 8px 18px rgba(0,0,0,0.07);
        transform: translateY(-3px);
    }
    .news-img {
        height: 185px;
        background-color: #e2e8f0;
        background-size: cover;
        background-position: center;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 38px;
    }
    .news-content { padding: 20px; flex: 1; display: flex; flex-direction: column; }
    .news-category { font-size: 12px; font-weight: 800; color: var(--primary-color); text-transform: uppercase; margin-bottom: 8px; }
    .news-title { font-size: 17.5px; margin: 0 0 10px; color: var(--text-dark); line-height: 1.4; }
    .news-summary { font-size: 14px; color: var(--text-muted); line-height: 1.55; margin: 0 0 14px; }
    .news-date { font-size: 12.5px; color: var(--text-muted); margin-top: auto; font-weight: 600; }
    .empty-box {
        background: white;
        border: 1px solid var(--border-color);
        border-radius: 14px;
        padding: 36px 24px;
        text-align: center;
        color: var(--text-muted);
    }
    @media (min-width: 768px) {
        .headline-card { flex-direction: row; }
        .headline-img { width: 52%; height: auto; min-height: 310px; }
        .headline-content { width: 48%; padding: 36px; display: flex; flex-direction: column; justify-content: center; }
    }
</style>

<div class="page-header">
    <div>
        <h1 class="page-title">Pusat Informasi & Berita Kebencanaan</h1>
        <p class="page-desc">Berita bencana, informasi peringatan dini, informasi wilayah, dan artikel edukasi kesiapsiagaan resmi pada aplikasi SiagaBencana.</p>
    </div>
    @auth
        @if (auth()->user()->isReportStaff())
            <a href="{{ route('petugas.berita.index') }}" class="btn-read">⚙️ Kelola Berita (Admin/Petugas)</a>
        @endif
    @endauth
</div>

<section class="filter-bar" aria-label="Pencarian dan Filter Berita">
    <form method="GET" action="{{ route('berita') }}" class="filter-form">
        @if (!empty($filters['category']))
            <input type="hidden" name="category" value="{{ $filters['category'] }}">
        @endif
        <input
            type="text"
            name="search"
            value="{{ $filters['search'] }}"
            placeholder="Cari berita berdasarkan judul..."
            class="filter-input"
        >
        <button type="submit" class="btn-read">Cari Berita</button>
        @if (!empty($filters['search']) || !empty($filters['category']))
            <a href="{{ route('berita') }}" class="category-pill">Reset Filter</a>
        @endif
    </form>

    <div class="category-pills">
        <a
            href="{{ route('berita', array_filter(['search' => $filters['search']])) }}"
            class="category-pill {{ empty($filters['category']) ? 'active' : '' }}"
        >
            Semua Kategori
        </a>
        @foreach ($categories as $category)
            <a
                href="{{ route('berita', array_filter(['search' => $filters['search'], 'category' => $category])) }}"
                class="category-pill {{ $filters['category'] === $category ? 'active' : '' }}"
            >
                {{ $category }}
            </a>
        @endforeach
    </div>
</section>

@if ($featuredArticle)
    @php
        $featuredImageUrl = \App\Http\Controllers\NewsArticleController::resolveImageUrl($featuredArticle);
        $featuredDate = \App\Http\Controllers\NewsArticleController::formatPublishedDate($featuredArticle->published_at ?? $featuredArticle->created_at);
    @endphp
    <article class="headline-card">
        <div
            class="headline-img"
            @if ($featuredImageUrl)
                style="background-image: url('{{ $featuredImageUrl }}');"
            @endif
        >
            @if (!$featuredImageUrl)
                📰
            @endif
            <span class="headline-badge">BERITA UTAMA · {{ strtoupper($featuredArticle->category) }}</span>
        </div>
        <div class="headline-content">
            <span class="headline-meta">{{ $featuredDate }} • Sumber: {{ $featuredArticle->source }}</span>
            <h2 class="headline-title">{{ $featuredArticle->title }}</h2>
            <p class="headline-excerpt">{{ $featuredArticle->summary }}</p>
            <div>
                <a href="{{ route('berita.show', $featuredArticle->slug) }}" class="btn-read">Baca Selengkapnya →</a>
            </div>
        </div>
    </article>
@endif

<h3 class="news-section-title">Berita Terbaru</h3>

@if ($articles->isEmpty())
    <div class="empty-box">
        <h4 style="color: var(--text-dark); margin: 0 0 8px; font-size: 18px;">Belum ada berita yang ditampilkan</h4>
        <p style="margin: 0;">Belum ada berita yang dipublikasikan atau cocok dengan kriteria pencarian dan kategori yang dipilih.</p>
    </div>
@else
    <div class="news-grid">
        @foreach ($articles as $article)
            @php
                $imageUrl = \App\Http\Controllers\NewsArticleController::resolveImageUrl($article);
                $dateFormatted = \App\Http\Controllers\NewsArticleController::formatPublishedDate($article->published_at ?? $article->created_at);
            @endphp
            <a href="{{ route('berita.show', $article->slug) }}" class="news-card">
                <div
                    class="news-img"
                    @if ($imageUrl)
                        style="background-image: url('{{ $imageUrl }}');"
                    @endif
                >
                    @if (!$imageUrl)
                        📰
                    @endif
                </div>
                <div class="news-content">
                    <span class="news-category">{{ $article->category }}</span>
                    <h4 class="news-title">{{ $article->title }}</h4>
                    <p class="news-summary">{{ \Illuminate\Support\Str::limit($article->summary, 120) }}</p>
                    <span class="news-date">{{ $dateFormatted }} • {{ $article->source }}</span>
                </div>
            </a>
        @endforeach
    </div>
@endif
@endsection
