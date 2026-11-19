<?php

namespace App\Services;

use App\Models\Badge;
use App\Models\LearningActivityLog;
use App\Models\LearningMaterial;
use App\Models\LearningProgress;
use App\Models\LearningReminderPreference;
use App\Models\Mission;
use App\Models\Quiz;
use App\Models\QuizResult;
use App\Models\Simulation;
use App\Models\SimulationDraft;
use App\Models\SimulationResult;
use App\Models\User;
use App\Models\UserBadge;
use App\Models\UserMission;
use Illuminate\Support\Carbon;
use Illuminate\Support\Collection;

class EducationProgressService
{
    public const MATERIAL_COMPLETION_POINTS = 25;

    /**
     * Record an immutable activity log entry for a user.
     *
     * @param  array<string, mixed>  $metadata
     */
    public function logActivity(
        User $user,
        string $activityType,
        ?string $subjectType,
        ?int $subjectId,
        string $subjectTitle,
        ?string $category = null,
        int $pointsEarned = 0,
        array $metadata = []
    ): LearningActivityLog {
        return LearningActivityLog::create([
            'user_id' => $user->id,
            'activity_type' => $activityType,
            'subject_type' => $subjectType,
            'subject_id' => $subjectId,
            'subject_title' => $subjectTitle,
            'category' => $category,
            'points_earned' => $pointsEarned,
            'metadata' => $metadata,
        ]);
    }

    /**
     * Compute user preparedness level based on backend-validated total points.
     *
     * @return array{
     *     level_number: int,
     *     level_name: string,
     *     current_points: int,
     *     min_points: int,
     *     next_level_points: int,
     *     level_progress_percent: int
     * }
     */
    public function computeLevel(int $totalPoints): array
    {
        $tiers = [
            ['level' => 1, 'name' => 'Pemula Siaga', 'min' => 0, 'next' => 200],
            ['level' => 2, 'name' => 'Warga Tanggap', 'min' => 200, 'next' => 500],
            ['level' => 3, 'name' => 'Relawan Muda', 'min' => 500, 'next' => 1000],
            ['level' => 4, 'name' => 'Penjaga Keselamatan', 'min' => 1000, 'next' => 1600],
            ['level' => 5, 'name' => 'Duta Siaga Bencana', 'min' => 1600, 'next' => 1600],
        ];

        $current = $tiers[0];
        foreach ($tiers as $tier) {
            if ($totalPoints >= $tier['min']) {
                $current = $tier;
            }
        }

        if ($current['level'] === 5) {
            $pct = 100;
        } else {
            $span = max(1, $current['next'] - $current['min']);
            $pct = (int) min(100, max(0, round((($totalPoints - $current['min']) / $span) * 100)));
        }

        return [
            'level_number' => $current['level'],
            'level_name' => $current['name'],
            'current_points' => $totalPoints,
            'min_points' => $current['min'],
            'next_level_points' => $current['next'],
            'level_progress_percent' => $pct,
        ];
    }

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

        $completedMaterials = LearningMaterial::withTrashed()
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
            ->with(['simulation' => fn ($q) => $q->withTrashed()->select(['id', 'category'])])
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
            ->with(['quiz' => fn ($q) => $q->withTrashed()->select(['id', 'category'])])
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

                $this->logActivity(
                    user: $user,
                    activityType: LearningActivityLog::TYPE_BADGE_AWARDED,
                    subjectType: 'badge',
                    subjectId: $badge->id,
                    subjectTitle: $badge->name,
                    category: $badge->category,
                    pointsEarned: (int) $badge->points_reward,
                    metadata: ['badge_code' => $badge->code],
                );

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
     * Get or initialize reminder preferences for a user.
     *
     * @return array<string, mixed>
     */
    public function serializeReminderPreference(User $user): array
    {
        $pref = LearningReminderPreference::query()
            ->where('user_id', $user->id)
            ->first();

        return [
            'is_enabled' => (bool) ($pref?->is_enabled ?? false),
            'reminder_time' => $pref?->reminder_time ?? '19:00',
            'frequency' => $pref?->frequency ?? LearningReminderPreference::FREQUENCY_DAILY,
            'frequency_label' => LearningReminderPreference::frequencyLabel($pref?->frequency ?? LearningReminderPreference::FREQUENCY_DAILY),
            'remind_unfinished_materials' => (bool) ($pref?->remind_unfinished_materials ?? true),
            'remind_pending_missions' => (bool) ($pref?->remind_pending_missions ?? true),
            'remind_inactive_learning' => (bool) ($pref?->remind_inactive_learning ?? true),
            'last_reminded_at' => $pref?->last_reminded_at?->toIso8601String(),
        ];
    }

