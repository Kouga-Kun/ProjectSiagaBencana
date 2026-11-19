<?php

namespace App\Http\Controllers;

use App\Models\LearningActivityLog;
use App\Models\LearningCategory;
use App\Models\LearningMaterial;
use App\Models\LearningProgress;
use App\Models\LearningReminderPreference;
use App\Models\Mission;
use App\Models\Quiz;
use App\Models\QuizOption;
use App\Models\QuizQuestion;
use App\Models\QuizResult;
use App\Models\Simulation;
use App\Models\SimulationChoice;
use App\Models\SimulationDraft;
use App\Models\SimulationResult;
use App\Models\SimulationStep;
use App\Models\UserMission;
use App\Services\EducationProgressService;
use Database\Seeders\DisasterEducationSeeder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;
use Symfony\Component\HttpFoundation\Response;

class DisasterEducationApiController extends Controller
{
    public function __construct(public EducationProgressService $progressService) {}

    public function summaryJson(Request $request): JsonResponse
    {
        DisasterEducationSeeder::ensureSeeded();

        $user = $request->user();
        $progress = $this->progressService->buildUserProgress($user);
        $userProgressMap = LearningProgress::query()
            ->where('user_id', $user->id)
            ->get()
            ->keyBy('learning_material_id');

        $categories = LearningCategory::query()
            ->orderBy('sort_order')
            ->get()
            ->map(function (LearningCategory $cat) {
                $materialsCount = LearningMaterial::query()
                    ->where('category', $cat->name)
                    ->where('status', LearningMaterial::STATUS_PUBLISHED)
                    ->count();
                $simulationsCount = Simulation::query()
                    ->where('category', $cat->name)
                    ->where('status', Simulation::STATUS_PUBLISHED)
                    ->count();
                $quizzesCount = Quiz::query()
                    ->where('category', $cat->name)
                    ->where('status', Quiz::STATUS_PUBLISHED)
                    ->count();
                $missionsCount = Mission::query()
                    ->where('category', $cat->name)
                    ->where('status', Mission::STATUS_PUBLISHED)
                    ->count();

                return [
                    'id' => $cat->id,
                    'name' => $cat->name,
                    'slug' => $cat->slug,
                    'description' => $cat->description,
                    'icon' => $cat->icon,
                    'materials_count' => $materialsCount,
                    'simulations_count' => $simulationsCount,
                    'quizzes_count' => $quizzesCount,
                    'missions_count' => $missionsCount,
                ];
            })
            ->values();

        // Recommend next unfinished materials first
        $completedIds = $progress['materials']['completed_ids'] ?? [];
        $recommendedMaterials = LearningMaterial::query()
            ->where('status', LearningMaterial::STATUS_PUBLISHED)
            ->orderByRaw('CASE WHEN id IN ('.(count($completedIds) > 0 ? implode(',', array_map('intval', $completedIds)) : '0').') THEN 1 ELSE 0 END ASC')
            ->orderBy('sort_order')
            ->limit(6)
            ->get()
            ->map(fn (LearningMaterial $item) => self::serializeMaterial($item, $userProgressMap->get($item->id)))
            ->values();

        return response()->json([
            'title' => 'Edukasi Gempa Bumi dan Tsunami',
            'subtitle' => 'Kenali Risikonya, Lindungi Dirimu, Selamatkan Sesama.',
            'categories' => $categories,
            'recommended_materials' => $recommendedMaterials,
            'progress' => $progress,
        ]);
    }

    public function materialsIndexJson(Request $request): JsonResponse
    {
        DisasterEducationSeeder::ensureSeeded();

        $filters = $request->validate([
            'search' => ['nullable', 'string', 'max:200'],
            'category' => ['nullable', Rule::in(LearningMaterial::CATEGORIES)],
            'difficulty' => ['nullable', Rule::in(LearningMaterial::DIFFICULTIES)],
            'favorites_only' => ['nullable', 'boolean'],
        ]);

        $user = $request->user();
        $userProgressMap = LearningProgress::query()
            ->where('user_id', $user->id)
            ->get()
            ->keyBy('learning_material_id');

        $query = LearningMaterial::query()
            ->where('status', LearningMaterial::STATUS_PUBLISHED);

        if (! empty($filters['search'])) {
            $keyword = trim((string) $filters['search']);
            if ($keyword !== '') {
                $query->where(function ($q) use ($keyword) {
                    $q->where('title', 'like', '%'.$keyword.'%')
                        ->orWhere('summary', 'like', '%'.$keyword.'%')
                        ->orWhere('content', 'like', '%'.$keyword.'%');
                });
            }
        }

        if (! empty($filters['category'])) {
            $query->where('category', $filters['category']);
        }

        if (! empty($filters['difficulty'])) {
            $query->where('difficulty', $filters['difficulty']);
        }

        if (! empty($filters['favorites_only'])) {
            $favoriteIds = $userProgressMap
                ->filter(fn (LearningProgress $p) => $p->is_favorite)
                ->keys()
                ->all();
            $query->whereIn('id', $favoriteIds ?: [0]);
        }

        $materials = $query
            ->orderBy('category')
            ->orderBy('sort_order')
            ->orderBy('id')
            ->get()
            ->map(fn (LearningMaterial $item) => self::serializeMaterial($item, $userProgressMap->get($item->id)))
            ->values();

        return response()->json([
            'data' => $materials,
            'categories' => LearningMaterial::CATEGORIES,
            'difficulties' => LearningMaterial::DIFFICULTIES,
            'progress' => $this->progressService->buildUserProgress($user)['materials'],
        ]);
    }

    public function materialShowJson(Request $request, string $slug): JsonResponse
    {
        DisasterEducationSeeder::ensureSeeded();

        $material = LearningMaterial::query()
            ->where('status', LearningMaterial::STATUS_PUBLISHED)
            ->where(function ($query) use ($slug) {
                $query->where('slug', $slug);
                if (ctype_digit($slug)) {
                    $query->orWhere('id', (int) $slug);
                }
            })
            ->first();

        if (! $material) {
            return response()->json([
                'message' => 'Materi edukasi tidak ditemukan atau belum dipublikasikan.',
            ], 404);
        }

        $user = $request->user();
        $progressRecord = LearningProgress::query()
            ->where('user_id', $user->id)
            ->where('learning_material_id', $material->id)
            ->first();

        $siblings = LearningMaterial::query()
            ->where('status', LearningMaterial::STATUS_PUBLISHED)
            ->where('category', $material->category)
            ->orderBy('sort_order')
            ->orderBy('id')
            ->get(['id', 'title', 'slug', 'category', 'difficulty']);

        $currentIndex = $siblings->search(fn (LearningMaterial $m) => $m->id === $material->id);
        $prev = ($currentIndex !== false && $currentIndex > 0) ? $siblings->get($currentIndex - 1) : null;
        $next = ($currentIndex !== false && $currentIndex < $siblings->count() - 1) ? $siblings->get($currentIndex + 1) : null;

        return response()->json([
            'data' => array_merge(
                self::serializeMaterial($material, $progressRecord),
                [
                    'previous_material' => $prev ? [
                        'id' => $prev->id,
                        'title' => $prev->title,
                        'slug' => $prev->slug,
                        'category' => $prev->category,
                    ] : null,
                    'next_material' => $next ? [
                        'id' => $next->id,
                        'title' => $next->title,
                        'slug' => $next->slug,
                        'category' => $next->category,
                    ] : null,
                ]
            ),
        ]);
    }

