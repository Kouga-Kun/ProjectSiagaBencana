<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\Rules\Password;
use Illuminate\View\View;

class UserAuthController extends Controller
{
    public function csrfToken(): JsonResponse
    {
        return response()
            ->json(['csrf_token' => csrf_token()])
            ->header('Cache-Control', 'no-store, private');
    }

    public function registerJson(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'email', 'max:255', 'unique:users,email'],
            'password' => ['required', 'confirmed', Password::min(8)],
        ], [
            'name.required' => 'Nama lengkap wajib diisi.',
            'name.max' => 'Nama lengkap maksimal 255 karakter.',
            'email.required' => 'Email wajib diisi.',
            'email.email' => 'Masukkan alamat email yang valid.',
            'email.unique' => 'Email tersebut sudah terdaftar.',
            'password.required' => 'Kata sandi wajib diisi.',
            'password.confirmed' => 'Konfirmasi kata sandi tidak cocok.',
            'password.min' => 'Kata sandi minimal harus 8 karakter.',
        ]);

        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'password' => $validated['password'],
        ]);
        $user->refresh();

        Auth::login($user);
        $request->session()->regenerate();

        return response()->json([
            'message' => 'Pendaftaran berhasil.',
            'user' => $this->userPayload($user),
        ], 201);
    }

    public function loginJson(Request $request): JsonResponse
    {
        $credentials = $request->validate([
            'email' => ['required', 'email', 'max:255'],
            'password' => ['required', 'string'],
        ], [
            'email.required' => 'Email wajib diisi.',
            'email.email' => 'Masukkan alamat email yang valid.',
            'password.required' => 'Kata sandi wajib diisi.',
        ]);

        if (! Auth::attempt($credentials)) {
            return response()->json([
                'message' => 'Email atau kata sandi tidak sesuai.',
                'errors' => ['email' => ['Email atau kata sandi tidak sesuai.']],
            ], 422);
        }

        $request->session()->regenerate();
        $user = Auth::user();

        return response()->json([
            'message' => 'Login berhasil.',
            'user' => $this->userPayload($user),
        ]);
    }

    public function statusJson(Request $request): JsonResponse
    {
        $user = $request->user();

        return response()->json([
            'authenticated' => $user !== null,
            'user' => $user === null ? null : $this->userPayload($user),
        ]);
    }

    public function logoutJson(Request $request): JsonResponse
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return response()->json(['message' => 'Kamu berhasil keluar dari akun.']);
    }

    /**
     * @return array{id: int, name: string, email: string, role: string}
     */
    private function userPayload(User $user): array
    {
        return [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'role' => $user->role,
        ];
    }

    public function createLogin(): View
    {
        return view('auth.login');
    }

    public function storeLogin(Request $request): RedirectResponse
    {
        $credentials = $request->validate([
            'email' => ['required', 'email', 'max:255'],
            'password' => ['required', 'string'],
        ], [
            'email.required' => 'Email wajib diisi.',
            'email.email' => 'Masukkan alamat email yang valid.',
            'password.required' => 'Kata sandi wajib diisi.',
        ]);

        if (! Auth::attempt($credentials, $request->boolean('remember'))) {
            return back()
                ->withErrors(['email' => 'Email atau kata sandi tidak sesuai.'])
                ->onlyInput('email');
        }

        $request->session()->regenerate();

        return redirect()->intended(route('profil'));
    }

    public function createRegistration(): View
    {
        return view('auth.register');
    }

    public function storeRegistration(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'email', 'max:255', 'unique:users,email'],
            'password' => ['required', 'confirmed', Password::min(8)],
        ], [
            'name.required' => 'Nama lengkap wajib diisi.',
            'name.max' => 'Nama lengkap maksimal 255 karakter.',
            'email.required' => 'Email wajib diisi.',
            'email.email' => 'Masukkan alamat email yang valid.',
            'email.unique' => 'Email tersebut sudah terdaftar.',
            'password.required' => 'Kata sandi wajib diisi.',
            'password.confirmed' => 'Konfirmasi kata sandi tidak cocok.',
            'password.min' => 'Kata sandi minimal harus 8 karakter.',
        ]);

        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'password' => $validated['password'],
        ]);

        Auth::login($user);
        $request->session()->regenerate();

        return redirect()->route('profil')->with('status', 'Pendaftaran berhasil. Selamat datang di SiagaBencana.');
    }

    public function showProfile(): View
    {
        return view('profil', ['user' => Auth::user()]);
    }

    public function logout(Request $request): RedirectResponse
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect()->route('home')->with('status', 'Kamu berhasil keluar dari akun.');
    }
}