    /**
     * Build actionable in-app reminders for unfinished activities only (never completed ones).
     *
     * @return list<array<string, mixed>>
     */
    public function buildPendingReminders(User $user): array
    {
        $pref = LearningReminderPreference::query()
            ->where('user_id', $user->id)
            ->first();

        $reminders = [];

        $remindMaterials = $pref === null ? true : (bool) $pref->remind_unfinished_materials;
        $remindMissions = $pref === null ? true : (bool) $pref->remind_pending_missions;
        $remindInactive = $pref === null ? true : (bool) $pref->remind_inactive_learning;

        if ($remindMaterials) {
            $unfinishedMaterials = LearningProgress::query()
                ->with('material:id,title,slug,category,status')
                ->where('user_id', $user->id)
                ->where('is_completed', false)
                ->where('progress_percent', '>', 0)
                ->orderByDesc('last_read_at')
                ->limit(3)
                ->get()
                ->filter(fn (LearningProgress $lp) => $lp->material !== null && $lp->material->trashed() === false && $lp->material->isPublished());

            foreach ($unfinishedMaterials as $lp) {
                $reminders[] = [
                    'type' => 'unfinished_material',
                    'title' => 'Lanjutkan Materi: '.$lp->material->title,
                    'message' => 'Progres membacamu sudah '.$lp->progress_percent.'%. Lanjutkan dari posisi terakhir agar tidak terputus.',
                    'target_type' => 'material',
                    'target_slug' => $lp->material->slug,
                    'category' => $lp->material->category,
                    'progress_percent' => (int) $lp->progress_percent,
                ];
            }
        }

        if ($remindMissions) {
            $pendingMissions = UserMission::query()
                ->with('mission:id,title,slug,category,status,points')
                ->where('user_id', $user->id)
                ->where('status', UserMission::STATUS_IN_PROGRESS)
                ->orderByDesc('updated_at')
                ->limit(3)
                ->get()
                ->filter(fn (UserMission $um) => $um->mission !== null && $um->mission->trashed() === false && $um->mission->isPublished());

            foreach ($pendingMissions as $um) {
                $reminders[] = [
                    'type' => 'pending_mission',
                    'title' => 'Misi Siaga Belum Selesai: '.$um->mission->title,
                    'message' => 'Selesaikan Misi Siaga ini bersama keluarga untuk meraih +'.$um->mission->points.' poin.',
                    'target_type' => 'mission',
                    'target_slug' => $um->mission->slug,
                    'category' => $um->mission->category,
                    'progress_percent' => 50,
                ];
            }
        }

        // Simulation drafts unfinished
        $drafts = SimulationDraft::query()
            ->with('simulation:id,title,slug,category,status')
            ->where('user_id', $user->id)
            ->orderByDesc('updated_at')
            ->limit(2)
            ->get()
            ->filter(fn (SimulationDraft $d) => $d->simulation !== null && $d->simulation->trashed() === false && $d->simulation->isPublished());

        foreach ($drafts as $draft) {
            $reminders[] = [
                'type' => 'unfinished_simulation',
                'title' => 'Lanjutkan Simulasi: '.$draft->simulation->title,
                'message' => 'Simulasi daruratmu sempat tersimpan di langkah '.($draft->current_step_index + 1).'. Lanjutkan sampai selesai!',
                'target_type' => 'simulation',
                'target_slug' => $draft->simulation->slug,
                'category' => $draft->simulation->category,
                'progress_percent' => 50,
            ];
        }

        if ($remindInactive && count($reminders) === 0) {
            $lastActivity = LearningActivityLog::query()
                ->where('user_id', $user->id)
                ->latest('created_at')
                ->first();

            $completedCount = LearningProgress::query()
                ->where('user_id', $user->id)
                ->where('is_completed', true)
                ->count();
            $totalPublished = LearningMaterial::query()
                ->where('status', LearningMaterial::STATUS_PUBLISHED)
                ->count();

            if ($completedCount < $totalPublished && ($lastActivity === null || $lastActivity->created_at->lt(now()->subHours(24)))) {
                $nextMaterial = LearningMaterial::query()
                    ->where('status', LearningMaterial::STATUS_PUBLISHED)
                    ->whereNotIn('id', LearningProgress::query()->where('user_id', $user->id)->where('is_completed', true)->pluck('learning_material_id'))
                    ->orderBy('sort_order')
                    ->first();

                if ($nextMaterial !== null) {
                    $reminders[] = [
                        'type' => 'continue_learning',
                        'title' => 'Waktunya Melanjutkan Belajar Kesiapsiagaan',
                        'message' => 'Rekomendasi berikutnya: "'.$nextMaterial->title.'" ('.$nextMaterial->category.').',
                        'target_type' => 'material',
                        'target_slug' => $nextMaterial->slug,
                        'category' => $nextMaterial->category,
                        'progress_percent' => 0,
                    ];
                }
            }
        }

        return $reminders;
    }

