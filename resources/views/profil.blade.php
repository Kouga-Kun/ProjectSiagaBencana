@extends('layouts.app')

@section('title', 'Profil - SiagaBencana')

@section('content')
<style>
    .page-title { color: #123b63; margin-bottom: 8px; }
    .description { color: #64748b; margin-bottom: 24px; }
    .profile-card { background: white; padding: 24px; border-radius: 12px; margin-bottom: 20px; box-shadow: 0 3px 12px #0000000a; }
    .profile-header { display: flex; align-items: center; gap: 18px; flex-wrap: wrap; }
    .avatar { width: 72px; height: 72px; border-radius: 50%; background: #eaf3fb; display: flex; align-items: center; justify-content: center; font-size: 32px; }
    .menu-list { display: grid; gap: 12px; }
    .menu-item { padding: 15px; border: 1px solid #e2e8f0; border-radius: 8px; transition: all 0.3s ease; }
    .menu-item strong { display: block; margin-bottom: 5px; }
    .menu-item p { color: #64748b; margin: 0; }
    .notice { background: #fff7ed; padding: 16px; border-radius: 8px; color: #9a3412; }
    .auth-actions { display: flex; flex-wrap: wrap; gap: 12px; margin-top: 18px; }
    .auth-button { display: inline-flex; justify-content: center; padding: 11px 18px; border-radius: 8px; color: white; background: #1e40af; text-decoration: none; font-weight: 700; }
    .auth-button.secondary { color: #1e40af; background: #eff6ff; border: 1px solid #bfdbfe; }
    .logout-button { margin-top: 12px; border: 1px solid #fecaca; color: #b91c1c; background: #fff; cursor: pointer; font: inherit; }
    .status-message { padding: 12px 16px; border-radius: 8px; color: #166534; background: #dcfce7; }
    
    /* Grid 2 kolom yang awalnya disembunyikan */
    .contact-grid { display: none; grid-template-columns: repeat(2, 1fr); gap: 12px; margin-top: 15px; border-top: 1px dashed #fecaca; padding-top: 15px; }
    
    @media (max-width: 576px) {
        .contact-grid { grid-template-columns: 1fr; }
    }
    
    .contact-card { padding: 12px; background-color: #f8f9fa; border-radius: 8px; border: 1px solid #e2e8f0; }
    .contact-title { font-size: 0.85rem; color: #64748b; }
    .contact-number { color: #dc3545; text-decoration: none; font-weight: bold; font-size: 1.05rem; display: block; margin-top: 2px; }
    
    /* Indikator panah yang bisa berputar */
    .toggle-icon { font-size: 0.8rem; transition: transform 0.3s ease; color: #64748b; }
    .expanded .toggle-icon { transform: rotate(180deg); }
</style>

<h1 class="page-title">Profil Pengguna</h1>
<p class="description">
    Kelola informasi akun dan akses fitur pendukung keselamatan.
</p>

@if (session('status'))
    <p class="status-message" role="status">{{ session('status') }}</p>
@endif

<section class="profile-card">
    @guest
        <div class="profile-header">
            <div class="avatar">👤</div>
            <div>
                <h2 style="margin-bottom: 5px;">Profil pengguna</h2>
                <p style="margin: 0; color: #64748b;">Silakan login terlebih dahulu untuk mengakses halaman profil.</p>
            </div>
        </div>
        <div class="auth-actions">
            <a class="auth-button" href="{{ route('login') }}">Login</a>
            <a class="auth-button secondary" href="{{ route('register') }}">Daftar Akun</a>
        </div>
    @else
        <div class="profile-header">
            <div class="avatar">👤</div>
            <div>
                <h2 style="margin-bottom: 5px;">{{ $user->name }}</h2>
                <p style="margin: 0; color: #64748b;">{{ $user->email }}</p>
            </div>
        </div>
        <p>Akun terdaftar sejak {{ $user->created_at?->translatedFormat('d F Y') ?? 'tanggal tidak tersedia' }}.</p>
        <form method="POST" action="{{ route('logout') }}">
            @csrf
            <button class="auth-button logout-button" type="submit">Keluar</button>
        </form>
    @endguest
</section>

<section class="profile-card">
    <div style="display:flex;flex-wrap:wrap;justify-content:space-between;align-items:center;gap:12px;margin-bottom:14px;">
        <div>
            <h2 style="margin:0 0 4px 0;">🎓 Progres Edukasi Gempa Bumi &amp; Tsunami</h2>
            <p style="margin:0;color:#64748b;font-size:14px;">Ringkasan materi belajar, simulasi, hasil kuis, misi siaga, dan badge kesiapsiagaan Anda.</p>
        </div>
        <a class="auth-button" href="{{ route('edukasi.index') }}">Buka Edukasi Bencana →</a>
    </div>

    @if (! empty($educationProgress))
        <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(150px,1fr));gap:12px;margin-bottom:16px;">
            <div style="padding:12px 14px;background:#f8fafc;border:1px solid #e2e8f0;border-radius:10px;">
                <div style="font-size:12px;color:#64748b;">Progres Total</div>
                <div style="font-size:1.35rem;font-weight:800;color:#1e3a8a;">{{ $educationProgress['overall_progress_percentage'] ?? 0 }}%</div>
            </div>
            <div style="padding:12px 14px;background:#f8fafc;border:1px solid #e2e8f0;border-radius:10px;">
                <div style="font-size:12px;color:#64748b;">Materi Selesai</div>
                <div style="font-size:1.35rem;font-weight:800;color:#059669;">{{ $educationProgress['materials']['completed'] ?? 0 }} / {{ $educationProgress['materials']['total'] ?? 24 }}</div>
            </div>
            <div style="padding:12px 14px;background:#f8fafc;border:1px solid #e2e8f0;border-radius:10px;">
                <div style="font-size:12px;color:#64748b;">Nilai Kuis Gempa / Tsunami</div>
                <div style="font-size:1.25rem;font-weight:800;color:#1e3a8a;">{{ $educationProgress['quizzes']['earthquake_best_average'] ?? 0 }} / {{ $educationProgress['quizzes']['tsunami_best_average'] ?? 0 }}</div>
            </div>
            <div style="padding:12px 14px;background:#f8fafc;border:1px solid #e2e8f0;border-radius:10px;">
                <div style="font-size:12px;color:#64748b;">Total Poin &amp; Badge</div>
                <div style="font-size:1.25rem;font-weight:800;color:#d97706;">{{ $educationProgress['total_points'] ?? 0 }} Poin · {{ $educationProgress['badges']['earned_count'] ?? 0 }} Badge</div>
            </div>
        </div>

        <div style="display:flex;flex-wrap:wrap;gap:8px;">
            @foreach ($educationProgress['badges']['items'] ?? [] as $badge)
                <span style="padding:6px 12px;border-radius:999px;font-size:12.5px;font-weight:700;background:{{ $badge['is_earned'] ? '#dcfce7' : '#f1f5f9' }};color:{{ $badge['is_earned'] ? '#15803d' : '#64748b' }};">
                    🏅 {{ $badge['name'] }} {{ $badge['is_earned'] ? '✓' : '' }}
                </span>
            @endforeach
        </div>
    @else
        <p style="margin:0;color:#64748b;">Silakan login untuk menyimpan dan memantau capaian belajar, nilai kuis, serta badge kesiapsiagaan gempa bumi dan tsunami.</p>
    @endif
</section>

<section class="profile-card">
    <h2>Pengaturan dan Bantuan</h2>

    <div class="menu-list">
        <div class="menu-item">
            <strong>👤 Informasi Profil</strong>
            <p>Melihat dan memperbarui nama serta informasi akun.</p>
        </div>

        <div class="menu-item">
            <strong>🔔 Notifikasi</strong>
            <p>Pengaturan peringatan dan informasi kebencanaan.</p>
        </div>

        <!-- Menu Kontak Darurat dengan fitur Klik (Toggle) -->
        <div class="menu-item" id="contact-menu" style="cursor: pointer;" onclick="toggleContacts()">
            <div style="display: flex; justify-content: space-between; align-items: center;">
                <div>
                    <strong>📞 Kontak Darurat Kota Padang</strong>
                    <p id="contact-desc">Informasi kontak instansi dan layanan darurat resmi.</p>
                </div>
                <span class="toggle-icon" id="toggle-icon">▼</span>
            </div>
            
            <div class="contact-grid" id="contact-grid">
                <div class="contact-card">
                    <span class="contact-title">BPBD Kota Padang</span>
                    <a href="tel:0751778775" class="contact-number">0751-778775</a>
                </div>
                <div class="contact-card">
                    <span class="contact-title">SAR Kota Padang</span>
                    <a href="tel:0751484534" class="contact-number">0751-484534</a>
                </div>
                <div class="contact-card">
                    <span class="contact-title">Pemadam Kebakaran</span>
                    <a href="tel:075128558" class="contact-number">113 / 0751-28558</a>
                </div>
                <div class="contact-card">
                    <span class="contact-title">PMI Padang</span>
                    <a href="tel:075131795" class="contact-number">0751-31795</a>
                </div>
                <div class="contact-card">
                    <span class="contact-title">Polisi / Poltabes</span>
                    <a href="tel:075133724" class="contact-number">110 / 0751-33724</a>
                </div>
                <div class="contact-card">
                    <span class="contact-title">RS M. Djamil Padang</span>
                    <a href="tel:075137030" class="contact-number">0751-37030</a>
                </div>
            </div>
        </div>

        <div class="menu-item">
            <strong>❓ Pusat Bantuan</strong>
            <p>Panduan penggunaan aplikasi dan informasi keselamatan.</p>
        </div>

        <div class="menu-item">
            <strong>⚙️ Pengaturan Aplikasi</strong>
            <p>Preferensi dan pengaturan penggunaan aplikasi.</p>
        </div>
    </div>
</section>

<section class="profile-card">
    <h2>🆘 Bantuan Darurat (SOS)</h2>
    <div class="notice">
        Fitur SOS belum aktif. Jika berada dalam keadaan darurat,
        segera hubungi layanan darurat resmi atau ikuti arahan petugas.
        Jangan mengandalkan halaman ini sebagai sistem permintaan bantuan.
    </div>
</section>

<!-- Script untuk mengatur buka-tutup kotak kontak -->
<script>
    function toggleContacts() {
        const menu = document.getElementById('contact-menu');
        const grid = document.getElementById('contact-grid');
        const desc = document.getElementById('contact-desc');
        
        // Cek apakah saat ini disembunyikan
        if (grid.style.display === 'none' || grid.style.display === '') {
            grid.style.display = 'grid';
            menu.classList.add('expanded');
            menu.style.borderColor = '#fecaca';
            menu.style.backgroundColor = '#fffafa';
            desc.textContent = 'Nomor telepon instansi resmi. Ketuk nomor untuk memanggil langsung dari ponsel Anda.';
        } else {
            grid.style.display = 'none';
            menu.classList.remove('expanded');
            menu.style.borderColor = '#e2e8f0';
            menu.style.backgroundColor = 'transparent';
            desc.textContent = 'Informasi kontak instansi dan layanan darurat resmi.';
        }
    }
</script>
@endsection
