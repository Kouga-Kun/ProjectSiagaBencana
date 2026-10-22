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