    public function materialImage(Request $request, LearningMaterial $learningMaterial): Response
    {
        $user = $request->user();
        $isStaff = $user !== null && method_exists($user, 'isReportStaff') && $user->isReportStaff();

        if (! $learningMaterial->isPublished() && ! $isStaff) {
            abort(404, 'Gambar materi tidak ditemukan.');
        }

        $path = $learningMaterial->image_path;
        if (! is_string($path) || trim($path) === '') {
            abort(404, 'Gambar materi tidak ditemukan.');
        }

        $trimmed = trim($path);
        if (str_starts_with(strtolower($trimmed), 'http://') || str_starts_with(strtolower($trimmed), 'https://')) {
            return redirect()->away($trimmed);
        }

        if (! Storage::disk('public')->exists($trimmed)) {
            abort(404, 'Gambar materi tidak ditemukan.');
        }

        return Storage::disk('public')->response($trimmed, null, [
            'Cache-Control' => 'public, max-age=86400',
        ]);
    }

    public function saveMaterialProgressJson(Request $request, LearningMaterial $learningMaterial): JsonResponse
    {
        if (! $learningMaterial->isPublished()) {
            return response()->json([
                'message' => 'Materi ini belum dipublikasikan.',
            ], 404);
        }

        $validated = $request->validate([
            'last_position' => ['nullable', 'integer', 'min:0', 'max:100'],
            'last_section' => ['nullable', 'string', 'max:100'],
            'progress_percent' => ['nullable', 'integer', 'min:0', 'max:100'],
            'is_favorite' => ['nullable', 'boolean'],
        ]);

        $user = $request->user();

        $progressRecord = DB::transaction(function () use ($user, $learningMaterial, $validated): LearningProgress {
            $existing = LearningProgress::query()
                ->where('user_id', $user->id)
                ->where('learning_material_id', $learningMaterial->id)
                ->first();

            $wasNew = $existing === null;
            $isCompleted = (bool) ($existing?->is_completed ?? false);
            $incomingPos = array_key_exists('last_position', $validated) ? (int) $validated['last_position'] : ($existing?->last_position ?? 0);
            $incomingPct = array_key_exists('progress_percent', $validated)
                ? (int) $validated['progress_percent']
                : max($incomingPos, (int) ($existing?->progress_percent ?? 0));

            if ($isCompleted) {
                $incomingPct = 100;
            } else {
                $incomingPct = max($incomingPct, (int) ($existing?->progress_percent ?? 0));
            }

            $record = LearningProgress::query()->updateOrCreate(
                [
                    'user_id' => $user->id,
                    'learning_material_id' => $learningMaterial->id,
                ],
                [
                    'is_completed' => $isCompleted,
                    'last_position' => $incomingPos,
                    'last_section' => array_key_exists('last_section', $validated)
                        ? ($validated['last_section'] !== null ? trim((string) $validated['last_section']) : null)
                        : $existing?->last_section,
                    'progress_percent' => min(100, max(0, $incomingPct)),
                    'is_favorite' => array_key_exists('is_favorite', $validated)
                        ? (bool) $validated['is_favorite']
                        : (bool) ($existing?->is_favorite ?? false),
                    'last_read_at' => now(),
                ]
            );

            if ($wasNew && $incomingPct > 0) {
                $this->progressService->logActivity(
                    user: $user,
                    activityType: LearningActivityLog::TYPE_MATERIAL_READ,
                    subjectType: 'learning_material',
                    subjectId: $learningMaterial->id,
                    subjectTitle: $learningMaterial->title,
                    category: $learningMaterial->category,
                    pointsEarned: 0,
                    metadata: [
                        'progress_percent' => $record->progress_percent,
                        'last_section' => $record->last_section,
                    ],
                );
            }

            return $record;
        });

        return response()->json([
            'message' => 'Progres membaca berhasil disimpan otomatis.',
            'saved_at' => $progressRecord->last_read_at?->toIso8601String(),
            'data' => [
                'material_id' => $learningMaterial->id,
                'is_completed' => (bool) $progressRecord->is_completed,
                'is_favorite' => (bool) $progressRecord->is_favorite,
                'last_position' => (int) $progressRecord->last_position,
                'last_section' => $progressRecord->last_section,
                'progress_percent' => (int) $progressRecord->progress_percent,
                'last_read_at' => $progressRecord->last_read_at?->toIso8601String(),
            ],
        ]);
    }

    public function completeMaterialJson(Request $request, LearningMaterial $learningMaterial): JsonResponse
    {
        if (! $learningMaterial->isPublished()) {
            return response()->json([
                'message' => 'Materi ini belum dipublikasikan.',
            ], 404);
        }

        $validated = $request->validate([
            'is_completed' => ['nullable', 'boolean'],
        ]);

        $user = $request->user();
        $targetCompleted = array_key_exists('is_completed', $validated)
            ? (bool) $validated['is_completed']
            : true;

        $result = DB::transaction(function () use ($user, $learningMaterial, $targetCompleted): array {
            $existing = LearningProgress::query()
                ->where('user_id', $user->id)
                ->where('learning_material_id', $learningMaterial->id)
                ->first();

            $wasAlreadyCompleted = (bool) ($existing?->is_completed ?? false);

            $progressRecord = LearningProgress::query()->updateOrCreate(
                [
                    'user_id' => $user->id,
                    'learning_material_id' => $learningMaterial->id,
                ],
                [
                    'is_completed' => $targetCompleted,
                    'last_position' => $targetCompleted ? 100 : (int) ($existing?->last_position ?? 0),
                    'progress_percent' => $targetCompleted ? 100 : min(95, (int) ($existing?->progress_percent ?? 0)),
                    'is_favorite' => (bool) ($existing?->is_favorite ?? false),
                    'last_read_at' => now(),
                    'completed_at' => $targetCompleted ? ($existing?->completed_at ?? now()) : null,
                ]
            );

            if ($targetCompleted && ! $wasAlreadyCompleted) {
                $this->progressService->logActivity(
                    user: $user,
                    activityType: LearningActivityLog::TYPE_MATERIAL_COMPLETED,
                    subjectType: 'learning_material',
                    subjectId: $learningMaterial->id,
                    subjectTitle: $learningMaterial->title,
                    category: $learningMaterial->category,
                    pointsEarned: EducationProgressService::MATERIAL_COMPLETION_POINTS,
                    metadata: ['difficulty' => $learningMaterial->difficulty],
                );
            }

            $newBadges = $this->progressService->evaluateAndAwardBadges($user);

            return [
                'record' => $progressRecord,
                'newly_awarded_badges' => $newBadges,
            ];
        });

        /** @var LearningProgress $progressRecord */
        $progressRecord = $result['record'];
        $updatedProgress = $this->progressService->buildUserProgress($user);

        return response()->json([
            'message' => $progressRecord->is_completed
                ? 'Materi "'.$learningMaterial->title.'" berhasil ditandai selesai!'
                : 'Penanda selesai pada materi telah dibatalkan.',
            'is_completed' => (bool) $progressRecord->is_completed,
            'newly_awarded_badges' => $result['newly_awarded_badges'],
            'progress' => $updatedProgress,
        ]);
    }

