@extends('layouts.app')

@section('title', $article->title . ' - Berita SiagaBencana')

@section('content')
<style>
    .detail-wrap { max-width: 920px; margin: 0 auto; }
    .back-link { display: inline-flex; align-items: center; gap: 8px; color: var(--primary-color); font-weight: 700; text-decoration: none; margin-bottom: 20px; padding: 9px 14px; background: #eff6ff; border-radius: 10px; }
    .back-link:hover { background: #dbeafe; }
    .detail-card { background: white; border: 1px solid var(--border-color); border-radius: 16px; overflow: hidden; box-shadow: 0 6px 20px rgba(0,0,0,0.04); }
    .detail-hero { width: 100%; height: 360px; background-color: #e2e8f0; background-size: cover; background-position: center; display: flex; align-items: center; justify-content: center; font-size: 64px; }
    .detail-body { padding: 32px; }
    .detail-badge { display: inline-block; background: #eff6ff; color: var(--primary-color); font-weight: 800; font-size: 12px; text-transform: uppercase; padding: 6px 12px; border-radius: 999px; margin-bottom: 14px; }
    .detail-title { margin: 0 0 14px; font-size: clamp(24px, 3vw, 34px); color: var(--text-dark); line-height: 1.3; }
    .detail-meta { display: flex; flex-wrap: wrap; gap: 16px; color: var(--text-muted); font-size: 14px; padding-bottom: 20px; margin-bottom: 22px; border-bottom: 1px solid var(--border-color); }
    .detail-summary { background: #f8fafc; border-left: 4px solid var(--primary-color); padding: 16px 18px; border-radius: 10px; color: #334155; font-weight: 600; line-height: 1.65; margin-bottom: 24px; }
    .detail-content { color: var(--text-dark); font-size: 16px; line-height: 1.8; white-space: pre-line; }
    @media (max-width: 600px) {
        .detail-hero { height: 220px; }
        .detail-body { padding: 22px; }
    }
</style>

@php
    $imageUrl = \App\Http\Controllers\NewsArticleController::resolveImageUrl($article);
    $dateFormatted = \App\Http\Controllers\NewsArticleController::formatPublishedDate($article->published_at ?? $article->created_at);
@endphp

<div class="detail-wrap">
    <a href="{{ route('berita') }}" class="back-link">← Kembali ke Halaman Berita</a>

    <article class="detail-card">
        <div
            class="detail-hero"
            @if ($imageUrl)
                style="background-image: url('{{ $imageUrl }}');"
            @endif
        >
            @if (!$imageUrl)
                📰
            @endif
        </div>

        <div class="detail-body">
            <span class="detail-badge">{{ $article->category }}</span>
            <h1 class="detail-title">{{ $article->title }}</h1>

            <div class="detail-meta">
                <span>📅 {{ $dateFormatted }}</span>
                <span>🏛️ Sumber: <strong>{{ $article->source }}</strong></span>
            </div>

            <div class="detail-summary">
                {{ $article->summary }}
            </div>

            <div class="detail-content">{{ $article->content }}</div>
        </div>
    </article>
</div>
@endsection

