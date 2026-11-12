<?php

namespace App\Services;

use App\Models\Badge;
use App\Models\LearningMaterial;
use App\Models\LearningProgress;
use App\Models\Mission;
use App\Models\Quiz;
use App\Models\QuizResult;
use App\Models\Simulation;
use App\Models\SimulationResult;
use App\Models\User;
use App\Models\UserBadge;
use App\Models\UserMission;
use Illuminate\Support\Collection;

class EducationProgressService
{
    public const MATERIAL_COMPLETION_POINTS = 25;

    /**
     * Evaluate clear achievement criteria and award newly earned badges to the user.
     *
     * @return list<array<string, mixed>>
     */
    public function evaluateAndAwardBadges(User $user): array
    {
        $completedMaterialIds = LearningProgress::query()
            ->where('user_id', $user->id)
            ->where('is_completed', true)
            ->pluck('learning_material_id');

        $completedMaterials = LearningMaterial::query()
            ->whereIn('id', $completedMaterialIds)
            ->get(['id', 'category']);

        $eqMaterialsDone = $completedMaterials
            ->where('category', LearningMaterial::CATEGORY_EARTHQUAKE)
            ->count();
        $tsMaterialsDone = $completedMaterials
            ->where('category', LearningMaterial::CATEGORY_TSUNAMI)
            ->count();
        $totalMaterialsDone = $completedMaterials->count();

        $simResults = SimulationResult::query()
            ->with('simulation:id,category')
            ->where('user_id', $user->id)
            ->get();

        $eqSimsDone = $simResults
            ->filter(fn (SimulationResult $r) => $r->simulation?->category === LearningMaterial::CATEGORY_EARTHQUAKE)
            ->pluck('simulation_id')
            ->unique()
            ->count();

        $tsSimsDone = $simResults
            ->filter(fn (SimulationResult $r) => $r->simulation?->category === LearningMaterial::CATEGORY_TSUNAMI)
            ->pluck('simulation_id')
            ->unique()
            ->count();

        $highScoreSimsDone = $simResults
            ->filter(fn (SimulationResult $r) => $r->score >= 80)
            ->pluck('simulation_id')
            ->unique()
            ->count();

        $quizResults = QuizResult::query()
            ->with('quiz:id,category')
            ->where('user_id', $user->id)
            ->get();

        $eqQuizzesDone = $quizResults
            ->filter(fn (QuizResult $r) => $r->quiz?->category === LearningMaterial::CATEGORY_EARTHQUAKE)
            ->pluck('quiz_id')
            ->unique()
            ->count();

        $tsQuizzesDone = $quizResults
            ->filter(fn (QuizResult $r) => $r->quiz?->category === LearningMaterial::CATEGORY_TSUNAMI)
            ->pluck('quiz_id')
            ->unique()
            ->count();

        $totalQuizzesDone = $quizResults->pluck('quiz_id')->unique()->count();

        $completedMissionsCount = UserMission::query()
            ->where('user_id', $user->id)
            ->where('status', UserMission::STATUS_COMPLETED)
            ->count();

        $criteriaMap = [
            'siaga-gempa' => $eqMaterialsDone >= 3 && $eqSimsDone >= 1 && $eqQuizzesDone >= 1,
            'siaga-tsunami' => $tsMaterialsDone >= 3 && $tsSimsDone >= 1 && $tsQuizzesDone >= 1,
            'ahli-evakuasi' => $highScoreSimsDone >= 2,
            'pembelajar-aktif' => $totalMaterialsDone >= 6 && $totalQuizzesDone >= 2,
            'keluarga-siaga' => $completedMissionsCount >= 3,
        ];

        $newlyAwarded = [];
        $badges = Badge::query()->get();

        foreach ($badges as $badge) {
            $qualifies = $criteriaMap[$badge->code] ?? false;
            if (! $qualifies) {
                continue;
            }

            $alreadyHas = UserBadge::query()
                ->where('user_id', $user->id)
                ->where('badge_id', $badge->id)
                ->exists();

            if (! $alreadyHas) {
                $userBadge = UserBadge::create([
                    'user_id' => $user->id,
                    'badge_id' => $badge->id,
                    'awarded_at' => now(),
                ]);

                $newlyAwarded[] = [
                    'id' => $badge->id,
                    'code' => $badge->code,
                    'name' => $badge->name,
                    'description' => $badge->description,
                    'criteria_description' => $badge->criteria_description,
                    'icon' => $badge->icon,
                    'points_reward' => $badge->points_reward,
                    'awarded_at' => $userBadge->awarded_at?->toIso8601String(),
                ];
            }
        }

        return $newlyAwarded;
    }