    public function simulationsIndexJson(Request $request): JsonResponse
    {
        DisasterEducationSeeder::ensureSeeded();

        $filters = $request->validate([
            'category' => ['nullable', Rule::in(LearningMaterial::CATEGORIES)],
            'difficulty' => ['nullable', Rule::in(LearningMaterial::DIFFICULTIES)],
        ]);

        $user = $request->user();
        $userResultsGrouped = SimulationResult::query()
            ->where('user_id', $user->id)
            ->orderByDesc('completed_at')
            ->orderByDesc('id')
            ->get()
            ->groupBy('simulation_id');

        $draftsMap = SimulationDraft::query()
            ->where('user_id', $user->id)
            ->get()
            ->keyBy('simulation_id');

        $query = Simulation::query()
            ->with(['steps.choices'])
            ->where('status', Simulation::STATUS_PUBLISHED);

        if (! empty($filters['category'])) {
            $query->where('category', $filters['category']);
        }

        if (! empty($filters['difficulty'])) {
            $query->where('difficulty', $filters['difficulty']);
        }

        $simulations = $query
            ->orderBy('sort_order')
            ->orderBy('id')
            ->get()
            ->map(function (Simulation $sim) use ($userResultsGrouped, $draftsMap) {
                $group = $userResultsGrouped->get($sim->id);
                $bestScore = $group !== null ? (int) $group->max('score') : null;
                $latestScore = $group !== null ? (int) $group->first()->score : null;
                $attemptsCount = $group !== null ? $group->count() : 0;

                return self::serializeSimulation(
                    $sim,
                    $attemptsCount > 0,
                    $bestScore,
                    $latestScore,
                    $attemptsCount,
                    $draftsMap->get($sim->id),
                );
            })
            ->values();

        return response()->json([
            'data' => $simulations,
            'history' => $this->progressService->buildUserProgress($user)['simulations']['history'],
        ]);
    }

    public function simulationShowJson(Request $request, string $slug): JsonResponse
    {
        DisasterEducationSeeder::ensureSeeded();

        $simulation = Simulation::query()
            ->with(['steps.choices'])
            ->where('status', Simulation::STATUS_PUBLISHED)
            ->where(function ($query) use ($slug) {
                $query->where('slug', $slug);
                if (ctype_digit($slug)) {
                    $query->orWhere('id', (int) $slug);
                }
            })
            ->first();

        if (! $simulation) {
            return response()->json([
                'message' => 'Simulasi tidak ditemukan atau belum dipublikasikan.',
            ], 404);
        }

        $user = $request->user();
        $results = SimulationResult::query()
            ->where('user_id', $user->id)
            ->where('simulation_id', $simulation->id)
            ->orderByDesc('completed_at')
            ->orderByDesc('id')
            ->get();

        $draft = SimulationDraft::query()
            ->where('user_id', $user->id)
            ->where('simulation_id', $simulation->id)
            ->first();

        return response()->json([
            'data' => self::serializeSimulation(
                $simulation,
                $results->isNotEmpty(),
                $results->isNotEmpty() ? (int) $results->max('score') : null,
                $results->isNotEmpty() ? (int) $results->first()->score : null,
                $results->count(),
                $draft,
            ),
        ]);
    }

    public function saveSimulationProgressJson(Request $request, Simulation $simulation): JsonResponse
    {
        if (! $simulation->isPublished()) {
            return response()->json([
                'message' => 'Simulasi ini belum dipublikasikan.',
            ], 404);
        }

        $validated = $request->validate([
            'current_step_index' => ['required', 'integer', 'min:0'],
            'selected_choices' => ['nullable', 'array'],
            'selected_choices.*' => ['integer'],
        ]);

        $simulation->load(['steps.choices']);
        $maxStepIndex = max(0, $simulation->steps->count() - 1);
        $validChoiceIds = $simulation->steps->flatMap(fn (SimulationStep $s) => $s->choices->pluck('id'))->all();

        $cleanChoices = [];
        foreach (($validated['selected_choices'] ?? []) as $stepKey => $choiceId) {
            if (in_array((int) $choiceId, $validChoiceIds, true)) {
                $cleanChoices[(string) $stepKey] = (int) $choiceId;
            }
        }

        $user = $request->user();
        $draft = SimulationDraft::query()->updateOrCreate(
            [
                'user_id' => $user->id,
                'simulation_id' => $simulation->id,
            ],
            [
                'current_step_index' => min($maxStepIndex, (int) $validated['current_step_index']),
                'selected_choices' => $cleanChoices,
            ]
        );

        return response()->json([
            'message' => 'Tahapan simulasi tersimpan otomatis.',
            'draft' => [
                'current_step_index' => $draft->current_step_index,
                'selected_choices' => $draft->selected_choices ?? [],
                'updated_at' => $draft->updated_at?->toIso8601String(),
            ],
        ]);
    }