    /**
     * Build comprehensive learning progress & achievements payload for the given user.
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
            return $this->buildGuestProgressPayload(
                $totalMaterials,
                $totalEqMaterials,
                $totalTsMaterials,
                $totalSimulations,
                $totalQuizzes,
                $totalMissions,
                $allBadges
            );
        }

        $this->evaluateAndAwardBadges($user);

        $allProgressRecords = LearningProgress::query()
            ->with(['material' => fn ($q) => $q->withTrashed()->select(['id', 'title', 'slug', 'category', 'difficulty', 'status', 'deleted_at'])])
            ->where('user_id', $user->id)
            ->orderByDesc('last_read_at')
            ->orderByDesc('updated_at')
            ->get();

        $completedRecords = $allProgressRecords->where('is_completed', true);
        $inProgressRecords = $allProgressRecords
            ->where('is_completed', false)
            ->filter(fn (LearningProgress $lp) => $lp->progress_percent > 0 && $lp->material !== null && ! $lp->material->trashed());
        $favoriteRecords = $allProgressRecords->where('is_favorite', true);

        $completedMaterialIds = $completedRecords->pluck('learning_material_id')->all();
        $favoriteMaterialIds = $favoriteRecords->pluck('learning_material_id')->all();

        $completedMaterialsCount = $completedRecords->count();
        $eqMaterialsCompleted = $completedRecords
            ->filter(fn (LearningProgress $lp) => $lp->material?->category === LearningMaterial::CATEGORY_EARTHQUAKE)
            ->count();
        $tsMaterialsCompleted = $completedRecords
            ->filter(fn (LearningProgress $lp) => $lp->material?->category === LearningMaterial::CATEGORY_TSUNAMI)
            ->count();

        $eqPercent = $totalEqMaterials > 0 ? (int) min(100, round(($eqMaterialsCompleted / $totalEqMaterials) * 100)) : 0;
        $tsPercent = $totalTsMaterials > 0 ? (int) min(100, round(($tsMaterialsCompleted / $totalTsMaterials) * 100)) : 0;

        $lastReadRecord = $allProgressRecords
            ->filter(fn (LearningProgress $lp) => $lp->material !== null && ! $lp->material->trashed() && $lp->material->isPublished())
            ->first();

        $simResults = SimulationResult::query()
            ->with(['simulation' => fn ($q) => $q->withTrashed()->select(['id', 'title', 'slug', 'category', 'difficulty'])])
            ->where('user_id', $user->id)
            ->orderByDesc('completed_at')
            ->orderByDesc('id')
            ->get();

        $completedSimulationIds = $simResults->pluck('simulation_id')->unique();
        $completedSimulationsCount = $completedSimulationIds->count();

        $simDrafts = SimulationDraft::query()
            ->with(['simulation' => fn ($q) => $q->withTrashed()->select(['id', 'title', 'slug', 'category', 'difficulty'])])
            ->where('user_id', $user->id)
            ->orderByDesc('updated_at')
            ->get();

        $quizResults = QuizResult::query()
            ->with(['quiz' => fn ($q) => $q->withTrashed()->select(['id', 'title', 'slug', 'category', 'topic', 'difficulty'])])
            ->where('user_id', $user->id)
            ->orderByDesc('completed_at')
            ->orderByDesc('id')
            ->get();

        $completedQuizIds = $quizResults->pluck('quiz_id')->unique();
        $completedQuizzesCount = $completedQuizIds->count();

        $userMissions = UserMission::query()
            ->with(['mission' => fn ($q) => $q->withTrashed()->select(['id', 'title', 'slug', 'category', 'difficulty', 'points'])])
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

        // Backend-validated non-duplicating point computation:
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
        $level = $this->computeLevel($totalPoints);

        $totalUnits = $totalMaterials + $totalSimulations + $totalQuizzes + $totalMissions;
        $completedUnits = min($totalMaterials, $completedMaterialsCount)
            + min($totalSimulations, $completedSimulationsCount)
            + min($totalQuizzes, $completedQuizzesCount)
            + min($totalMissions, $completedMissionsCount);

        $overallPercentage = $totalUnits > 0
            ? (int) round(($completedUnits / $totalUnits) * 100)
            : 0;

        $hasActivity = $completedUnits > 0 || $inProgressMissionsCount > 0 || $inProgressRecords->isNotEmpty() || $simDrafts->isNotEmpty();

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

        $overallQuizAvg = $quizResults->isNotEmpty() ? (int) round((float) $quizResults->avg('final_score')) : 0;
        $overallQuizBest = $quizResults->isNotEmpty() ? (int) $quizResults->max('final_score') : 0;
        $overallQuizLatest = $quizResults->isNotEmpty() ? (int) $quizResults->first()->final_score : null;

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

        $recentLogs = LearningActivityLog::query()
            ->where('user_id', $user->id)
            ->orderByDesc('created_at')
            ->orderByDesc('id')
            ->limit(25)
            ->get()
            ->map(fn (LearningActivityLog $log) => [
                'id' => $log->id,
                'activity_type' => $log->activity_type,
                'type_label' => $log->typeLabel(),
                'subject_type' => $log->subject_type,
                'subject_id' => $log->subject_id,
                'subject_title' => $log->subject_title,
                'category' => $log->category,
                'points_earned' => $log->points_earned,
                'metadata' => $log->metadata,
                'created_at' => $log->created_at?->toIso8601String(),
            ])
            ->values()
            ->all();

        $activityChart = $this->buildUser7DayActivityChart($user);
        $reminderPreference = $this->serializeReminderPreference($user);
        $pendingReminders = $this->buildPendingReminders($user);

        $initMessage = $hasActivity
            ? 'Terus tingkatkan kesiapsiagaanmu dengan menuntaskan materi, simulasi, kuis, dan Misi Siaga.'
            : 'Belum ada aktivitas pembelajaran. Mulai pelajari materi Gempa Bumi atau Tsunami pertamamu hari ini!';

        return [
            'authenticated' => true,
            'user_id' => $user->id,
            'has_activity' => $hasActivity,
            'initial_message' => $initMessage,
            'initial_state_message' => $initMessage,
            'overall_percentage' => $overallPercentage,
            'overall_progress_percentage' => $overallPercentage,
            'total_points' => $totalPoints,
            'level' => $level,
            'materials' => [
                'completed' => $completedMaterialsCount,
                'total' => $totalMaterials,
                'completed_count' => $completedMaterialsCount,
                'total_count' => $totalMaterials,
                'earthquake_completed' => $eqMaterialsCompleted,
                'earthquake_total' => $totalEqMaterials,
                'earthquake_percentage' => $eqPercent,
                'tsunami_completed' => $tsMaterialsCompleted,
                'tsunami_total' => $totalTsMaterials,
                'tsunami_percentage' => $tsPercent,
                'in_progress_count' => $inProgressRecords->count(),
                'favorites_count' => $favoriteRecords->count(),
                'completed_ids' => array_values($completedMaterialIds),
                'favorite_ids' => array_values($favoriteMaterialIds),
                'in_progress_items' => $inProgressRecords->map(fn (LearningProgress $lp) => [
                    'material_id' => $lp->learning_material_id,
                    'title' => $lp->material?->title ?? 'Materi Edukasi',
                    'slug' => $lp->material?->slug,
                    'category' => $lp->material?->category,
                    'progress_percent' => (int) $lp->progress_percent,
                    'last_position' => (int) $lp->last_position,
                    'last_section' => $lp->last_section,
                    'last_read_at' => $lp->last_read_at?->toIso8601String(),
                ])->values()->all(),
                'last_read_material' => $lastReadRecord !== null ? [
                    'material_id' => $lastReadRecord->learning_material_id,
                    'title' => $lastReadRecord->material?->title,
                    'slug' => $lastReadRecord->material?->slug,
                    'category' => $lastReadRecord->material?->category,
                    'is_completed' => (bool) $lastReadRecord->is_completed,
                    'progress_percent' => (int) $lastReadRecord->progress_percent,
                    'last_position' => (int) $lastReadRecord->last_position,
                    'last_section' => $lastReadRecord->last_section,
                    'last_read_at' => $lastReadRecord->last_read_at?->toIso8601String(),
                ] : null,
            ],
            'simulations' => [
                'completed' => $completedSimulationsCount,
                'total' => $totalSimulations,
                'completed_count' => $completedSimulationsCount,
                'total_count' => $totalSimulations,
                'in_progress_drafts' => $simDrafts->map(fn (SimulationDraft $d) => [
                    'simulation_id' => $d->simulation_id,
                    'simulation_title' => $d->simulation?->title ?? 'Simulasi Bencana',
                    'simulation_slug' => $d->simulation?->slug,
                    'category' => $d->simulation?->category,
                    'current_step_index' => $d->current_step_index,
                    'selected_choices' => $d->selected_choices ?? [],
                    'updated_at' => $d->updated_at?->toIso8601String(),
                ])->values()->all(),
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
                'average_score' => $overallQuizAvg,
                'best_score' => $overallQuizBest,
                'latest_score' => $overallQuizLatest,
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
            'recent_activities' => $recentLogs,
            'activity_chart' => $activityChart,
            'reminder_preference' => $reminderPreference,
            'pending_reminders' => $pendingReminders,
        ];
    }

    /**
     * Build overview and deep analytics of user progress across the system for Admin/Petugas.
     *
     * @return array<string, mixed>
     */
    public function buildAdminAnalytics(): array
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

