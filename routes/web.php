<?php

use App\Http\Controllers\DisasterEducationAdminController;
use App\Http\Controllers\DisasterEducationApiController;
use App\Http\Controllers\DisasterEducationWebController;
use App\Http\Controllers\DisasterReportApiController;
use App\Http\Controllers\DisasterReportController;
use App\Http\Controllers\EvacuationApiController;
use App\Http\Controllers\NewsArticleController;
use App\Http\Controllers\ReportStaffAuthController;
use App\Http\Controllers\SosRequestController;
use App\Http\Controllers\UserAuthController;
use App\Http\Controllers\WeatherAlertController;
use Illuminate\Support\Facades\Route;

Route::view('/', 'home')->name('home');

Route::view('/evakuasi', 'evakuasi')->name('evakuasi');
Route::get('/berita', [NewsArticleController::class, 'publicIndexWeb'])->name('berita');
Route::get('/berita/{slug}', [NewsArticleController::class, 'publicShowWeb'])->name('berita.show');
Route::view('/mitigasi', 'mitigasi')->name('mitigasi');

// Halaman Web Edukasi Bencana (Gempa Bumi & Tsunami) — Wajib Login
Route::middleware('auth')->group(function () {
    Route::get('/edukasi', [DisasterEducationWebController::class, 'index'])
        ->name('edukasi.index');
    Route::get('/edukasi/materi/{slug}', [DisasterEducationWebController::class, 'showMaterial'])
        ->name('edukasi.materi.show');
    Route::post('/edukasi/materi/{learningMaterial}/selesai', [DisasterEducationWebController::class, 'completeMaterial'])
        ->name('edukasi.materi.complete');
    Route::get('/edukasi/simulasi/{slug}', [DisasterEducationWebController::class, 'showSimulation'])
        ->name('edukasi.simulasi.show');
    Route::post('/edukasi/simulasi/{simulation}/submit', [DisasterEducationWebController::class, 'submitSimulation'])
        ->name('edukasi.simulasi.submit');
    Route::get('/edukasi/kuis/{slug}', [DisasterEducationWebController::class, 'showQuiz'])
        ->name('edukasi.kuis.show');
    Route::post('/edukasi/kuis/{quiz}/submit', [DisasterEducationWebController::class, 'submitQuiz'])
        ->name('edukasi.kuis.submit');
    Route::post('/edukasi/misi/{mission}/status', [DisasterEducationWebController::class, 'updateMissionStatus'])
        ->name('edukasi.misi.status');
    Route::put('/edukasi/pengingat', [DisasterEducationWebController::class, 'updateReminderWeb'])
        ->name('edukasi.pengingat.update');
});

Route::get('/laporan', [DisasterReportController::class, 'index'])
    ->name('laporan');

Route::get('/masuk', [UserAuthController::class, 'createLogin'])
    ->middleware('guest')
    ->name('login');

Route::post('/masuk', [UserAuthController::class, 'storeLogin'])
    ->middleware(['guest', 'throttle:user-login'])
    ->name('login.store');

Route::get('/daftar', [UserAuthController::class, 'createRegistration'])
    ->middleware('guest')
    ->name('register');

Route::post('/daftar', [UserAuthController::class, 'storeRegistration'])
    ->middleware(['guest', 'throttle:user-login'])
    ->name('register.store');

Route::post('/keluar', [UserAuthController::class, 'logout'])
    ->middleware('auth')
    ->name('logout');

// API autentikasi Flutter
Route::prefix('/api/auth')->name('api.auth.')->group(function () {
    Route::get('/csrf', [UserAuthController::class, 'csrfToken'])
        ->name('csrf');

    Route::get('/status', [UserAuthController::class, 'statusJson'])
        ->name('status');

    Route::post('/register', [UserAuthController::class, 'registerJson'])
        ->middleware(['guest', 'throttle:user-login'])
        ->name('register');

    Route::post('/login', [UserAuthController::class, 'loginJson'])
        ->middleware(['guest', 'throttle:user-login'])
        ->name('login');

    Route::post('/logout', [UserAuthController::class, 'logoutJson'])
        ->middleware('auth')
        ->name('logout');
});

// API profil pengguna untuk Flutter
Route::middleware('auth')->group(function () {
    Route::get('/api/profile', [UserAuthController::class, 'profileJson'])
        ->name('api.profile.show');

    Route::post('/api/profile', [UserAuthController::class, 'updateProfileJson'])
        ->name('api.profile.update');

    Route::match(['put', 'patch'], '/api/profile', [UserAuthController::class, 'updateProfileJson'])
        ->name('api.profile.update.method');
});