    public function submitSimulationJson(Request $request, Simulation $simulation): JsonResponse
    {
        if (! $simulation->isPublished()) {
            return response()->json([
                'message' => 'Simulasi ini belum dipublikasikan.',
            ], 404);
        }

        $validated = $request->validate([
            'choices' => ['required', 'array', 'min:1'],
            'choices.*' => ['required', 'integer'],
            'client_submission_id' => ['nullable', 'string', 'max:100'],
        ], [
            'choices.required' => 'Pilih tindakan untuk setiap langkah skenario simulasi.',
        ]);

        $user = $request->user();
        $clientSubmissionId = isset($validated['client_submission_id']) && trim((string) $validated['client_submission_id']) !== ''
            ? trim((string) $validated['client_submission_id'])
            : null;

        // Idempotent replay check: prevents duplicate rows/points when client retries after network glitch
        if ($clientSubmissionId !== null) {
            $existingReplay = SimulationResult::query()
                ->where('user_id', $user->id)
                ->where('client_submission_id', $clientSubmissionId)
                ->first();

            if ($existingReplay !== null) {
                return response()->json([
                    'message' => 'Hasil simulasi sudah tersimpan sebelumnya.',
                    'idempotent_replay' => true,
                    'result' => [
                        'id' => $existingReplay->id,
                        'simulation_id' => $existingReplay->simulation_id,
                        'simulation_title' => $simulation->title,
                        'category' => $simulation->category,
                        'score' => $existingReplay->score,
                        'max_score' => $existingReplay->max_score,
                        'correct_choices' => $existingReplay->correct_choices,
                        'total_steps' => $existingReplay->total_steps,
                        'reviews' => $existingReplay->selected_answers ?? [],
                        'safety_disclaimer' => 'Panduan simulasi ini merupakan sarana edukasi kesiapsiagaan dan bukan pengganti instruksi petugas maupun otoritas resmi di lokasi bencana.',
                        'completed_at' => $existingReplay->completed_at?->toIso8601String(),
                    ],
                    'newly_awarded_badges' => [],
                    'progress' => $this->progressService->buildUserProgress($user),
                ], 200);
            }
        }

        $simulation->load(['steps.choices']);
        $steps = $simulation->steps;

        $totalScore = 0;
        $maxScore = 0;
        $correctCount = 0;
        $stepReviews = [];

        foreach ($steps as $step) {
            $stepMax = (int) $step->choices->max('score');
            $maxScore += max($stepMax, 50);

            $chosenId = $validated['choices'][$step->id] ?? $validated['choices'][(string) $step->id] ?? null;
            if ($chosenId === null && isset($validated['choices'][$step->step_number - 1])) {
                $chosenId = $validated['choices'][$step->step_number - 1];
            }

            /** @var SimulationChoice|null $chosen */
            $chosen = $chosenId !== null ? $step->choices->firstWhere('id', (int) $chosenId) : null;

            // Strict validation: reject forged choice IDs that do not belong to this simulation step
            if ($chosenId !== null && $chosen === null) {
                return response()->json([
                    'message' => 'Pilihan simulasi tidak valid untuk skenario ini.',
                    'errors' => ['choices' => ['Pilihan tindakan tidak sesuai dengan tahapan skenario yang sah.']],
                ], 422);
            }

            /** @var SimulationChoice|null $bestChoice */
            $bestChoice = $step->choices->firstWhere('is_correct', true) ?? $step->choices->sortByDesc('score')->first();

            $isStepCorrect = $chosen !== null && $chosen->is_correct;
            $earned = $chosen !== null ? (int) $chosen->score : 0;

            if ($isStepCorrect) {
                $correctCount++;
            }
            $totalScore += $earned;

            $stepReviews[] = [
                'step_id' => $step->id,
                'step_number' => $step->step_number,
                'situation_title' => $step->situation_title,
                'situation_text' => $step->situation_text,
                'selected_choice_id' => $chosen?->id,
                'selected_choice_label' => $chosen?->label,
                'selected_choice_text' => $chosen?->choice_text,
                'is_correct' => $isStepCorrect,
                'score_earned' => $earned,
                'assessment' => $chosen?->assessment ?? 'Belum Dijawab',
                'feedback' => $chosen?->feedback ?? 'Pilih tindakan yang mengutamakan keselamatan jiwa.',
                'recommended_action' => $step->recommended_action,
                'correct_choice_label' => $bestChoice?->label,
                'correct_choice_text' => $bestChoice?->choice_text,
            ];
        }

        $normalizedScore = $maxScore > 0
            ? (int) round(($totalScore / $maxScore) * 100)
            : 0;

        $tx = DB::transaction(function () use ($user, $simulation, $clientSubmissionId, $normalizedScore, $correctCount, $steps, $stepReviews): array {
            $previousBest = (int) (SimulationResult::query()
                ->where('user_id', $user->id)
                ->where('simulation_id', $simulation->id)
                ->max('score') ?? 0);

            $resultRecord = SimulationResult::create([
                'user_id' => $user->id,
                'simulation_id' => $simulation->id,
                'client_submission_id' => $clientSubmissionId,
                'score' => $normalizedScore,
                'max_score' => 100,
                'correct_choices' => $correctCount,
                'total_steps' => $steps->count(),
                'selected_answers' => $stepReviews,
                'completed_at' => now(),
            ]);

            // Clear unfinished draft once submitted
            SimulationDraft::query()
                ->where('user_id', $user->id)
                ->where('simulation_id', $simulation->id)
                ->delete();

            $deltaPoints = max(0, $normalizedScore - $previousBest);

            $this->progressService->logActivity(
                user: $user,
                activityType: LearningActivityLog::TYPE_SIMULATION_COMPLETED,
                subjectType: 'simulation',
                subjectId: $simulation->id,
                subjectTitle: $simulation->title,
                category: $simulation->category,
                pointsEarned: $deltaPoints,
                metadata: [
                    'score' => $normalizedScore,
                    'correct_choices' => $correctCount,
                    'total_steps' => $steps->count(),
                ],
            );

            $newBadges = $this->progressService->evaluateAndAwardBadges($user);

            return [
                'record' => $resultRecord,
                'newly_awarded_badges' => $newBadges,
            ];
        });

        /** @var SimulationResult $resultRecord */
        $resultRecord = $tx['record'];
        $updatedProgress = $this->progressService->buildUserProgress($user);

        return response()->json([
            'message' => 'Simulasi "'.$simulation->title.'" selesai! Nilai kamu: '.$normalizedScore.'/100.',
            'idempotent_replay' => false,
            'result' => [
                'id' => $resultRecord->id,
                'simulation_id' => $simulation->id,
                'simulation_title' => $simulation->title,
                'category' => $simulation->category,
                'score' => $normalizedScore,
                'max_score' => 100,
                'correct_choices' => $correctCount,
                'total_steps' => $steps->count(),
                'reviews' => $stepReviews,
                'safety_disclaimer' => 'Panduan simulasi ini merupakan sarana edukasi kesiapsiagaan dan bukan pengganti instruksi petugas maupun otoritas resmi di lokasi bencana.',
                'completed_at' => $resultRecord->completed_at?->toIso8601String(),
            ],
            'newly_awarded_badges' => $tx['newly_awarded_badges'],
            'progress' => $updatedProgress,
        ], 201);
    }

