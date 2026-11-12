<?php

namespace App\Http\Controllers;

use App\Models\LearningCategory;
use App\Models\LearningMaterial;
use App\Models\LearningProgress;
use App\Models\Mission;
use App\Models\Quiz;
use App\Models\QuizOption;
use App\Models\QuizResult;
use App\Models\Simulation;
use App\Models\SimulationChoice;
use App\Models\SimulationResult;
use App\Models\UserMission;
use App\Services\EducationProgressService;
use Database\Seeders\DisasterEducationSeeder;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Illuminate\View\View;

class DisasterEducationWebController extends Controller
{
    public function __construct(public EducationProgressService $progressService) {}

    public function index(Request $request): View
    {
        DisasterEducationSeeder::ensureSeeded();

        $user = $request->user();
        $progress = $this->progressService->buildUserProgress($user);
        $completedMaterialIds = $progress['materials']['completed_ids'] ?? [];

        $activeTab = (string) $request->query('tab', 'belajar');
        if (! in_array($activeTab, ['belajar', 'simulasi', 'kuis', 'misi', 'progres'], true)) {
            $activeTab = 'belajar';
        }

        $selectedCategory = (string) $request->query('category', '');
        $selectedDifficulty = (string) $request->query('difficulty', '');
        $search = trim((string) $request->query('search', ''));

        $materialsQuery = LearningMaterial::query()
            ->where('status', LearningMaterial::STATUS_PUBLISHED);

        if ($selectedCategory !== '' && in_array($selectedCategory, LearningMaterial::CATEGORIES, true)) {
            $materialsQuery->where('category', $selectedCategory);
        }
        if ($selectedDifficulty !== '' && in_array($selectedDifficulty, LearningMaterial::DIFFICULTIES, true)) {
            $materialsQuery->where('difficulty', $selectedDifficulty);
        }
        if ($search !== '') {
            $materialsQuery->where(function ($q) use ($search) {
                $q->where('title', 'like', '%'.$search.'%')
                    ->orWhere('summary', 'like', '%'.$search.'%')
                    ->orWhere('content', 'like', '%'.$search.'%');
            });
        }

        $materials = $materialsQuery
            ->orderBy('category')
            ->orderBy('sort_order')
            ->orderBy('id')
            ->get();

        $simulations = Simulation::query()
            ->with(['steps.choices'])
            ->where('status', Simulation::STATUS_PUBLISHED)
            ->when(
                $selectedCategory !== '' && in_array($selectedCategory, LearningMaterial::CATEGORIES, true),
                fn ($q) => $q->where('category', $selectedCategory)
            )
            ->orderBy('sort_order')
            ->orderBy('id')
            ->get();

        $quizzes = Quiz::query()
            ->withCount('questions')
            ->where('status', Quiz::STATUS_PUBLISHED)
            ->when(
                $selectedCategory !== '' && in_array($selectedCategory, LearningMaterial::CATEGORIES, true),
                fn ($q) => $q->where('category', $selectedCategory)
            )
            ->orderBy('sort_order')
            ->orderBy('id')
            ->get();

        $missions = Mission::query()
            ->where('status', Mission::STATUS_PUBLISHED)
            ->when(
                $selectedCategory !== '' && in_array($selectedCategory, LearningMaterial::CATEGORIES, true),
                fn ($q) => $q->where('category', $selectedCategory)
            )
            ->orderBy('sort_order')
            ->orderBy('id')
            ->get();

        $userMissionMap = $user !== null
            ? UserMission::query()
                ->where('user_id', $user->id)
                ->get()
                ->keyBy('mission_id')
            : collect();

        $categories = LearningCategory::query()
            ->orderBy('sort_order')
            ->get();

        return view('edukasi', [
            'activeTab' => $activeTab,
            'selectedCategory' => $selectedCategory,
            'selectedDifficulty' => $selectedDifficulty,
            'search' => $search,
            'categories' => $categories,
            'materials' => $materials,
            'completedMaterialIds' => $completedMaterialIds,
            'simulations' => $simulations,
            'quizzes' => $quizzes,
            'missions' => $missions,
            'userMissionMap' => $userMissionMap,
            'progress' => $progress,
        ]);
    }

