@extends('layouts.app')

@section('title', 'Edukasi Gempa Bumi dan Tsunami · SiagaBencana')

@push('styles')
<style>
    .edu-hero {
        background: linear-gradient(135deg, #1e3a8a 0%, #0f172a 100%);
        color: #ffffff;
        border-radius: 20px;
        padding: 32px;
        display: grid;
        grid-template-columns: 1.5fr 1fr;
        gap: 24px;
        align-items: center;
        box-shadow: 0 12px 28px rgba(15, 23, 42, 0.16);
        margin-bottom: 24px;
    }
    .edu-hero-badge {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        background: rgba(255, 255, 255, 0.15);
        padding: 6px 14px;
        border-radius: 999px;
        font-size: 12.5px;
        font-weight: 700;
        letter-spacing: 0.4px;
        text-transform: uppercase;
        margin-bottom: 12px;
    }
    .edu-hero h1 {
        margin: 0 0 8px 0;
        font-size: 2rem;
        line-height: 1.25;
    }
    .edu-subtitle {
        margin: 0 0 12px 0;
        font-size: 1.1rem;
        font-weight: 700;
        color: #93c5fd;
    }
    .edu-hero p {
        margin: 0 0 20px 0;
        color: #e2e8f0;
        line-height: 1.6;
        font-size: 0.96rem;
    }
    .edu-cta-row {
        display: flex;
        flex-wrap: wrap;
        gap: 12px;
    }
    .edu-btn {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
        padding: 11px 18px;
        border-radius: 12px;
        font-weight: 700;
        font-size: 14px;
        text-decoration: none;
        border: none;
        cursor: pointer;
        transition: all 0.2s ease;
    }
    .edu-btn-primary {
        background: #dc2626;
        color: #ffffff;
    }
    .edu-btn-primary:hover { background: #b91c1c; }
    .edu-btn-secondary {
        background: rgba(255, 255, 255, 0.14);
        color: #ffffff;
        border: 1px solid rgba(255, 255, 255, 0.28);
    }
    .edu-btn-secondary:hover { background: rgba(255, 255, 255, 0.22); }
    .edu-btn-navy {
        background: #1e3a8a;
        color: #ffffff;
    }
    .edu-btn-navy:hover { background: #1e40af; }
    .edu-btn-outline {
        background: #ffffff;
        color: #1e3a8a;
        border: 1px solid #cbd5e1;
    }
    .edu-illustration-box {
        background: rgba(255, 255, 255, 0.08);
        border: 1px solid rgba(255, 255, 255, 0.18);
        border-radius: 18px;
        padding: 20px;
        text-align: center;
    }
    .edu-grid-2 {
        display: grid;
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 18px;
        margin-bottom: 24px;
    }
    .edu-cat-card {
        background: #ffffff;
        border-radius: 18px;
        padding: 24px;
        border: 1px solid #e2e8f0;
        box-shadow: 0 4px 14px rgba(15, 23, 42, 0.05);
        display: flex;
        flex-direction: column;
        justify-content: space-between;
        gap: 14px;
    }
    .edu-cat-card.gempa { border-left: 6px solid #d97706; }
    .edu-cat-card.tsunami { border-left: 6px solid #0284c7; }
    .edu-progress-panel {
        background: #ffffff;
        border-radius: 18px;
        padding: 22px 24px;
        border: 1px solid #e2e8f0;
        margin-bottom: 24px;
        box-shadow: 0 4px 14px rgba(15, 23, 42, 0.04);
    }
    .edu-progress-bar-bg {
        width: 100%;
        height: 12px;
        background: #e2e8f0;
        border-radius: 999px;
        overflow: hidden;
        margin: 10px 0 16px 0;
    }
    .edu-progress-bar-fill {
        height: 100%;
        background: linear-gradient(90deg, #1e3a8a, #059669);
        border-radius: 999px;
    }
    .edu-stats-grid {
        display: grid;
        grid-template-columns: repeat(5, minmax(0, 1fr));
        gap: 12px;
    }
    .edu-stat-item {
        background: #f8fafc;
        border: 1px solid #e2e8f0;
        border-radius: 12px;
        padding: 12px 14px;
    }
    .edu-stat-item .val {
        font-size: 1.35rem;
        font-weight: 800;
        color: #1e3a8a;
    }
    .edu-stat-item .lbl {
        font-size: 12.5px;
        color: #64748b;
        margin-top: 2px;
    }
    .edu-tabs {
        display: flex;
        flex-wrap: wrap;
        gap: 10px;
        margin-bottom: 22px;
    }
    .edu-tab-link {
        padding: 11px 20px;
        border-radius: 12px;
        background: #ffffff;
        border: 1px solid #cbd5e1;
        color: #334155;
        font-weight: 700;
        text-decoration: none;
        font-size: 14.5px;
    }
    .edu-tab-link.active {
        background: #1e3a8a;
        color: #ffffff;
        border-color: #1e3a8a;
    }
    .edu-filter-bar {
        background: #ffffff;
        border: 1px solid #e2e8f0;
        border-radius: 16px;
        padding: 16px;
        margin-bottom: 20px;
        display: flex;
        flex-wrap: wrap;
        gap: 12px;
        align-items: center;
    }
    .edu-input, .edu-select {
        padding: 10px 14px;
        border-radius: 10px;
        border: 1px solid #cbd5e1;
        font-size: 14px;
        background: #ffffff;
    }
    .edu-cards-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(310px, 1fr));
        gap: 18px;
    }
    .edu-item-card {
        background: #ffffff;
        border: 1px solid #e2e8f0;
        border-radius: 16px;
        padding: 20px;
        display: flex;
        flex-direction: column;
        justify-content: space-between;
        gap: 14px;
        box-shadow: 0 2px 10px rgba(15, 23, 42, 0.04);
    }
    .edu-chip {
        display: inline-flex;
        align-items: center;
        padding: 4px 10px;
        border-radius: 999px;
        font-size: 12px;
        font-weight: 700;
    }
    .chip-gempa { background: #fef3c7; color: #b45309; }
    .chip-tsunami { background: #e0f2fe; color: #0369a1; }
    .chip-dasar { background: #dcfce7; color: #15803d; }
    .chip-menengah { background: #fef9c3; color: #a16207; }
    .chip-lanjutan { background: #fee2e2; color: #b91c1c; }
    .chip-done { background: #d1fae5; color: #047857; }
    @media (max-width: 900px) {
        .edu-hero { grid-template-columns: 1fr; padding: 24px; }
        .edu-grid-2 { grid-template-columns: 1fr; }
        .edu-stats-grid { grid-template-columns: repeat(2, minmax(0, 1fr)); }
    }
</style>
@endpush

@section('content')
    @if (session('status'))
        <div style="background:#dcfce7;border:1px solid #86efac;color:#166534;padding:14px 18px;border-radius:12px;margin-bottom:18px;font-weight:700;">
            {{ session('status') }}
        </div>
    @endif

    <!-- HEADER UTAMA EDUKASI GEMPA BUMI DAN TSUNAMI -->
    <section class="edu-hero">
        <div>
            <div class="edu-hero-badge">🛡️ Pusat Edukasi Mitigasi SiagaBencana</div>
            <h1>Edukasi Gempa Bumi dan Tsunami</h1>
            <div class="edu-subtitle">"Kenali Risikonya, Lindungi Dirimu, Selamatkan Sesama."</div>
            <p>
                Wilayah pesisir dan patahan aktif memiliki risiko gempa bumi dan tsunami yang dapat terjadi sewaktu-waktu.
                Pelajari cara mengenali tanda bahaya, menyiapkan tas siaga, melakukan prosedur <strong>Drop, Cover, and Hold On</strong>,
                serta mengevakuasi diri secara mandiri ke tempat tinggi sesuai pedoman resmi BNPB, BMKG, Basarnas, dan BPBD.
            </p>
            <div class="edu-cta-row">
                <a href="{{ route('edukasi.index', ['tab' => 'belajar']) }}#area-fitur" class="edu-btn edu-btn-primary">
                    Mulai Belajar Sekarang
                </a>
                <a href="{{ route('edukasi.index', ['tab' => 'simulasi']) }}#area-fitur" class="edu-btn edu-btn-secondary">
                    Coba Simulasi Skenario
                </a>
                <a href="{{ route('evakuasi') }}" class="edu-btn edu-btn-secondary">
                    Lihat Peta Evakuasi
                </a>
            </div>
        </div>
        <div class="edu-illustration-box">
            <div style="font-size:3.2rem;margin-bottom:8px;">🌍 🌊 🏃</div>
            <h3 style="margin:0 0 6px 0;font-size:1.1rem;color:#ffffff;">Prinsip Emas Kesiapsiagaan Pesisir</h3>
            <p style="margin:0;font-size:0.88rem;color:#cbd5e1;">
                Jika merasakan gempa kuat (sulit berdiri) atau guncangan berlangsung lama (&gt;20 detik) di wilayah pantai,
                <strong>segera evakuasi ke tempat tinggi (&gt;20 mdpl)</strong> tanpa menunggu bunyi sirine resmi.
            </p>
        </div>
    </section>

    <!-- KATEGORI UTAMA: GEMPA BUMI & TSUNAMI -->
    <section class="edu-grid-2">
        <div class="edu-cat-card gempa">
            <div>
                <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:10px;">
                    <span class="edu-chip chip-gempa">A. Kategori Utama</span>
                    <span style="font-size:1.8rem;">🏚️</span>
                </div>
                <h2 style="margin:0 0 8px 0;font-size:1.35rem;">Gempa Bumi</h2>
                <p style="margin:0;color:#475569;line-height:1.55;font-size:0.95rem;">
                    Pelajari pengertian, penyebab, dan karakteristik gempa bumi, persiapan rumah tahan guncangan,
                    tindakan perlindungan diri di rumah, sekolah, gedung bertingkat, hingga penanganan bahaya susulan.
                </p>
            </div>
            <div style="display:flex;align-items:center;justify-content:space-between;padding-top:8px;border-top:1px solid #f1f5f9;">
                <span style="font-size:13px;color:#64748b;font-weight:600;">
                    12 Materi · 6 Simulasi · Kuis &amp; 7 Misi Siaga
                </span>
                <a href="{{ route('edukasi.index', ['tab' => 'belajar', 'category' => 'Gempa Bumi']) }}#area-fitur" class="edu-btn edu-btn-navy">
                    Pelajari Gempa Bumi
                </a>
            </div>
        </div>

        <div class="edu-cat-card tsunami">
            <div>
                <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:10px;">
                    <span class="edu-chip chip-tsunami">B. Kategori Utama</span>
                    <span style="font-size:1.8rem;">🌊</span>
                </div>
                <h2 style="margin:0 0 8px 0;font-size:1.35rem;">Tsunami</h2>
                <p style="margin:0;color:#475569;line-height:1.55;font-size:0.95rem;">
                    Pahami hubungan gempa bawah laut dengan tsunami, level peringatan dini BMKG (Awas, Siaga, Waspada),
                    tanda alam surutnya air laut, serta cara evakuasi cepat menuju tempat tinggi atau shelter vertikal.
                </p>
            </div>
            <div style="display:flex;align-items:center;justify-content:space-between;padding-top:8px;border-top:1px solid #f1f5f9;">
                <span style="font-size:13px;color:#64748b;font-weight:600;">
                    12 Materi · 6 Simulasi · Kuis &amp; 7 Misi Siaga
                </span>
                <a href="{{ route('edukasi.index', ['tab' => 'belajar', 'category' => 'Tsunami']) }}#area-fitur" class="edu-btn edu-btn-navy">
                    Pelajari Tsunami
                </a>
            </div>
        </div>
    </section>

    <!-- BAGIAN PROGRES PENGGUNA -->
    <section class="edu-progress-panel">
        <div style="display:flex;flex-wrap:wrap;justify-content:space-between;align-items:center;gap:12px;">
            <div>
                <h3 style="margin:0;font-size:1.15rem;">Progres Kesiapsiagaan Gempa Bumi &amp; Tsunami</h3>
                <p style="margin:4px 0 0 0;font-size:13.5px;color:#64748b;">
                    {{ $progress['initial_state_message'] ?? 'Pantau capaian belajar, simulasi, kuis, dan misi kesiapsiagaan keluarga.' }}
                </p>
            </div>
            <div style="display:flex;align-items:center;gap:12px;">
                <span style="font-size:1.4rem;font-weight:800;color:#1e3a8a;">
                    {{ $progress['overall_progress_percentage'] ?? 0 }}%
                </span>
                <span class="edu-chip chip-done">⭐ {{ $progress['total_points'] ?? 0 }} Poin Siaga</span>
            </div>
        </div>

        <div class="edu-progress-bar-bg">
            <div class="edu-progress-bar-fill" style="width: {{ min(100, max(0, (float) ($progress['overall_progress_percentage'] ?? 0))) }}%;"></div>
        </div>

        <div class="edu-stats-grid">
            <div class="edu-stat-item">
                <div class="val">{{ $progress['materials']['completed'] ?? 0 }} / {{ $progress['materials']['total'] ?? 24 }}</div>
                <div class="lbl">Materi Selesai</div>
            </div>
            <div class="edu-stat-item">
                <div class="val">{{ $progress['simulations']['completed'] ?? 0 }} / {{ $progress['simulations']['total'] ?? 12 }}</div>
                <div class="lbl">Simulasi Diselesaikan</div>
            </div>
            <div class="edu-stat-item">
                <div class="val">{{ $progress['quizzes']['completed_quizzes'] ?? 0 }} / {{ $progress['quizzes']['total_quizzes'] ?? 4 }}</div>
                <div class="lbl">Kuis Dikerjakan</div>
            </div>
            <div class="edu-stat-item">
                <div class="val">{{ $progress['missions']['completed'] ?? 0 }} / {{ $progress['missions']['total'] ?? 14 }}</div>
                <div class="lbl">Misi Siaga Selesai</div>
            </div>
            <div class="edu-stat-item">
                <div class="val">{{ $progress['badges']['earned_count'] ?? 0 }} / {{ $progress['badges']['total_count'] ?? 5 }}</div>
                <div class="lbl">Badge Penghargaan</div>
            </div>
        </div>
    </section>

    <!-- EMPAT MENU FITUR UTAMA EDUKASI -->
    <div id="area-fitur" class="edu-tabs">
        <a href="{{ route('edukasi.index', ['tab' => 'belajar', 'category' => $selectedCategory]) }}#area-fitur"
           class="edu-tab-link {{ $activeTab === 'belajar' ? 'active' : '' }}">
            📚 1. Belajar ({{ $materials->count() }})
        </a>
        <a href="{{ route('edukasi.index', ['tab' => 'simulasi', 'category' => $selectedCategory]) }}#area-fitur"
           class="edu-tab-link {{ $activeTab === 'simulasi' ? 'active' : '' }}">
            🎮 2. Simulasi ({{ $simulations->count() }})
        </a>
        <a href="{{ route('edukasi.index', ['tab' => 'kuis', 'category' => $selectedCategory]) }}#area-fitur"
           class="edu-tab-link {{ $activeTab === 'kuis' ? 'active' : '' }}">
            📝 3. Kuis ({{ $quizzes->count() }})
        </a>
        <a href="{{ route('edukasi.index', ['tab' => 'misi', 'category' => $selectedCategory]) }}#area-fitur"
           class="edu-tab-link {{ $activeTab === 'misi' ? 'active' : '' }}">
            🎯 4. Misi Siaga ({{ $missions->count() }})
        </a>
        <a href="{{ route('edukasi.index', ['tab' => 'progres']) }}#area-fitur"
           class="edu-tab-link {{ $activeTab === 'progres' ? 'active' : '' }}">
            🏆 Progres &amp; Pencapaian
        </a>
    </div>

    @if ($activeTab === 'belajar')
        <!-- FILTER & PENCARIAN MATERI -->
        <form method="GET" action="{{ route('edukasi.index') }}" class="edu-filter-bar">
            <input type="hidden" name="tab" value="belajar">
            <input type="text" name="search" value="{{ $search }}" placeholder="Cari materi gempa bumi atau tsunami..." class="edu-input" style="flex:1;min-width:220px;">
            <select name="category" class="edu-select">
                <option value="">Semua Kategori (Gempa &amp; Tsunami)</option>
                <option value="Gempa Bumi" {{ $selectedCategory === 'Gempa Bumi' ? 'selected' : '' }}>Gempa Bumi</option>
                <option value="Tsunami" {{ $selectedCategory === 'Tsunami' ? 'selected' : '' }}>Tsunami</option>
            </select>
            <select name="difficulty" class="edu-select">
                <option value="">Semua Tingkat Kesulitan</option>
                <option value="Dasar" {{ $selectedDifficulty === 'Dasar' ? 'selected' : '' }}>Dasar</option>
                <option value="Menengah" {{ $selectedDifficulty === 'Menengah' ? 'selected' : '' }}>Menengah</option>
                <option value="Lanjutan" {{ $selectedDifficulty === 'Lanjutan' ? 'selected' : '' }}>Lanjutan</option>
            </select>
            <button type="submit" class="edu-btn edu-btn-navy">Terapkan Filter</button>
            @if ($search !== '' || $selectedCategory !== '' || $selectedDifficulty !== '')
                <a href="{{ route('edukasi.index', ['tab' => 'belajar']) }}" class="edu-btn edu-btn-outline">Reset</a>
            @endif
        </form>

        <div class="edu-cards-grid">
            @forelse ($materials as $item)
                @php
                    $isDone = in_array($item->id, $completedMaterialIds, true);
                    $diffClass = $item->difficulty === 'Dasar' ? 'chip-dasar' : ($item->difficulty === 'Menengah' ? 'chip-menengah' : 'chip-lanjutan');
                @endphp
                <article class="edu-item-card">
                    <div>
                        <div style="display:flex;flex-wrap:wrap;gap:6px;margin-bottom:10px;">
                            <span class="edu-chip {{ $item->category === 'Gempa Bumi' ? 'chip-gempa' : 'chip-tsunami' }}">
                                {{ $item->category }}
                            </span>
                            <span class="edu-chip {{ $diffClass }}">
                                {{ $item->difficulty }}
                            </span>
                            @if ($isDone)
                                <span class="edu-chip chip-done">✓ Selesai</span>
                            @endif
                        </div>
                        <h3 style="margin:0 0 8px 0;font-size:1.1rem;line-height:1.35;">
                            {{ $item->title }}
                        </h3>
                        <p style="margin:0;color:#475569;font-size:0.9rem;line-height:1.55;">
                            {{ $item->summary }}
                        </p>
                    </div>
                    <div style="display:flex;align-items:center;justify-content:space-between;padding-top:12px;border-top:1px solid #f1f5f9;">
                        <span style="font-size:12px;color:#64748b;">Ref: {{ \Illuminate\Support\Str::limit($item->source_reference, 28) }}</span>
                        <a href="{{ route('edukasi.materi.show', $item->slug) }}" class="edu-btn edu-btn-navy" style="padding:8px 14px;font-size:13px;">
                            Baca Materi →
                        </a>
                    </div>
                </article>
            @empty
                <div style="grid-column: 1 / -1; background:#ffffff; padding:32px; border-radius:16px; text-align:center;">
                    Tidak ada materi yang cocok dengan kata kunci pencarian Anda.
                </div>
            @endforelse
        </div>
    @elseif ($activeTab === 'simulasi')
        <div class="edu-cards-grid">
            @foreach ($simulations as $sim)
                @php
                    $diffClass = $sim->difficulty === 'Dasar' ? 'chip-dasar' : ($sim->difficulty === 'Menengah' ? 'chip-menengah' : 'chip-lanjutan');
                @endphp
                <article class="edu-item-card">
                    <div>
                        <div style="display:flex;flex-wrap:wrap;gap:6px;margin-bottom:10px;">
                            <span class="edu-chip {{ $sim->category === 'Gempa Bumi' ? 'chip-gempa' : 'chip-tsunami' }}">
                                Simulasi {{ $sim->category }}
                            </span>
                            <span class="edu-chip {{ $diffClass }}">{{ $sim->difficulty }}</span>
                        </div>
                        <h3 style="margin:0 0 8px 0;font-size:1.1rem;">{{ $sim->title }}</h3>
                        <p style="margin:0 0 10px 0;color:#475569;font-size:0.9rem;line-height:1.55;">
                            {{ $sim->description }}
                        </p>
                        <div style="background:#f8fafc;border-left:3px solid #1e3a8a;padding:10px 12px;border-radius:8px;font-size:0.86rem;color:#334155;">
                            "{{ \Illuminate\Support\Str::limit($sim->scenario_context, 130) }}"
                        </div>
                    </div>
                    <div style="display:flex;align-items:center;justify-content:space-between;padding-top:12px;border-top:1px solid #f1f5f9;">
                        <span style="font-size:12.5px;color:#64748b;font-weight:600;">{{ $sim->steps->count() }} Tahap Keputusan</span>
                        <a href="{{ route('edukasi.simulasi.show', $sim->slug) }}" class="edu-btn edu-btn-primary" style="padding:8px 14px;font-size:13px;">
                            Mulai Simulasi
                        </a>
                    </div>
                </article>
            @endforeach
        </div>
    @elseif ($activeTab === 'kuis')
        <div class="edu-cards-grid">
            @foreach ($quizzes as $quiz)
                @php
                    $diffClass = $quiz->difficulty === 'Dasar' ? 'chip-dasar' : ($quiz->difficulty === 'Menengah' ? 'chip-menengah' : 'chip-lanjutan');
                @endphp
                <article class="edu-item-card">
                    <div>
                        <div style="display:flex;flex-wrap:wrap;gap:6px;margin-bottom:10px;">
                            <span class="edu-chip {{ $quiz->category === 'Gempa Bumi' ? 'chip-gempa' : 'chip-tsunami' }}">
                                {{ $quiz->category }}
                            </span>
                            <span class="edu-chip {{ $diffClass }}">{{ $quiz->difficulty }}</span>
                        </div>
                        <h3 style="margin:0 0 8px 0;font-size:1.12rem;">{{ $quiz->title }}</h3>
                        <p style="margin:0 0 8px 0;color:#475569;font-size:0.9rem;line-height:1.55;">
                            {{ $quiz->description }}
                        </p>
                        <div style="font-size:12.5px;color:#64748b;">Topik: {{ $quiz->topic }}</div>
                    </div>
                    <div style="display:flex;align-items:center;justify-content:space-between;padding-top:12px;border-top:1px solid #f1f5f9;">
                        <span style="font-size:13px;font-weight:700;color:#1e3a8a;">{{ $quiz->questions_count }} Soal Pilihan Ganda</span>
                        <a href="{{ route('edukasi.kuis.show', $quiz->slug) }}" class="edu-btn edu-btn-navy" style="padding:8px 14px;font-size:13px;">
                            Kerjakan Kuis →
                        </a>
                    </div>
                </article>
            @endforeach
        </div>
    @elseif ($activeTab === 'misi')
        <div class="edu-cards-grid">
            @foreach ($missions as $mission)
                @php
                    $um = $userMissionMap->get($mission->id);
                    $uStatus = $um?->status ?? \App\Models\UserMission::STATUS_NOT_STARTED;
                    $uLabel = \App\Models\UserMission::labelForStatus($uStatus);
                    $diffClass = $mission->difficulty === 'Dasar' ? 'chip-dasar' : ($mission->difficulty === 'Menengah' ? 'chip-menengah' : 'chip-lanjutan');
                @endphp
                <article class="edu-item-card">
                    <div>
                        <div style="display:flex;flex-wrap:wrap;justify-content:space-between;gap:6px;margin-bottom:10px;">
                            <div style="display:flex;gap:6px;">
                                <span class="edu-chip {{ $mission->category === 'Gempa Bumi' ? 'chip-gempa' : 'chip-tsunami' }}">
                                    {{ $mission->category }}
                                </span>
                                <span class="edu-chip {{ $diffClass }}">{{ $mission->difficulty }}</span>
                            </div>
                            <span class="edu-chip chip-done">+{{ $mission->points }} Poin</span>
                        </div>
                        <h3 style="margin:0 0 8px 0;font-size:1.08rem;">{{ $mission->title }}</h3>
                        <p style="margin:0 0 10px 0;color:#475569;font-size:0.9rem;line-height:1.5;">
                            {{ $mission->description }}
                        </p>
                        @if (! empty($mission->instructions))
                            <ul style="margin:0;padding-left:18px;font-size:0.86rem;color:#334155;line-height:1.5;">
                                @foreach ($mission->instructions as $inst)
                                    <li>{{ $inst }}</li>
                                @endforeach
                            </ul>
                        @endif
                    </div>

                    <div style="padding-top:12px;border-top:1px solid #f1f5f9;">
                        <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:8px;">
                            <span style="font-size:12.5px;color:#64748b;">Status Misi:</span>
                            <span class="edu-chip {{ $uStatus === 'selesai' ? 'chip-done' : ($uStatus === 'sedang_dikerjakan' ? 'chip-menengah' : 'chip-gempa') }}">
                                {{ $uLabel }}
                            </span>
                        </div>
                        @auth
                            <form method="POST" action="{{ route('edukasi.misi.status', $mission) }}" style="display:flex;gap:8px;">
                                @csrf
                                <select name="status" class="edu-select" style="flex:1;padding:7px 10px;font-size:13px;">
                                    <option value="belum_dimulai" {{ $uStatus === 'belum_dimulai' ? 'selected' : '' }}>Belum dimulai</option>
                                    <option value="sedang_dikerjakan" {{ $uStatus === 'sedang_dikerjakan' ? 'selected' : '' }}>Sedang dikerjakan</option>
                                    <option value="selesai" {{ $uStatus === 'selesai' ? 'selected' : '' }}>Selesai</option>
                                </select>
                                <button type="submit" class="edu-btn edu-btn-navy" style="padding:7px 12px;font-size:13px;">Simpan</button>
                            </form>
                        @else
                            <a href="{{ route('login') }}" style="font-size:12.5px;color:#1e3a8a;font-weight:700;text-decoration:none;">
                                Masuk akun untuk menyimpan progres misi →
                            </a>
                        @endauth
                    </div>
                </article>
            @endforeach
        </div>
    @else
        <!-- TAB PROGRES & BADGE PENCAPAIAN -->
        <div class="edu-grid-2">
            <div class="edu-cat-card">
                <h3 style="margin:0 0 12px 0;">Badge &amp; Penghargaan Kesiapsiagaan</h3>
                <div style="display:grid;gap:12px;">
                    @foreach ($progress['badges']['items'] ?? [] as $badge)
                        <div style="display:flex;align-items:center;justify-content:space-between;padding:12px 14px;border-radius:12px;border:1px solid {{ $badge['is_earned'] ? '#86efac' : '#e2e8f0' }};background:{{ $badge['is_earned'] ? '#f0fdf4' : '#f8fafc' }};">
                            <div>
                                <div style="font-weight:800;color:#0f172a;">
                                    🏅 {{ $badge['name'] }}
                                </div>
                                <div style="font-size:13px;color:#475569;margin-top:2px;">{{ $badge['description'] }}</div>
                                <div style="font-size:12px;color:#64748b;margin-top:2px;">Syarat: {{ $badge['criteria_text'] }}</div>
                            </div>
                            <span class="edu-chip {{ $badge['is_earned'] ? 'chip-done' : 'chip-menengah' }}">
                                {{ $badge['is_earned'] ? 'Diraih ✓' : 'Belum Diraih' }}
                            </span>
                        </div>
                    @endforeach
                </div>
            </div>

            <div class="edu-cat-card">
                <h3 style="margin:0 0 12px 0;">Rincian Capaian Pembelajaran</h3>
                <ul style="margin:0;padding-left:18px;line-height:1.8;color:#334155;">
                    <li>Materi Gempa Bumi Selesai: <strong>{{ $progress['materials']['earthquake_completed'] ?? 0 }} / {{ $progress['materials']['earthquake_total'] ?? 12 }}</strong></li>
                    <li>Materi Tsunami Selesai: <strong>{{ $progress['materials']['tsunami_completed'] ?? 0 }} / {{ $progress['materials']['tsunami_total'] ?? 12 }}</strong></li>
                    <li>Simulasi Skenario Diselesaikan: <strong>{{ $progress['simulations']['completed'] ?? 0 }} / {{ $progress['simulations']['total'] ?? 12 }}</strong></li>
                    <li>Rata-rata Nilai Kuis Gempa Bumi: <strong>{{ $progress['quizzes']['earthquake_best_average'] ?? 0 }}</strong></li>
                    <li>Rata-rata Nilai Kuis Tsunami: <strong>{{ $progress['quizzes']['tsunami_best_average'] ?? 0 }}</strong></li>
                    <li>Misi Siaga Selesai: <strong>{{ $progress['missions']['completed'] ?? 0 }} / {{ $progress['missions']['total'] ?? 14 }}</strong></li>
                    <li>Total Poin Kesiapsiagaan: <strong>{{ $progress['total_points'] ?? 0 }} Poin</strong></li>
                </ul>
            </div>
        </div>
    @endif
@endsection