    public function quizzesIndexJson(Request $request): JsonResponse
    {
        DisasterEducationSeeder::ensureSeeded();

        $filters = $request->validate([
            'category' => ['nullable', Rule::in(LearningMaterial::CATEGORIES)],
            'difficulty' => ['nullable', Rule::in(LearningMaterial::DIFFICULTIES)],
        ]);

        $user = $request->user();
        $userQuizResultsGrouped = QuizResult::query()
            ->where('user_id', $user->id)
            ->orderByDesc('completed_at')
            ->orderByDesc('id')
            ->get()
            ->groupBy('quiz_id');

        $query = Quiz::query()
            ->withCount('questions')
            ->where('status', Quiz::STATUS_PUBLISHED);

        if (! empty($filters['category'])) {
            $query->where('category', $filters['category']);
        }

        if (! empty($filters['difficulty'])) {
            $query->where('difficulty', $filters['difficulty']);
        }

        $quizzes = $query
            ->orderBy('sort_order')
            ->orderBy('id')
            ->get()
            ->map(function (Quiz $quiz) use ($userQuizResultsGrouped) {
                $group = $userQuizResultsGrouped->get($quiz->id);

                return [
                    'id' => $quiz->id,
                    'category' => $quiz->category,
                    'topic' => $quiz->topic,
                    'title' => $quiz->title,
                    'slug' => $quiz->slug,
                    'difficulty' => $quiz->difficulty,
                    'description' => $quiz->description,
                    'questions_count' => $quiz->questions_count,
                    'is_completed' => $group !== null && $group->isNotEmpty(),
                    'best_score' => $group !== null ? (int) $group->max('final_score') : null,
                    'latest_score' => $group !== null ? (int) $group->first()->final_score : null,
                    'attempts_count' => $group !== null ? $group->count() : 0,
                ];
            })
            ->values();

        return response()->json([
            'data' => $quizzes,
            'history' => $this->progressService->buildUserProgress($user)['quizzes']['history'],
        ]);
    }

    public function quizShowJson(Request $request, string $slug): JsonResponse
    {
        DisasterEducationSeeder::ensureSeeded();

        $quiz = Quiz::query()
            ->with(['questions.options'])
            ->where('status', Quiz::STATUS_PUBLISHED)
            ->where(function ($query) use ($slug) {
                $query->where('slug', $slug);
                if (ctype_digit($slug)) {
                    $query->orWhere('id', (int) $slug);
                }
            })
            ->first();

        if (! $quiz) {
            return response()->json([
                'message' => 'Kuis tidak ditemukan atau belum dipublikasikan.',
            ], 404);
        }

        $user = $request->user();
        $attempts = QuizResult::query()
            ->where('user_id', $user->id)
            ->where('quiz_id', $quiz->id)
            ->orderByDesc('completed_at')
            ->orderByDesc('id')
            ->get();

        // PENTING: Jangan pernah mengekspos is_correct atau explanation sebelum kuis dikirim!
        return response()->json([
            'data' => [
                'id' => $quiz->id,
                'category' => $quiz->category,
                'topic' => $quiz->topic,
                'title' => $quiz->title,
                'slug' => $quiz->slug,
                'difficulty' => $quiz->difficulty,
                'description' => $quiz->description,
                'questions_count' => $quiz->questions->count(),
                'is_completed' => $attempts->isNotEmpty(),
                'best_score' => $attempts->isNotEmpty() ? (int) $attempts->max('final_score') : null,
                'latest_score' => $attempts->isNotEmpty() ? (int) $attempts->first()->final_score : null,
                'attempts_count' => $attempts->count(),
                'questions' => $quiz->questions->map(fn (QuizQuestion $q) => [
                    'id' => $q->id,
                    'question_number' => $q->question_number,
                    'subtopic' => $q->subtopic,
                    'question_text' => $q->question_text,
                    'options' => $q->options->map(fn (QuizOption $opt) => [
                        'id' => $opt->id,
                        'option_label' => $opt->option_label,
                        'option_text' => $opt->option_text,
                    ])->values(),
                ])->values(),
            ],
        ]);
    }