Route::get('/api/profile/photo/{user}', [UserAuthController::class, 'profilePhoto'])
    ->name('api.profile.photo');

// API Berita publik untuk Flutter
Route::get('/api/berita', [NewsArticleController::class, 'indexJson'])
    ->name('api.berita.index');

Route::get('/api/berita/gambar/{newsArticle}', [NewsArticleController::class, 'image'])
    ->name('api.berita.image');

Route::get('/api/berita/{slug}', [NewsArticleController::class, 'showJson'])
    ->name('api.berita.show');

// API pengelolaan Berita untuk Admin/Petugas
Route::middleware(['auth', 'report.staff'])->group(function () {
    Route::get('/api/admin/berita', [NewsArticleController::class, 'adminIndexJson'])
        ->name('api.admin.berita.index');

    Route::get('/api/admin/berita/{newsArticle}', [NewsArticleController::class, 'adminShowJson'])
        ->name('api.admin.berita.show');

    Route::post('/api/admin/berita', [NewsArticleController::class, 'storeJson'])
        ->name('api.admin.berita.store');

    Route::match(['put', 'patch', 'post'], '/api/admin/berita/{newsArticle}', [NewsArticleController::class, 'updateJson'])
        ->name('api.admin.berita.update');

    Route::match(['patch', 'post'], '/api/admin/berita/{newsArticle}/headline', [NewsArticleController::class, 'setHeadlineJson'])
        ->name('api.admin.berita.headline');

    Route::match(['patch', 'post'], '/api/admin/berita/{newsArticle}/publikasi', [NewsArticleController::class, 'togglePublishJson'])
        ->name('api.admin.berita.publish');

    Route::delete('/api/admin/berita/{newsArticle}', [NewsArticleController::class, 'destroyJson'])
        ->name('api.admin.berita.destroy');
});

// API laporan bencana untuk Flutter
Route::get('/api/laporan', [DisasterReportApiController::class, 'index'])
    ->name('api.laporan.index');

Route::post('/api/laporan', [DisasterReportApiController::class, 'store'])
    ->middleware('auth')
    ->name('api.laporan.store');

// API Bantuan Darurat SOS untuk pengguna Flutter
Route::middleware('auth')->group(function () {
    Route::post('/api/sos', [SosRequestController::class, 'storeJson'])
        ->name('api.sos.store');

    Route::get('/api/sos/riwayat', [SosRequestController::class, 'userHistoryJson'])
        ->name('api.sos.history');
});

// API Bantuan Darurat SOS untuk Admin/Petugas
Route::middleware(['auth', 'report.staff'])->group(function () {
    Route::get('/api/admin/sos', [SosRequestController::class, 'adminIndexJson'])
        ->name('api.admin.sos.index');

    Route::get('/api/admin/sos/{sosRequest}', [SosRequestController::class, 'adminShowJson'])
        ->name('api.admin.sos.show');

    Route::match(['patch', 'post'], '/api/admin/sos/{sosRequest}/status', [SosRequestController::class, 'updateStatusJson'])
        ->name('api.admin.sos.status');
});

// Autentikasi petugas laporan
Route::get('/petugas/masuk', [ReportStaffAuthController::class, 'create'])
    ->middleware('guest')
    ->name('report-staff.login');

Route::post('/petugas/masuk', [ReportStaffAuthController::class, 'store'])
    ->middleware(['guest', 'throttle:report-staff-login'])
    ->name('report-staff.login.store');

