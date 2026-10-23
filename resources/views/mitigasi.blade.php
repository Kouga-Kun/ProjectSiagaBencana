@extends('layouts.app')

@section('title', 'Mitigasi Bencana - SiagaBencana')

@section('content')
<style>
    .mitigasi-page { --mitigasi-primary: #123b63; --mitigasi-muted: #64748b; }
    .mitigasi-header { margin-bottom: 22px; }
    .mitigasi-title { color: var(--mitigasi-primary); margin: 0 0 8px; font-size: 30px; }
    .mitigasi-lead { color: var(--mitigasi-muted); line-height: 1.7; max-width: 760px; margin: 0; }
    .quick-nav { display: flex; flex-wrap: wrap; gap: 10px; margin: 20px 0 28px; }
    .quick-nav a { display: inline-block; padding: 9px 13px; border: 1px solid var(--border-color); border-radius: 8px; background: var(--bg-card); color: var(--primary-color); font-weight: 600; text-decoration: none; }
    .quick-nav a:hover { background: #eff6ff; }
    .quick-nav a:focus-visible, .mitigasi-page a:focus-visible, .check-item:focus-within { outline: 3px solid #f59e0b; outline-offset: 3px; }
    .mitigasi-section { scroll-margin-top: 24px; margin-bottom: 28px; }
    .mitigasi-section > h2 { color: var(--mitigasi-primary); font-size: 22px; margin: 0 0 14px; }
    .mitigasi-card { background: #fff; padding: 22px; border: 1px solid var(--border-color); border-radius: 12px; box-shadow: 0 3px 12px #0000000a; }
    .mitigasi-card p { color: var(--text-muted); line-height: 1.7; }
    .tsunami-warning { border: 2px solid var(--color-danger); background: #fff7f7; }
    .tsunami-warning h2 { color: var(--color-danger); }
    .mitigasi-card p.evacuation-action { margin: 16px 0 0; padding: 16px; border-radius: 8px; background: var(--color-danger); color: #fff; font-size: 18px; font-weight: 700; line-height: 1.5; }
    .signs-grid, .safety-grid { display: flex; flex-wrap: wrap; justify-content: center; gap: 22px; }
    .sign-card, .safety-card { position: relative; isolation: isolate; overflow: hidden; flex: 0 1 calc(33.333% - 15px); min-width: 280px; background: linear-gradient(145deg, #fff 65%, #f5f9ff); padding: 78px 24px 24px; border: 1px solid #dce6f2; border-radius: 18px; box-shadow: 0 8px 24px rgba(18, 59, 99, 0.06); transition: transform 0.22s ease, border-color 0.22s ease, box-shadow 0.22s ease; }
    .sign-card::before, .safety-card::before { position: absolute; top: 20px; left: 22px; display: grid; width: 42px; height: 42px; place-items: center; border: 1px solid #dbeafe; border-radius: 14px; background: #eff6ff; color: #1d4ed8; font-size: 20px; font-weight: 700; }
    .sign-card:nth-child(1)::before { content: '⚠'; }
    .sign-card:nth-child(2)::before { content: '≈'; }
    .sign-card:nth-child(3)::before { content: '≋'; }
    #panduan-gempa .safety-card:nth-child(1)::before { content: '⌂'; }
    #panduan-gempa .safety-card:nth-child(2)::before { content: '↔'; }
    #panduan-gempa .safety-card:nth-child(3)::before { content: '✓'; }
    #panduan-tsunami .safety-card:nth-child(1)::before { content: '⌂'; }
    #panduan-tsunami .safety-card:nth-child(2)::before { content: '↑'; }
    #panduan-tsunami .safety-card:nth-child(3)::before { content: '✓'; }
    .sign-card:hover, .safety-card:hover { transform: translateY(-5px); border-color: #93c5fd; box-shadow: 0 14px 30px rgba(18, 59, 99, 0.12); }
    .sign-card h3, .safety-card h3 { color: var(--mitigasi-primary); font-size: 18px; line-height: 1.4; margin: 0 0 12px; }
    .sign-card p, .safety-card li { color: var(--text-muted); line-height: 1.7; }
    .sign-card p { margin: 0; }
    .safety-card ul { padding-left: 20px; margin: 0; }
    .safety-card li { padding-left: 3px; }
    .safety-card li + li { margin-top: 5px; }
    .checklist-progress { margin: 16px 0 18px; }
    .checklist-progress p { margin: 0 0 8px; color: var(--text-dark); font-weight: 600; }
    .checklist-progress progress { display: block; width: 100%; height: 16px; accent-color: var(--color-safe); }
    .checklist { display: grid; grid-template-columns: repeat(auto-fit, minmax(230px, 1fr)); gap: 12px; }
    .check-item { display: flex; align-items: flex-start; gap: 10px; background: #fff; padding: 16px; border: 1px solid var(--border-color); border-radius: 12px; box-shadow: 0 3px 12px #0000000a; line-height: 1.5; cursor: pointer; transition: border-color 0.2s ease, box-shadow 0.2s ease; }
    .check-item:hover { border-color: #93c5fd; box-shadow: 0 6px 12px rgba(0, 0, 0, 0.06); }
    .check-item input { width: 18px; height: 18px; flex: 0 0 auto; margin: 1px 0 0; accent-color: var(--color-safe); }
    .no-js-note { color: var(--text-muted); font-size: 14px; }
    @media (max-width: 600px) {
        .mitigasi-title { font-size: 25px; }
        .quick-nav { flex-wrap: nowrap; overflow-x: auto; padding: 3px 3px 8px; }
        .quick-nav a { flex: 0 0 auto; }
        .mitigasi-card { padding: 18px; }
        .sign-card, .safety-card { flex: 1 1 100%; min-width: 0; }
        .evacuation-action { font-size: 16px; }
    }
</style>

<div class="mitigasi-page">
    <header class="mitigasi-header">
        <h1 class="mitigasi-title">Edukasi dan Mitigasi Bencana</h1>
        <p class="mitigasi-lead">Kenali langkah untuk mengurangi risiko dan menjaga keselamatan diri serta keluarga sebelum, saat, dan setelah gempa bumi atau tsunami.</p>
    </header>

    <nav class="quick-nav" aria-label="Navigasi cepat mitigasi">
        <a href="#zonasi">Peta zonasi</a>
        <a href="#tanda-tsunami">Tanda tsunami</a>
        <a href="#panduan-gempa">Panduan gempa</a>
        <a href="#panduan-tsunami">Panduan tsunami</a>
        <a href="#tas-siaga">Tas siaga</a>
    </nav>

    <section class="mitigasi-section" id="zonasi" aria-labelledby="zonasi-title">
        <h2 id="zonasi-title">Peta Zonasi Bahaya</h2>
        <div class="mitigasi-card">
            @include('partials.evacuation-map')
        </div>
    </section>

    <section class="mitigasi-section" id="tanda-tsunami" aria-labelledby="tanda-tsunami-title">
        <div class="mitigasi-card tsunami-warning">
            <h2 id="tanda-tsunami-title">🌊 Kenali Tanda Alami Tsunami</h2>
            <div class="signs-grid">
                <article class="sign-card">
                    <h3>Gempa kuat atau lama</h3>
                    <p>Jika berada di wilayah pesisir dan merasakan gempa yang kuat atau berlangsung lama, segera menjauh dari pantai.</p>
                </article>
                <article class="sign-card">
                    <h3>Perubahan air laut</h3>
                    <p>Air laut tiba-tiba surut jauh atau naik dengan cepat dapat menjadi tanda bahaya. Jangan mendekati pantai untuk melihatnya.</p>
                </article>
                <article class="sign-card">
                    <h3>Suara gemuruh dari laut</h3>
                    <p>Suara gemuruh yang tidak biasa dari arah laut juga dapat menjadi tanda bahaya tsunami.</p>
                </article>
            </div>
            <p class="evacuation-action">BERTINDAK SEGERA: tinggalkan pantai dan bergerak ke tempat yang lebih tinggi atau menjauh ke daratan. Jangan menunggu peringatan resmi jika merasakan tanda alam. Ikuti petunjuk petugas dan jangan kembali sebelum dinyatakan aman.</p>
        </div>
    </section>

    <section class="mitigasi-section" id="panduan-gempa" aria-labelledby="panduan-gempa-title">
        <h2 id="panduan-gempa-title">🛡️ Panduan Keselamatan Gempa Bumi</h2>
        <div class="safety-grid">
            <article class="safety-card">
                <h3>Sebelum gempa</h3>
                <ul>
                    <li>Amankan lemari dan benda berat agar tidak mudah jatuh.</li>
                    <li>Kenali tempat berlindung yang kokoh dan jalur keluar di rumah.</li>
                    <li>Buat rencana komunikasi dan titik berkumpul keluarga.</li>
                    <li>Siapkan tas siaga dan simpan nomor penting.</li>
                </ul>
            </article>
            <article class="safety-card">
                <h3>Saat gempa</h3>
                <ul>
                    <li>Merunduk, berlindung di bawah meja yang kokoh, dan berpegangan.</li>
                    <li>Lindungi kepala dan leher; jauhi kaca serta benda yang mudah jatuh.</li>
                    <li>Jangan menggunakan lift. Jika di luar, jauhi bangunan dan kabel.</li>
                    <li>Jika di pesisir dan guncangan kuat atau lama, segera evakuasi dari pantai setelah guncangan mereda.</li>
                </ul>
            </article>
            <article class="safety-card">
                <h3>Setelah gempa</h3>
                <ul>
                    <li>Waspadai gempa susulan dan periksa bahaya di sekitar sebelum bergerak.</li>
                    <li>Tolong orang lain jika aman; hindari bangunan yang rusak.</li>
                    <li>Gunakan pesan singkat untuk menghemat jaringan telepon.</li>
                    <li>Ikuti informasi resmi dan jangan masuk kembali ke bangunan yang belum dinyatakan aman.</li>
                </ul>
            </article>
        </div>
    </section>

    <section class="mitigasi-section" id="panduan-tsunami" aria-labelledby="panduan-tsunami-title">
        <h2 id="panduan-tsunami-title">🌊 Panduan Keselamatan Tsunami</h2>
        <div class="safety-grid">
            <article class="safety-card">
                <h3>Sebelum tsunami</h3>
                <ul>
                    <li>Kenali tanda alami tsunami dan siapkan tas siaga.</li>
                    <li>Pelajari arahan evakuasi dari BPBD setempat.</li>
                    <li>Sepakati rencana keluarga jika komunikasi terputus.</li>
                </ul>
            </article>
            <article class="safety-card">
                <h3>Saat ada tanda tsunami</h3>
                <ul>
                    <li>Segera menjauh dari pantai menuju tempat tinggi atau ke arah daratan.</li>
                    <li>Ikuti arahan petugas dan peringatan resmi bila tersedia.</li>
                    <li>Jangan berhenti untuk mengambil barang, menonton, atau mendekati laut.</li>
                    <li>Bantu anak-anak, lansia, dan orang yang membutuhkan bantuan jika aman.</li>
                </ul>
            </article>
            <article class="safety-card">
                <h3>Setelah tsunami</h3>
                <ul>
                    <li>Tetap di tempat aman; gelombang dapat datang lebih dari satu kali.</li>
                    <li>Jauhi pantai, sungai, genangan, kabel jatuh, dan bangunan rusak.</li>
                    <li>Kembali hanya setelah petugas menyatakan keadaan aman.</li>
                </ul>
            </article>
        </div>
    </section>

    <section class="mitigasi-section" id="tas-siaga" aria-labelledby="tas-siaga-title">
        <h2 id="tas-siaga-title">🎒 Checklist Tas Siaga</h2>
        <div class="mitigasi-card">
            <p id="checklist-count" aria-live="polite">0 dari 9 item siap</p>
            <div class="checklist-progress">
                <label for="checklist-progress-bar">Progres persiapan</label>
                <progress id="checklist-progress-bar" value="0" max="9">0%</progress>
            </div>
            <noscript><p class="no-js-note">JavaScript tidak aktif. Checklist tetap bisa dicentang, tetapi jumlah dan progres tidak diperbarui otomatis.</p></noscript>
            <div class="checklist" id="checklist-items">
                <label class="check-item"><input type="checkbox" name="tas-siaga[]" value="air"> <span>Air minum</span></label>
                <label class="check-item"><input type="checkbox" name="tas-siaga[]" value="makanan"> <span>Makanan tahan lama</span></label>
                <label class="check-item"><input type="checkbox" name="tas-siaga[]" value="p3k"> <span>P3K dan obat pribadi</span></label>
                <label class="check-item"><input type="checkbox" name="tas-siaga[]" value="senter"> <span>Senter dan baterai cadangan</span></label>
                <label class="check-item"><input type="checkbox" name="tas-siaga[]" value="dokumen"> <span>Dokumen penting dalam wadah tahan air</span></label>
                <label class="check-item"><input type="checkbox" name="tas-siaga[]" value="ponsel"> <span>Ponsel dan pengisi daya</span></label>
                <label class="check-item"><input type="checkbox" name="tas-siaga[]" value="pakaian"> <span>Pakaian dan perlengkapan kebersihan</span></label>
                <label class="check-item"><input type="checkbox" name="tas-siaga[]" value="peluit"> <span>Peluit</span></label>
                <label class="check-item"><input type="checkbox" name="tas-siaga[]" value="uang"> <span>Uang tunai</span></label>
            </div>
        </div>
    </section>
</div>
@endsection

@push('scripts')
<script>
document.addEventListener('DOMContentLoaded', function () {
    const checklist = document.getElementById('checklist-items');
    const count = document.getElementById('checklist-count');
    const progress = document.getElementById('checklist-progress-bar');

    if (!checklist || !count || !progress) return;

    const boxes = checklist.querySelectorAll('input[type="checkbox"]');
    const updateProgress = function () {
        const checked = checklist.querySelectorAll('input[type="checkbox"]:checked').length;
        count.textContent = checked + ' dari ' + boxes.length + ' item siap';
        progress.value = checked;
        progress.textContent = Math.round((checked / boxes.length) * 100) + '%';
    };

    checklist.addEventListener('change', updateProgress);
    updateProgress();
});
</script>
@endpush