        // Distinct users who have used Edukasi Bencana
        $eduUserIds = collect()
            ->merge(LearningProgress::query()->distinct()->pluck('user_id'))
            ->merge(SimulationResult::query()->distinct()->pluck('user_id'))
            ->merge(QuizResult::query()->distinct()->pluck('user_id'))
            ->merge(UserMission::query()->distinct()->pluck('user_id'))
            ->merge(LearningActivityLog::query()->distinct()->pluck('user_id'))
            ->unique();

        $active7d = LearningActivityLog::query()
            ->where('created_at', '>=', now()->subDays(7))
            ->distinct('user_id')
            ->count('user_id');

        $active30d = LearningActivityLog::query()
            ->where('created_at', '>=', now()->subDays(30))
            ->distinct('user_id')
            ->count('user_id');

        $avgQuizScore = (float) (QuizResult::query()->avg('final_score') ?? 0);

        // Quiz score distribution buckets
        $allQuizScores = QuizResult::query()->pluck('final_score');
        $quizDistribution = [
            ['label' => '0–49 (Perlu Belajar Lagi)', 'count' => $allQuizScores->filter(fn ($s) => $s < 50)->count()],
            ['label' => '50–69 (Cukup)', 'count' => $allQuizScores->filter(fn ($s) => $s >= 50 && $s < 70)->count()],
            ['label' => '70–84 (Baik)', 'count' => $allQuizScores->filter(fn ($s) => $s >= 70 && $s < 85)->count()],
            ['label' => '85–100 (Sangat Siaga)', 'count' => $allQuizScores->filter(fn ($s) => $s >= 85)->count()],
        ];

