@extends('layouts.app')

@section('title', 'Masuk Petugas - SiagaBencana')

@section('content')
<style>
    .login-card { max-width: 480px; margin: 40px auto; padding: 28px; background: #fff; border: 1px solid #dce6f2; border-radius: 16px; box-shadow: 0 8px 24px rgba(18, 59, 99, .07); }
    .login-card h1 { color: #123b63; margin: 0 0 8px; font-size: 27px; }
    .login-card p { color: #64748b; line-height: 1.6; }
    .login-card form { display: grid; gap: 15px; }
    .login-card label { display: grid; gap: 6px; color: #334155; font-weight: 600; }
    .login-card .report-button { border: 0; border-radius: 9px; padding: 11px 15px; color: #fff; background: #1e40af; font: inherit; font-weight: 700; cursor: pointer; }
    .login-card .error { color: #b91c1c; font-size: 14px; }
</style>

<section class="login-card">
    <h1>Masuk petugas</h1>
    <p>Gunakan akun petugas yang telah disiapkan pengelola SiagaBencana.</p>
    @if ($errors->any())
        <p class="error" role="alert">{{ $errors->first() }}</p>
    @endif
    <form method="POST" action="{{ route('report-staff.login.store') }}">
        @csrf
        <label>Email <input type="email" name="email" value="{{ old('email') }}" autocomplete="username" required autofocus></label>
        <label>Kata sandi <input type="password" name="password" autocomplete="current-password" required></label>
        <label><span><input type="checkbox" name="remember" value="1"> Ingat saya</span></label>
        <button class="report-button" type="submit">Masuk</button>
    </form>
</section>
@endsection
