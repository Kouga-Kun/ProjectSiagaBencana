<?php

namespace Tests\Feature;

use App\Models\SosRequest;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;

class SosRequestFeatureTest extends TestCase
{
    use RefreshDatabase;

    public function test_authenticated_user_can_send_sos_using_their_logged_in_account_identity(): void
    {
        $user = User::factory()->create([
            'name' => 'Rina Warga',
            'email' => 'rina@example.com',
            'phone' => '081234567890',
            'address' => 'Jl. Pemuda No. 12, Padang',
        ]);
        $otherUser = User::factory()->create(['name' => 'Orang Lain']);

        $response = $this->actingAs($user)
            ->postJson('/api/sos', [
                'user_id' => $otherUser->id,
                'user_name' => 'Nama Palsu',
                'user_phone' => '000000',
                'latitude' => -0.9471,
                'longitude' => 100.4172,
                'status' => 'selesai',
            ]);

        $response->assertCreated()
            ->assertJsonPath('data.user_id', $user->id)
            ->assertJsonPath('data.user_name', 'Rina Warga')
            ->assertJsonPath('data.user_phone', '081234567890')
            ->assertJsonPath('data.address', 'Jl. Pemuda No. 12, Padang')
            ->assertJsonPath('data.status', SosRequest::STATUS_WAITING)
            ->assertJsonPath('data.status_label', 'Menunggu');

        $this->assertDatabaseHas('sos_requests', [
            'user_id' => $user->id,
            'user_name' => 'Rina Warga',
            'user_phone' => '081234567890',
            'status' => 'menunggu',
        ]);
    }

    public function test_user_can_only_view_their_own_sos_history(): void
    {
        $userA = User::factory()->create(['name' => 'Warga A']);
        $userB = User::factory()->create(['name' => 'Warga B']);

        SosRequest::create([
            'user_id' => $userA->id,
            'user_name' => $userA->name,
            'user_phone' => '0811111111',
            'latitude' => -0.9471,
            'longitude' => 100.4172,
            'address' => 'Lokasi Warga A',
            'status' => SosRequest::STATUS_WAITING,
        ]);

        SosRequest::create([
            'user_id' => $userB->id,
            'user_name' => $userB->name,
            'user_phone' => '0822222222',
            'latitude' => -0.9500,
            'longitude' => 100.4200,
            'address' => 'Lokasi Warga B',
            'status' => SosRequest::STATUS_PROCESSING,
        ]);

        $response = $this->actingAs($userA)
            ->getJson('/api/sos/riwayat');

        $response->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.user_id', $userA->id)
            ->assertJsonPath('data.0.address', 'Lokasi Warga A');
    }

    public function test_only_report_staff_can_view_admin_sos_and_update_status(): void
    {
        $resident = User::factory()->create(['name' => 'Warga Biasa']);
        $staff = User::factory()->create(['name' => 'Petugas Siaga']);
        DB::table('users')->where('id', $staff->id)->update(['role' => 'petugas']);
        $staff->refresh();

        $sos = SosRequest::create([
            'user_id' => $resident->id,
            'user_name' => $resident->name,
            'user_phone' => '08123456789',
            'latitude' => -0.9471,
            'longitude' => 100.4172,
            'address' => 'Dekat Pantai Padang',
            'status' => SosRequest::STATUS_WAITING,
        ]);

        // Warga biasa ditolak mengakses endpoint petugas
        $this->actingAs($resident)
            ->getJson('/api/admin/sos')
            ->assertForbidden();

        $this->actingAs($resident)
            ->patchJson('/api/admin/sos/'.$sos->id.'/status', ['status' => 'diproses'])
            ->assertForbidden();

        // Petugas dapat melihat daftar SOS dan mengubah status menjadi Diproses lalu Selesai
        $this->actingAs($staff)
            ->getJson('/api/admin/sos')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('stats.menunggu', 1);

        $this->actingAs($staff)
            ->patchJson('/api/admin/sos/'.$sos->id.'/status', ['status' => 'diproses'])
            ->assertOk()
            ->assertJsonPath('data.status', 'diproses')
            ->assertJsonPath('data.status_label', 'Diproses');

        $this->actingAs($staff)
            ->patchJson('/api/admin/sos/'.$sos->id.'/status', ['status' => 'selesai'])
            ->assertOk()
            ->assertJsonPath('data.status', 'selesai')
            ->assertJsonPath('data.status_label', 'Selesai');

        $this->actingAs($staff)
            ->get(route('petugas.sos.index'))
            ->assertOk()
            ->assertSeeText('Dashboard Permintaan Bantuan Darurat (SOS)')
            ->assertSeeText('Warga Biasa');
    }
}