        // Materials popularity, least studied, and abandoned
        $publishedMaterials = LearningMaterial::query()
            ->where('status', LearningMaterial::STATUS_PUBLISHED)
            ->withCount([
                'progressRecords as completed_count' => fn ($q) => $q->where('is_completed', true),
                'progressRecords as abandoned_count' => fn ($q) => $q->where('is_completed', false)->where('progress_percent', '>', 0),
                'progressRecords as total_readers_count',
            ])
            ->get(['id', 'title', 'slug', 'category', 'difficulty']);

        $popularMaterials = $publishedMaterials
            ->sortByDesc(fn (LearningMaterial $m) => ($m->completed_count * 10) + $m->total_readers_count)
            ->take(5)
            ->map(fn (LearningMaterial $m) => [
                'id' => $m->id,
                'title' => $m->title,
                'category' => $m->category,
                'difficulty' => $m->difficulty,
                'completed_count' => (int) $m->completed_count,
                'total_readers_count' => (int) $m->total_readers_count,
            ])
            ->values()
            ->all();

        $leastStudiedMaterials = $publishedMaterials
            ->sortBy(fn (LearningMaterial $m) => ($m->completed_count * 10) + $m->total_readers_count)
            ->take(5)
            ->map(fn (LearningMaterial $m) => [
                'id' => $m->id,
                'title' => $m->title,
                'category' => $m->category,
                'difficulty' => $m->difficulty,
                'completed_count' => (int) $m->completed_count,
                'total_readers_count' => (int) $m->total_readers_count,
            ])
            ->values()
            ->all();