// Fitur khusus petugas
Route::middleware(['auth', 'report.staff'])->group(function () {
    Route::post('/petugas/keluar', [ReportStaffAuthController::class, 'destroy'])
        ->name('report-staff.logout');

    Route::get('/laporan/{disasterReport}/edit', [DisasterReportController::class, 'edit'])
        ->name('laporan.edit');

    Route::patch('/laporan/{disasterReport}', [DisasterReportController::class, 'update'])
        ->name('laporan.update');

    Route::patch('/laporan/{disasterReport}/verifikasi', [DisasterReportController::class, 'verify'])
        ->name('laporan.verify');

    Route::get('/petugas/sos', [SosRequestController::class, 'adminDashboard'])
        ->name('petugas.sos.index');

    Route::patch('/petugas/sos/{sosRequest}/status', [SosRequestController::class, 'updateStatusWeb'])
        ->name('petugas.sos.status');

    Route::get('/petugas/berita', [NewsArticleController::class, 'adminDashboard'])
        ->name('petugas.berita.index');

    Route::post('/petugas/berita', [NewsArticleController::class, 'storeWeb'])
        ->name('petugas.berita.store');

    Route::match(['put', 'patch'], '/petugas/berita/{newsArticle}', [NewsArticleController::class, 'updateWeb'])
        ->name('petugas.berita.update');

    Route::patch('/petugas/berita/{newsArticle}/headline', [NewsArticleController::class, 'setHeadlineWeb'])
        ->name('petugas.berita.headline');

    Route::patch('/petugas/berita/{newsArticle}/publikasi', [NewsArticleController::class, 'togglePublishWeb'])
        ->name('petugas.berita.publish');

    Route::delete('/petugas/berita/{newsArticle}', [NewsArticleController::class, 'destroyWeb'])
        ->name('petugas.berita.destroy');

    // Pengelolaan Edukasi Bencana untuk Petugas/Admin (Web)
    Route::get('/petugas/edukasi', [DisasterEducationAdminController::class, 'adminDashboard'])
        ->name('petugas.edukasi.index');

    Route::post('/petugas/edukasi/materi', [DisasterEducationAdminController::class, 'storeMaterialWeb'])
        ->name('petugas.edukasi.materi.store');
    Route::match(['put', 'patch'], '/petugas/edukasi/materi/{learningMaterial}', [DisasterEducationAdminController::class, 'updateMaterialWeb'])
        ->name('petugas.edukasi.materi.update');
    Route::patch('/petugas/edukasi/materi/{learningMaterial}/publikasi', [DisasterEducationAdminController::class, 'togglePublishMaterialWeb'])
        ->name('petugas.edukasi.materi.publish');
    Route::delete('/petugas/edukasi/materi/{learningMaterial}', [DisasterEducationAdminController::class, 'destroyMaterialWeb'])
        ->name('petugas.edukasi.materi.destroy');

    Route::post('/petugas/edukasi/simulasi', [DisasterEducationAdminController::class, 'storeSimulationWeb'])
        ->name('petugas.edukasi.simulasi.store');
    Route::match(['put', 'patch'], '/petugas/edukasi/simulasi/{simulation}', [DisasterEducationAdminController::class, 'updateSimulationWeb'])
        ->name('petugas.edukasi.simulasi.update');
    Route::patch('/petugas/edukasi/simulasi/{simulation}/publikasi', [DisasterEducationAdminController::class, 'togglePublishSimulationWeb'])
        ->name('petugas.edukasi.simulasi.publish');
    Route::delete('/petugas/edukasi/simulasi/{simulation}', [DisasterEducationAdminController::class, 'destroySimulationWeb'])
        ->name('petugas.edukasi.simulasi.destroy');

    Route::post('/petugas/edukasi/kuis', [DisasterEducationAdminController::class, 'storeQuizWeb'])
        ->name('petugas.edukasi.kuis.store');
    Route::match(['put', 'patch'], '/petugas/edukasi/kuis/{quiz}', [DisasterEducationAdminController::class, 'updateQuizWeb'])
        ->name('petugas.edukasi.kuis.update');
    Route::patch('/petugas/edukasi/kuis/{quiz}/publikasi', [DisasterEducationAdminController::class, 'togglePublishQuizWeb'])
        ->name('petugas.edukasi.kuis.publish');
    Route::delete('/petugas/edukasi/kuis/{quiz}', [DisasterEducationAdminController::class, 'destroyQuizWeb'])
        ->name('petugas.edukasi.kuis.destroy');

    Route::post('/petugas/edukasi/misi', [DisasterEducationAdminController::class, 'storeMissionWeb'])
        ->name('petugas.edukasi.misi.store');
    Route::match(['put', 'patch'], '/petugas/edukasi/misi/{mission}', [DisasterEducationAdminController::class, 'updateMissionWeb'])
        ->name('petugas.edukasi.misi.update');
    Route::patch('/petugas/edukasi/misi/{mission}/publikasi', [DisasterEducationAdminController::class, 'togglePublishMissionWeb'])
        ->name('petugas.edukasi.misi.publish');
    Route::delete('/petugas/edukasi/misi/{mission}', [DisasterEducationAdminController::class, 'destroyMissionWeb'])
        ->name('petugas.edukasi.misi.destroy');

    Route::match(['put', 'patch'], '/petugas/edukasi/badge/{badge}', [DisasterEducationAdminController::class, 'updateBadgeWeb'])
        ->name('petugas.edukasi.badge.update');
});