    /**
     * Build comprehensive learning progress & achievements payload for the given user (or guest initial state).
     *
     * @return array<string, mixed>
     */
    public function buildUserProgress(?User $user): array
    {
        $publishedMaterials = LearningMaterial::query()
            ->where('status', LearningMaterial::STATUS_PUBLISHED)
            ->orderBy('sort_order')
            ->get(['id', 'title', 'slug', 'category', 'difficulty']);

        $totalMaterials = $publishedMaterials->count();
        $totalEqMaterials = $publishedMaterials->where('category', LearningMaterial::CATEGORY_EARTHQUAKE)->count();
        $totalTsMaterials = $publishedMaterials->where('category', LearningMaterial::CATEGORY_TSUNAMI)->count();

        $totalSimulations = Simulation::query()
            ->where('status', Simulation::STATUS_PUBLISHED)
            ->count();

        $totalQuizzes = Quiz::query()
            ->where('status', Quiz::STATUS_PUBLISHED)
            ->count();

        $totalMissions = Mission::query()
            ->where('status', Mission::STATUS_PUBLISHED)
            ->count();

        $allBadges = Badge::query()->orderBy('id')->get();

        if ($user === null) {
            $badgeItems = $allBadges->map(fn (Badge $badge) => [
                'id' => $badge->id,
                'code' => $badge->code,
                'slug' => $badge->code,
                'name' => $badge->name,
                'description' => $badge->description,
                'criteria_description' => $badge->criteria_description,
                'criteria_text' => $badge->criteria_description,
                'icon' => $badge->icon,
                'category' => $badge->category,
                'points_reward' => $badge->points_reward,
                'is_earned' => false,
                'awarded_at' => null,
            ])->values()->all();

            return [
                'authenticated' => false,
                'has_activity' => false,
                'initial_message' => 'Silakan masuk ke akun SiagaBencana untuk menyimpan progres belajar, hasil simulasi, nilai kuis, penyelesaian Misi Siaga, serta meraih badge kesiapsiagaan.',
                'initial_state_message' => 'Silakan masuk ke akun SiagaBencana untuk menyimpan progres belajar, hasil simulasi, nilai kuis, penyelesaian Misi Siaga, serta meraih badge kesiapsiagaan.',
                'overall_percentage' => 0,
                'overall_progress_percentage' => 0,
                'total_points' => 0,
                'materials' => [
                    'completed' => 0,
                    'total' => $totalMaterials,
                    'completed_count' => 0,
                    'total_count' => $totalMaterials,
                    'earthquake_completed' => 0,
                    'earthquake_total' => $totalEqMaterials,
                    'tsunami_completed' => 0,
                    'tsunami_total' => $totalTsMaterials,
                    'completed_ids' => [],
                ],
                'simulations' => [
                    'completed' => 0,
                    'total' => $totalSimulations,
                    'completed_count' => 0,
                    'total_count' => $totalSimulations,
                    'history' => [],
                ],
                'quizzes' => [
                    'completed_quizzes' => 0,
                    'total_quizzes' => $totalQuizzes,
                    'completed_count' => 0,
                    'total_count' => $totalQuizzes,
                    'earthquake_best_average' => 0,
                    'tsunami_best_average' => 0,
                    'earthquake_history' => [],
                    'tsunami_history' => [],
                    'history' => [],
                ],
                'missions' => [
                    'completed' => 0,
                    'total' => $totalMissions,
                    'completed_count' => 0,
                    'in_progress_count' => 0,
                    'not_started_count' => $totalMissions,
                    'total_count' => $totalMissions,
                    'history' => [],
                ],
                'badges' => [
                    'earned_count' => 0,
                    'total_count' => count($badgeItems),
                    'items' => $badgeItems,
                ],
                'badges_list' => $badgeItems,
                'earned_badges_count' => 0,
            ];
        }

        $this->evaluateAndAwardBadges($user);

        $progressItems = LearningProgress::query()
            ->where('user_id', $user->id)
            ->where('is_completed', true)
            ->get();

        $completedMaterialIds = $progressItems->pluck('learning_material_id')->all();
        $completedMaterialsSet = $publishedMaterials->whereIn('id', $completedMaterialIds);

        $completedMaterialsCount = $completedMaterialsSet->count();
        $eqMaterialsCompleted = $completedMaterialsSet
            ->where('category', LearningMaterial::CATEGORY_EARTHQUAKE)
            ->count();
        $tsMaterialsCompleted = $completedMaterialsSet
            ->where('category', LearningMaterial::CATEGORY_TSUNAMI)
            ->count();

        $simResults = SimulationResult::query()
            ->with('simulation:id,title,slug,category,difficulty')
            ->where('user_id', $user->id)
            ->orderByDesc('completed_at')
            ->orderByDesc('id')
            ->get();

        $completedSimulationIds = $simResults->pluck('simulation_id')->unique();
        $completedSimulationsCount = $completedSimulationIds->count();

        $quizResults = QuizResult::query()
            ->with('quiz:id,title,slug,category,topic,difficulty')
            ->where('user_id', $user->id)
            ->orderByDesc('completed_at')
            ->orderByDesc('id')
            ->get();

        $completedQuizIds = $quizResults->pluck('quiz_id')->unique();
        $completedQuizzesCount = $completedQuizIds->count();

        $userMissions = UserMission::query()
            ->with('mission:id,title,slug,category,difficulty,points')
            ->where('user_id', $user->id)
            ->orderByDesc('updated_at')
            ->get();

        $completedMissions = $userMissions->where('status', UserMission::STATUS_COMPLETED);
        $inProgressMissions = $userMissions->where('status', UserMission::STATUS_IN_PROGRESS);
        $completedMissionsCount = $completedMissions->count();
        $inProgressMissionsCount = $inProgressMissions->count();
        $notStartedMissionsCount = max(0, $totalMissions - $completedMissionsCount - $inProgressMissionsCount);

        $userBadgesMap = UserBadge::query()
            ->where('user_id', $user->id)
            ->get()
            ->keyBy('badge_id');

        $materialPoints = $completedMaterialsCount * self::MATERIAL_COMPLETION_POINTS;
        $simulationPoints = (int) $simResults
            ->groupBy('simulation_id')
            ->map(fn (Collection $group) => (int) $group->max('score'))
            ->sum();
        $quizPoints = (int) $quizResults
            ->groupBy('quiz_id')
            ->map(fn (Collection $group) => (int) $group->max('final_score'))
            ->sum();
        $missionPoints = (int) $completedMissions
            ->sum(fn (UserMission $um) => (int) ($um->mission?->points ?? 50));
        $badgePoints = (int) $allBadges
            ->filter(fn (Badge $b) => $userBadgesMap->has($b->id))
            ->sum('points_reward');

        $totalPoints = $materialPoints + $simulationPoints + $quizPoints + $missionPoints + $badgePoints;

        $totalUnits = $totalMaterials + $totalSimulations + $totalQuizzes + $totalMissions;
        $completedUnits = min($totalMaterials, $completedMaterialsCount)
            + min($totalSimulations, $completedSimulationsCount)
            + min($totalQuizzes, $completedQuizzesCount)
            + min($totalMissions, $completedMissionsCount);

        $overallPercentage = $totalUnits > 0
            ? (int) round(($completedUnits / $totalUnits) * 100)
            : 0;

        $hasActivity = $completedUnits > 0 || $inProgressMissionsCount > 0;

        $serializedQuizHistory = $quizResults->map(fn (QuizResult $qr) => [
            'id' => $qr->id,
            'quiz_id' => $qr->quiz_id,
            'quiz_title' => $qr->quiz?->title ?? 'Kuis Edukasi',
            'quiz_slug' => $qr->quiz?->slug,
            'category' => $qr->quiz?->category ?? LearningMaterial::CATEGORY_EARTHQUAKE,
            'difficulty' => $qr->quiz?->difficulty ?? 'Dasar',
            'total_questions' => $qr->total_questions,
            'correct_answers' => $qr->correct_answers,
            'wrong_answers' => $qr->wrong_answers,
            'final_score' => $qr->final_score,
            'percentage' => (float) $qr->percentage,
            'completed_at' => $qr->completed_at?->toIso8601String(),
        ])->values()->all();

        $eqQuizHistory = array_values(array_filter(
            $serializedQuizHistory,
            fn (array $item) => $item['category'] === LearningMaterial::CATEGORY_EARTHQUAKE
        ));

        $tsQuizHistory = array_values(array_filter(
            $serializedQuizHistory,
            fn (array $item) => $item['category'] === LearningMaterial::CATEGORY_TSUNAMI
        ));

        $eqBestAvg = count($eqQuizHistory) > 0
            ? (int) round(collect($eqQuizHistory)->avg('final_score'))
            : 0;
        $tsBestAvg = count($tsQuizHistory) > 0
            ? (int) round(collect($tsQuizHistory)->avg('final_score'))
            : 0;

        $badgeItems = $allBadges->map(function (Badge $badge) use ($userBadgesMap) {
            /** @var UserBadge|null $award */
            $award = $userBadgesMap->get($badge->id);

            return [
                'id' => $badge->id,
                'code' => $badge->code,
                'slug' => $badge->code,
                'name' => $badge->name,
                'description' => $badge->description,
                'criteria_description' => $badge->criteria_description,
                'criteria_text' => $badge->criteria_description,
                'icon' => $badge->icon,
                'category' => $badge->category,
                'points_reward' => $badge->points_reward,
                'is_earned' => $award !== null,
                'awarded_at' => $award?->awarded_at?->toIso8601String(),
            ];
        })->values()->all();

        $initMessage = $hasActivity
            ? 'Terus tingkatkan kesiapsiagaanmu dengan menuntaskan materi, simulasi, kuis, dan Misi Siaga.'
            : 'Belum ada aktivitas pembelajaran. Mulai pelajari materi Gempa Bumi atau Tsunami pertama Anda hari ini!';

        return [
            'authenticated' => true,
            'has_activity' => $hasActivity,
            'initial_message' => $initMessage,
            'initial_state_message' => $initMessage,
            'overall_percentage' => $overallPercentage,
            'overall_progress_percentage' => $overallPercentage,
            'total_points' => $totalPoints,
            'materials' => [
                'completed' => $completedMaterialsCount,
                'total' => $totalMaterials,
                'completed_count' => $completedMaterialsCount,
                'total_count' => $totalMaterials,
                'earthquake_completed' => $eqMaterialsCompleted,
                'earthquake_total' => $totalEqMaterials,
                'tsunami_completed' => $tsMaterialsCompleted,
                'tsunami_total' => $totalTsMaterials,
                'completed_ids' => array_values($completedMaterialIds),
            ],
            'simulations' => [
                'completed' => $completedSimulationsCount,
                'total' => $totalSimulations,
                'completed_count' => $completedSimulationsCount,
                'total_count' => $totalSimulations,
                'history' => $simResults->map(fn (SimulationResult $sr) => [
                    'id' => $sr->id,
                    'simulation_id' => $sr->simulation_id,
                    'simulation_title' => $sr->simulation?->title ?? 'Simulasi Bencana',
                    'simulation_slug' => $sr->simulation?->slug,
                    'category' => $sr->simulation?->category ?? LearningMaterial::CATEGORY_EARTHQUAKE,
                    'difficulty' => $sr->simulation?->difficulty ?? 'Dasar',
                    'score' => $sr->score,
                    'max_score' => $sr->max_score,
                    'correct_choices' => $sr->correct_choices,
                    'total_steps' => $sr->total_steps,
                    'completed_at' => $sr->completed_at?->toIso8601String(),
                ])->values()->all(),
            ],
            'quizzes' => [
                'completed_quizzes' => $completedQuizzesCount,
                'total_quizzes' => $totalQuizzes,
                'completed_count' => $completedQuizzesCount,
                'total_count' => $totalQuizzes,
                'earthquake_best_average' => $eqBestAvg,
                'tsunami_best_average' => $tsBestAvg,
                'earthquake_history' => $eqQuizHistory,
                'tsunami_history' => $tsQuizHistory,
                'history' => $serializedQuizHistory,
            ],
            'missions' => [
                'completed' => $completedMissionsCount,
                'total' => $totalMissions,
                'completed_count' => $completedMissionsCount,
                'in_progress_count' => $inProgressMissionsCount,
                'not_started_count' => $notStartedMissionsCount,
                'total_count' => $totalMissions,
                'history' => $userMissions->map(fn (UserMission $um) => [
                    'id' => $um->id,
                    'mission_id' => $um->mission_id,
                    'mission_title' => $um->mission?->title ?? 'Misi Siaga',
                    'mission_slug' => $um->mission?->slug,
                    'category' => $um->mission?->category ?? LearningMaterial::CATEGORY_EARTHQUAKE,
                    'difficulty' => $um->mission?->difficulty ?? 'Dasar',
                    'points' => $um->mission?->points ?? 50,
                    'status' => $um->status,
                    'status_label' => UserMission::labelForStatus($um->status),
                    'notes' => $um->notes,
                    'started_at' => $um->started_at?->toIso8601String(),
                    'completed_at' => $um->completed_at?->toIso8601String(),
                ])->values()->all(),
            ],
            'badges' => [
                'earned_count' => $userBadgesMap->count(),
                'total_count' => count($badgeItems),
                'items' => $badgeItems,
            ],
            'badges_list' => $badgeItems,
            'earned_badges_count' => $userBadgesMap->count(),
        ];
    }

