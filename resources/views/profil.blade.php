
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
    .menu-item { padding: 15px; border: 1px solid #e2e8f0; border-radius: 8px; }
    .menu-item strong { display: block; margin-bottom: 5px; }
    .menu-item p { color: #64748b; margin: 0; }
    .notice { background: #fff7ed; padding: 16px; border-radius: 8px; color: #9a3412; }
</style>

<h1 class="page-title">Profil Pengguna</h1>
<p class="description">
    Kelola informasi akun dan akses fitur pendukung keselamatan.
</p>

<section class="profile-card">
    <div class="profile-header">
        <div class="avatar">👤</div>
        <div>
            <h2 style="margin-bottom: 5px;">Pengguna SiagaBencana</h2>
            <p style="margin: 0; color: #64748b;">
                Akun tamu · Profil belum diatur
            </p>
        </div>
    </div>
    <p>
        Informasi profil akan tersedia setelah fitur pendaftaran,
        login, dan pengelolaan akun dibuat.
    </p>
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

        <div class="menu-item">
            <strong>📞 Kontak Darurat</strong>
            <p>Informasi kontak instansi dan layanan darurat resmi.</p>
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

@endsection
