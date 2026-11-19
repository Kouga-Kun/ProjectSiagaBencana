@extends('layouts.app')

@section('title', 'Kelola Edukasi Bencana · Petugas SiagaBencana')

@push('styles')
<style>
    .adm-header {
        background: linear-gradient(135deg, #0f172a 0%, #1e3a8a 100%);
        color: #ffffff;
        border-radius: 18px;
        padding: 24px 28px;
        margin-bottom: 20px;
    }
    .adm-tabs {
        display: flex;
        flex-wrap: wrap;
        gap: 10px;
        margin-bottom: 20px;
    }
    .adm-tab {
        padding: 10px 18px;
        border-radius: 10px;
        background: #ffffff;
        border: 1px solid #cbd5e1;
        color: #1e293b;
        font-weight: 700;
        text-decoration: none;
        font-size: 14px;
    }
    .adm-tab.active {
        background: #1e3a8a;
        color: #ffffff;
        border-color: #1e3a8a;
    }
    .adm-grid {
        display: grid;
        grid-template-columns: 1fr 1.4fr;
        gap: 22px;
        align-items: start;
    }
    .adm-card {
        background: #ffffff;
        border: 1px solid #e2e8f0;
        border-radius: 16px;
        padding: 22px;
        box-shadow: 0 2px 10px rgba(15, 23, 42, 0.04);
    }
    .adm-field {
        margin-bottom: 14px;
    }
    .adm-field label {
        display: block;
        font-size: 13px;
        font-weight: 700;
        margin-bottom: 5px;
        color: #334155;
    }
    .adm-input, .adm-textarea, .adm-select {
        width: 100%;
        padding: 9px 12px;
        border-radius: 10px;
        border: 1px solid #cbd5e1;
        font-size: 14px;
        font-family: inherit;
    }
    .adm-btn {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 8px 14px;
        border-radius: 8px;
        border: none;
        font-weight: 700;
        font-size: 13px;
        cursor: pointer;
        text-decoration: none;
    }
    @media (max-width: 960px) {
        .adm-grid { grid-template-columns: 1fr; }
    }
</style>
@endpush

@section('content')
    <div class="adm-header">
        <div style="display:flex;flex-wrap:wrap;justify-content:space-between;align-items:center;gap:12px;">
            <div>
                <div style="font-size:12px;text-transform:uppercase;letter-spacing:0.6px;color:#93c5fd;font-weight:700;">Panel Petugas &amp; Admin</div>
                <h1 style="margin:4px 0;font-size:1.65rem;">Manajemen Edukasi Gempa Bumi &amp; Tsunami</h1>
                <p style="margin:0;color:#cbd5e1;font-size:14px;">Kelola Materi Belajar, Skenario Simulasi, Soal Kuis, Misi Siaga, dan Pantau Progres Pengguna.</p>
            </div>
            <a href="{{ route('edukasi.index') }}" class="adm-btn" style="background:#ffffff;color:#1e3a8a;">
                Lihat Halaman Publik Edukasi →
            </a>
        </div>
    </div>

    @if (session('status'))
        <div style="background:#dcfce7;border:1px solid #86efac;color:#166534;padding:12px 16px;border-radius:12px;margin-bottom:16px;font-weight:700;">
            {{ session('status') }}
        </div>
    @endif

    @if ($errors->any())
        <div style="background:#fef2f2;border:1px solid #fca5a5;color:#991b1b;padding:12px 16px;border-radius:12px;margin-bottom:16px;">
            <ul style="margin:0;padding-left:18px;">
                @foreach ($errors->all() as $err)
                    <li>{{ $err }}</li>
                @endforeach
            </ul>
        </div>
    @endif

    <div class="adm-tabs">
        <a href="{{ route('petugas.edukasi.index', ['tab' => 'analitik']) }}" class="adm-tab {{ $activeTab === 'analitik' || $activeTab === 'progres' ? 'active' : '' }}">
            📊 Dashboard Analitik
        </a>
        <a href="{{ route('petugas.edukasi.index', ['tab' => 'materi']) }}" class="adm-tab {{ $activeTab === 'materi' ? 'active' : '' }}">
            📚 Materi ({{ $materials->count() }})
        </a>
        <a href="{{ route('petugas.edukasi.index', ['tab' => 'simulasi']) }}" class="adm-tab {{ $activeTab === 'simulasi' ? 'active' : '' }}">
            🎮 Simulasi ({{ $simulations->count() }})
        </a>
        <a href="{{ route('petugas.edukasi.index', ['tab' => 'kuis']) }}" class="adm-tab {{ $activeTab === 'kuis' ? 'active' : '' }}">
            📝 Kuis ({{ $quizzes->count() }})
        </a>
        <a href="{{ route('petugas.edukasi.index', ['tab' => 'misi']) }}" class="adm-tab {{ $activeTab === 'misi' ? 'active' : '' }}">
            🎯 Misi Siaga ({{ $missions->count() }})
        </a>
        <a href="{{ route('petugas.edukasi.index', ['tab' => 'badge']) }}" class="adm-tab {{ $activeTab === 'badge' ? 'active' : '' }}">
            🏅 Badge ({{ $badges->count() }})
        </a>
    </div>

    @if ($activeTab === 'badge')
        <div class="adm-grid">
            <div class="adm-card">
                <h2 style="margin:0 0 14px 0;font-size:1.15rem;">
                    {{ $editingBadge ? 'Edit Aturan & Reward Badge' : 'Pilih Badge untuk Diedit' }}
                </h2>
                @if ($editingBadge)
                    <form method="POST" action="{{ route('petugas.edukasi.badge.update', $editingBadge) }}">
                        @csrf
                        @method('PUT')
                        <div class="adm-field">
                            <label>Kode Badge</label>
                            <input type="text" value="{{ $editingBadge->code }}" class="adm-input" disabled>
                        </div>
                        <div class="adm-field">
                            <label>Nama Badge</label>
                            <input type="text" name="name" value="{{ old('name', $editingBadge->name) }}" class="adm-input" required>
                        </div>
                        <div class="adm-field">
                            <label>Deskripsi</label>
                            <textarea name="description" rows="2" class="adm-textarea" required>{{ old('description', $editingBadge->description) }}</textarea>
                        </div>
                        <div class="adm-field">
                            <label>Syarat Perolehan (Tampilan Pengguna)</label>
                            <input type="text" name="criteria_description" value="{{ old('criteria_description', $editingBadge->criteria_description) }}" class="adm-input" required>
                        </div>
                        <div class="adm-field">
                            <label>Bonus Poin Reward</label>
                            <input type="number" name="points_reward" value="{{ old('points_reward', $editingBadge->points_reward) }}" min="0" max="1000" class="adm-input" required>
                        </div>
                        <button type="submit" class="adm-btn" style="background:#1e3a8a;color:#ffffff;">Simpan Perubahan Badge</button>
                    </form>
                @else
                    <p style="color:#64748b;font-size:14px;">Klik tombol <strong>Edit</strong> pada salah satu badge di sebelah kanan untuk memperbarui nama, deskripsi, syarat perolehan, atau poin reward.</p>
                @endif
            </div>
            <div class="adm-card">
                <h2 style="margin:0 0 14px 0;font-size:1.15rem;">Daftar Badge Kesiapsiagaan ({{ $badges->count() }})</h2>
                <div style="display:grid;gap:10px;">
                    @foreach ($badges as $b)
                        <div style="border:1px solid #e2e8f0;border-radius:12px;padding:12px 14px;display:flex;justify-content:space-between;align-items:center;gap:12px;">
                            <div>
                                <div style="font-size:12px;color:#64748b;font-weight:700;">
                                    {{ $b->code }} · +{{ $b->points_reward }} Poin · Diraih oleh {{ $b->awarded_users_count }} pengguna
                                </div>
                                <div style="font-weight:800;">🏅 {{ $b->name }}</div>
                                <div style="font-size:13px;color:#475569;">{{ $b->criteria_description }}</div>
                            </div>
                            <a href="{{ route('petugas.edukasi.index', ['tab' => 'badge', 'edit_badge' => $b->id]) }}" class="adm-btn" style="background:#e2e8f0;color:#1e293b;">Edit</a>
                        </div>
                    @endforeach
                </div>
            </div>
        </div>
    @elseif ($activeTab === 'materi')
        <div class="adm-grid">
            <div class="adm-card">
                <h2 style="margin:0 0 14px 0;font-size:1.15rem;">
                    {{ $editingMaterial ? 'Edit Materi Edukasi' : 'Tambah Materi Edukasi Baru' }}
                </h2>
                <form method="POST"
                      action="{{ $editingMaterial ? route('petugas.edukasi.materi.update', $editingMaterial) : route('petugas.edukasi.materi.store') }}"
                      enctype="multipart/form-data">
                    @csrf
                    @if ($editingMaterial)
                        @method('PUT')
                    @endif
                    <div class="adm-field">
                        <label>Kategori (Khusus Gempa Bumi / Tsunami)</label>
                        <select name="category" class="adm-select" required>
                            @foreach ($categories as $cat)
                                <option value="{{ $cat }}" {{ old('category', $editingMaterial?->category) === $cat ? 'selected' : '' }}>{{ $cat }}</option>
                            @endforeach
                        </select>
                    </div>
                    <div class="adm-field">
                        <label>Judul Materi</label>
                        <input type="text" name="title" value="{{ old('title', $editingMaterial?->title) }}" class="adm-input" required>
                    </div>
                    <div class="adm-field">
                        <label>Tingkat Kesulitan</label>
                        <select name="difficulty" class="adm-select" required>
                            @foreach ($difficulties as $diff)
                                <option value="{{ $diff }}" {{ old('difficulty', $editingMaterial?->difficulty) === $diff ? 'selected' : '' }}>{{ $diff }}</option>
                            @endforeach
                        </select>
                    </div>
                    <div class="adm-field">
                        <label>Ringkasan Materi</label>
                        <textarea name="summary" rows="2" class="adm-textarea" required>{{ old('summary', $editingMaterial?->summary) }}</textarea>
                    </div>
                    <div class="adm-field">
                        <label>Penjelasan Lengkap Materi</label>
                        <textarea name="content" rows="5" class="adm-textarea" required>{{ old('content', $editingMaterial?->content) }}</textarea>
                    </div>
                    <div class="adm-field">
                        <label>Poin Penting (1 baris per poin)</label>
                        <textarea name="key_points" rows="3" class="adm-textarea">{{ old('key_points', is_array($editingMaterial?->key_points) ? implode("\n", $editingMaterial->key_points) : '') }}</textarea>
                    </div>
                    <div class="adm-field">
                        <label>Langkah yang Harus Dilakukan (1 baris per langkah)</label>
                        <textarea name="action_steps" rows="3" class="adm-textarea">{{ old('action_steps', is_array($editingMaterial?->action_steps) ? implode("\n", $editingMaterial->action_steps) : '') }}</textarea>
                    </div>
                    <div class="adm-field">
                        <label>Hal yang Harus Dihindari (1 baris per poin)</label>
                        <textarea name="things_to_avoid" rows="3" class="adm-textarea">{{ old('things_to_avoid', is_array($editingMaterial?->things_to_avoid) ? implode("\n", $editingMaterial->things_to_avoid) : '') }}</textarea>
                    </div>
                    <div class="adm-field">
                        <label>Sumber Referensi Resmi</label>
                        <input type="text" name="source_reference" value="{{ old('source_reference', $editingMaterial?->source_reference ?? 'BNPB & BMKG') }}" class="adm-input" required>
                    </div>
                    <div class="adm-field">
                        <label>Unggah Gambar Ilustrasi (Opsional)</label>
                        <input type="file" name="image" accept=".jpg,.jpeg,.png,.webp" class="adm-input">
                    </div>
                    <div class="adm-field">
                        <label>Status Publikasi</label>
                        <select name="status" class="adm-select">
                            <option value="published" {{ old('status', $editingMaterial?->status ?? 'published') === 'published' ? 'selected' : '' }}>Dipublikasikan</option>
                            <option value="draft" {{ old('status', $editingMaterial?->status) === 'draft' ? 'selected' : '' }}>Draft</option>
                        </select>
                    </div>
                    <button type="submit" class="adm-btn" style="background:#1e3a8a;color:#ffffff;">
                        {{ $editingMaterial ? 'Simpan Perubahan Materi' : 'Tambah Materi' }}
                    </button>
                </form>
            </div>

            <div class="adm-card">
                <h2 style="margin:0 0 14px 0;font-size:1.15rem;">Daftar Materi Edukasi ({{ $materials->count() }})</h2>
                <div style="display:grid;gap:10px;">
                    @foreach ($materials as $m)
                        <div style="border:1px solid #e2e8f0;border-radius:12px;padding:12px 14px;display:flex;justify-content:space-between;align-items:center;gap:12px;">
                            <div>
                                <div style="font-size:12px;color:#64748b;font-weight:700;">
                                    {{ $m->category }} · {{ $m->difficulty }} · <span style="color:{{ $m->isPublished() ? '#15803d' : '#b45309' }};">{{ $m->statusLabel() }}</span>
                                </div>
                                <div style="font-weight:700;color:#0f172a;">{{ $m->title }}</div>
                            </div>
                            <div style="display:flex;gap:6px;flex-wrap:wrap;">
                                <a href="{{ route('petugas.edukasi.index', ['tab' => 'materi', 'edit_materi' => $m->id]) }}" class="adm-btn" style="background:#e2e8f0;color:#1e293b;">Edit</a>
                                <form method="POST" action="{{ route('petugas.edukasi.materi.publish', $m) }}">
                                    @csrf
                                    @method('PATCH')
                                    <button type="submit" class="adm-btn" style="background:#059669;color:#ffffff;">
                                        {{ $m->isPublished() ? 'Draft' : 'Publish' }}
                                    </button>
                                </form>
                                <form method="POST" action="{{ route('petugas.edukasi.materi.destroy', $m) }}">
                                    @csrf
                                    @method('DELETE')
                                    <button type="submit" class="adm-btn" style="background:#dc2626;color:#ffffff;">Hapus</button>
                                </form>
                            </div>
                        </div>
                    @endforeach
                </div>
            </div>
        </div>

    @elseif ($activeTab === 'simulasi')
        <div class="adm-grid">
            <div class="adm-card">
                <h2 style="margin:0 0 14px 0;font-size:1.15rem;">
                    {{ $editingSimulation ? 'Edit Skenario Simulasi' : 'Tambah Skenario Simulasi Baru' }}
                </h2>
                <form method="POST" action="{{ $editingSimulation ? route('petugas.edukasi.simulasi.update', $editingSimulation) : route('petugas.edukasi.simulasi.store') }}">
                    @csrf
                    @if ($editingSimulation)
                        @method('PUT')
                    @endif
                    <div class="adm-field">
                        <label>Kategori</label>
                        <select name="category" class="adm-select" required>
                            @foreach ($categories as $cat)
                                <option value="{{ $cat }}" {{ old('category', $editingSimulation?->category) === $cat ? 'selected' : '' }}>{{ $cat }}</option>
                            @endforeach
                        </select>
                    </div>
                    <div class="adm-field">
                        <label>Judul Simulasi</label>
                        <input type="text" name="title" value="{{ old('title', $editingSimulation?->title) }}" class="adm-input" required>
                    </div>
                    <div class="adm-field">
                        <label>Tingkat Kesulitan</label>
                        <select name="difficulty" class="adm-select" required>
                            @foreach ($difficulties as $diff)
                                <option value="{{ $diff }}" {{ old('difficulty', $editingSimulation?->difficulty) === $diff ? 'selected' : '' }}>{{ $diff }}</option>
                            @endforeach
                        </select>
                    </div>
                    <div class="adm-field">
                        <label>Deskripsi Singkat</label>
                        <textarea name="description" rows="2" class="adm-textarea" required>{{ old('description', $editingSimulation?->description) }}</textarea>
                    </div>
                    <div class="adm-field">
                        <label>Konteks Skenario</label>
                        <textarea name="scenario_context" rows="3" class="adm-textarea" required>{{ old('scenario_context', $editingSimulation?->scenario_context) }}</textarea>
                    </div>
                    <div class="adm-field">
                        <label>Referensi Panduan Keselamatan</label>
                        <input type="text" name="safety_reference" value="{{ old('safety_reference', $editingSimulation?->safety_reference ?? 'Panduan Kesiapsiagaan BNPB & BMKG') }}" class="adm-input" required>
                    </div>
                    <div class="adm-field">
                        <label>Pertanyaan / Situasi Tahap Utama (Opsional jika menambah tahap baru)</label>
                        <textarea name="situation_text" rows="2" class="adm-textarea" placeholder="Contoh: Kamu berada di pantai saat gempa kuat terjadi..."></textarea>
                    </div>
                    <div class="adm-field">
                        <label>Pilihan Tindakan A (Tepat)</label>
                        <input type="text" name="choice_a_text" class="adm-input" placeholder="Segera evakuasi ke tempat tinggi...">
                    </div>
                    <div class="adm-field">
                        <label>Pilihan Tindakan B (Berbahaya)</label>
                        <input type="text" name="choice_b_text" class="adm-input" placeholder="Menunggu di tepi pantai...">
                    </div>
                    <div class="adm-field">
                        <label>Tindakan yang Seharusnya Dilakukan</label>
                        <input type="text" name="recommended_action" class="adm-input" placeholder="Jauhi pantai segera setelah gempa berhenti.">
                    </div>
                    <button type="submit" class="adm-btn" style="background:#1e3a8a;color:#ffffff;">
                        {{ $editingSimulation ? 'Simpan Perubahan Simulasi' : 'Tambah Simulasi' }}
                    </button>
                </form>
            </div>

            <div class="adm-card">
                <h2 style="margin:0 0 14px 0;font-size:1.15rem;">Daftar Skenario Simulasi ({{ $simulations->count() }})</h2>
                <div style="display:grid;gap:10px;">
                    @foreach ($simulations as $sim)
                        <div style="border:1px solid #e2e8f0;border-radius:12px;padding:12px 14px;display:flex;justify-content:space-between;align-items:center;gap:12px;">
                            <div>
                                <div style="font-size:12px;color:#64748b;font-weight:700;">
                                    {{ $sim->category }} · {{ $sim->difficulty }} · {{ $sim->steps->count() }} Tahap · {{ $sim->statusLabel() }}
                                </div>
                                <div style="font-weight:700;">{{ $sim->title }}</div>
                            </div>
                            <div style="display:flex;gap:6px;">
                                <a href="{{ route('petugas.edukasi.index', ['tab' => 'simulasi', 'edit_simulasi' => $sim->id]) }}" class="adm-btn" style="background:#e2e8f0;color:#1e293b;">Edit</a>
                                <form method="POST" action="{{ route('petugas.edukasi.simulasi.publish', $sim) }}">
                                    @csrf
                                    @method('PATCH')
                                    <button type="submit" class="adm-btn" style="background:#059669;color:#ffffff;">
                                        {{ $sim->isPublished() ? 'Draft' : 'Publish' }}
                                    </button>
                                </form>
                                <form method="POST" action="{{ route('petugas.edukasi.simulasi.destroy', $sim) }}">
                                    @csrf
                                    @method('DELETE')
                                    <button type="submit" class="adm-btn" style="background:#dc2626;color:#ffffff;">Hapus</button>
                                </form>
                            </div>
                        </div>
                    @endforeach
                </div>
            </div>
        </div>
    @elseif ($activeTab === 'kuis')
        <div class="adm-grid">
            <div class="adm-card">
                <h2 style="margin:0 0 14px 0;font-size:1.15rem;">
                    {{ $editingQuiz ? 'Edit Paket Kuis & Tambah Soal' : 'Tambah Paket Kuis Baru' }}
                </h2>
                <form method="POST" action="{{ $editingQuiz ? route('petugas.edukasi.kuis.update', $editingQuiz) : route('petugas.edukasi.kuis.store') }}">
                    @csrf
                    @if ($editingQuiz)
                        @method('PUT')
                    @endif
                    <div class="adm-field">
                        <label>Kategori</label>
                        <select name="category" class="adm-select" required>
                            @foreach ($categories as $cat)
                                <option value="{{ $cat }}" {{ old('category', $editingQuiz?->category) === $cat ? 'selected' : '' }}>{{ $cat }}</option>
                            @endforeach
                        </select>
                    </div>
                    <div class="adm-field">
                        <label>Judul Kuis</label>
                        <input type="text" name="title" value="{{ old('title', $editingQuiz?->title) }}" class="adm-input" required>
                    </div>
                    <div class="adm-field">
                        <label>Topik Kuis</label>
                        <input type="text" name="topic" value="{{ old('topic', $editingQuiz?->topic) }}" class="adm-input">
                    </div>
                    <div class="adm-field">
                        <label>Tingkat Kesulitan</label>
                        <select name="difficulty" class="adm-select" required>
                            @foreach ($difficulties as $diff)
                                <option value="{{ $diff }}" {{ old('difficulty', $editingQuiz?->difficulty) === $diff ? 'selected' : '' }}>{{ $diff }}</option>
                            @endforeach
                        </select>
                    </div>
                    <div class="adm-field">
                        <label>Deskripsi Kuis</label>
                        <textarea name="description" rows="2" class="adm-textarea" required>{{ old('description', $editingQuiz?->description) }}</textarea>
                    </div>
                    <hr style="border:none;border-top:1px solid #e2e8f0;margin:14px 0;">
                    <div style="font-size:13px;font-weight:800;color:#1e3a8a;margin-bottom:8px;">Tambah Soal Pilihan Ganda (Opsional)</div>
                    <div class="adm-field">
                        <label>Pertanyaan</label>
                        <textarea name="question_text" rows="2" class="adm-textarea"></textarea>
                    </div>
                    <div class="adm-field">
                        <label>Pilihan A</label>
                        <input type="text" name="option_a" class="adm-input">
                    </div>
                    <div class="adm-field">
                        <label>Pilihan B</label>
                        <input type="text" name="option_b" class="adm-input">
                    </div>
                    <div class="adm-field">
                        <label>Pilihan C</label>
                        <input type="text" name="option_c" class="adm-input">
                    </div>
                    <div class="adm-field">
                        <label>Pilihan D</label>
                        <input type="text" name="option_d" class="adm-input">
                    </div>
                    <div class="adm-field">
                        <label>Kunci Jawaban Benar</label>
                        <select name="correct_option" class="adm-select">
                            <option value="A">A</option>
                            <option value="B">B</option>
                            <option value="C">C</option>
                            <option value="D">D</option>
                        </select>
                    </div>
                    <div class="adm-field">
                        <label>Pembahasan Jawaban</label>
                        <textarea name="question_explanation" rows="2" class="adm-textarea"></textarea>
                    </div>
                    <button type="submit" class="adm-btn" style="background:#1e3a8a;color:#ffffff;">
                        {{ $editingQuiz ? 'Simpan Kuis' : 'Tambah Kuis' }}
                    </button>
                </form>
            </div>

            <div class="adm-card">
                <h2 style="margin:0 0 14px 0;font-size:1.15rem;">Daftar Paket Kuis ({{ $quizzes->count() }})</h2>
                <div style="display:grid;gap:10px;">
                    @foreach ($quizzes as $q)
                        <div style="border:1px solid #e2e8f0;border-radius:12px;padding:12px 14px;display:flex;justify-content:space-between;align-items:center;gap:12px;">
                            <div>
                                <div style="font-size:12px;color:#64748b;font-weight:700;">
                                    {{ $q->category }} · {{ $q->difficulty }} · {{ $q->questions->count() }} Soal · {{ $q->statusLabel() }}
                                </div>
                                <div style="font-weight:700;">{{ $q->title }}</div>
                            </div>
                            <div style="display:flex;gap:6px;">
                                <a href="{{ route('petugas.edukasi.index', ['tab' => 'kuis', 'edit_kuis' => $q->id]) }}" class="adm-btn" style="background:#e2e8f0;color:#1e293b;">Edit</a>
                                <form method="POST" action="{{ route('petugas.edukasi.kuis.publish', $q) }}">
                                    @csrf
                                    @method('PATCH')
                                    <button type="submit" class="adm-btn" style="background:#059669;color:#ffffff;">
                                        {{ $q->isPublished() ? 'Draft' : 'Publish' }}
                                    </button>
                                </form>
                                <form method="POST" action="{{ route('petugas.edukasi.kuis.destroy', $q) }}">
                                    @csrf
                                    @method('DELETE')
                                    <button type="submit" class="adm-btn" style="background:#dc2626;color:#ffffff;">Hapus</button>
                                </form>
                            </div>
                        </div>
                    @endforeach
                </div>
            </div>
        </div>
    @elseif ($activeTab === 'misi')
        <div class="adm-grid">
            <div class="adm-card">
                <h2 style="margin:0 0 14px 0;font-size:1.15rem;">
                    {{ $editingMission ? 'Edit Misi Siaga' : 'Tambah Misi Siaga Baru' }}
                </h2>
                <form method="POST" action="{{ $editingMission ? route('petugas.edukasi.misi.update', $editingMission) : route('petugas.edukasi.misi.store') }}">
                    @csrf
                    @if ($editingMission)
                        @method('PUT')
                    @endif
                    <div class="adm-field">
                        <label>Kategori</label>
                        <select name="category" class="adm-select" required>
                            @foreach ($categories as $cat)
                                <option value="{{ $cat }}" {{ old('category', $editingMission?->category) === $cat ? 'selected' : '' }}>{{ $cat }}</option>
                            @endforeach
                        </select>
                    </div>
                    <div class="adm-field">
                        <label>Judul Misi</label>
                        <input type="text" name="title" value="{{ old('title', $editingMission?->title) }}" class="adm-input" required>
                    </div>
                    <div class="adm-field">
                        <label>Tingkat Kesulitan</label>
                        <select name="difficulty" class="adm-select" required>
                            @foreach ($difficulties as $diff)
                                <option value="{{ $diff }}" {{ old('difficulty', $editingMission?->difficulty) === $diff ? 'selected' : '' }}>{{ $diff }}</option>
                            @endforeach
                        </select>
                    </div>
                    <div class="adm-field">
                        <label>Poin Penghargaan</label>
                        <input type="number" name="points" value="{{ old('points', $editingMission?->points ?? 25) }}" min="5" max="500" class="adm-input" required>
                    </div>
                    <div class="adm-field">
                        <label>Deskripsi Misi</label>
                        <textarea name="description" rows="2" class="adm-textarea" required>{{ old('description', $editingMission?->description) }}</textarea>
                    </div>
                    <div class="adm-field">
                        <label>Instruksi Pelaksanaan (1 baris per langkah)</label>
                        <textarea name="instructions" rows="4" class="adm-textarea">{{ old('instructions', is_array($editingMission?->instructions) ? implode("\n", $editingMission->instructions) : '') }}</textarea>
                    </div>
                    <button type="submit" class="adm-btn" style="background:#1e3a8a;color:#ffffff;">
                        {{ $editingMission ? 'Simpan Misi Siaga' : 'Tambah Misi Siaga' }}
                    </button>
                </form>
            </div>

            <div class="adm-card">
                <h2 style="margin:0 0 14px 0;font-size:1.15rem;">Daftar Misi Siaga ({{ $missions->count() }})</h2>
                <div style="display:grid;gap:10px;">
                    @foreach ($missions as $ms)
                        <div style="border:1px solid #e2e8f0;border-radius:12px;padding:12px 14px;display:flex;justify-content:space-between;align-items:center;gap:12px;">
                            <div>
                                <div style="font-size:12px;color:#64748b;font-weight:700;">
                                    {{ $ms->category }} · {{ $ms->difficulty }} · +{{ $ms->points }} Poin · {{ $ms->statusLabel() }}
                                </div>
                                <div style="font-weight:700;">{{ $ms->title }}</div>
                            </div>
                            <div style="display:flex;gap:6px;">
                                <a href="{{ route('petugas.edukasi.index', ['tab' => 'misi', 'edit_misi' => $ms->id]) }}" class="adm-btn" style="background:#e2e8f0;color:#1e293b;">Edit</a>
                                <form method="POST" action="{{ route('petugas.edukasi.misi.publish', $ms) }}">
                                    @csrf
                                    @method('PATCH')
                                    <button type="submit" class="adm-btn" style="background:#059669;color:#ffffff;">
                                        {{ $ms->isPublished() ? 'Draft' : 'Publish' }}
                                    </button>
                                </form>
                                <form method="POST" action="{{ route('petugas.edukasi.misi.destroy', $ms) }}">
                                    @csrf
                                    @method('DELETE')
                                    <button type="submit" class="adm-btn" style="background:#dc2626;color:#ffffff;">Hapus</button>
                                </form>
                            </div>
                        </div>
                    @endforeach
                </div>
            </div>
        </div>
    @else
        <!-- TAB DASHBOARD ANALITIK ADMIN -->
        @php
            $summary = $progressOverview['summary'] ?? [];
            $timeline = $progressOverview['activity_timeline_14d'] ?? [];
            $maxDayCount = max(1, collect($timeline)->max('count') ?? 1);
            $quizDist = $progressOverview['quiz_score_distribution'] ?? [];
            $maxBucket = max(1, collect($quizDist)->max('count') ?? 1);
        @endphp

        <div class="adm-card" style="margin-bottom:20px;">
            <h2 style="margin:0 0 14px 0;font-size:1.2rem;">📊 Dashboard Analitik Edukasi Bencana</h2>
            <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(175px,1fr));gap:12px;">
                <div style="background:#f8fafc;padding:14px;border-radius:12px;border:1px solid #e2e8f0;">
                    <div style="font-size:12px;color:#64748b;">Pengguna Edukasi / Total Akun</div>
                    <div style="font-size:1.5rem;font-weight:800;color:#1e3a8a;">{{ $summary['total_education_users'] ?? 0 }} / {{ $summary['total_users'] ?? 0 }}</div>
                </div>
                <div style="background:#f8fafc;padding:14px;border-radius:12px;border:1px solid #e2e8f0;">
                    <div style="font-size:12px;color:#64748b;">Pengguna Aktif (7 / 30 Hari)</div>
                    <div style="font-size:1.5rem;font-weight:800;color:#059669;">{{ $summary['active_users_7d'] ?? 0 }} / {{ $summary['active_users_30d'] ?? 0 }}</div>
                </div>
                <div style="background:#f8fafc;padding:14px;border-radius:12px;border:1px solid #e2e8f0;">
                    <div style="font-size:12px;color:#64748b;">Materi Selesai</div>
                    <div style="font-size:1.5rem;font-weight:800;color:#1e3a8a;">{{ $summary['total_material_completions'] ?? 0 }}</div>
                </div>
                <div style="background:#f8fafc;padding:14px;border-radius:12px;border:1px solid #e2e8f0;">
                    <div style="font-size:12px;color:#64748b;">Rata-rata Nilai Kuis</div>
                    <div style="font-size:1.5rem;font-weight:800;color:#d97706;">{{ $summary['average_quiz_score'] ?? 0 }}</div>
                </div>
                <div style="background:#f8fafc;padding:14px;border-radius:12px;border:1px solid #e2e8f0;">
                    <div style="font-size:12px;color:#64748b;">Penyelesaian Simulasi</div>
                    <div style="font-size:1.5rem;font-weight:800;color:#0369a1;">{{ $summary['simulation_completion_rate'] ?? 0 }}%</div>
                    <div style="font-size:11.5px;color:#64748b;">{{ $summary['total_simulation_attempts'] ?? 0 }} percobaan</div>
                </div>
                <div style="background:#f8fafc;padding:14px;border-radius:12px;border:1px solid #e2e8f0;">
                    <div style="font-size:12px;color:#64748b;">Penyelesaian Misi Siaga</div>
                    <div style="font-size:1.5rem;font-weight:800;color:#059669;">{{ $summary['mission_completion_rate'] ?? 0 }}%</div>
                    <div style="font-size:11.5px;color:#64748b;">{{ $summary['total_completed_missions'] ?? 0 }} selesai</div>
                </div>
            </div>
        </div>

        <div class="adm-grid" style="margin-bottom:20px;">
            <!-- Tren Aktivitas 14 Hari -->
            <div class="adm-card">
                <h3 style="margin:0 0 12px 0;font-size:1.05rem;">Tren Aktivitas Belajar (14 Hari Terakhir)</h3>
                <div style="display:flex;align-items:flex-end;gap:6px;height:150px;padding-top:16px;border-bottom:1px solid #cbd5e1;">
                    @foreach ($timeline as $point)
                        @php $barH = max(6, (int) round(($point['count'] / $maxDayCount) * 120)); @endphp
                        <div style="flex:1;display:flex;flex-direction:column;align-items:center;gap:4px;">
                            <span style="font-size:10px;font-weight:700;color:#1e3a8a;">{{ $point['count'] }}</span>
                            <div style="width:100%;max-width:24px;height:{{ $barH }}px;background:#1e3a8a;border-radius:6px 6px 0 0;"></div>
                            <span style="font-size:10px;color:#64748b;">{{ $point['label'] }}</span>
                        </div>
                    @endforeach
                </div>
            </div>

            <!-- Distribusi Hasil Kuis -->
            <div class="adm-card">
                <h3 style="margin:0 0 12px 0;font-size:1.05rem;">Distribusi Nilai Kuis ({{ $summary['total_quiz_attempts'] ?? 0 }} Percobaan)</h3>
                <div style="display:grid;gap:10px;">
                    @foreach ($quizDist as $bucket)
                        @php $wPct = (int) round(($bucket['count'] / $maxBucket) * 100); @endphp
                        <div>
                            <div style="display:flex;justify-content:space-between;font-size:13px;font-weight:600;margin-bottom:4px;">
                                <span>{{ $bucket['label'] }}</span>
                                <strong>{{ $bucket['count'] }} percobaan</strong>
                            </div>
                            <div style="height:10px;background:#e2e8f0;border-radius:999px;overflow:hidden;">
                                <div style="height:100%;width:{{ $wPct }}%;background:#059669;border-radius:999px;"></div>
                            </div>
                        </div>
                    @endforeach
                </div>
            </div>
        </div>

        <div class="adm-grid" style="margin-bottom:20px;">
            <div class="adm-card">
                <h3 style="margin:0 0 10px 0;font-size:1.05rem;">🔥 Materi Paling Populer</h3>
                @forelse ($progressOverview['popular_materials'] ?? [] as $pm)
                    <div style="padding:8px 0;border-bottom:1px solid #f1f5f9;display:flex;justify-content:space-between;font-size:13.5px;">
                        <span><strong>{{ $pm['title'] }}</strong> <span style="color:#64748b;">({{ $pm['category'] }})</span></span>
                        <span style="color:#059669;font-weight:700;">{{ $pm['completed_count'] }} selesai</span>
                    </div>
                @empty
                    <p style="color:#64748b;font-size:13px;">Belum ada data.</p>
                @endforelse

                <h3 style="margin:18px 0 10px 0;font-size:1.05rem;">📉 Materi Paling Jarang Dipelajari</h3>
                @forelse ($progressOverview['least_studied_materials'] ?? [] as $lm)
                    <div style="padding:8px 0;border-bottom:1px solid #f1f5f9;display:flex;justify-content:space-between;font-size:13.5px;">
                        <span>{{ $lm['title'] }} <span style="color:#64748b;">({{ $lm['category'] }})</span></span>
                        <span style="color:#d97706;font-weight:700;">{{ $lm['completed_count'] }} selesai</span>
                    </div>
                @empty
                    <p style="color:#64748b;font-size:13px;">Belum ada data.</p>
                @endforelse
            </div>

            <div class="adm-card">
                <h3 style="margin:0 0 10px 0;font-size:1.05rem;">🎮 Simulasi Paling Sering Dimainkan</h3>
                @forelse ($progressOverview['popular_simulations'] ?? [] as $ps)
                    <div style="padding:8px 0;border-bottom:1px solid #f1f5f9;display:flex;justify-content:space-between;font-size:13.5px;">
                        <span><strong>{{ $ps['title'] }}</strong></span>
                        <span style="color:#1e3a8a;font-weight:700;">{{ $ps['attempts_count'] }}x · Rata² {{ $ps['average_score'] }}</span>
                    </div>
                @empty
                    <p style="color:#64748b;font-size:13px;">Belum ada data simulasi.</p>
                @endforelse

                <h3 style="margin:18px 0 10px 0;font-size:1.05rem;">⏸️ Materi Sering Ditinggalkan (Belum Selesai)</h3>
                @forelse ($progressOverview['abandoned_materials'] ?? [] as $am)
                    <div style="padding:8px 0;border-bottom:1px solid #f1f5f9;display:flex;justify-content:space-between;font-size:13.5px;">
                        <span>{{ $am['title'] }}</span>
                        <span style="color:#dc2626;font-weight:700;">{{ $am['abandoned_count'] }} belum tuntas</span>
                    </div>
                @empty
                    <p style="color:#64748b;font-size:13px;">Belum ada materi yang ditinggalkan di tengah jalan.</p>
                @endforelse
            </div>
        </div>

        <div class="adm-card">
            <h3 style="margin:0 0 12px 0;">Progres Per Pengguna</h3>
            <div style="overflow-x:auto;">
                <table style="width:100%;border-collapse:collapse;font-size:13.5px;">
                    <thead>
                        <tr style="background:#f1f5f9;text-align:left;">
                            <th style="padding:10px 12px;">Nama Pengguna</th>
                            <th style="padding:10px 12px;">Materi Selesai</th>
                            <th style="padding:10px 12px;">Simulasi</th>
                            <th style="padding:10px 12px;">Kuis</th>
                            <th style="padding:10px 12px;">Misi Selesai</th>
                            <th style="padding:10px 12px;">Badge</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach ($progressOverview['users'] ?? [] as $u)
                            <tr style="border-bottom:1px solid #e2e8f0;">
                                <td style="padding:10px 12px;">
                                    <strong>{{ $u['name'] }}</strong>
                                    <div style="font-size:12px;color:#64748b;">{{ $u['email'] }}</div>
                                </td>
                                <td style="padding:10px 12px;">{{ $u['completed_materials_count'] }}</td>
                                <td style="padding:10px 12px;">{{ $u['simulation_attempts_count'] }}</td>
                                <td style="padding:10px 12px;">{{ $u['quiz_attempts_count'] }}</td>
                                <td style="padding:10px 12px;">{{ $u['completed_missions_count'] }}</td>
                                <td style="padding:10px 12px;">{{ $u['earned_badges_count'] }}</td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
        </div>
    @endif
@endsection