        $abandonedMaterials = $publishedMaterials
            ->filter(fn (LearningMaterial $m) => $m->abandoned_count > 0)
            ->sortByDesc('abandoned_count')
            ->take(5)
            ->map(fn (LearningMaterial $m) => [
                'id' => $m->id,
                'title' => $m->title,
                'category' => $m->category,
                'abandoned_count' => (int) $m->abandoned_count,
                'completed_count' => (int) $m->completed_count,
            ])
            ->values()
            ->all();

        // Popular simulations & completion rate
        $popularSimulations = Simulation::query()
            ->where('status', Simulation::STATUS_PUBLISHED)
            ->withCount('results as attempts_count')
            ->withAvg('results as avg_score', 'score')
            ->orderByDesc('attempts_count')
            ->limit(5)
            ->get(['id', 'title', 'category', 'difficulty'])
            ->map(fn (Simulation $s) => [
                'id' => $s->id,
                'title' => $s->title,
                'category' => $s->category,
                'difficulty' => $s->difficulty,
                'attempts_count' => (int) $s->attempts_count,
                'average_score' => round((float) ($s->avg_score ?? 0), 1),
            ])
            ->values()
            ->all();

        $completedSimPairs = SimulationResult::query()
            ->select(['user_id', 'simulation_id'])
            ->distinct()
            ->get()
            ->map(fn ($r) => $r->user_id.':'.$r->simulation_id);
        $draftSimPairs = SimulationDraft::query()
            ->select(['user_id', 'simulation_id'])
            ->get()
            ->map(fn ($d) => $d->user_id.':'.$d->simulation_id);
        $totalStartedSimPairs = $completedSimPairs->merge($draftSimPairs)->unique()->count();
        $simCompletionRate = $totalStartedSimPairs > 0
            ? round(($completedSimPairs->count() / $totalStartedSimPairs) * 100, 1)
            : 0.0;

        $startedMissions = UserMission::query()
            ->whereIn('status', [UserMission::STATUS_IN_PROGRESS, UserMission::STATUS_COMPLETED])
            ->count();
        $completedMissionsTotal = UserMission::query()
            ->where('status', UserMission::STATUS_COMPLETED)
            ->count();
        $missionCompletionRate = $startedMissions > 0
            ? round(($completedMissionsTotal / $startedMissions) * 100, 1)
            : 0.0;

        // 14-day activity trend
        $timeline14d = [];
        $startDate = now()->subDays(13)->startOfDay();
        $rawDailyLogs = LearningActivityLog::query()
            ->where('created_at', '>=', $startDate)
            ->get(['created_at'])
            ->groupBy(fn (LearningActivityLog $l) => $l->created_at->format('Y-m-d'));

        for ($i = 13; $i >= 0; $i--) {
            $day = now()->subDays($i);
            $key = $day->format('Y-m-d');
            $timeline14d[] = [
                'date' => $key,
                'label' => $day->format('d/m'),
                'count' => isset($rawDailyLogs[$key]) ? $rawDailyLogs[$key]->count() : 0,
            ];
        }

