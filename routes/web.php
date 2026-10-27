<?php

use App\Http\Controllers\DisasterReportApiController;
use App\Http\Controllers\DisasterReportController;
use App\Http\Controllers\ReportStaffAuthController;
use App\Http\Controllers\UserAuthController;
use App\Http\Controllers\WeatherAlertController;
use Illuminate\Support\Facades\Route;

Route::view('/', 'home')->name('home');

Route::view('/evakuasi', 'evakuasi')->name('evakuasi');
Route::view('/berita', 'berita')->name('berita');
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

// API laporan bencana untuk Flutter
Route::get('/api/laporan', [DisasterReportApiController::class, 'index'])
    ->name('api.laporan.index');

Route::post('/api/laporan', [DisasterReportApiController::class, 'store'])
    ->middleware('auth')
    ->name('api.laporan.store');

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