    public function submitQuizJson(Request $request, Quiz $quiz): JsonResponse
    {
        if (! $quiz->isPublished()) {
            return response()->json([
                'message' => 'Kuis ini belum dipublikasikan.',
            ], 404);
        }

        $validated = $request->validate([
            'answers' => ['required', 'array', 'min:1'],
            'answers.*' => ['required', 'integer'],
            'client_submission_id' => ['nullable', 'string', 'max:100'],
        ], [
            'answers.required' => 'Jawab pertanyaan kuis terlebih dahulu sebelum mengirim hasil.',
        ]);

        $user = $request->user();
        $clientSubmissionId = isset($validated['client_submission_id']) && trim((string) $validated['client_submission_id']) !== ''
            ? trim((string) $validated['client_submission_id'])
            : null;

        // Idempotent replay check
        if ($clientSubmissionId !== null) {
            $existingReplay = QuizResult::query()
                ->where('user_id', $user->id)
                ->where('client_submission_id', $clientSubmissionId)
                ->first();

            if ($existingReplay !== null) {
                $attempts = QuizResult::query()
                    ->where('user_id', $user->id)
                    ->where('quiz_id', $quiz->id)
                    ->get();

                return response()->json([
                    'message' => 'Hasil kuis sudah tersimpan sebelumnya.',
                    'idempotent_replay' => true,
                    'result' => [
                        'id' => $existingReplay->id,
                        'quiz_id' => $existingReplay->quiz_id,
                        'quiz_title' => $quiz->title,
                        'category' => $quiz->category,
                        'difficulty' => $quiz->difficulty,
                        'total_questions' => $existingReplay->total_questions,
                        'correct_answers' => $existingReplay->correct_answers,
                        'wrong_answers' => $existingReplay->wrong_answers,
                        'final_score' => $existingReplay->final_score,
                        'percentage' => (float) $existingReplay->percentage,
                        'best_score' => (int) $attempts->max('final_score'),
                        'latest_score' => $existingReplay->final_score,
                        'attempts_count' => $attempts->count(),
                        'reviews' => $existingReplay->answers_detail ?? [],
                        'recommended_materials' => $existingReplay->recommended_materials ?? [],
                        'completed_at' => $existingReplay->completed_at?->toIso8601String(),
                    ],
                    'newly_awarded_badges' => [],
                    'progress' => $this->progressService->buildUserProgress($user),
                ], 200);
            }
        }

        $quiz->load(['questions.options']);
        $questions = $quiz->questions;
        $totalQuestions = $questions->count();
        $correctAnswers = 0;
        $wrongAnswers = 0;
        $reviews = [];
        $recommendedSlugs = [];

        foreach ($questions as $index => $question) {
            $selectedOptionId = $validated['answers'][$question->id]
                ?? $validated['answers'][(string) $question->id]
                ?? ($validated['answers'][$index] ?? null);

            /** @var QuizOption|null $selectedOpt */
            $selectedOpt = $selectedOptionId !== null
                ? $question->options->firstWhere('id', (int) $selectedOptionId)
                : null;

            if ($selectedOptionId !== null && $selectedOpt === null) {
                return response()->json([
                    'message' => 'Pilihan jawaban kuis tidak valid.',
                    'errors' => ['answers' => ['Opsi jawaban tidak cocok dengan pertanyaan pada kuis ini.']],
                ], 422);
            }

            /** @var QuizOption|null $correctOpt */
            $correctOpt = $question->options->firstWhere('is_correct', true);

            $isCorrect = $selectedOpt !== null && $selectedOpt->is_correct;
            if ($isCorrect) {
                $correctAnswers++;
            } else {
                $wrongAnswers++;
                if ($question->recommended_material_slug) {
                    $recommendedSlugs[] = $question->recommended_material_slug;
                }
            }

            $reviews[] = [
                'question_id' => $question->id,
                'question_number' => $question->question_number,
                'subtopic' => $question->subtopic,
                'question_text' => $question->question_text,
                'selected_option_id' => $selectedOpt?->id,
                'selected_option_label' => $selectedOpt?->option_label,
                'selected_option_text' => $selectedOpt?->option_text,
                'correct_option_id' => $correctOpt?->id,
                'correct_option_label' => $correctOpt?->option_label,
                'correct_option_text' => $correctOpt?->option_text,
                'is_correct' => $isCorrect,
                'explanation' => $question->explanation,
                'recommended_material_slug' => $question->recommended_material_slug,
            ];
        }

        $percentage = $totalQuestions > 0
            ? round(($correctAnswers / $totalQuestions) * 100, 2)
            : 0.0;
        $finalScore = (int) round($percentage);

        $recommendedQuery = LearningMaterial::query()
            ->where('status', LearningMaterial::STATUS_PUBLISHED);

        if (! empty($recommendedSlugs)) {
            $recommendedQuery->whereIn('slug', array_unique($recommendedSlugs));
        } else {
            $recommendedQuery->where('category', $quiz->category)->limit(3);
        }

        $recommendedMaterials = $recommendedQuery
            ->get(['id', 'title', 'slug', 'category', 'difficulty', 'summary'])
            ->map(fn (LearningMaterial $m) => [
                'id' => $m->id,
                'title' => $m->title,
                'slug' => $m->slug,
                'category' => $m->category,
                'difficulty' => $m->difficulty,
                'summary' => $m->summary,
            ])
            ->values()
            ->all();

        $tx = DB::transaction(function () use (
            $user,
            $quiz,
            $clientSubmissionId,
            $totalQuestions,
            $correctAnswers,
            $wrongAnswers,
            $finalScore,
            $percentage,
            $reviews,
            $recommendedMaterials
        ): array {
            $previousBest = (int) (QuizResult::query()
                ->where('user_id', $user->id)
                ->where('quiz_id', $quiz->id)
                ->max('final_score') ?? 0);

            // Always create a NEW attempt record — never overwrite historical quiz attempts!
            $resultRecord = QuizResult::create([
                'user_id' => $user->id,
                'quiz_id' => $quiz->id,
                'client_submission_id' => $clientSubmissionId,
                'total_questions' => $totalQuestions,
                'correct_answers' => $correctAnswers,
                'wrong_answers' => $wrongAnswers,
                'final_score' => $finalScore,
                'percentage' => $percentage,
                'answers_detail' => $reviews,
                'recommended_materials' => $recommendedMaterials,
                'completed_at' => now(),
            ]);

            $deltaPoints = max(0, $finalScore - $previousBest);

            $this->progressService->logActivity(
                user: $user,
                activityType: LearningActivityLog::TYPE_QUIZ_COMPLETED,
                subjectType: 'quiz',
                subjectId: $quiz->id,
                subjectTitle: $quiz->title,
                category: $quiz->category,
                pointsEarned: $deltaPoints,
                metadata: [
                    'final_score' => $finalScore,
                    'percentage' => $percentage,
                    'correct_answers' => $correctAnswers,
                    'total_questions' => $totalQuestions,
                ],
            );

            $newBadges = $this->progressService->evaluateAndAwardBadges($user);

            $attempts = QuizResult::query()
                ->where('user_id', $user->id)
                ->where('quiz_id', $quiz->id)
                ->get();

            return [
                'record' => $resultRecord,
                'best_score' => (int) $attempts->max('final_score'),
                'attempts_count' => $attempts->count(),
                'newly_awarded_badges' => $newBadges,
            ];
        });

        /** @var QuizResult $resultRecord */
        $resultRecord = $tx['record'];
        $updatedProgress = $this->progressService->buildUserProgress($user);

        return response()->json([
            'message' => 'Kuis "'.$quiz->title.'" selesai dinilai! Nilai akhir: '.$finalScore.' ('.$percentage.'%).',
            'idempotent_replay' => false,
            'result' => [
                'id' => $resultRecord->id,
                'quiz_id' => $quiz->id,
                'quiz_title' => $quiz->title,
                'category' => $quiz->category,
                'difficulty' => $quiz->difficulty,
                'total_questions' => $totalQuestions,
                'correct_answers' => $correctAnswers,
                'wrong_answers' => $wrongAnswers,
                'final_score' => $finalScore,
                'percentage' => $percentage,
                'best_score' => $tx['best_score'],
                'latest_score' => $finalScore,
                'attempts_count' => $tx['attempts_count'],
                'reviews' => $reviews,
                'recommended_materials' => $recommendedMaterials,
                'completed_at' => $resultRecord->completed_at?->toIso8601String(),
            ],
            'newly_awarded_badges' => $tx['newly_awarded_badges'],
            'progress' => $updatedProgress,
        ], 201);
    }

