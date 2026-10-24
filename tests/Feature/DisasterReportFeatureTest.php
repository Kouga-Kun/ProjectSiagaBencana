<?php

namespace Tests\Feature;

use App\Models\DisasterReport;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;

class DisasterReportFeatureTest extends TestCase
{
    use RefreshDatabase;

    public function test_public_history_shows_real_statistics_and_escapes_report_text(): void
    {
        $report = $this->createReport([
            'description' => '<script>alert(1)</script>',
            'affected_area' => 'Pantai Padang',
            'verification_status' => DisasterReport::STATUS_PENDING,
        ]);

        $this->get(route('laporan'))
            ->assertOk()
            ->assertSeeText('Menunggu verifikasi')
            ->assertSee('&lt;script&gt;alert(1)&lt;/script&gt;', false)
            ->assertDontSee('<script>alert(1)</script>', false)
            ->assertViewHas('totalReports', 1)
            ->assertViewHas('disasterTypeCount', 1)
            ->assertViewHas('affectedAreaCount', 1)
            ->assertViewHas('pendingReports', 1);
    }

    public function test_filters_history_by_status_type_and_date(): void
    {
        $this->createReport([
            'disaster_type' => 'Gempa bumi',
            'occurred_at' => '2026-01-02 10:00:00',
            'description' => 'Laporan yang cocok.',
            'verification_status' => DisasterReport::STATUS_VERIFIED,
        ]);
        $this->createReport([
            'disaster_type' => 'Banjir',
            'occurred_at' => '2025-12-30 10:00:00',
            'description' => 'Laporan yang tidak cocok.',
            'verification_status' => DisasterReport::STATUS_PENDING,
        ]);

        $this->get(route('laporan', [
            'verification_status' => 'verified',
            'disaster_type' => 'Gempa bumi',
            'start_date' => '2026-01-01',
            'end_date' => '2026-01-31',
        ]))
            ->assertOk()
            ->assertSeeText('Laporan yang cocok.')
            ->assertDontSeeText('Laporan yang tidak cocok.');
    }

    public function test_history_displays_pending_verified_and_rejected_statuses(): void
    {
        $this->createReport(['verification_status' => DisasterReport::STATUS_PENDING]);
        $this->createReport(['verification_status' => DisasterReport::STATUS_VERIFIED]);
        $this->createReport(['verification_status' => DisasterReport::STATUS_REJECTED]);

        $this->get(route('laporan'))
            ->assertOk()
            ->assertSeeText('Menunggu verifikasi')
            ->assertSeeText('Terverifikasi')
            ->assertSeeText('Ditolak');
    }

    public function test_history_filters_by_source_and_each_location_level(): void
    {
        $this->createReport([
            'source_type' => DisasterReport::SOURCE_OFFICIAL,
            'province' => 'Sumatera Barat',
            'city_district' => 'Kota Padang',
            'district' => 'Koto Tangah',
            'description' => 'Laporan sesuai seluruh wilayah.',
        ]);
        $this->createReport([
            'source_type' => DisasterReport::SOURCE_STAFF,
            'district' => 'Padang Barat',
            'description' => 'Laporan wilayah lain.',
        ]);

        $this->get(route('laporan', [
            'source_type' => 'official',
            'province' => 'Sumatera Barat',
            'city_district' => 'Kota Padang',
            'district' => 'Koto Tangah',
        ]))
            ->assertOk()
            ->assertSeeText('Laporan sesuai seluruh wilayah.')
            ->assertDontSeeText('Laporan wilayah lain.');
    }

    public function test_empty_history_displays_informative_message(): void
    {
        $this->get(route('laporan'))
            ->assertOk()
            ->assertSeeText('Belum ada data laporan.')
            ->assertViewHas('totalReports', 0);
    }

    public function test_end_date_can_be_used_alone_and_must_not_precede_start_date(): void
    {
        $this->get(route('laporan', ['end_date' => '2026-01-31']))
            ->assertOk();

        $this->from(route('laporan'))
            ->get(route('laporan', [
                'start_date' => '2026-02-01',
                'end_date' => '2026-01-31',
            ]))
            ->assertRedirect(route('laporan'))
            ->assertSessionHasErrors('end_date');
    }

    public function test_history_paginates_ten_reports_and_preserves_page_query(): void
    {
        foreach (range(1, 11) as $number) {
            $this->createReport([
                'description' => sprintf('Laporan %02d', $number),
                'occurred_at' => '2026-01-01 10:00:00',
            ]);
        }

        $this->get(route('laporan'))
            ->assertOk()
            ->assertSeeText('Laporan 11')
            ->assertDontSeeText('Laporan 01');

        $this->get(route('laporan', ['page' => 2]))
            ->assertOk()
            ->assertSeeText('Laporan 01');
    }

    public function test_only_authenticated_users_can_submit_while_staff_actions_remain_protected(): void
    {
        $this->get(route('laporan.create'))->assertRedirect(route('login'));

        $resident = User::factory()->create();
        $report = $this->createReport();

        $this->actingAs($resident)
            ->get(route('laporan.create'))
            ->assertOk()
            ->assertSeeText('Buat laporan bencana');

        $this->actingAs($resident)
            ->post(route('laporan.store'), ['disaster_type' => 'Banjir'])
            ->assertRedirect(route('laporan'));

        $submittedReport = DisasterReport::query()->where('submitted_by', $resident->id)->sole();
        $this->assertSame('Banjir', $submittedReport->disaster_type);
        $this->assertSame(DisasterReport::SOURCE_COMMUNITY, $submittedReport->source_type);
        $this->assertSame($resident->name, $submittedReport->source_name);
        $this->assertSame(DisasterReport::STATUS_PENDING, $submittedReport->verification_status);

        $this->actingAs($resident)
            ->patch(route('laporan.verify', $report), ['verification_status' => 'verified'])
            ->assertForbidden();
    }