// API Edukasi Bencana (Gempa Bumi & Tsunami) untuk Flutter & Web — Wajib Login & Anti Akses Lintas Akun
Route::middleware(['auth', 'education.own'])->prefix('/api/edukasi')->name('api.edukasi.')->group(function () {
    Route::get('/', [DisasterEducationApiController::class, 'summaryJson'])
        ->name('summary');

    Route::get('/progres', [DisasterEducationApiController::class, 'progressJson'])
        ->name('progres');
    Route::get('/riwayat', [DisasterEducationApiController::class, 'historyJson'])
        ->name('riwayat');
    Route::get('/badge', [DisasterEducationApiController::class, 'badgesJson'])
        ->name('badge');
    Route::get('/pengingat', [DisasterEducationApiController::class, 'reminderShowJson'])
        ->name('pengingat.show');
    Route::match(['put', 'post'], '/pengingat', [DisasterEducationApiController::class, 'reminderUpdateJson'])
        ->name('pengingat.update');

    Route::get('/materi', [DisasterEducationApiController::class, 'materialsIndexJson'])
        ->name('materi.index');
    Route::get('/materi/gambar/{learningMaterial}', [DisasterEducationApiController::class, 'materialImage'])
        ->name('materi.image');
    Route::get('/materi/{slug}', [DisasterEducationApiController::class, 'materialShowJson'])
        ->name('materi.show');
    Route::post('/materi/{learningMaterial}/progres', [DisasterEducationApiController::class, 'saveMaterialProgressJson'])
        ->name('materi.progress');
    Route::post('/materi/{learningMaterial}/selesai', [DisasterEducationApiController::class, 'completeMaterialJson'])
        ->name('materi.complete');

    Route::get('/simulasi', [DisasterEducationApiController::class, 'simulationsIndexJson'])
        ->name('simulasi.index');
    Route::get('/simulasi/{slug}', [DisasterEducationApiController::class, 'simulationShowJson'])
        ->name('simulasi.show');
    Route::post('/simulasi/{simulation}/progres', [DisasterEducationApiController::class, 'saveSimulationProgressJson'])
        ->name('simulasi.progress');
    Route::post('/simulasi/{simulation}/submit', [DisasterEducationApiController::class, 'submitSimulationJson'])
        ->name('simulasi.submit');
    Route::post('/simulasi/{simulation}/hasil', [DisasterEducationApiController::class, 'submitSimulationJson'])
        ->name('simulasi.result');

    Route::get('/kuis', [DisasterEducationApiController::class, 'quizzesIndexJson'])
        ->name('kuis.index');
    Route::get('/kuis/{slug}', [DisasterEducationApiController::class, 'quizShowJson'])
        ->name('kuis.show');
    Route::post('/kuis/{quiz}/submit', [DisasterEducationApiController::class, 'submitQuizJson'])
        ->name('kuis.submit');
    Route::post('/kuis/{quiz}/hasil', [DisasterEducationApiController::class, 'submitQuizJson'])
        ->name('kuis.result');

    Route::get('/misi', [DisasterEducationApiController::class, 'missionsIndexJson'])
        ->name('misi.index');
    Route::post('/misi/{mission}/progres', [DisasterEducationApiController::class, 'startMissionJson'])
        ->name('misi.progress');
    Route::post('/misi/{mission}/selesai', [DisasterEducationApiController::class, 'completeMissionJson'])
        ->name('misi.complete');
    Route::match(['patch', 'post'], '/misi/{mission}/status', [DisasterEducationApiController::class, 'updateMissionStatusJson'])
        ->name('misi.status');
});

