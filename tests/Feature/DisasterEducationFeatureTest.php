<?php

namespace Tests\Feature;

use App\Models\LearningMaterial;
use App\Models\Mission;
use App\Models\Quiz;
use App\Models\Simulation;
use App\Models\User;
use App\Models\UserMission;
use Database\Seeders\DisasterEducationSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class DisasterEducationFeatureTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        DisasterEducationSeeder::ensureSeeded();
    }

    public function test_public_can_access_education_web_and_api_summary_with_earthquake_and_tsunami_categories(): void
    {
        $webResponse = $this->get(route('edukasi.index'));
        $webResponse->assertOk()
            ->assertSee('Edukasi Gempa Bumi dan Tsunami')
            ->assertSee('Kenali Risikonya, Lindungi Dirimu, Selamatkan Sesama.')
            ->assertSee('Gempa Bumi')
            ->assertSee('Tsunami');

        $apiResponse = $this->getJson(route('api.edukasi.summary'));
        $apiResponse->assertOk()
            ->assertJsonPath('title', 'Edukasi Gempa Bumi dan Tsunami')
            ->assertJsonPath('subtitle', 'Kenali Risikonya, Lindungi Dirimu, Selamatkan Sesama.')
            ->assertJsonCount(2, 'categories');
    }

    public function test_materials_endpoint_returns_12_earthquake_and_12_tsunami_materials_and_supports_filters(): void
    {
        $allResponse = $this->getJson(route('api.edukasi.materi.index'));
        $allResponse->assertOk()
            ->assertJsonCount(24, 'data');

        $gempaResponse = $this->getJson(route('api.edukasi.materi.index', ['category' => 'Gempa Bumi']));
        $gempaResponse->assertOk()
            ->assertJsonCount(12, 'data');

        $tsunamiResponse = $this->getJson(route('api.edukasi.materi.index', ['category' => 'Tsunami']));
        $tsunamiResponse->assertOk()
            ->assertJsonCount(12, 'data');

        $searchResponse = $this->getJson(route('api.edukasi.materi.index', ['search' => 'Tas Siaga']));
        $searchResponse->assertOk();
        $this->assertNotEmpty($searchResponse->json('data'));
    }

    public function test_material_detail_can_be_opened_and_marked_completed_by_logged_in_user(): void
    {
        $user = User::factory()->create();
        $material = LearningMaterial::where('category', 'Gempa Bumi')->orderBy('sort_order')->firstOrFail();

        $detailResponse = $this->getJson(route('api.edukasi.materi.show', $material->slug));
        $detailResponse->assertOk()
            ->assertJsonPath('data.title', $material->title)
            ->assertJsonPath('data.category', 'Gempa Bumi')
            ->assertJsonStructure([
                'data' => [
                    'id',
                    'title',
                    'slug',
                    'key_points',
                    'action_steps',
                    'things_to_avoid',
                    'source_reference',
                    'previous_material',
                    'next_material',
                ],
            ]);

        $completeResponse = $this->actingAs($user)
            ->postJson(route('api.edukasi.materi.complete', $material), ['is_completed' => true]);

        $completeResponse->assertOk()
            ->assertJsonPath('is_completed', true)
            ->assertJsonPath('progress.materials.completed', 1);

        $this->assertDatabaseHas('learning_progress', [
            'user_id' => $user->id,
            'learning_material_id' => $material->id,
            'is_completed' => true,
        ]);
    }

    public function test_simulations_list_has_12_scenarios_and_logged_in_user_can_submit_simulation(): void
    {
        $user = User::factory()->create();

        $listResponse = $this->getJson(route('api.edukasi.simulasi.index'));
        $listResponse->assertOk()
            ->assertJsonCount(12, 'data');

        $simulation = Simulation::with('steps.choices')->where('category', 'Tsunami')->firstOrFail();
        $choicesPayload = [];
        foreach ($simulation->steps as $step) {
            $correctChoice = $step->choices->firstWhere('is_correct', true);
            $choicesPayload[$step->id] = $correctChoice->id;
        }

        $submitResponse = $this->actingAs($user)
            ->postJson(route('api.edukasi.simulasi.submit', $simulation), [
                'choices' => $choicesPayload,
            ]);

        $submitResponse->assertCreated()
            ->assertJsonPath('result.score', 100)
            ->assertJsonPath('result.correct_choices', $simulation->steps->count());

        $this->assertDatabaseHas('simulation_results', [
            'user_id' => $user->id,
            'simulation_id' => $simulation->id,
            'score' => 100,
        ]);
    }

    public function test_quiz_does_not_expose_correct_answers_before_submission_and_grades_accurately_on_submit(): void
    {
        $user = User::factory()->create();
        $quiz = Quiz::with('questions.options')->where('category', 'Gempa Bumi')->firstOrFail();

        $showResponse = $this->getJson(route('api.edukasi.kuis.show', $quiz->slug));
        $showResponse->assertOk();

        $firstQuestion = $showResponse->json('data.questions.0');
        $this->assertArrayNotHasKey('explanation', $firstQuestion);
        $this->assertArrayNotHasKey('is_correct', $firstQuestion['options'][0]);

        $answersPayload = [];
        foreach ($quiz->questions as $question) {
            $correctOpt = $question->options->firstWhere('is_correct', true);
            $answersPayload[$question->id] = $correctOpt->id;
        }

        $submitResponse = $this->actingAs($user)
            ->postJson(route('api.edukasi.kuis.submit', $quiz), [
                'answers' => $answersPayload,
            ]);

        $submitResponse->assertCreated()
            ->assertJsonPath('result.correct_answers', $quiz->questions->count())
            ->assertJsonPath('result.wrong_answers', 0)
            ->assertJsonPath('result.final_score', 100);

        $this->assertNotEmpty($submitResponse->json('result.reviews.0.explanation'));

        $this->assertDatabaseHas('quiz_results', [
            'user_id' => $user->id,
            'quiz_id' => $quiz->id,
            'final_score' => 100,
        ]);
    }

    public function test_missions_status_can_be_updated_and_awards_keluarga_siaga_badge_when_criteria_met(): void
    {
        $user = User::factory()->create();
        $missions = Mission::where('status', Mission::STATUS_PUBLISHED)->limit(5)->get();

        foreach ($missions as $mission) {
            $response = $this->actingAs($user)
                ->patchJson(route('api.edukasi.misi.status', $mission), [
                    'status' => UserMission::STATUS_COMPLETED,
                    'notes' => 'Telah didiskusikan bersama keluarga di rumah.',
                ]);
            $response->assertOk()
                ->assertJsonPath('data.user_status', UserMission::STATUS_COMPLETED);
        }

        $progressResponse = $this->actingAs($user)->getJson(route('api.edukasi.progres'));
        $progressResponse->assertOk()
            ->assertJsonPath('data.missions.completed', 5);

        $badges = collect($progressResponse->json('data.badges.items'));
        $keluargaSiaga = $badges->firstWhere('slug', 'keluarga-siaga');
        $this->assertNotNull($keluargaSiaga);
        $this->assertTrue($keluargaSiaga['is_earned']);
    }

    public function test_admin_endpoints_are_protected_and_allow_staff_to_crud_education_content(): void
    {
        $regularUser = User::factory()->create(['role' => User::ROLE_PUBLIC]);
        $staffUser = User::factory()->reportStaff()->create();

        $this->actingAs($regularUser)
            ->postJson(route('api.admin.edukasi.materi.store'), [
                'category' => 'Gempa Bumi',
                'title' => 'Materi Uji Coba',
            ])
            ->assertForbidden();

        $createResponse = $this->actingAs($staffUser)
            ->postJson(route('api.admin.edukasi.materi.store'), [
                'category' => 'Gempa Bumi',
                'title' => 'Panduan Audit Struktur Rumah Tahan Gempa',
                'difficulty' => 'Menengah',
                'summary' => 'Cara memeriksa kolom, balok, dan ikatan dinding rumah tinggal.',
                'content' => 'Penjelasan lengkap mengenai pemeriksaan struktur bangunan sederhana tahan gempa sesuai pedoman teknis.',
                'key_points' => ['Periksa ikatan sloof, kolom, dan ring balk', 'Gunakan adukan mortar yang proporsional'],
                'action_steps' => ['Amati retakan struktural pada kolom utama', 'Konsultasikan perkuatan dengan tenaga ahli'],
                'things_to_avoid' => ['Membongkar dinding pemikul beban tanpa perhitungan'],
                'source_reference' => 'Pedoman Teknis Rumah Tahan Gempa PUPR & BNPB',
                'status' => 'published',
            ]);

        $createResponse->assertCreated()
            ->assertJsonPath('data.title', 'Panduan Audit Struktur Rumah Tahan Gempa');

        $materialId = $createResponse->json('data.id');

        $this->actingAs($staffUser)
            ->patchJson(route('api.admin.edukasi.materi.publish', $materialId), [
                'status' => 'draft',
            ])
            ->assertOk()
            ->assertJsonPath('data.status', 'draft');

        $this->actingAs($staffUser)
            ->deleteJson(route('api.admin.edukasi.materi.destroy', $materialId))
            ->assertOk();

        $this->assertDatabaseMissing('learning_materials', ['id' => $materialId]);
    }
}
