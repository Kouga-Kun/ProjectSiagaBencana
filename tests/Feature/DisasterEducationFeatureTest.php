<?php

namespace Tests\Feature;

use App\Models\LearningMaterial;
use App\Models\LearningProgress;
use App\Models\Mission;
use App\Models\Quiz;
use App\Models\QuizResult;
use App\Models\Simulation;
use App\Models\SimulationResult;
use App\Models\User;
use App\Models\UserMission;
use Database\Seeders\DisasterEducationSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\File;
use Tests\TestCase;

class DisasterEducationFeatureTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        DisasterEducationSeeder::ensureSeeded();
    }

    public function test_unauthenticated_users_cannot_access_education_web_or_api_and_redirect_back_after_login(): void
    {
        // Web route redirects unauthenticated users to login
        $this->get(route('edukasi.index'))
            ->assertRedirect(route('login'));

        // All API endpoints return HTTP 401 when unauthenticated
        $this->getJson(route('api.edukasi.summary'))->assertUnauthorized();
        $this->getJson(route('api.edukasi.materi.index'))->assertUnauthorized();
        $this->getJson(route('api.edukasi.simulasi.index'))->assertUnauthorized();
        $this->getJson(route('api.edukasi.kuis.index'))->assertUnauthorized();
        $this->getJson(route('api.edukasi.misi.index'))->assertUnauthorized();
        $this->getJson(route('api.edukasi.progres'))->assertUnauthorized();
        $this->getJson(route('api.edukasi.riwayat'))->assertUnauthorized();
        $this->getJson(route('api.edukasi.badge'))->assertUnauthorized();
        $this->getJson(route('api.edukasi.pengingat.show'))->assertUnauthorized();

        // After logging in, user is redirected back to the intended /edukasi page
        $user = User::factory()->create([
            'password' => 'PasswordAman123!',
        ]);

        $this->post(route('login.store'), [
            'email' => $user->email,
            'password' => 'PasswordAman123!',
        ])->assertRedirect(route('edukasi.index'));

        $this->get(route('edukasi.index'))
            ->assertOk()
            ->assertSee('Edukasi Gempa Bumi dan Tsunami')
            ->assertSee('Kenali Risikonya, Lindungi Dirimu, Selamatkan Sesama.');
    }

    public function test_authenticated_user_can_browse_and_filter_24_earthquake_and_tsunami_materials(): void
    {
        $user = User::factory()->create();

        $summary = $this->actingAs($user)->getJson(route('api.edukasi.summary'));
        $summary->assertOk()
            ->assertJsonPath('title', 'Edukasi Gempa Bumi dan Tsunami')
            ->assertJsonCount(2, 'categories');

        $this->actingAs($user)->getJson(route('api.edukasi.materi.index'))
            ->assertOk()
            ->assertJsonCount(24, 'data');

        $this->actingAs($user)->getJson(route('api.edukasi.materi.index', ['category' => 'Gempa Bumi']))
            ->assertOk()
            ->assertJsonCount(12, 'data');

        $this->actingAs($user)->getJson(route('api.edukasi.materi.index', ['category' => 'Tsunami']))
            ->assertOk()
            ->assertJsonCount(12, 'data');

        $searchResponse = $this->actingAs($user)->getJson(route('api.edukasi.materi.index', ['search' => 'Tas Siaga']));
        $searchResponse->assertOk();
        $this->assertNotEmpty($searchResponse->json('data'));
    }

    public function test_auto_save_reading_progress_favorites_and_non_duplicating_material_completion(): void
    {
        $user = User::factory()->create();
        $material = LearningMaterial::where('category', 'Gempa Bumi')->orderBy('sort_order')->firstOrFail();

        // Save mid-reading auto-save position & favorite
        $autoSave = $this->actingAs($user)->postJson(route('api.edukasi.materi.progress', $material), [
            'last_position' => 45,
            'last_section' => 'langkah-tindakan',
            'progress_percent' => 45,
            'is_favorite' => true,
        ]);

        $autoSave->assertOk()
            ->assertJsonPath('data.last_position', 45)
            ->assertJsonPath('data.last_section', 'langkah-tindakan')
            ->assertJsonPath('data.is_favorite', true)
            ->assertJsonPath('data.is_completed', false);

        // Re-opening material returns saved last position so user can resume
        $this->actingAs($user)->getJson(route('api.edukasi.materi.show', $material->slug))
            ->assertOk()
            ->assertJsonPath('data.last_position', 45)
            ->assertJsonPath('data.last_section', 'langkah-tindakan')
            ->assertJsonPath('data.is_favorite', true);

        // Complete material twice — must NOT create duplicate progress rows or double points
        $firstComplete = $this->actingAs($user)
            ->postJson(route('api.edukasi.materi.complete', $material), ['is_completed' => true]);
        $firstComplete->assertOk()
            ->assertJsonPath('is_completed', true)
            ->assertJsonPath('progress.total_points', 25);

        $secondComplete = $this->actingAs($user)
            ->postJson(route('api.edukasi.materi.complete', $material), ['is_completed' => true]);
        $secondComplete->assertOk()
            ->assertJsonPath('progress.total_points', 25)
            ->assertJsonPath('progress.materials.completed', 1);

        $this->assertSame(
            1,
            LearningProgress::where('user_id', $user->id)->where('learning_material_id', $material->id)->count()
        );
    }

    public function test_simulation_draft_validation_idempotency_and_non_duplicating_points(): void
    {
        $user = User::factory()->create();
        $simulation = Simulation::with('steps.choices')->where('category', 'Tsunami')->firstOrFail();
        $otherSim = Simulation::with('steps.choices')->where('id', '!=', $simulation->id)->firstOrFail();

        // Save in-progress simulation draft
        $firstStep = $simulation->steps->first();
        $firstChoice = $firstStep->choices->first();
        $this->actingAs($user)->postJson(route('api.edukasi.simulasi.progress', $simulation), [
            'current_step_index' => 0,
            'selected_choices' => [$firstStep->id => $firstChoice->id],
        ])->assertOk();

        $this->actingAs($user)->getJson(route('api.edukasi.simulasi.show', $simulation->slug))
            ->assertOk()
            ->assertJsonPath('data.draft.current_step_index', 0);

        // Forged choice from another simulation must be rejected with 422
        $foreignChoiceId = $otherSim->steps->first()->choices->first()->id;
        $this->actingAs($user)->postJson(route('api.edukasi.simulasi.submit', $simulation), [
            'choices' => [$firstStep->id => $foreignChoiceId],
        ])->assertUnprocessable();

        // Valid submission with client_submission_id
        $validChoices = [];
        foreach ($simulation->steps as $step) {
            $validChoices[$step->id] = $step->choices->firstWhere('is_correct', true)->id;
        }

        $submit1 = $this->actingAs($user)->postJson(route('api.edukasi.simulasi.submit', $simulation), [
            'choices' => $validChoices,
            'client_submission_id' => 'sim-attempt-uuid-001',
            'score' => 99999, // Forged client score must be ignored
        ]);
        $submit1->assertCreated()
            ->assertJsonPath('result.score', 100)
            ->assertJsonPath('progress.total_points', 100);

        // Retry same client_submission_id is idempotent (no duplicate row, no duplicate points)
        $retry = $this->actingAs($user)->postJson(route('api.edukasi.simulasi.submit', $simulation), [
            'choices' => $validChoices,
            'client_submission_id' => 'sim-attempt-uuid-001',
        ]);
        $retry->assertOk()
            ->assertJsonPath('idempotent_replay', true)
            ->assertJsonPath('progress.total_points', 100);

        $this->assertSame(1, SimulationResult::where('user_id', $user->id)->where('simulation_id', $simulation->id)->count());

        // Playing again (new submission ID) records new history row but does NOT double points
        $replay = $this->actingAs($user)->postJson(route('api.edukasi.simulasi.submit', $simulation), [
            'choices' => $validChoices,
            'client_submission_id' => 'sim-attempt-uuid-002',
        ]);
        $replay->assertCreated()
            ->assertJsonPath('progress.total_points', 100);

        $this->assertSame(2, SimulationResult::where('user_id', $user->id)->where('simulation_id', $simulation->id)->count());
    }

    public function test_quiz_hides_answers_keeps_all_attempt_history_and_computes_best_and_latest_scores_on_backend(): void
    {
        $user = User::factory()->create();
        $quiz = Quiz::with('questions.options')->where('category', 'Gempa Bumi')->firstOrFail();

        // Before submit: no is_correct or explanation exposed
        $showResponse = $this->actingAs($user)->getJson(route('api.edukasi.kuis.show', $quiz->slug));
        $showResponse->assertOk();
        $firstQuestion = $showResponse->json('data.questions.0');
        $this->assertArrayNotHasKey('explanation', $firstQuestion);
        $this->assertArrayNotHasKey('is_correct', $firstQuestion['options'][0]);

        // Attempt 1: all correct -> 100
        $perfectAnswers = [];
        $wrongAnswers = [];
        foreach ($quiz->questions as $question) {
            $perfectAnswers[$question->id] = $question->options->firstWhere('is_correct', true)->id;
            $wrongAnswers[$question->id] = $question->options->firstWhere('is_correct', false)->id;
        }

        $attempt1 = $this->actingAs($user)->postJson(route('api.edukasi.kuis.submit', $quiz), [
            'answers' => $perfectAnswers,
            'client_submission_id' => 'quiz-run-1',
        ]);
        $attempt1->assertCreated()
            ->assertJsonPath('result.final_score', 100)
            ->assertJsonPath('result.best_score', 100)
            ->assertJsonPath('result.latest_score', 100)
            ->assertJsonPath('result.attempts_count', 1);

        // Attempt 2: all wrong -> 0, but best_score remains 100 and latest_score is 0, both attempts preserved!
        $attempt2 = $this->actingAs($user)->postJson(route('api.edukasi.kuis.submit', $quiz), [
            'answers' => $wrongAnswers,
            'client_submission_id' => 'quiz-run-2',
            'final_score' => 100, // Client forged score must be ignored
        ]);
        $attempt2->assertCreated()
            ->assertJsonPath('result.final_score', 0)
            ->assertJsonPath('result.best_score', 100)
            ->assertJsonPath('result.latest_score', 0)
            ->assertJsonPath('result.attempts_count', 2);

        $this->assertSame(2, QuizResult::where('user_id', $user->id)->where('quiz_id', $quiz->id)->count());
    }

    public function test_account_isolation_logout_persistence_and_cross_account_rejection(): void
    {
        $userA = User::factory()->create(['password' => 'PasswordA123!']);
        $userB = User::factory()->create(['password' => 'PasswordB123!']);
        $materials = LearningMaterial::where('status', LearningMaterial::STATUS_PUBLISHED)->limit(2)->get();

        // User A completes 2 materials -> 50 points
        foreach ($materials as $m) {
            $this->actingAs($userA)
                ->postJson(route('api.edukasi.materi.complete', $m), ['is_completed' => true])
                ->assertOk();
        }

        $this->actingAs($userA)->getJson(route('api.edukasi.progres'))
            ->assertOk()
            ->assertJsonPath('data.materials.completed', 2)
            ->assertJsonPath('data.total_points', 50);

        // Logout User A -> access blocked, progress NOT deleted
        $this->actingAs($userA)->postJson(route('api.auth.logout'))->assertOk();
        $this->getJson(route('api.edukasi.progres'))->assertUnauthorized();

        // Login as User B -> sees ONLY 0 progress, NOT User A's progress
        $this->actingAs($userB)->getJson(route('api.edukasi.progres'))
            ->assertOk()
            ->assertJsonPath('data.materials.completed', 0)
            ->assertJsonPath('data.total_points', 0);

        // User B tries to manipulate user_id parameter to read/modify User A's data -> HTTP 403 Forbidden!
        $this->actingAs($userB)
            ->getJson(route('api.edukasi.progres', ['user_id' => $userA->id]))
            ->assertForbidden();

        $this->actingAs($userB)
            ->postJson(route('api.edukasi.materi.complete', $materials->first()), [
                'user_id' => $userA->id,
                'is_completed' => false,
            ])
            ->assertForbidden();

        // Log back in as User A -> previous progress is completely intact!
        $this->actingAs($userA)->getJson(route('api.edukasi.progres'))
            ->assertOk()
            ->assertJsonPath('data.materials.completed', 2)
            ->assertJsonPath('data.total_points', 50);
    }

    public function test_missions_badges_and_reminder_preferences_skip_completed_items(): void
    {
        $user = User::factory()->create();
        $missions = Mission::where('status', Mission::STATUS_PUBLISHED)->limit(4)->get();

        // Start 1st mission -> shows up in pending reminders
        $this->actingAs($user)
            ->postJson(route('api.edukasi.misi.progress', $missions[0]))
            ->assertOk()
            ->assertJsonPath('data.user_status', UserMission::STATUS_IN_PROGRESS);

        // Enable reminder preference
        $this->actingAs($user)->putJson(route('api.edukasi.pengingat.update'), [
            'is_enabled' => true,
            'reminder_time' => '19:30',
            'frequency' => 'daily',
            'remind_unfinished_materials' => true,
            'remind_pending_missions' => true,
            'remind_inactive_learning' => true,
        ])->assertOk()
            ->assertJsonPath('data.is_enabled', true)
            ->assertJsonPath('data.reminder_time', '19:30');

        $remBefore = $this->actingAs($user)->getJson(route('api.edukasi.pengingat.show'))->assertOk();
        $pendingBefore = collect($remBefore->json('pending_reminders'));
        $this->assertTrue($pendingBefore->contains(fn ($r) => $r['target_slug'] === $missions[0]->slug));

        // Complete 3 missions -> mission[0] leaves pending reminders & Keluarga Siaga badge is earned
        foreach ($missions->take(3) as $m) {
            $this->actingAs($user)->postJson(route('api.edukasi.misi.complete', $m))->assertOk();
        }

        $remAfter = $this->actingAs($user)->getJson(route('api.edukasi.pengingat.show'))->assertOk();
        $pendingAfter = collect($remAfter->json('pending_reminders'));
        $this->assertFalse($pendingAfter->contains(fn ($r) => $r['target_slug'] === $missions[0]->slug));

        $badgesRes = $this->actingAs($user)->getJson(route('api.edukasi.badge'))->assertOk();
        $keluargaSiaga = collect($badgesRes->json('data.items'))->firstWhere('code', 'keluarga-siaga');
        $this->assertTrue($keluargaSiaga['is_earned']);

        // Run reminder dispatch artisan command
        $this->artisan('edukasi:dispatch-reminders')->assertSuccessful();
    }

    public function test_admin_analytics_soft_delete_preserves_history_and_backup_restore_commands_work(): void
    {
        $regularUser = User::factory()->create(['role' => User::ROLE_PUBLIC]);
        $staffUser = User::factory()->reportStaff()->create();

        // Regular user cannot access admin analytics or web admin dashboard
        $this->actingAs($regularUser)->getJson(route('api.admin.edukasi.analytics'))->assertForbidden();
        $this->actingAs($regularUser)->get(route('petugas.edukasi.index'))->assertForbidden();

        // Regular user completes a material before admin edits & soft-deletes it
        $material = LearningMaterial::where('status', LearningMaterial::STATUS_PUBLISHED)->firstOrFail();
        $this->actingAs($regularUser)
            ->postJson(route('api.edukasi.materi.complete', $material), ['is_completed' => true])
            ->assertOk();

        // Admin views analytics dashboard (API + Web)
        $analytics = $this->actingAs($staffUser)->getJson(route('api.admin.edukasi.analytics'));
        $analytics->assertOk()
            ->assertJsonPath('data.summary.total_education_users', 1)
            ->assertJsonPath('data.summary.total_material_completions', 1)
            ->assertJsonStructure([
                'data' => [
                    'summary',
                    'quiz_score_distribution',
                    'popular_materials',
                    'least_studied_materials',
                    'abandoned_materials',
                    'popular_simulations',
                    'activity_timeline_14d',
                    'users',
                ],
            ]);

        $this->actingAs($staffUser)->get(route('petugas.edukasi.index'))
            ->assertOk()
            ->assertSee('Dashboard Analitik Edukasi Bencana');

        // Admin deletes (soft-deletes) the material -> user's learning history MUST remain preserved!
        $this->actingAs($staffUser)
            ->deleteJson(route('api.admin.edukasi.materi.destroy', $material))
            ->assertOk();

        $this->assertSoftDeleted('learning_materials', ['id' => $material->id]);
        $this->assertDatabaseHas('learning_progress', [
            'user_id' => $regularUser->id,
            'learning_material_id' => $material->id,
            'is_completed' => true,
        ]);

        // Test Backup & Restore commands
        $tmpBackupDir = storage_path('framework/testing/edu_backups_'.uniqid());
        Artisan::call('edukasi:backup', ['--path' => $tmpBackupDir]);
        $files = File::files($tmpBackupDir);
        $this->assertCount(1, $files);

        $backupFile = $files[0]->getPathname();
        $this->artisan('edukasi:restore', ['file' => $backupFile, '--force' => true])
            ->assertSuccessful();

        File::deleteDirectory($tmpBackupDir);
    }
}
