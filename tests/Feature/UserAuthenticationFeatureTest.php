<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class UserAuthenticationFeatureTest extends TestCase
{
    use RefreshDatabase;

    public function test_guest_can_register_and_is_signed_in_without_assigning_a_privileged_role(): void
    {
        $response = $this->post(route('register.store'), [
            'name' => 'Sari Pengguna',
            'email' => 'sari@example.com',
            'password' => 'password123',
            'password_confirmation' => 'password123',
            'role' => 'petugas',
        ]);

        $user = User::where('email', 'sari@example.com')->firstOrFail();

        $response->assertRedirect(route('profil'));
        $this->assertAuthenticatedAs($user);
        $this->assertDatabaseHas('users', [
            'id' => $user->id,
            'name' => 'Sari Pengguna',
            'email' => 'sari@example.com',
            'role' => 'warga',
        ]);
        $this->assertTrue(Hash::check('password123', $user->password));
        $this->assertNotSame('password123', $user->password);
    }

    public function test_registration_rejects_an_email_that_is_already_registered(): void
    {
        User::factory()->create(['email' => 'sari@example.com']);

        $this->from(route('register'))
            ->post(route('register.store'), [
                'name' => 'Sari Baru',
                'email' => 'sari@example.com',
                'password' => 'password123',
                'password_confirmation' => 'password123',
            ])
            ->assertRedirect(route('register'))
            ->assertSessionHasErrors('email');
    }

    public function test_registration_rejects_passwords_that_do_not_match_or_are_too_short(): void
    {
        $this->post(route('register.store'), [
            'name' => 'Sari Pengguna',
            'email' => 'sari@example.com',
            'password' => 'short',
            'password_confirmation' => 'different',
        ])->assertSessionHasErrors(['password']);

        $this->assertDatabaseMissing('users', ['email' => 'sari@example.com']);
    }

    public function test_user_can_log_in_with_valid_credentials(): void
    {
        $user = User::factory()->create([
            'email' => 'sari@example.com',
            'password' => Hash::make('password123'),
        ]);

        $this->post(route('login.store'), [
            'email' => 'sari@example.com',
            'password' => 'password123',
        ])->assertRedirect(route('profil'));

        $this->assertAuthenticatedAs($user);
    }

    public function test_login_rejects_invalid_credentials_with_a_clear_error(): void
    {
        User::factory()->create([
            'email' => 'sari@example.com',
            'password' => Hash::make('password123'),
        ]);

        $this->from(route('login'))
            ->post(route('login.store'), [
                'email' => 'sari@example.com',
                'password' => 'wrong-password',
            ])
            ->assertRedirect(route('login'))
            ->assertSessionHasErrors('email');

        $this->assertGuest();
    }

    public function test_guest_profile_prompts_for_login_and_registration(): void
    {
        $this->get(route('profil'))
            ->assertOk()
            ->assertSeeText('Silakan login terlebih dahulu untuk mengakses halaman profil.')
            ->assertSee(route('login'), false)
            ->assertSee(route('register'), false)
            ->assertDontSeeText('Akun tamu');
    }

    public function test_authenticated_user_sees_only_their_basic_profile_information(): void
    {
        $user = User::factory()->create([
            'name' => 'Sari Pengguna',
            'email' => 'sari@example.com',
            'password' => Hash::make('password123'),
        ]);

        $this->actingAs($user)
            ->get(route('profil'))
            ->assertOk()
            ->assertSeeText('Sari Pengguna')
            ->assertSeeText('sari@example.com')
            ->assertSee(route('logout'), false)
            ->assertDontSee($user->password, false);
    }

    public function test_logout_ends_the_session_and_returns_to_guest_mode(): void
    {
        $user = User::factory()->create();

        $this->actingAs($user)
            ->post(route('logout'))
            ->assertRedirect(route('home'))
            ->assertSessionHas('status', 'Kamu berhasil keluar dari akun.');

        $this->assertGuest();

        $this->get(route('profil'))
            ->assertOk()
            ->assertSeeText('Silakan login terlebih dahulu untuk mengakses halaman profil.');
    }

    public function test_public_pages_remain_accessible_to_guests(): void
    {
        foreach (['home', 'evakuasi', 'berita', 'mitigasi', 'laporan'] as $routeName) {
            $this->get(route($routeName))->assertOk();
        }

        $this->get(route('laporan'))
            ->assertSee(route('report-staff.login'), false);
    }
}
