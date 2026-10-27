<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class UserAuthJsonFeatureTest extends TestCase
{
    use RefreshDatabase;

    public function test_csrf_endpoint_returns_a_non_cacheable_token(): void
    {
        $response = $this->getJson('/api/auth/csrf');

        $response->assertOk()
            ->assertJsonStructure(['csrf_token'])
            ->assertHeader('Cache-Control', 'no-store, private');
        $this->assertNotSame('', $response->json('csrf_token'));
    }

    public function test_guest_can_register_a_warga_account_without_receiving_password_data(): void
    {
        $response = $this->postJson('/api/auth/register', [
            'name' => 'Sari Pengguna',
            'email' => 'sari@example.com',
            'password' => 'password123',
            'password_confirmation' => 'password123',
            'role' => 'petugas',
        ]);

        $user = User::where('email', 'sari@example.com')->firstOrFail();

        $response->assertCreated()
            ->assertJsonPath('user.name', 'Sari Pengguna')
            ->assertJsonPath('user.email', 'sari@example.com')
            ->assertJsonPath('user.role', 'warga')
            ->assertJsonMissingPath('user.password');
        $this->assertModelExists($user);
        $this->assertAuthenticatedAs($user);
        $this->assertSame('warga', $user->role);
        $this->assertTrue(Hash::check('password123', $user->password));
    }

    public function test_registration_rejects_duplicate_email_with_json_validation_errors(): void
    {
        User::factory()->create(['email' => 'sari@example.com']);

        $this->postJson('/api/auth/register', [
            'name' => 'Sari Baru',
            'email' => 'sari@example.com',
            'password' => 'password123',
            'password_confirmation' => 'password123',
        ])->assertUnprocessable()
            ->assertJsonValidationErrors('email');

        $this->assertDatabaseCount('users', 1);
        $this->assertGuest();
    }

    public function test_user_can_log_in_and_receives_only_public_account_fields(): void
    {
        $user = User::factory()->create([
            'email' => 'sari@example.com',
            'password' => Hash::make('password123'),
        ]);

        $this->postJson('/api/auth/login', [
            'email' => 'sari@example.com',
            'password' => 'password123',
        ])->assertOk()
            ->assertJsonPath('user.id', $user->id)
            ->assertJsonPath('user.email', 'sari@example.com')
            ->assertJsonMissingPath('user.password');

        $this->assertAuthenticatedAs($user);
    }

    public function test_login_rejects_invalid_credentials_without_authenticating(): void
    {
        User::factory()->create([
            'email' => 'sari@example.com',
            'password' => Hash::make('password123'),
        ]);

        $this->postJson('/api/auth/login', [
            'email' => 'sari@example.com',
            'password' => 'password-salah',
        ])->assertUnprocessable()
            ->assertJsonValidationErrors('email');

        $this->assertGuest();
    }

    public function test_status_endpoint_reports_guest_and_authenticated_session(): void
    {
        $this->getJson('/api/auth/status')
            ->assertOk()
            ->assertJsonPath('authenticated', false)
            ->assertJsonPath('user', null);

        $user = User::factory()->create();

        $this->actingAs($user)
            ->getJson('/api/auth/status')
            ->assertOk()
            ->assertJsonPath('authenticated', true)
            ->assertJsonPath('user.id', $user->id);
    }

    public function test_authenticated_user_can_log_out_and_session_is_invalidated(): void
    {
        $user = User::factory()->create();

        $this->actingAs($user)
            ->postJson('/api/auth/logout')
            ->assertOk()
            ->assertJsonPath('message', 'Kamu berhasil keluar dari akun.');

        $this->assertGuest();
        $this->getJson('/api/auth/status')
            ->assertOk()
            ->assertJsonPath('authenticated', false);
    }
}