    public function missionsIndexJson(Request $request): JsonResponse
    {
        DisasterEducationSeeder::ensureSeeded();

        $filters = $request->validate([
            'category' => ['nullable', Rule::in(LearningMaterial::CATEGORIES)],
            'difficulty' => ['nullable', Rule::in(LearningMaterial::DIFFICULTIES)],
        ]);

        $user = $request->user();
        $userMissionMap = UserMission::query()
            ->where('user_id', $user->id)
            ->get()
            ->keyBy('mission_id');

        $query = Mission::query()
            ->where('status', Mission::STATUS_PUBLISHED);

        if (! empty($filters['category'])) {
            $query->where('category', $filters['category']);
        }

        if (! empty($filters['difficulty'])) {
            $query->where('difficulty', $filters['difficulty']);
        }

        $missions = $query
            ->orderBy('sort_order')
            ->orderBy('id')
            ->get()
            ->map(function (Mission $mission) use ($userMissionMap) {
                /** @var UserMission|null $um */
                $um = $userMissionMap->get($mission->id);
                $userStatus = $um?->status ?? UserMission::STATUS_NOT_STARTED;

                return self::serializeMission(
                    $mission,
                    $userStatus,
                    $um?->notes,
                    $um?->completed_at?->toIso8601String(),
                    $um?->started_at?->toIso8601String(),
                );
            })
            ->values();

        return response()->json([
            'data' => $missions,
            'progress' => $this->progressService->buildUserProgress($user)['missions'],
        ]);
    }

    public function startMissionJson(Request $request, Mission $mission): JsonResponse
    {
        $request->merge(['status' => UserMission::STATUS_IN_PROGRESS]);

        return $this->updateMissionStatusJson($request, $mission);
    }

    public function completeMissionJson(Request $request, Mission $mission): JsonResponse
    {
        $request->merge(['status' => UserMission::STATUS_COMPLETED]);

        return $this->updateMissionStatusJson($request, $mission);
    }

    public function updateMissionStatusJson(Request $request, Mission $mission): JsonResponse
    {
        if (! $mission->isPublished()) {
            return response()->json([
                'message' => 'Misi ini belum dipublikasikan.',
            ], 404);
        }

        $validated = $request->validate([
            'status' => ['required', Rule::in(UserMission::STATUSES)],
            'notes' => ['nullable', 'string', 'max:500'],
        ], [
            'status.required' => 'Status penyelesaian misi wajib dipilih.',
            'status.in' => 'Status misi harus salah satu dari: belum_dimulai, sedang_dikerjakan, atau selesai.',
        ]);

        $user = $request->user();
        $status = (string) $validated['status'];

        $tx = DB::transaction(function () use ($user, $mission, $status, $validated): array {
            $existing = UserMission::query()
                ->where('user_id', $user->id)
                ->where('mission_id', $mission->id)
                ->first();

            $previousStatus = $existing?->status ?? UserMission::STATUS_NOT_STARTED;

            $startedAt = $existing?->started_at;
            if ($status !== UserMission::STATUS_NOT_STARTED && $startedAt === null) {
                $startedAt = now();
            }

            $completedAt = $status === UserMission::STATUS_COMPLETED
                ? ($existing?->completed_at ?? now())
                : null;

            $userMission = UserMission::query()->updateOrCreate(
                [
                    'user_id' => $user->id,
                    'mission_id' => $mission->id,
                ],
                [
                    'status' => $status,
                    'notes' => isset($validated['notes']) ? trim((string) $validated['notes']) : $existing?->notes,
                    'started_at' => $startedAt,
                    'completed_at' => $completedAt,
                ]
            );

            if ($status === UserMission::STATUS_IN_PROGRESS && $previousStatus === UserMission::STATUS_NOT_STARTED) {
                $this->progressService->logActivity(
                    user: $user,
                    activityType: LearningActivityLog::TYPE_MISSION_STARTED,
                    subjectType: 'mission',
                    subjectId: $mission->id,
                    subjectTitle: $mission->title,
                    category: $mission->category,
                    pointsEarned: 0,
                );
            } elseif ($status === UserMission::STATUS_COMPLETED && $previousStatus !== UserMission::STATUS_COMPLETED) {
                $this->progressService->logActivity(
                    user: $user,
                    activityType: LearningActivityLog::TYPE_MISSION_COMPLETED,
                    subjectType: 'mission',
                    subjectId: $mission->id,
                    subjectTitle: $mission->title,
                    category: $mission->category,
                    pointsEarned: (int) $mission->points,
                );
            }

            $newBadges = $this->progressService->evaluateAndAwardBadges($user);

            return [
                'record' => $userMission,
                'newly_awarded_badges' => $newBadges,
            ];
        });

        /** @var UserMission $userMission */
        $userMission = $tx['record'];
        $updatedProgress = $this->progressService->buildUserProgress($user);

        return response()->json([
            'message' => 'Status Misi Siaga "'.$mission->title.'" diperbarui menjadi '.UserMission::labelForStatus($userMission->status).'.',
            'data' => self::serializeMission(
                $mission,
                $userMission->status,
                $userMission->notes,
                $userMission->completed_at?->toIso8601String(),
                $userMission->started_at?->toIso8601String(),
            ),
            'newly_awarded_badges' => $tx['newly_awarded_badges'],
            'progress' => $updatedProgress,
        ]);
    }

    public function progressJson(Request $request): JsonResponse
    {
        DisasterEducationSeeder::ensureSeeded();

        return response()->json([
            'data' => $this->progressService->buildUserProgress($request->user()),
        ]);
    }

    public function historyJson(Request $request): JsonResponse
    {
        DisasterEducationSeeder::ensureSeeded();

        $user = $request->user();
        $progress = $this->progressService->buildUserProgress($user);

        return response()->json([
            'data' => [
                'recent_activities' => $progress['recent_activities'],
                'activity_chart' => $progress['activity_chart'],
                'simulations' => $progress['simulations']['history'],
                'quizzes' => $progress['quizzes']['history'],
                'missions' => $progress['missions']['history'],
            ],
        ]);
    }

    public function badgesJson(Request $request): JsonResponse
    {
        DisasterEducationSeeder::ensureSeeded();

        $progress = $this->progressService->buildUserProgress($request->user());

        return response()->json([
            'data' => $progress['badges'],
            'level' => $progress['level'],
            'total_points' => $progress['total_points'],
        ]);
    }

    public function reminderShowJson(Request $request): JsonResponse
    {
        DisasterEducationSeeder::ensureSeeded();

        $user = $request->user();

        return response()->json([
            'data' => $this->progressService->serializeReminderPreference($user),
            'pending_reminders' => $this->progressService->buildPendingReminders($user),
        ]);
    }