    public function showMaterial(Request $request, string $slug): View
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
            ->firstOrFail();

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
            ->get();

        $currentIndex = $siblings->search(fn (LearningMaterial $m) => $m->id === $material->id);
        $previousMaterial = ($currentIndex !== false && $currentIndex > 0)
            ? $siblings->get($currentIndex - 1)
            : null;
        $nextMaterial = ($currentIndex !== false && $currentIndex < $siblings->count() - 1)
            ? $siblings->get($currentIndex + 1)
            : null;

        return view('edukasi-materi-detail', [
            'material' => $material,
            'isCompleted' => $isCompleted,
            'previousMaterial' => $previousMaterial,
            'nextMaterial' => $nextMaterial,
            'siblings' => $siblings,
        ]);
    }

    public function completeMaterial(Request $request, LearningMaterial $learningMaterial): RedirectResponse
    {
        if (! $learningMaterial->isPublished()) {
            abort(404);
        }

        $user = $request->user();
        $targetCompleted = $request->has('is_completed')
            ? $request->boolean('is_completed')
            : true;

        LearningProgress::query()->updateOrCreate(
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
        $badgeNote = count($newBadges) > 0
            ? ' Selamat! Kamu mendapatkan badge baru: '.implode(', ', array_column($newBadges, 'name')).'.'
            : '';

        return redirect()
            ->route('edukasi.materi.show', $learningMaterial->slug)
            ->with(
                'status',
                ($targetCompleted
                    ? 'Materi "'.$learningMaterial->title.'" telah ditandai selesai!'
                    : 'Status selesai materi dibatalkan.').$badgeNote
            );
    }

    public function showSimulation(Request $request, string $slug): View
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
            ->firstOrFail();

        $user = $request->user();
        $history = $user !== null
            ? SimulationResult::query()
                ->where('user_id', $user->id)
                ->where('simulation_id', $simulation->id)
                ->orderByDesc('completed_at')
                ->limit(5)
                ->get()
            : collect();

        return view('edukasi-simulasi-detail', [
            'simulation' => $simulation,
            'history' => $history,
            'submissionResult' => session('simulation_result'),
        ]);
    }

    public function submitSimulation(Request $request, Simulation $simulation): RedirectResponse
    {
        if (! $simulation->isPublished()) {
            abort(404);
        }

        $validated = $request->validate([
            'choices' => ['required', 'array', 'min:1'],
            'choices.*' => ['required', 'integer'],
        ], [
            'choices.required' => 'Pilih tindakan pada setiap tahapan skenario simulasi.',
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
                'step_number' => $step->step_number,
                'situation_title' => $step->situation_title,
                'situation_text' => $step->situation_text,
                'selected_choice_label' => $chosen?->label,
                'selected_choice_text' => $chosen?->choice_text,
                'is_correct' => $isStepCorrect,
                'score_earned' => $earned,
                'assessment' => $chosen?->assessment ?? 'Belum Dijawab',
                'feedback' => $chosen?->feedback ?? '-',
                'recommended_action' => $step->recommended_action,
                'correct_choice_label' => $bestChoice?->label,
                'correct_choice_text' => $bestChoice?->choice_text,
            ];
        }

        $normalizedScore = $maxScore > 0 ? (int) round(($totalScore / $maxScore) * 100) : 0;

        $user = $request->user();
        if ($user !== null) {
            SimulationResult::create([
                'user_id' => $user->id,
                'simulation_id' => $simulation->id,
                'score' => $normalizedScore,
                'max_score' => 100,
                'correct_choices' => $correctCount,
                'total_steps' => $steps->count(),
                'selected_answers' => $stepReviews,
                'completed_at' => now(),
            ]);
            $this->progressService->evaluateAndAwardBadges($user);
        }

        return redirect()
            ->route('edukasi.simulasi.show', $simulation->slug)
            ->with('status', 'Simulasi selesai! Skor kesiapsiagaan kamu: '.$normalizedScore.'/100.')
            ->with('simulation_result', [
                'score' => $normalizedScore,
                'correct_choices' => $correctCount,
                'total_steps' => $steps->count(),
                'reviews' => $stepReviews,
            ]);
    }

    public function showQuiz(Request $request, string $slug): View
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
            ->firstOrFail();

        $user = $request->user();
        $history = $user !== null
            ? QuizResult::query()
                ->where('user_id', $user->id)
                ->where('quiz_id', $quiz->id)
                ->orderByDesc('completed_at')
                ->limit(5)
                ->get()
            : collect();

        return view('edukasi-kuis-detail', [
            'quiz' => $quiz,
            'history' => $history,
            'quizResult' => session('quiz_result'),
        ]);
    }

    public function submitQuiz(Request $request, Quiz $quiz): RedirectResponse
    {
        if (! $quiz->isPublished()) {
            abort(404);
        }

        $validated = $request->validate([
            'answers' => ['required', 'array', 'min:1'],
            'answers.*' => ['required', 'integer'],
        ], [
            'answers.required' => 'Silakan pilih jawaban untuk setiap soal kuis.',
        ]);

        $quiz->load(['questions.options']);
        $questions = $quiz->questions;
        $totalQuestions = $questions->count();
        $correctAnswers = 0;
        $wrongAnswers = 0;
        $reviews = [];
        $recommendedSlugs = [];

        foreach ($questions as $question) {
            $selectedOptionId = $validated['answers'][$question->id] ?? $validated['answers'][(string) $question->id] ?? null;
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
                'question_number' => $question->question_number,
                'subtopic' => $question->subtopic,
                'question_text' => $question->question_text,
                'selected_option_label' => $selectedOpt?->option_label,
                'selected_option_text' => $selectedOpt?->option_text,
                'correct_option_label' => $correctOpt?->option_label,
                'correct_option_text' => $correctOpt?->option_text,
                'is_correct' => $isCorrect,
                'explanation' => $question->explanation,
                'recommended_material_slug' => $question->recommended_material_slug,
            ];
        }

        $percentage = $totalQuestions > 0 ? round(($correctAnswers / $totalQuestions) * 100, 2) : 0.0;
        $finalScore = (int) round($percentage);

        $recommendedMaterials = LearningMaterial::query()
            ->where('status', LearningMaterial::STATUS_PUBLISHED)
            ->when(
                ! empty($recommendedSlugs),
                fn ($q) => $q->whereIn('slug', array_unique($recommendedSlugs)),
                fn ($q) => $q->where('category', $quiz->category)->limit(3)
            )
            ->get(['id', 'title', 'slug', 'category', 'difficulty'])
            ->toArray();

        $user = $request->user();
        if ($user !== null) {
            QuizResult::create([
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
            $this->progressService->evaluateAndAwardBadges($user);
        }

        return redirect()
            ->route('edukasi.kuis.show', $quiz->slug)
            ->with('status', 'Kuis selesai dinilai! Nilai akhir kamu: '.$finalScore.' ('.$percentage.'%).')
            ->with('quiz_result', [
                'total_questions' => $totalQuestions,
                'correct_answers' => $correctAnswers,
                'wrong_answers' => $wrongAnswers,
                'final_score' => $finalScore,
                'percentage' => $percentage,
                'reviews' => $reviews,
                'recommended_materials' => $recommendedMaterials,
            ]);
    }

    public function updateMissionStatus(Request $request, Mission $mission): RedirectResponse
    {
        if (! $mission->isPublished()) {
            abort(404);
        }

        $validated = $request->validate([
            'status' => ['required', Rule::in(UserMission::STATUSES)],
            'notes' => ['nullable', 'string', 'max:500'],
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

        UserMission::query()->updateOrCreate(
            [
                'user_id' => $user->id,
                'mission_id' => $mission->id,
            ],
            [
                'status' => $status,
                'notes' => $validated['notes'] ?? $existing?->notes,
                'started_at' => $startedAt,
                'completed_at' => $completedAt,
            ]
        );

        $this->progressService->evaluateAndAwardBadges($user);

        return redirect()
            ->route('edukasi.index', ['tab' => 'misi'])
            ->with('status', 'Status Misi Siaga "'.$mission->title.'" diperbarui menjadi '.UserMission::labelForStatus($status).'.');
    }
}

