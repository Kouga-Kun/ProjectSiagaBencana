@extends('layouts.app')

@section('title', $material->title.' · Edukasi Bencana')

@push('styles')
<style>
    .mat-wrap {
        display: grid;
        grid-template-columns: 2fr 1fr;
        gap: 24px;
        align-items: start;
    }
    .mat-card {
        background: #ffffff;
        border: 1px solid #e2e8f0;
        border-radius: 18px;
        padding: 28px;
        box-shadow: 0 4px 14px rgba(15, 23, 42, 0.05);
        margin-bottom: 20px;
    }
    .mat-chip {
        display: inline-flex;
        padding: 5px 12px;
        border-radius: 999px;
        font-size: 12.5px;
        font-weight: 700;
    }
    .mat-btn {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        padding: 11px 18px;
        border-radius: 12px;
        font-weight: 700;
        font-size: 14px;
        text-decoration: none;
        border: none;
        cursor: pointer;
    }
    .mat-section-box {
        border-radius: 14px;
        padding: 18px 20px;
        margin-top: 18px;
    }
    @media (max-width: 900px) {
        .mat-wrap { grid-template-columns: 1fr; }
    }
</style>
@endpush

@section('content')
    <div style="margin-bottom:16px;">
        <a href="{{ route('edukasi.index', ['tab' => 'belajar', 'category' => $material->category]) }}" style="color:#1e3a8a;font-weight:700;text-decoration:none;">
            ← Kembali ke Daftar Materi {{ $material->category }}
        </a>
    </div>

    @if (session('status'))
        <div style="background:#dcfce7;border:1px solid #86efac;color:#166534;padding:14px 18px;border-radius:12px;margin-bottom:18px;font-weight:700;">
            {{ session('status') }}
        </div>
    @endif

    <div class="mat-wrap">
        <div>
            <article class="mat-card">
                <div style="display:flex;flex-wrap:wrap;gap:8px;margin-bottom:14px;">
                    <span class="mat-chip" style="background:{{ $material->category === 'Gempa Bumi' ? '#fef3c7' : '#e0f2fe' }};color:{{ $material->category === 'Gempa Bumi' ? '#b45309' : '#0369a1' }};">
                        {{ $material->category }}
                    </span>
                    <span class="mat-chip" style="background:#f1f5f9;color:#334155;">
                        Tingkat: {{ $material->difficulty }}
                    </span>
                    @if ($isCompleted)
                        <span class="mat-chip" style="background:#dcfce7;color:#15803d;">
                            ✓ Telah Dipelajari
                        </span>
                    @endif
                </div>

                <h1 style="margin:0 0 14px 0;font-size:1.75rem;line-height:1.3;">{{ $material->title }}</h1>

                <!-- Ilustrasi Edukasi -->
                <div style="background:linear-gradient(135deg, {{ $material->category === 'Gempa Bumi' ? '#1e3a8a, #b45309' : '#0369a1, #0f172a' }});color:#ffffff;padding:24px;border-radius:16px;margin-bottom:20px;display:flex;align-items:center;gap:18px;">
                    <div style="font-size:3rem;">{{ $material->category === 'Gempa Bumi' ? '🏚️🛡️' : '🌊🏃' }}</div>
                    <div>
                        <div style="font-size:12px;text-transform:uppercase;letter-spacing:0.5px;opacity:0.85;font-weight:700;">Ringkasan Inti Materi</div>
                        <p style="margin:6px 0 0 0;font-size:0.98rem;line-height:1.55;">{{ $material->summary }}</p>
                    </div>
                </div>

                <!-- Penjelasan Materi -->
                <h2 style="font-size:1.2rem;margin:0 0 10px 0;color:#1e3a8a;">Penjelasan Materi</h2>
                <div style="color:#1e293b;line-height:1.75;font-size:0.98rem;white-space:pre-line;">{{ $material->content }}</div>

                <!-- Poin Penting -->
                @if (! empty($material->key_points))
                    <div class="mat-section-box" style="background:#eff6ff;border:1px solid #bfdbfe;">
                        <h3 style="margin:0 0 10px 0;color:#1e3a8a;font-size:1.08rem;">📌 Poin Penting</h3>
                        <ul style="margin:0;padding-left:20px;line-height:1.7;color:#1e293b;">
                            @foreach ($material->key_points as $point)
                                <li>{{ $point }}</li>
                            @endforeach
                        </ul>
                    </div>
                @endif

                <!-- Langkah yang Harus Dilakukan -->
                @if (! empty($material->action_steps))
                    <div class="mat-section-box" style="background:#f0fdf4;border:1px solid #bbf7d0;">
                        <h3 style="margin:0 0 10px 0;color:#047857;font-size:1.08rem;">✅ Langkah yang Harus Dilakukan</h3>
                        <ol style="margin:0;padding-left:20px;line-height:1.7;color:#1e293b;">
                            @foreach ($material->action_steps as $step)
                                <li>{{ $step }}</li>
                            @endforeach
                        </ol>
                    </div>
                @endif

                <!-- Hal yang Harus Dihindari -->
                @if (! empty($material->things_to_avoid))
                    <div class="mat-section-box" style="background:#fef2f2;border:1px solid #fecaca;">
                        <h3 style="margin:0 0 10px 0;color:#b91c1c;font-size:1.08rem;">⚠️ Hal yang Harus Dihindari</h3>
                        <ul style="margin:0;padding-left:20px;line-height:1.7;color:#7f1d1d;">
                            @foreach ($material->things_to_avoid as $avoid)
                                <li>{{ $avoid }}</li>
                            @endforeach
                        </ul>
                    </div>
                @endif

                <!-- Sumber Referensi -->
                <div style="margin-top:20px;padding-top:16px;border-top:1px solid #e2e8f0;font-size:13.5px;color:#475569;">
                    <strong>Sumber Referensi Resmi:</strong> {{ $material->source_reference }}
                </div>

                <!-- Tombol Tandai Selesai & Navigasi Materi Sebelumnya/Berikutnya -->
                <div style="margin-top:24px;padding-top:20px;border-top:1px solid #e2e8f0;display:flex;flex-wrap:wrap;justify-content:space-between;align-items:center;gap:12px;">
                    <div>
                        @auth
                            <form method="POST" action="{{ route('edukasi.materi.complete', $material) }}">
                                @csrf
                                <input type="hidden" name="is_completed" value="{{ $isCompleted ? '0' : '1' }}">
                                <button type="submit" class="mat-btn" style="background:{{ $isCompleted ? '#059669' : '#1e3a8a' }};color:#ffffff;">
                                    {{ $isCompleted ? '✓ Sudah Ditandai Selesai (Batalkan)' : '✓ Tandai Materi Selesai' }}
                                </button>
                            </form>
                        @else
                            <a href="{{ route('login') }}" class="mat-btn" style="background:#1e3a8a;color:#ffffff;">
                                Masuk untuk Tandai Selesai
                            </a>
                        @endauth
                    </div>

                    <div style="display:flex;gap:10px;">
                        @if ($previousMaterial)
                            <a href="{{ route('edukasi.materi.show', $previousMaterial->slug) }}" class="mat-btn" style="background:#f1f5f9;color:#1e293b;">
                                ← Materi Sebelumnya
                            </a>
                        @endif
                        @if ($nextMaterial)
                            <a href="{{ route('edukasi.materi.show', $nextMaterial->slug) }}" class="mat-btn" style="background:#1e3a8a;color:#ffffff;">
                                Materi Berikutnya →
                            </a>
                        @endif
                    </div>
                </div>
            </article>
        </div>

        <!-- SIDEBAR DAFTAR MATERI SEKATEGORI & INTEGRASI -->
        <aside>
            <div class="mat-card">
                <h3 style="margin:0 0 12px 0;font-size:1.05rem;">Daftar Materi {{ $material->category }}</h3>
                <div style="display:grid;gap:8px;">
                    @foreach ($siblings as $idx => $sib)
                        <a href="{{ route('edukasi.materi.show', $sib->slug) }}"
                           style="display:block;padding:10px 12px;border-radius:10px;text-decoration:none;font-size:13.5px;font-weight:{{ $sib->id === $material->id ? '800' : '600' }};background:{{ $sib->id === $material->id ? '#eff6ff' : '#f8fafc' }};color:{{ $sib->id === $material->id ? '#1e3a8a' : '#334155' }};border:1px solid {{ $sib->id === $material->id ? '#93c5fd' : '#e2e8f0' }};">
                            {{ $idx + 1 }}. {{ $sib->title }}
                        </a>
                    @endforeach
                </div>
            </div>

            <div class="mat-card" style="background:#f8fafc;">
                <h4 style="margin:0 0 8px 0;">Uji Pemahamanmu</h4>
                <p style="margin:0 0 12px 0;font-size:13.5px;color:#475569;">
                    Setelah mempelajari materi ini, uji kemampuan pengambilan keputusanmu melalui Simulasi dan Kuis.
                </p>
                <div style="display:grid;gap:8px;">
                    <a href="{{ route('edukasi.index', ['tab' => 'simulasi', 'category' => $material->category]) }}" class="mat-btn" style="background:#dc2626;color:#ffffff;justify-content:center;">
                        Coba Simulasi {{ $material->category }}
                    </a>
                    <a href="{{ route('edukasi.index', ['tab' => 'kuis', 'category' => $material->category]) }}" class="mat-btn" style="background:#1e3a8a;color:#ffffff;justify-content:center;">
                        Kerjakan Kuis {{ $material->category }}
                    </a>
                </div>
            </div>
        </aside>
    </div>
@endsection