    public function reminderUpdateJson(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'is_enabled' => ['required', 'boolean'],
            'reminder_time' => ['required', 'regex:/^([01]\d|2[0-3]):[0-5]\d$/'],
            'frequency' => ['required', Rule::in(LearningReminderPreference::FREQUENCIES)],
            'remind_unfinished_materials' => ['nullable', 'boolean'],
            'remind_pending_missions' => ['nullable', 'boolean'],
            'remind_inactive_learning' => ['nullable', 'boolean'],
        ], [
            'reminder_time.regex' => 'Format waktu pengingat harus HH:MM (contoh: 19:00).',
        ]);

        $user = $request->user();

        LearningReminderPreference::query()->updateOrCreate(
            ['user_id' => $user->id],
            [
                'is_enabled' => (bool) $validated['is_enabled'],
                'reminder_time' => (string) $validated['reminder_time'],
                'frequency' => (string) $validated['frequency'],
                'remind_unfinished_materials' => array_key_exists('remind_unfinished_materials', $validated)
                    ? (bool) $validated['remind_unfinished_materials']
                    : true,
                'remind_pending_missions' => array_key_exists('remind_pending_missions', $validated)
                    ? (bool) $validated['remind_pending_missions']
                    : true,
                'remind_inactive_learning' => array_key_exists('remind_inactive_learning', $validated)
                    ? (bool) $validated['remind_inactive_learning']
                    : true,
            ]
        );

        return response()->json([
            'message' => $validated['is_enabled']
                ? 'Pengingat belajar berhasil diaktifkan dan disimpan ke akun Anda.'
                : 'Pengingat belajar dinonaktifkan.',
            'data' => $this->progressService->serializeReminderPreference($user),
            'pending_reminders' => $this->progressService->buildPendingReminders($user),
        ]);
    }

    public static function resolveMaterialImageUrl(LearningMaterial $material): ?string
    {
        $path = $material->image_path;
        if (! is_string($path) || trim($path) === '') {
            return null;
        }

        $trimmed = trim($path);
        if (str_starts_with(strtolower($trimmed), 'http://') || str_starts_with(strtolower($trimmed), 'https://')) {
            return $trimmed;
        }

        if (str_starts_with($trimmed, 'illustrations/')) {
            return null;
        }

        return route('api.edukasi.materi.image', [
            'learningMaterial' => $material->id,
            'v' => $material->updated_at?->timestamp ?? time(),
        ]);
    }

    /**
     * @return array<string, mixed>
     */
    public static function serializeMaterial(LearningMaterial $material, LearningProgress|bool|null $progress = false): array
    {
        $isCompleted = $progress instanceof LearningProgress
            ? (bool) $progress->is_completed
            : (bool) $progress;

        $isFavorite = $progress instanceof LearningProgress ? (bool) $progress->is_favorite : false;
        $lastPosition = $progress instanceof LearningProgress ? (int) $progress->last_position : ($isCompleted ? 100 : 0);
        $lastSection = $progress instanceof LearningProgress ? $progress->last_section : null;
        $progressPercent = $progress instanceof LearningProgress ? (int) $progress->progress_percent : ($isCompleted ? 100 : 0);
        $lastReadAt = $progress instanceof LearningProgress ? $progress->last_read_at?->toIso8601String() : null;

        return [
            'id' => $material->id,
            'learning_category_id' => $material->learning_category_id,
            'category' => $material->category,
            'title' => $material->title,
            'slug' => $material->slug,
            'difficulty' => $material->difficulty,
            'image_path' => $material->image_path,
            'image_url' => self::resolveMaterialImageUrl($material),
            'summary' => $material->summary,
            'content' => $material->content,
            'key_points' => $material->key_points ?? [],
            'action_steps' => $material->action_steps ?? [],
            'things_to_avoid' => $material->things_to_avoid ?? [],
            'source_reference' => $material->source_reference,
            'sort_order' => $material->sort_order,
            'status' => $material->status,
            'status_label' => $material->statusLabel(),
            'is_completed' => $isCompleted,
            'is_favorite' => $isFavorite,
            'last_position' => $lastPosition,
            'last_section' => $lastSection,
            'progress_percent' => $progressPercent,
            'last_read_at' => $lastReadAt,
            'created_at' => $material->created_at?->toIso8601String(),
            'updated_at' => $material->updated_at?->toIso8601String(),
        ];
    }

    /**
     * @return array<string, mixed>
     */
    public static function serializeSimulation(
        Simulation $simulation,
        bool $isCompleted = false,
        ?int $bestScore = null,
        ?int $latestScore = null,
        int $attemptsCount = 0,
        ?SimulationDraft $draft = null
    ): array {
        return [
            'id' => $simulation->id,
            'category' => $simulation->category,
            'title' => $simulation->title,
            'slug' => $simulation->slug,
            'difficulty' => $simulation->difficulty,
            'description' => $simulation->description,
            'scenario_context' => $simulation->scenario_context,
            'safety_reference' => $simulation->safety_reference,
            'sort_order' => $simulation->sort_order,
            'status' => $simulation->status,
            'status_label' => $simulation->statusLabel(),
            'is_completed' => $isCompleted,
            'best_score' => $bestScore,
            'latest_score' => $latestScore,
            'attempts_count' => $attemptsCount,
            'draft' => $draft !== null ? [
                'current_step_index' => $draft->current_step_index,
                'selected_choices' => $draft->selected_choices ?? [],
                'updated_at' => $draft->updated_at?->toIso8601String(),
            ] : null,
            'steps_count' => $simulation->relationLoaded('steps') ? $simulation->steps->count() : $simulation->steps()->count(),
            'steps' => $simulation->relationLoaded('steps')
                ? $simulation->steps->map(fn (SimulationStep $step) => [
                    'id' => $step->id,
                    'step_number' => $step->step_number,
                    'situation_title' => $step->situation_title,
                    'situation_text' => $step->situation_text,
                    'recommended_action' => $step->recommended_action,
                    'choices' => $step->relationLoaded('choices')
                        ? $step->choices->map(fn (SimulationChoice $choice) => [
                            'id' => $choice->id,
                            'label' => $choice->label,
                            'choice_text' => $choice->choice_text,
                            'is_correct' => (bool) $choice->is_correct,
                            'score' => (int) $choice->score,
                            'assessment' => $choice->assessment,
                            'feedback' => $choice->feedback,
                        ])->values()
                        : [],
                ])->values()
                : [],
        ];
    }

    /**
     * @return array<string, mixed>
     */
    public static function serializeMission(
        Mission $mission,
        string $userStatus = UserMission::STATUS_NOT_STARTED,
        ?string $notes = null,
        ?string $completedAt = null,
        ?string $startedAt = null
    ): array {
        return [
            'id' => $mission->id,
            'category' => $mission->category,
            'title' => $mission->title,
            'slug' => $mission->slug,
            'description' => $mission->description,
            'illustration' => $mission->illustration,
            'instructions' => $mission->instructions ?? [],
            'difficulty' => $mission->difficulty,
            'points' => (int) $mission->points,
            'sort_order' => (int) $mission->sort_order,
            'status' => $mission->status,
            'status_label' => $mission->statusLabel(),
            'user_status' => $userStatus,
            'user_status_label' => UserMission::labelForStatus($userStatus),
            'notes' => $notes,
            'started_at' => $startedAt,
            'completed_at' => $completedAt,
        ];
    }
}
