<?php

use App\Http\Controllers\DisasterReportController;
use App\Http\Controllers\ReportStaffAuthController;
use App\Http\Controllers\WeatherAlertController;
use Illuminate\Support\Facades\Route;

Route::view('/', 'home')->name('home');

Route::view('/evakuasi', 'evakuasi')->name('evakuasi');
Route::view('/berita', 'berita')->name('berita');
Route::view('/mitigasi', 'mitigasi')->name('mitigasi');
Route::get('/laporan', [DisasterReportController::class, 'index'])->name('laporan');

Route::get('/petugas/masuk', [ReportStaffAuthController::class, 'create'])->middleware('guest')->name('login');
Route::post('/petugas/masuk', [ReportStaffAuthController::class, 'store'])->middleware(['guest', 'throttle:report-staff-login'])->name('report-staff.login.store');

Route::middleware(['auth', 'report.staff'])->group(function () {
    Route::post('/petugas/keluar', [ReportStaffAuthController::class, 'destroy'])->name('report-staff.logout');

    Route::get('/laporan/buat', [DisasterReportController::class, 'create'])->name('laporan.create');
    Route::post('/laporan', [DisasterReportController::class, 'store'])->name('laporan.store');
    Route::get('/laporan/{disasterReport}/edit', [DisasterReportController::class, 'edit'])->name('laporan.edit');
    Route::patch('/laporan/{disasterReport}', [DisasterReportController::class, 'update'])->name('laporan.update');
    Route::patch('/laporan/{disasterReport}/verifikasi', [DisasterReportController::class, 'verify'])->name('laporan.verify');
});
Route::view('/profil', 'profil')->name('profil');

Route::get('/api/peringatan-bencana', [WeatherAlertController::class, 'index'])
    ->name('api.peringatan');
