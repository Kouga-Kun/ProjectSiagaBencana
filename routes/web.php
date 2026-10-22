
<?php

use Illuminate\Support\Facades\Route;

Route::view('/', 'home')->name('home');

Route::view('/evakuasi', 'evakuasi')->name('evakuasi');
Route::view('/berita', 'berita')->name('berita');
Route::view('/mitigasi', 'mitigasi')->name('mitigasi');
Route::view('/laporan', 'laporan')->name('laporan');
Route::view('/profil', 'profil')->name('profil');

use App\Http\Controllers\WeatherAlertController;

Route::get('/api/peringatan-bencana', [WeatherAlertController::class, 'index'])
    ->name('api.peringatan');