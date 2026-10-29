<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rules\Password;
use Illuminate\View\View;
use Symfony\Component\HttpFoundation\StreamedResponse;

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

    public function profileJson(Request $request): JsonResponse
    {
        $user = $request->user();

        return response()->json([
            'user' => $this->userPayload($user),
        ]);
    }

    public function updateProfileJson(Request $request): JsonResponse
    {
        $user = $request->user();

        $validated = $request->validate([
            'name' => ['required', 'string', 'min:2', 'max:255'],
            'phone' => ['required', 'string', 'min:8', 'max:30', 'regex:/^[0-9+\-\s()]+$/'],
            'address' => ['required', 'string', 'min:5', 'max:500'],
            'photo' => ['nullable', 'image', 'mimes:jpg,jpeg,png,webp', 'max:2048'],
        ], [
            'name.required' => 'Nama lengkap wajib diisi.',
            'name.min' => 'Nama lengkap minimal 2 karakter.',
            'name.max' => 'Nama lengkap maksimal 255 karakter.',
            'phone.required' => 'Nomor telepon wajib diisi.',
            'phone.min' => 'Nomor telepon minimal 8 karakter.',
            'phone.max' => 'Nomor telepon maksimal 30 karakter.',
            'phone.regex' => 'Format nomor telepon hanya boleh berisi angka dan tanda telepon (+, -, spasi, kurung).',
            'address.required' => 'Alamat wajib diisi.',
            'address.min' => 'Alamat minimal 5 karakter.',
            'address.max' => 'Alamat maksimal 500 karakter.',
            'photo.image' => 'File foto profil harus berupa gambar.',
            'photo.mimes' => 'Format foto profil harus JPG, JPEG, PNG, atau WEBP.',
            'photo.max' => 'Ukuran foto profil maksimal 2 MB.',
        ]);

        if ($request->hasFile('photo')) {
            $newPhotoPath = $request->file('photo')->store('profile-photos', 'public');

            if (
                is_string($user->profile_photo_path) &&
                $user->profile_photo_path !== '' &&
                Storage::disk('public')->exists($user->profile_photo_path)
            ) {
                Storage::disk('public')->delete($user->profile_photo_path);
            }

            $user->profile_photo_path = $newPhotoPath;
        }

        $user->name = trim($validated['name']);
        $user->phone = trim($validated['phone']);
        $user->address = trim($validated['address']);
        $user->save();
        $user->refresh();

        return response()->json([
            'message' => 'Informasi profil berhasil diperbarui.',
            'user' => $this->userPayload($user),
        ]);
    }

    public function profilePhoto(User $user): StreamedResponse
    {
        $path = $user->profile_photo_path;

        if (! is_string($path) || $path === '' || ! Storage::disk('public')->exists($path)) {
            abort(404, 'Foto profil tidak ditemukan.');
        }

        return Storage::disk('public')->response($path, null, [
            'Cache-Control' => 'public, max-age=86400',
        ]);
    }

    /**
     * @return array{
     *     id: int,
     *     name: string,
     *     email: string,
     *     role: string,
     *     phone: ?string,
     *     address: ?string,
     *     profile_photo_url: ?string
     * }
     */
    private function userPayload(User $user): array
    {
        return [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'role' => $user->role,
            'phone' => $user->phone,
            'address' => $user->address,
            'profile_photo_url' => $this->profilePhotoUrl($user),
        ];
    }

    private function profilePhotoUrl(User $user): ?string
    {
        if (! is_string($user->profile_photo_path) || trim($user->profile_photo_path) === '') {
            return null;
        }

        return route('api.profile.photo', [
            'user' => $user->id,
            'v' => $user->updated_at?->timestamp ?? time(),
        ]);
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
