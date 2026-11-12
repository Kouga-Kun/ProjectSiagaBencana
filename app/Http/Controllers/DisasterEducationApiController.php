<?php

namespace App\Http\Controllers;

use App\Models\LearningCategory;
use App\Models\LearningMaterial;
use App\Models\LearningProgress;
use App\Models\Mission;
use App\Models\Quiz;
use App\Models\QuizOption;
use App\Models\QuizQuestion;
use App\Models\QuizResult;
use App\Models\Simulation;
use App\Models\SimulationChoice;
use App\Models\SimulationResult;
use App\Models\SimulationStep;
use App\Models\UserMission;
use App\Services\EducationProgressService;
use Database\Seeders\DisasterEducationSeeder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
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
        $completedMaterialIds = $progress['materials']['completed_ids'] ?? [];

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

        $recommendedMaterials = LearningMaterial::query()
            ->where('status', LearningMaterial::STATUS_PUBLISHED)
            ->orderBy('sort_order')
            ->limit(6)
            ->get()
            ->map(fn (LearningMaterial $item) => self::serializeMaterial($item, in_array($item->id, $completedMaterialIds, true)))
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
        ]);

        $user = $request->user();
        $completedIds = $user
            ? LearningProgress::query()
                ->where('user_id', $user->id)
                ->where('is_completed', true)
                ->pluck('learning_material_id')
                ->all()
            : [];

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

        $materials = $query
            ->orderBy('category')
            ->orderBy('sort_order')
            ->orderBy('id')
            ->get()
            ->map(fn (LearningMaterial $item) => self::serializeMaterial($item, in_array($item->id, $completedIds, true)))
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
        $isCompleted = $user !== null && LearningProgress::query()
            ->where('user_id', $user->id)
            ->where('learning_material_id', $material->id)
            ->where('is_completed', true)
            ->exists();

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
                self::serializeMaterial($material, $isCompleted),
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

        $progressRecord = LearningProgress::query()->updateOrCreate(
            [
                'user_id' => $user->id,
                'learning_material_id' => $learningMaterial->id,
            ],
            [
                'is_completed' => $targetCompleted,
                'completed_at' => $targetCompleted ? now() : null,
            ]
        );

        $newBadges = $this->progressService->evaluateAndAwardBadges($user);
        $updatedProgress = $this->progressService->buildUserProgress($user);

        return response()->json([
            'message' => $progressRecord->is_completed
                ? 'Materi "'.$learningMaterial->title.'" berhasil ditandai selesai!'
                : 'Penanda selesai pada materi telah dibatalkan.',
            'is_completed' => (bool) $progressRecord->is_completed,
            'newly_awarded_badges' => $newBadges,
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
        $userBestScores = [];
        if ($user !== null) {
            $userBestScores = SimulationResult::query()
                ->where('user_id', $user->id)
                ->get()
                ->groupBy('simulation_id')
                ->map(fn ($group) => (int) $group->max('score'))
                ->all();
        }

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
            ->map(fn (Simulation $sim) => self::serializeSimulation(
                $sim,
                array_key_exists($sim->id, $userBestScores),
                $userBestScores[$sim->id] ?? null,
            ))
            ->values();

        return response()->json([
            'data' => $simulations,
            'history' => $user !== null
                ? $this->progressService->buildUserProgress($user)['simulations']['history']
                : [],
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
        $bestScore = null;
        $isCompleted = false;
        if ($user !== null) {
            $results = SimulationResult::query()
                ->where('user_id', $user->id)
                ->where('simulation_id', $simulation->id)
                ->get();
            if ($results->isNotEmpty()) {
                $isCompleted = true;
                $bestScore = (int) $results->max('score');
            }
        }

        return response()->json([
            'data' => self::serializeSimulation($simulation, $isCompleted, $bestScore),
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
        ], [
            'choices.required' => 'Pilih tindakan untuk setiap langkah skenario simulasi.',
        ]);

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
            $chosen = $step->choices->firstWhere('id', (int) $chosenId);
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

        $user = $request->user();
        $resultRecord = SimulationResult::create([
            'user_id' => $user->id,
            'simulation_id' => $simulation->id,
            'score' => $normalizedScore,
            'max_score' => 100,
            'correct_choices' => $correctCount,
            'total_steps' => $steps->count(),
            'selected_answers' => $stepReviews,
            'completed_at' => now(),
        ]);

        $newBadges = $this->progressService->evaluateAndAwardBadges($user);
        $updatedProgress = $this->progressService->buildUserProgress($user);

        return response()->json([
            'message' => 'Simulasi "'.$simulation->title.'" selesai! Nilai kamu: '.$normalizedScore.'/100.',
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
            'newly_awarded_badges' => $newBadges,
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
        $bestQuizScores = [];
        if ($user !== null) {
            $bestQuizScores = QuizResult::query()
                ->where('user_id', $user->id)
                ->get()
                ->groupBy('quiz_id')
                ->map(fn ($group) => (int) $group->max('final_score'))
                ->all();
        }

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
            ->map(fn (Quiz $quiz) => [
                'id' => $quiz->id,
                'category' => $quiz->category,
                'topic' => $quiz->topic,
                'title' => $quiz->title,
                'slug' => $quiz->slug,
                'difficulty' => $quiz->difficulty,
                'description' => $quiz->description,
                'questions_count' => $quiz->questions_count,
                'is_completed' => array_key_exists($quiz->id, $bestQuizScores),
                'best_score' => $bestQuizScores[$quiz->id] ?? null,
            ])
            ->values();

        return response()->json([
            'data' => $quizzes,
            'history' => $user !== null
                ? $this->progressService->buildUserProgress($user)['quizzes']['history']
                : [],
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

        // PENTING: Jangan menampilkan jawaban benar atau pembahasan sebelum kuis selesai!
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
        ], [
            'answers.required' => 'Jawab pertanyaan kuis terlebih dahulu sebelum mengirim hasil.',
        ]);

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
            $selectedOpt = $question->options->firstWhere('id', (int) $selectedOptionId);
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

        $user = $request->user();
        $resultRecord = QuizResult::create([
            'user_id' => $user->id,
            'quiz_id' => $quiz->id,
            'total_questions' => $totalQuestions,
            'correct_answers' => $correctAnswers,
            'wrong_answers' => $wrongAnswers,
            'final_score' => $finalScore,
            'percentage' => $percentage,
            'answers_detail' => $reviews,
            'recommended_materials' => $recommendedMaterials,
            'completed_at' => now(),
        ]);

        $newBadges = $this->progressService->evaluateAndAwardBadges($user);
        $updatedProgress = $this->progressService->buildUserProgress($user);

        return response()->json([
            'message' => 'Kuis "'.$quiz->title.'" selesai dinilai! Nilai akhir: '.$finalScore.' ('.$percentage.'%).',
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
                'reviews' => $reviews,
                'recommended_materials' => $recommendedMaterials,
                'completed_at' => $resultRecord->completed_at?->toIso8601String(),
            ],
            'newly_awarded_badges' => $newBadges,
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
        $userMissionMap = $user !== null
            ? UserMission::query()
                ->where('user_id', $user->id)
                ->get()
                ->keyBy('mission_id')
            : collect();

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

                return self::serializeMission($mission, $userStatus, $um?->notes, $um?->completed_at?->toIso8601String());
            })
            ->values();

        return response()->json([
            'data' => $missions,
            'progress' => $this->progressService->buildUserProgress($user)['missions'],
        ]);
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

        $existing = UserMission::query()
            ->where('user_id', $user->id)
            ->where('mission_id', $mission->id)
            ->first();

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

        $newBadges = $this->progressService->evaluateAndAwardBadges($user);
        $updatedProgress = $this->progressService->buildUserProgress($user);

        return response()->json([
            'message' => 'Status Misi Siaga "'.$mission->title.'" diperbarui menjadi '.UserMission::labelForStatus($userMission->status).'.',
            'data' => self::serializeMission(
                $mission,
                $userMission->status,
                $userMission->notes,
                $userMission->completed_at?->toIso8601String()
            ),
            'newly_awarded_badges' => $newBadges,
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
    public static function serializeMaterial(LearningMaterial $material, bool $isCompleted = false): array
    {
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
        ?int $bestScore = null
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
        ?string $completedAt = null
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
            'completed_at' => $completedAt,
        ];
    }
}

