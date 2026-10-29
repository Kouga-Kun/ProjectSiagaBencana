<?php

use App\Http\Controllers\DisasterReportApiController;
use App\Http\Controllers\DisasterReportController;
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

    Route::patch('/petugas/berita/{newsArticle}/publikasi', [NewsArticleController::class, 'togglePublishWeb'])
        ->name('petugas.berita.publish');

    Route::delete('/petugas/berita/{newsArticle}', [NewsArticleController::class, 'destroyWeb'])
        ->name('petugas.berita.destroy');
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