// API Admin Edukasi Bencana untuk Petugas/Admin
Route::middleware(['auth', 'report.staff'])->prefix('/api/admin/edukasi')->name('api.admin.edukasi.')->group(function () {
    Route::get('/overview', [DisasterEducationAdminController::class, 'adminOverviewJson'])
        ->name('overview');
    Route::get('/progres', [DisasterEducationAdminController::class, 'adminProgressOverviewJson'])
        ->name('progres');
    Route::get('/analytics', [DisasterEducationAdminController::class, 'adminAnalyticsJson'])
        ->name('analytics');
    Route::get('/badge', [DisasterEducationAdminController::class, 'adminBadgesIndexJson'])
        ->name('badge.index');
    Route::match(['put', 'patch'], '/badge/{badge}', [DisasterEducationAdminController::class, 'updateBadgeJson'])
        ->name('badge.update');

    Route::get('/materi', [DisasterEducationAdminController::class, 'adminMaterialsIndexJson'])
        ->name('materi.index');
    Route::post('/materi', [DisasterEducationAdminController::class, 'storeMaterialJson'])
        ->name('materi.store');
    Route::match(['put', 'patch', 'post'], '/materi/{learningMaterial}', [DisasterEducationAdminController::class, 'updateMaterialJson'])
        ->name('materi.update');
    Route::match(['patch', 'post'], '/materi/{learningMaterial}/publikasi', [DisasterEducationAdminController::class, 'togglePublishMaterialJson'])
        ->name('materi.publish');
    Route::delete('/materi/{learningMaterial}', [DisasterEducationAdminController::class, 'destroyMaterialJson'])
        ->name('materi.destroy');

    Route::get('/simulasi', [DisasterEducationAdminController::class, 'adminSimulationsIndexJson'])
        ->name('simulasi.index');
    Route::post('/simulasi', [DisasterEducationAdminController::class, 'storeSimulationJson'])
        ->name('simulasi.store');
    Route::match(['put', 'patch', 'post'], '/simulasi/{simulation}', [DisasterEducationAdminController::class, 'updateSimulationJson'])
        ->name('simulasi.update');
    Route::match(['patch', 'post'], '/simulasi/{simulation}/publikasi', [DisasterEducationAdminController::class, 'togglePublishSimulationJson'])
        ->name('simulasi.publish');
    Route::delete('/simulasi/{simulation}', [DisasterEducationAdminController::class, 'destroySimulationJson'])
        ->name('simulasi.destroy');

    Route::get('/kuis', [DisasterEducationAdminController::class, 'adminQuizzesIndexJson'])
        ->name('kuis.index');
    Route::post('/kuis', [DisasterEducationAdminController::class, 'storeQuizJson'])
        ->name('kuis.store');
    Route::match(['put', 'patch', 'post'], '/kuis/{quiz}', [DisasterEducationAdminController::class, 'updateQuizJson'])
        ->name('kuis.update');
    Route::match(['patch', 'post'], '/kuis/{quiz}/publikasi', [DisasterEducationAdminController::class, 'togglePublishQuizJson'])
        ->name('kuis.publish');
    Route::delete('/kuis/{quiz}', [DisasterEducationAdminController::class, 'destroyQuizJson'])
        ->name('kuis.destroy');

    Route::get('/misi', [DisasterEducationAdminController::class, 'adminMissionsIndexJson'])
        ->name('misi.index');
    Route::post('/misi', [DisasterEducationAdminController::class, 'storeMissionJson'])
        ->name('misi.store');
    Route::match(['put', 'patch', 'post'], '/misi/{mission}', [DisasterEducationAdminController::class, 'updateMissionJson'])
        ->name('misi.update');
    Route::match(['patch', 'post'], '/misi/{mission}/publikasi', [DisasterEducationAdminController::class, 'togglePublishMissionJson'])
        ->name('misi.publish');
    Route::delete('/misi/{mission}', [DisasterEducationAdminController::class, 'destroyMissionJson'])
        ->name('misi.destroy');
});

// Fitur laporan melalui website
Route::middleware('auth')->group(function () {
    Route::get('/laporan/buat', [DisasterReportController::class, 'create'])
        ->name('laporan.create');

    Route::post('/laporan', [DisasterReportController::class, 'store'])
        ->name('laporan.store');
});

Route::get('/profil', [UserAuthController::class, 'showProfile'])
    ->name('profil');

Route::get('/api/peringatan-bencana', [WeatherAlertController::class, 'index'])
    ->name('api.peringatan');

// API Peta Evakuasi, Zona Bencana, dan Titik Evakuasi untuk Flutter
Route::get('/api/evakuasi', [EvacuationApiController::class, 'index'])
    ->name('api.evakuasi.index');

Route::get('/api/evakuasi/zona', [EvacuationApiController::class, 'zones'])
    ->name('api.evakuasi.zones');

Route::get('/api/evakuasi/titik', [EvacuationApiController::class, 'points'])
    ->name('api.evakuasi.points');

Route::get('/api/evakuasi/cek-lokasi', [EvacuationApiController::class, 'checkLocation'])
    ->name('api.evakuasi.check-location');