        return [
            'summary' => [
                'total_users' => User::count(),
                'total_education_users' => $eduUserIds->count(),
                'active_users_7d' => $active7d,
                'active_users_30d' => $active30d,
                'total_material_completions' => LearningProgress::where('is_completed', true)->count(),
                'total_simulation_attempts' => SimulationResult::count(),
                'simulation_completion_rate' => $simCompletionRate,
                'total_quiz_attempts' => QuizResult::count(),
                'average_quiz_score' => round($avgQuizScore, 1),
                'total_completed_missions' => $completedMissionsTotal,
                'mission_completion_rate' => $missionCompletionRate,
                'total_awarded_badges' => UserBadge::count(),
            ],
            'quiz_score_distribution' => $quizDistribution,
            'popular_materials' => $popularMaterials,
            'least_studied_materials' => $leastStudiedMaterials,
            'abandoned_materials' => $abandonedMaterials,
            'popular_simulations' => $popularSimulations,
            'activity_timeline_14d' => $timeline14d,
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

    /**
     * Backward-compatible alias for buildAdminAnalytics().
     *
     * @return array<string, mixed>
     */
    public function buildAdminProgressOverview(): array
    {
        return $this->buildAdminAnalytics();
    }

    /**
     * @return list<array{date: string, label: string, count: int}>
     */
    private function buildUser7DayActivityChart(User $user): array
    {
        $start = now()->subDays(6)->startOfDay();
        $logs = LearningActivityLog::query()
            ->where('user_id', $user->id)
            ->where('created_at', '>=', $start)
            ->get(['created_at'])
            ->groupBy(fn (LearningActivityLog $log) => $log->created_at->format('Y-m-d'));

        $days = [];
        for ($i = 6; $i >= 0; $i--) {
            /** @var Carbon $day */
            $day = now()->subDays($i);
            $key = $day->format('Y-m-d');
            $days[] = [
                'date' => $key,
                'label' => $day->format('d/m'),
                'count' => isset($logs[$key]) ? $logs[$key]->count() : 0,
            ];
        }

        return $days;
    }

    /**
     * @param  Collection<int, Badge>  $allBadges
     * @return array<string, mixed>
     */
    private function buildGuestProgressPayload(
        int $totalMaterials,
        int $totalEqMaterials,
        int $totalTsMaterials,
        int $totalSimulations,
        int $totalQuizzes,
        int $totalMissions,
        Collection $allBadges
    ): array {
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

        $msg = 'Silakan masuk ke akun SiagaBencana untuk mengakses Edukasi Bencana dan menyimpan progres pembelajaran.';

        return [
            'authenticated' => false,
            'has_activity' => false,
            'initial_message' => $msg,
            'initial_state_message' => $msg,
            'overall_percentage' => 0,
            'overall_progress_percentage' => 0,
            'total_points' => 0,
            'level' => $this->computeLevel(0),
            'materials' => [
                'completed' => 0,
                'total' => $totalMaterials,
                'completed_count' => 0,
                'total_count' => $totalMaterials,
                'earthquake_completed' => 0,
                'earthquake_total' => $totalEqMaterials,
                'earthquake_percentage' => 0,
                'tsunami_completed' => 0,
                'tsunami_total' => $totalTsMaterials,
                'tsunami_percentage' => 0,
                'in_progress_count' => 0,
                'favorites_count' => 0,
                'completed_ids' => [],
                'favorite_ids' => [],
                'in_progress_items' => [],
                'last_read_material' => null,
            ],
            'simulations' => [
                'completed' => 0,
                'total' => $totalSimulations,
                'completed_count' => 0,
                'total_count' => $totalSimulations,
                'in_progress_drafts' => [],
                'history' => [],
            ],
            'quizzes' => [
                'completed_quizzes' => 0,
                'total_quizzes' => $totalQuizzes,
                'completed_count' => 0,
                'total_count' => $totalQuizzes,
                'average_score' => 0,
                'best_score' => 0,
                'latest_score' => null,
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
            'recent_activities' => [],
            'activity_chart' => [],
            'reminder_preference' => null,
            'pending_reminders' => [],
        ];
    }
}