    /**
     * Build overview of user progress across the system for Admin/Petugas monitoring.
     *
     * @return array<string, mixed>
     */
    public function buildAdminProgressOverview(): array
    {
        $users = User::query()
            ->withCount([
                'learningProgress as completed_materials_count' => fn ($q) => $q->where('is_completed', true),
                'simulationResults as simulation_attempts_count',
                'quizResults as quiz_attempts_count',
                'userMissions as completed_missions_count' => fn ($q) => $q->where('status', UserMission::STATUS_COMPLETED),
                'userBadges as earned_badges_count',
            ])
            ->orderByDesc('completed_materials_count')
            ->limit(50)
            ->get();

        $avgQuizScore = (float) (QuizResult::query()->avg('final_score') ?? 0);

        return [
            'summary' => [
                'total_users' => User::count(),
                'total_material_completions' => LearningProgress::where('is_completed', true)->count(),
                'total_simulation_attempts' => SimulationResult::count(),
                'total_quiz_attempts' => QuizResult::count(),
                'average_quiz_score' => round($avgQuizScore, 1),
                'total_completed_missions' => UserMission::where('status', UserMission::STATUS_COMPLETED)->count(),
                'total_awarded_badges' => UserBadge::count(),
            ],
            'users' => $users->map(fn (User $u) => [
                'id' => $u->id,
                'name' => $u->name,
                'email' => $u->email,
                'role' => $u->role,
                'completed_materials_count' => (int) $u->completed_materials_count,
                'simulation_attempts_count' => (int) $u->simulation_attempts_count,
                'quiz_attempts_count' => (int) $u->quiz_attempts_count,
                'completed_missions_count' => (int) $u->completed_missions_count,
                'earned_badges_count' => (int) $u->earned_badges_count,
            ])->values()->all(),
        ];
    }
}
