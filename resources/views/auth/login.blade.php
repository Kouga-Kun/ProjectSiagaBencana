@extends('layouts.app')

@section('title', 'Login - SiagaBencana')

@section('content')
<style>
    .auth-card { max-width: 480px; margin: 40px auto; padding: 28px; background: #fff; border: 1px solid #dce6f2; border-radius: 16px; box-shadow: 0 8px 24px rgba(18, 59, 99, .07); }
    .auth-card h1 { color: #123b63; margin: 0 0 8px; font-size: 27px; }
    .auth-card > p { color: #64748b; line-height: 1.6; }
    .auth-card form { display: grid; gap: 15px; }
    .auth-card label { display: grid; gap: 6px; color: #334155; font-weight: 600; }
    .auth-card input:not([type=checkbox]) { width: 100%; padding: 10px 12px; border: 1px solid #cbd5e1; border-radius: 8px; font: inherit; }
    .auth-card input:focus { outline: 2px solid #93c5fd; border-color: #2563eb; }
    .auth-button { border: 0; border-radius: 9px; padding: 11px 15px; color: #fff; background: #1e40af; font: inherit; font-weight: 700; cursor: pointer; text-align: center; text-decoration: none; }
    .auth-error { color: #b91c1c; font-size: 14px; margin: 0; }
    .auth-link { text-align: center; color: #475569; }
</style>

<section class="auth-card">
    <h1>Login</h1>
    <p>Masuk ke akun SiagaBencana untuk membuka profilmu.</p>

    @if ($errors->any())
        <p class="auth-error" role="alert">{{ $errors->first() }}</p>
    @endif

    <form method="POST" action="{{ route('login.store') }}">
        @csrf
        <label>Email
            <input type="email" name="email" value="{{ old('email') }}" autocomplete="username" required autofocus>
        </label>
        <label>Kata sandi
            <input type="password" name="password" autocomplete="current-password" required>
        </label>
        <label><span><input type="checkbox" name="remember" value="1"> Ingat saya</span></label>
        <button class="auth-button" type="submit">Login</button>
    </form>

    <p class="auth-link">Belum punya akun? <a href="{{ route('register') }}">Daftar akun</a></p>
</section>
@endsection