    public function test_staff_can_create_pending_report_but_cannot_set_verification_fields(): void
    {
        $staff = $this->createStaff();

        $this->actingAs($staff)
            ->post(route('laporan.store'), $this->validPayload() + [
                'verification_status' => 'verified',
                'verified_by' => $staff->id,
            ])
            ->assertRedirect(route('laporan'));

        $report = DisasterReport::query()->sole();
        $this->assertSame(DisasterReport::STATUS_PENDING, $report->verification_status);
        $this->assertSame($staff->id, $report->submitted_by);
        $this->assertNull($report->verified_by);
        $this->assertModelExists($report);
    }

    public function test_report_input_validation_rejects_an_empty_report(): void
    {
        $staff = $this->createStaff();

        $this->actingAs($staff)
            ->from(route('laporan.create'))
            ->post(route('laporan.store'), [])
            ->assertRedirect(route('laporan.create'))
            ->assertSessionHasErrors('description');

        $this->assertDatabaseCount('disaster_reports', 0);
    }

    public function test_staff_verification_records_status_actor_and_time(): void
    {
        $staff = $this->createStaff();
        $report = $this->createReport();

        $this->actingAs($staff)
            ->patch(route('laporan.verify', $report), ['verification_status' => 'verified'])
            ->assertRedirect(route('laporan'));

        $this->assertDatabaseHas('disaster_reports', [
            'id' => $report->id,
            'verification_status' => DisasterReport::STATUS_VERIFIED,
            'verified_by' => $staff->id,
        ]);
        $this->assertNotNull($report->fresh()->verified_at);
    }

    public function test_editing_report_returns_it_to_pending_verification(): void
    {
        $staff = $this->createStaff();
        $verifier = $this->createStaff();
        $report = $this->createReport([
            'verification_status' => DisasterReport::STATUS_VERIFIED,
        ]);
        $report->verified_by = $verifier->id;
        $report->verified_at = now();
        $report->save();

        $payload = $this->validPayload();
        $payload['description'] = 'Deskripsi telah diperbarui.';
        $this->actingAs($staff)
            ->patch(route('laporan.update', $report), $payload)
            ->assertRedirect(route('laporan'));

        $this->assertDatabaseHas('disaster_reports', [
            'id' => $report->id,
            'description' => 'Deskripsi telah diperbarui.',
            'verification_status' => DisasterReport::STATUS_PENDING,
            'verified_by' => null,
            'verified_at' => null,
        ]);
    }

    public function test_deleting_user_preserves_report_and_clears_staff_references(): void
    {
        $staff = $this->createStaff();
        $report = $this->createReport();
        $report->submitted_by = $staff->id;
        $report->verified_by = $staff->id;
        $report->verified_at = now();
        $report->save();

        $staff->delete();

        $this->assertDatabaseHas('disaster_reports', [
            'id' => $report->id,
            'submitted_by' => null,
            'verified_by' => null,
        ]);
    }

    public function test_staff_login_rejects_accounts_without_staff_role(): void
    {
        $resident = User::factory()->create();

        $this->from(route('login'))
            ->post(route('report-staff.login.store'), [
                'email' => $resident->email,
                'password' => 'password',
            ])
            ->assertRedirect(route('login'))
            ->assertSessionHasErrors('email');

        $this->assertGuest();
    }

    public function test_report_staff_can_sign_in_with_existing_account(): void
    {
        $staff = $this->createStaff();

        $this->post(route('report-staff.login.store'), [
            'email' => $staff->email,
            'password' => 'password',
        ])->assertRedirect(route('laporan'));

        $this->assertAuthenticatedAs($staff);
    }

    private function createStaff(): User
    {
        $staff = User::factory()->create();
        DB::table('users')->where('id', $staff->id)->update(['role' => 'petugas']);

        return $staff->refresh();
    }

    /**
     * @param  array<string, mixed>  $overrides
     */
    private function createReport(array $overrides = []): DisasterReport
    {
        $attributes = array_merge([
            'disaster_type' => 'Gempa bumi',
            'occurred_at' => '2026-01-01 10:00:00',
            'province' => 'Sumatera Barat',
            'city_district' => 'Kota Padang',
            'district' => 'Padang Barat',
            'affected_area' => 'Pantai Padang',
            'description' => 'Keterangan kejadian.',
            'source_type' => DisasterReport::SOURCE_STAFF,
            'source_name' => 'Petugas SiagaBencana',
            'verification_status' => DisasterReport::STATUS_PENDING,
        ], $overrides);
        $verificationStatus = $attributes['verification_status'];
        unset($attributes['verification_status']);

        $report = DisasterReport::factory()->create($attributes);
        $report->verification_status = $verificationStatus;
        $report->save();

        return $report;
    }

    /**
     * @return array<string, string>
     */
    private function validPayload(): array
    {
        return [
            'disaster_type' => 'Banjir',
            'occurred_at' => '2026-02-10T12:30',
            'province' => 'Sumatera Barat',
            'city_district' => 'Kota Padang',
            'district' => 'Koto Tangah',
            'affected_area' => 'Lubuk Buaya',
            'description' => 'Genangan dilaporkan di beberapa ruas jalan.',
            'source_type' => 'official',
            'source_name' => 'BPBD Kota Padang',
            'source_url' => 'https://example.test/laporan/1',
        ];
    }
}
