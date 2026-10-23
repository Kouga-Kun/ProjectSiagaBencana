@extends('layouts.app')

@section('title', 'Daftar Akun - SiagaBencana')

@section('content')
<style>
    .auth-card { max-width: 480px; margin: 40px auto; padding: 28px; background: #fff; border: 1px solid #dce6f2; border-radius: 16px; box-shadow: 0 8px 24px rgba(18, 59, 99, .07); }
    .auth-card h1 { color: #123b63; margin: 0 0 8px; font-size: 27px; }
    .auth-card > p { color: #64748b; line-height: 1.6; }
    .auth-card form { display: grid; gap: 15px; }
    .auth-card label { display: grid; gap: 6px; color: #334155; font-weight: 600; }
    .auth-card input { width: 100%; padding: 10px 12px; border: 1px solid #cbd5e1; border-radius: 8px; font: inherit; }
    .auth-card input:focus { outline: 2px solid #93c5fd; border-color: #2563eb; }
    .auth-button { border: 0; border-radius: 9px; padding: 11px 15px; color: #fff; background: #1e40af; font: inherit; font-weight: 700; cursor: pointer; text-align: center; text-decoration: none; }
    .auth-error { color: #b91c1c; font-size: 14px; margin: 0; }
    .auth-link { text-align: center; color: #475569; }
</style>

<section class="auth-card">
    <h1>Daftar akun</h1>
    <p>Buat akun untuk mengakses halaman profil SiagaBencana.</p>

    @if ($errors->any())
        <p class="auth-error" role="alert">{{ $errors->first() }}</p>
    @endif

    <form method="POST" action="{{ route('register.store') }}">
        @csrf
        <label>Nama lengkap
            <input type="text" name="name" value="{{ old('name') }}" autocomplete="name" maxlength="255" required autofocus>
        </label>
        <label>Email
            <input type="email" name="email" value="{{ old('email') }}" autocomplete="email" maxlength="255" required>
        </label>
        <label>Kata sandi (minimal 8 karakter)
            <input type="password" name="password" autocomplete="new-password" required>
        </label>
        <label>Konfirmasi kata sandi
            <input type="password" name="password_confirmation" autocomplete="new-password" required>
        </label>
        <button class="auth-button" type="submit">Daftar Akun</button>
    </form>

    <p class="auth-link">Sudah punya akun? <a href="{{ route('login') }}">Login</a></p>
</section>
@endsection
