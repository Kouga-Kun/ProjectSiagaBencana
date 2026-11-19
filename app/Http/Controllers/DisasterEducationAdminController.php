<?php

namespace App\Http\Controllers;

use App\Models\Badge;
use App\Models\LearningCategory;
use App\Models\LearningMaterial;
use App\Models\Mission;
use App\Models\Quiz;
use App\Models\QuizOption;
use App\Models\QuizQuestion;
use App\Models\Simulation;
use App\Models\SimulationChoice;
use App\Models\SimulationStep;
use App\Services\EducationProgressService;
use Database\Seeders\DisasterEducationSeeder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;
use Illuminate\View\View;

class DisasterEducationAdminController extends Controller
{
    public function __construct(public EducationProgressService $progressService) {}

    public function adminOverviewJson(): JsonResponse
    {
        DisasterEducationSeeder::ensureSeeded();

        return response()->json([
            'materials_total' => LearningMaterial::count(),
            'materials_published' => LearningMaterial::where('status', LearningMaterial::STATUS_PUBLISHED)->count(),
            'simulations_total' => Simulation::count(),
            'simulations_published' => Simulation::where('status', Simulation::STATUS_PUBLISHED)->count(),
            'quizzes_total' => Quiz::count(),
            'quizzes_published' => Quiz::where('status', Quiz::STATUS_PUBLISHED)->count(),
            'missions_total' => Mission::count(),
            'missions_published' => Mission::where('status', Mission::STATUS_PUBLISHED)->count(),
            'progress_overview' => $this->progressService->buildAdminProgressOverview(),
        ]);
    }

    public function adminMaterialsIndexJson(Request $request): JsonResponse
    {
        DisasterEducationSeeder::ensureSeeded();

        $query = LearningMaterial::query();
        if ($request->filled('category')) {
            $query->where('category', (string) $request->query('category'));
        }
        if ($request->filled('status')) {
            $query->where('status', (string) $request->query('status'));
        }
        if ($request->filled('search')) {
            $kw = trim((string) $request->query('search'));
            $query->where(function ($q) use ($kw) {
                $q->where('title', 'like', '%'.$kw.'%')
                    ->orWhere('summary', 'like', '%'.$kw.'%');
            });
        }

        $items = $query
            ->orderBy('category')
            ->orderBy('sort_order')
            ->orderByDesc('id')
            ->get()
            ->map(fn (LearningMaterial $item) => DisasterEducationApiController::serializeMaterial($item, false))
            ->values();

        return response()->json([
            'data' => $items,
            'categories' => LearningMaterial::CATEGORIES,
            'difficulties' => LearningMaterial::DIFFICULTIES,
        ]);
    }

    public function storeMaterialJson(Request $request): JsonResponse
    {
        $validated = $this->validateMaterialPayload($request);
        $material = $this->persistMaterial($request, $validated);

        return response()->json([
            'message' => 'Materi edukasi "'.$material->title.'" berhasil ditambahkan.',
            'data' => DisasterEducationApiController::serializeMaterial($material),
        ], 201);
    }

    public function updateMaterialJson(Request $request, LearningMaterial $learningMaterial): JsonResponse
    {
        $validated = $this->validateMaterialPayload($request);
        $material = $this->persistMaterial($request, $validated, $learningMaterial);

        return response()->json([
            'message' => 'Materi edukasi "'.$material->title.'" berhasil diperbarui.',
            'data' => DisasterEducationApiController::serializeMaterial($material),
        ]);
    }

    public function togglePublishMaterialJson(Request $request, LearningMaterial $learningMaterial): JsonResponse
    {
        $targetStatus = $request->filled('status')
            ? (string) $request->input('status')
            : ($learningMaterial->isPublished() ? LearningMaterial::STATUS_DRAFT : LearningMaterial::STATUS_PUBLISHED);

        if (! in_array($targetStatus, LearningMaterial::STATUSES, true)) {
            $targetStatus = LearningMaterial::STATUS_PUBLISHED;
        }

        $learningMaterial->update([
            'status' => $targetStatus,
            'updated_by' => $request->user()?->id,
        ]);

        return response()->json([
            'message' => $learningMaterial->isPublished()
                ? 'Materi "'.$learningMaterial->title.'" berhasil dipublikasikan.'
                : 'Materi "'.$learningMaterial->title.'" disimpan sebagai draft.',
            'data' => DisasterEducationApiController::serializeMaterial($learningMaterial->fresh()),
        ]);
    }

    public function destroyMaterialJson(LearningMaterial $learningMaterial): JsonResponse
    {
        $title = $learningMaterial->title;
        $learningMaterial->delete();

        return response()->json([
            'message' => 'Materi edukasi "'.$title.'" berhasil diarsipkan (riwayat belajar pengguna tetap terjaga).',
        ]);
    }

    public function adminSimulationsIndexJson(): JsonResponse
    {
        DisasterEducationSeeder::ensureSeeded();

        $simulations = Simulation::query()
            ->with(['steps.choices'])
            ->orderBy('category')
            ->orderBy('sort_order')
            ->orderByDesc('id')
            ->get()
            ->map(fn (Simulation $sim) => DisasterEducationApiController::serializeSimulation($sim))
            ->values();

        return response()->json([
            'data' => $simulations,
        ]);
    }

    public function storeSimulationJson(Request $request): JsonResponse
    {
        $validated = $this->validateSimulationPayload($request);
        $simulation = $this->persistSimulation($validated);

        return response()->json([
            'message' => 'Simulasi "'.$simulation->title.'" berhasil ditambahkan.',
            'data' => DisasterEducationApiController::serializeSimulation($simulation->load(['steps.choices'])),
        ], 201);
    }

    public function updateSimulationJson(Request $request, Simulation $simulation): JsonResponse
    {
        $validated = $this->validateSimulationPayload($request);
        $simulation = $this->persistSimulation($validated, $simulation);

        return response()->json([
            'message' => 'Simulasi "'.$simulation->title.'" berhasil diperbarui.',
            'data' => DisasterEducationApiController::serializeSimulation($simulation->load(['steps.choices'])),
        ]);
    }

    public function togglePublishSimulationJson(Request $request, Simulation $simulation): JsonResponse
    {
        $targetStatus = $request->filled('status')
            ? (string) $request->input('status')
            : ($simulation->isPublished() ? Simulation::STATUS_DRAFT : Simulation::STATUS_PUBLISHED);

        if (! in_array($targetStatus, Simulation::STATUSES, true)) {
            $targetStatus = Simulation::STATUS_PUBLISHED;
        }

        $simulation->update(['status' => $targetStatus]);

        return response()->json([
            'message' => $simulation->isPublished()
                ? 'Simulasi "'.$simulation->title.'" berhasil dipublikasikan.'
                : 'Simulasi "'.$simulation->title.'" disimpan sebagai draft.',
            'data' => DisasterEducationApiController::serializeSimulation($simulation->load(['steps.choices'])),
        ]);
    }

    public function destroySimulationJson(Simulation $simulation): JsonResponse
    {
        $title = $simulation->title;
        $simulation->delete();

        return response()->json([
            'message' => 'Simulasi "'.$title.'" berhasil dihapus.',
        ]);
    }

    public function adminQuizzesIndexJson(): JsonResponse
    {
        DisasterEducationSeeder::ensureSeeded();

        $quizzes = Quiz::query()
            ->with(['questions.options'])
            ->orderBy('category')
            ->orderBy('sort_order')
            ->orderByDesc('id')
            ->get()
            ->map(fn (Quiz $quiz) => self::serializeQuizAdmin($quiz))
            ->values();

        return response()->json([
            'data' => $quizzes,
        ]);
    }

    public function storeQuizJson(Request $request): JsonResponse
    {
        $validated = $this->validateQuizPayload($request);
        $quiz = $this->persistQuiz($validated);

        return response()->json([
            'message' => 'Kuis "'.$quiz->title.'" berhasil ditambahkan.',
            'data' => self::serializeQuizAdmin($quiz->load(['questions.options'])),
        ], 201);
    }

    public function updateQuizJson(Request $request, Quiz $quiz): JsonResponse
    {
        $validated = $this->validateQuizPayload($request);
        $quiz = $this->persistQuiz($validated, $quiz);

        return response()->json([
            'message' => 'Kuis "'.$quiz->title.'" berhasil diperbarui.',
            'data' => self::serializeQuizAdmin($quiz->load(['questions.options'])),
        ]);
    }

    public function togglePublishQuizJson(Request $request, Quiz $quiz): JsonResponse
    {
        $targetStatus = $request->filled('status')
            ? (string) $request->input('status')
            : ($quiz->isPublished() ? Quiz::STATUS_DRAFT : Quiz::STATUS_PUBLISHED);

        if (! in_array($targetStatus, Quiz::STATUSES, true)) {
            $targetStatus = Quiz::STATUS_PUBLISHED;
        }

        $quiz->update(['status' => $targetStatus]);

        return response()->json([
            'message' => $quiz->isPublished()
                ? 'Kuis "'.$quiz->title.'" berhasil dipublikasikan.'
                : 'Kuis "'.$quiz->title.'" disimpan sebagai draft.',
            'data' => self::serializeQuizAdmin($quiz->load(['questions.options'])),
        ]);
    }

    public function destroyQuizJson(Quiz $quiz): JsonResponse
    {
        $title = $quiz->title;
        $quiz->delete();

        return response()->json([
            'message' => 'Kuis "'.$title.'" berhasil dihapus.',
        ]);
    }

    public function adminMissionsIndexJson(): JsonResponse
    {
        DisasterEducationSeeder::ensureSeeded();

        $missions = Mission::query()
            ->orderBy('category')
            ->orderBy('sort_order')
            ->orderByDesc('id')
            ->get()
            ->map(fn (Mission $mission) => DisasterEducationApiController::serializeMission($mission))
            ->values();

        return response()->json([
            'data' => $missions,
        ]);
    }

    public function storeMissionJson(Request $request): JsonResponse
    {
        $validated = $this->validateMissionPayload($request);
        $mission = $this->persistMission($validated);

        return response()->json([
            'message' => 'Misi Siaga "'.$mission->title.'" berhasil ditambahkan.',
            'data' => DisasterEducationApiController::serializeMission($mission),
        ], 201);
    }

    public function updateMissionJson(Request $request, Mission $mission): JsonResponse
    {
        $validated = $this->validateMissionPayload($request);
        $mission = $this->persistMission($validated, $mission);

        return response()->json([
            'message' => 'Misi Siaga "'.$mission->title.'" berhasil diperbarui.',
            'data' => DisasterEducationApiController::serializeMission($mission),
        ]);
    }

    public function togglePublishMissionJson(Request $request, Mission $mission): JsonResponse
    {
        $targetStatus = $request->filled('status')
            ? (string) $request->input('status')
            : ($mission->isPublished() ? Mission::STATUS_DRAFT : Mission::STATUS_PUBLISHED);

        if (! in_array($targetStatus, Mission::STATUSES, true)) {
            $targetStatus = Mission::STATUS_PUBLISHED;
        }

        $mission->update(['status' => $targetStatus]);

        return response()->json([
            'message' => $mission->isPublished()
                ? 'Misi Siaga "'.$mission->title.'" berhasil dipublikasikan.'
                : 'Misi Siaga "'.$mission->title.'" disimpan sebagai draft.',
            'data' => DisasterEducationApiController::serializeMission($mission->fresh()),
        ]);
    }

    public function destroyMissionJson(Mission $mission): JsonResponse
    {
        $title = $mission->title;
        $mission->delete();

        return response()->json([
            'message' => 'Misi Siaga "'.$title.'" berhasil dihapus.',
        ]);
    }

    public function adminProgressOverviewJson(): JsonResponse
    {
        DisasterEducationSeeder::ensureSeeded();

        return response()->json([
            'data' => $this->progressService->buildAdminAnalytics(),
        ]);
    }

    public function adminAnalyticsJson(): JsonResponse
    {
        DisasterEducationSeeder::ensureSeeded();

        return response()->json([
            'data' => $this->progressService->buildAdminAnalytics(),
        ]);
    }

    public function adminBadgesIndexJson(): JsonResponse
    {
        DisasterEducationSeeder::ensureSeeded();

        $badges = Badge::query()
            ->withCount('userBadges as awarded_users_count')
            ->orderBy('id')
            ->get()
            ->map(fn (Badge $b) => [
                'id' => $b->id,
                'code' => $b->code,
                'name' => $b->name,
                'description' => $b->description,
                'criteria_description' => $b->criteria_description,
                'icon' => $b->icon,
                'category' => $b->category,
                'points_reward' => (int) $b->points_reward,
                'awarded_users_count' => (int) $b->awarded_users_count,
            ])
            ->values();

        return response()->json(['data' => $badges]);
    }

    public function updateBadgeJson(Request $request, Badge $badge): JsonResponse
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:120'],
            'description' => ['required', 'string', 'max:500'],
            'criteria_description' => ['required', 'string', 'max:300'],
            'points_reward' => ['required', 'integer', 'min:0', 'max:1000'],
        ]);

        $badge->update($validated);

        return response()->json([
            'message' => 'Badge "'.$badge->name.'" berhasil diperbarui.',
            'data' => $badge->fresh(),
        ]);
    }

    // =========================================================================
    // Web Admin Dashboard & Actions (/petugas/edukasi)
    // =========================================================================

    public function adminDashboard(Request $request): View
    {
        DisasterEducationSeeder::ensureSeeded();

        $activeTab = (string) $request->query('tab', 'analitik');
        if (! in_array($activeTab, ['analitik', 'materi', 'simulasi', 'kuis', 'misi', 'badge', 'progres'], true)) {
            $activeTab = 'analitik';
        }

        $materials = LearningMaterial::query()
            ->orderBy('category')
            ->orderBy('sort_order')
            ->orderByDesc('id')
            ->get();

        $simulations = Simulation::query()
            ->with(['steps.choices'])
            ->orderBy('category')
            ->orderBy('sort_order')
            ->orderByDesc('id')
            ->get();

        $quizzes = Quiz::query()
            ->with(['questions.options'])
            ->orderBy('category')
            ->orderBy('sort_order')
            ->orderByDesc('id')
            ->get();

        $missions = Mission::query()
            ->orderBy('category')
            ->orderBy('sort_order')
            ->orderByDesc('id')
            ->get();

        $badges = Badge::query()
            ->withCount('userBadges as awarded_users_count')
            ->orderBy('id')
            ->get();

        $progressOverview = $this->progressService->buildAdminAnalytics();

        $editingMaterial = $request->filled('edit_materi')
            ? LearningMaterial::find((int) $request->query('edit_materi'))
            : null;
        $editingSimulation = $request->filled('edit_simulasi')
            ? Simulation::with(['steps.choices'])->find((int) $request->query('edit_simulasi'))
            : null;
        $editingQuiz = $request->filled('edit_kuis')
            ? Quiz::with(['questions.options'])->find((int) $request->query('edit_kuis'))
            : null;
        $editingMission = $request->filled('edit_misi')
            ? Mission::find((int) $request->query('edit_misi'))
            : null;
        $editingBadge = $request->filled('edit_badge')
            ? Badge::find((int) $request->query('edit_badge'))
            : null;

        return view('petugas.edukasi', [
            'activeTab' => $activeTab,
            'materials' => $materials,
            'simulations' => $simulations,
            'quizzes' => $quizzes,
            'missions' => $missions,
            'badges' => $badges,
            'progressOverview' => $progressOverview,
            'editingMaterial' => $editingMaterial,
            'editingSimulation' => $editingSimulation,
            'editingQuiz' => $editingQuiz,
            'editingMission' => $editingMission,
            'editingBadge' => $editingBadge,
            'categories' => LearningMaterial::CATEGORIES,
            'difficulties' => LearningMaterial::DIFFICULTIES,
        ]);
    }

    public function updateBadgeWeb(Request $request, Badge $badge): RedirectResponse
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:120'],
            'description' => ['required', 'string', 'max:500'],
            'criteria_description' => ['required', 'string', 'max:300'],
            'points_reward' => ['required', 'integer', 'min:0', 'max:1000'],
        ]);

        $badge->update($validated);

        return redirect()
            ->route('petugas.edukasi.index', ['tab' => 'badge'])
            ->with('status', 'Badge "'.$badge->name.'" berhasil diperbarui.');
    }

    public function storeMaterialWeb(Request $request): RedirectResponse
    {
        $validated = $this->validateMaterialPayload($request);
        $material = $this->persistMaterial($request, $validated);

        return redirect()
            ->route('petugas.edukasi.index', ['tab' => 'materi'])
            ->with('status', 'Materi "'.$material->title.'" berhasil ditambahkan.');
    }

    public function updateMaterialWeb(Request $request, LearningMaterial $learningMaterial): RedirectResponse
    {
        $validated = $this->validateMaterialPayload($request);
        $material = $this->persistMaterial($request, $validated, $learningMaterial);

        return redirect()
            ->route('petugas.edukasi.index', ['tab' => 'materi'])
            ->with('status', 'Materi "'.$material->title.'" berhasil diperbarui.');
    }

    public function togglePublishMaterialWeb(LearningMaterial $learningMaterial): RedirectResponse
    {
        $target = $learningMaterial->isPublished()
            ? LearningMaterial::STATUS_DRAFT
            : LearningMaterial::STATUS_PUBLISHED;
        $learningMaterial->update(['status' => $target]);

        return redirect()
            ->route('petugas.edukasi.index', ['tab' => 'materi'])
            ->with('status', 'Status publikasi materi "'.$learningMaterial->title.'" diperbarui.');
    }

    public function destroyMaterialWeb(LearningMaterial $learningMaterial): RedirectResponse
    {
        $title = $learningMaterial->title;
        $learningMaterial->delete();

        return redirect()
            ->route('petugas.edukasi.index', ['tab' => 'materi'])
            ->with('status', 'Materi "'.$title.'" berhasil diarsipkan (riwayat belajar pengguna tetap terjaga).');
    }

    public function storeSimulationWeb(Request $request): RedirectResponse
    {
        $validated = $this->validateSimulationPayload($request);
        $simulation = $this->persistSimulation($validated);

        return redirect()
            ->route('petugas.edukasi.index', ['tab' => 'simulasi'])
            ->with('status', 'Simulasi "'.$simulation->title.'" berhasil ditambahkan.');
    }

    public function updateSimulationWeb(Request $request, Simulation $simulation): RedirectResponse
    {
        $validated = $this->validateSimulationPayload($request);
        $simulation = $this->persistSimulation($validated, $simulation);

        return redirect()
            ->route('petugas.edukasi.index', ['tab' => 'simulasi'])
            ->with('status', 'Simulasi "'.$simulation->title.'" berhasil diperbarui.');
    }

    public function togglePublishSimulationWeb(Simulation $simulation): RedirectResponse
    {
        $target = $simulation->isPublished()
            ? Simulation::STATUS_DRAFT
            : Simulation::STATUS_PUBLISHED;
        $simulation->update(['status' => $target]);

        return redirect()
            ->route('petugas.edukasi.index', ['tab' => 'simulasi'])
            ->with('status', 'Status publikasi simulasi "'.$simulation->title.'" diperbarui.');
    }

    public function destroySimulationWeb(Simulation $simulation): RedirectResponse
    {
        $title = $simulation->title;
        $simulation->delete();

        return redirect()
            ->route('petugas.edukasi.index', ['tab' => 'simulasi'])
            ->with('status', 'Simulasi "'.$title.'" berhasil dihapus.');
    }

    public function storeQuizWeb(Request $request): RedirectResponse
    {
        $validated = $this->validateQuizPayload($request);
        $quiz = $this->persistQuiz($validated);

        return redirect()
            ->route('petugas.edukasi.index', ['tab' => 'kuis'])
            ->with('status', 'Kuis "'.$quiz->title.'" berhasil ditambahkan.');
    }

    public function updateQuizWeb(Request $request, Quiz $quiz): RedirectResponse
    {
        $validated = $this->validateQuizPayload($request);
        $quiz = $this->persistQuiz($validated, $quiz);

        return redirect()
            ->route('petugas.edukasi.index', ['tab' => 'kuis'])
            ->with('status', 'Kuis "'.$quiz->title.'" berhasil diperbarui.');
    }

    public function togglePublishQuizWeb(Quiz $quiz): RedirectResponse
    {
        $target = $quiz->isPublished()
            ? Quiz::STATUS_DRAFT
            : Quiz::STATUS_PUBLISHED;
        $quiz->update(['status' => $target]);

        return redirect()
            ->route('petugas.edukasi.index', ['tab' => 'kuis'])
            ->with('status', 'Status publikasi kuis "'.$quiz->title.'" diperbarui.');
    }

    public function destroyQuizWeb(Quiz $quiz): RedirectResponse
    {
        $title = $quiz->title;
        $quiz->delete();

        return redirect()
            ->route('petugas.edukasi.index', ['tab' => 'kuis'])
            ->with('status', 'Kuis "'.$title.'" berhasil dihapus.');
    }

    public function storeMissionWeb(Request $request): RedirectResponse
    {
        $validated = $this->validateMissionPayload($request);
        $mission = $this->persistMission($validated);

        return redirect()
            ->route('petugas.edukasi.index', ['tab' => 'misi'])
            ->with('status', 'Misi Siaga "'.$mission->title.'" berhasil ditambahkan.');
    }

    public function updateMissionWeb(Request $request, Mission $mission): RedirectResponse
    {
        $validated = $this->validateMissionPayload($request);
        $mission = $this->persistMission($validated, $mission);

        return redirect()
            ->route('petugas.edukasi.index', ['tab' => 'misi'])
            ->with('status', 'Misi Siaga "'.$mission->title.'" berhasil diperbarui.');
    }

    public function togglePublishMissionWeb(Mission $mission): RedirectResponse
    {
        $target = $mission->isPublished()
            ? Mission::STATUS_DRAFT
            : Mission::STATUS_PUBLISHED;
        $mission->update(['status' => $target]);

        return redirect()
            ->route('petugas.edukasi.index', ['tab' => 'misi'])
            ->with('status', 'Status publikasi misi "'.$mission->title.'" diperbarui.');
    }

    public function destroyMissionWeb(Mission $mission): RedirectResponse
    {
        $title = $mission->title;
        $mission->delete();

        return redirect()
            ->route('petugas.edukasi.index', ['tab' => 'misi'])
            ->with('status', 'Misi Siaga "'.$title.'" berhasil dihapus.');
    }

    /**
     * @return array<string, mixed>
     */
    private function validateMaterialPayload(Request $request): array
    {
        return $request->validate([
            'category' => ['required', Rule::in(LearningMaterial::CATEGORIES)],
            'title' => ['required', 'string', 'max:200'],
            'difficulty' => ['required', Rule::in(LearningMaterial::DIFFICULTIES)],
            'summary' => ['required', 'string', 'max:1000'],
            'content' => ['required', 'string', 'min:20'],
            'key_points' => ['nullable'],
            'action_steps' => ['nullable'],
            'things_to_avoid' => ['nullable'],
            'source_reference' => ['required', 'string', 'max:350'],
            'sort_order' => ['nullable', 'integer', 'min:0'],
            'status' => ['nullable', Rule::in(LearningMaterial::STATUSES)],
            'image' => ['nullable', 'file', 'mimes:jpg,jpeg,png,webp', 'max:4096'],
            'image_path' => ['nullable', 'string', 'max:500'],
        ], [
            'category.required' => 'Kategori materi wajib dipilih (Gempa Bumi atau Tsunami).',
            'category.in' => 'Kategori hanya boleh Gempa Bumi atau Tsunami.',
            'title.required' => 'Judul materi wajib diisi.',
            'difficulty.required' => 'Tingkat kesulitan materi wajib dipilih.',
            'summary.required' => 'Ringkasan materi wajib diisi.',
            'content.required' => 'Penjelasan materi wajib diisi.',
            'source_reference.required' => 'Sumber referensi resmi wajib dicantumkan.',
        ]);
    }

    /**
     * @param  array<string, mixed>  $validated
     */
    private function persistMaterial(Request $request, array $validated, ?LearningMaterial $existing = null): LearningMaterial
    {
        DisasterEducationSeeder::ensureSeeded();

        $categoryName = (string) $validated['category'];
        $categoryModel = LearningCategory::where('name', $categoryName)->first();

        $imagePath = $existing?->image_path ?? ($validated['image_path'] ?? null);
        if ($request->hasFile('image')) {
            if ($existing) {
                $this->deleteStoredImageIfLocal($existing->image_path);
            }
            $imagePath = $request->file('image')->store('edukasi-materials', 'public');
        } elseif (! empty($validated['image_path'])) {
            $imagePath = trim((string) $validated['image_path']);
        }

        $title = trim((string) $validated['title']);
        $slug = $existing && $existing->title === $title
            ? $existing->slug
            : $this->uniqueSlug(LearningMaterial::class, $title, $existing?->id);

        $payload = [
            'learning_category_id' => $categoryModel?->id,
            'category' => $categoryName,
            'title' => $title,
            'slug' => $slug,
            'difficulty' => (string) $validated['difficulty'],
            'image_path' => $imagePath ?: ($categoryName === LearningMaterial::CATEGORY_TSUNAMI ? 'illustrations/tsunami-default.svg' : 'illustrations/gempa-default.svg'),
            'summary' => trim((string) $validated['summary']),
            'content' => trim((string) $validated['content']),
            'key_points' => $this->parseLines($validated['key_points'] ?? ($existing?->key_points ?? [])),
            'action_steps' => $this->parseLines($validated['action_steps'] ?? ($existing?->action_steps ?? [])),
            'things_to_avoid' => $this->parseLines($validated['things_to_avoid'] ?? ($existing?->things_to_avoid ?? [])),
            'source_reference' => trim((string) $validated['source_reference']),
            'sort_order' => isset($validated['sort_order']) ? (int) $validated['sort_order'] : ($existing?->sort_order ?? 99),
            'status' => $validated['status'] ?? ($existing?->status ?? LearningMaterial::STATUS_PUBLISHED),
            'updated_by' => $request->user()?->id,
        ];

        if ($existing) {
            $existing->update($payload);

            return $existing->fresh();
        }

        $payload['created_by'] = $request->user()?->id;

        return LearningMaterial::create($payload);
    }

    /**
     * @return array<string, mixed>
     */
    private function validateSimulationPayload(Request $request): array
    {
        return $request->validate([
            'category' => ['required', Rule::in(LearningMaterial::CATEGORIES)],
            'title' => ['required', 'string', 'max:200'],
            'difficulty' => ['required', Rule::in(LearningMaterial::DIFFICULTIES)],
            'description' => ['required', 'string', 'max:1000'],
            'scenario_context' => ['required', 'string'],
            'safety_reference' => ['required', 'string', 'max:350'],
            'sort_order' => ['nullable', 'integer', 'min:0'],
            'status' => ['nullable', Rule::in(Simulation::STATUSES)],
            'steps' => ['nullable', 'array'],
            'situation_title' => ['nullable', 'string', 'max:200'],
            'situation_text' => ['nullable', 'string'],
            'recommended_action' => ['nullable', 'string'],
            'choice_a_text' => ['nullable', 'string'],
            'choice_a_feedback' => ['nullable', 'string'],
            'choice_b_text' => ['nullable', 'string'],
            'choice_b_feedback' => ['nullable', 'string'],
            'choice_c_text' => ['nullable', 'string'],
            'choice_c_feedback' => ['nullable', 'string'],
            'correct_choice' => ['nullable', Rule::in(['A', 'B', 'C'])],
        ]);
    }

    /**
     * @param  array<string, mixed>  $validated
     */
    private function persistSimulation(array $validated, ?Simulation $existing = null): Simulation
    {
        return DB::transaction(function () use ($validated, $existing) {
            $title = trim((string) $validated['title']);
            $slug = $existing && $existing->title === $title
                ? $existing->slug
                : $this->uniqueSlug(Simulation::class, $title, $existing?->id);

            $payload = [
                'category' => (string) $validated['category'],
                'title' => $title,
                'slug' => $slug,
                'difficulty' => (string) $validated['difficulty'],
                'description' => trim((string) $validated['description']),
                'scenario_context' => trim((string) $validated['scenario_context']),
                'safety_reference' => trim((string) $validated['safety_reference']),
                'sort_order' => isset($validated['sort_order']) ? (int) $validated['sort_order'] : ($existing?->sort_order ?? 99),
                'status' => $validated['status'] ?? ($existing?->status ?? Simulation::STATUS_PUBLISHED),
            ];

            if ($existing) {
                $existing->update($payload);
                $simulation = $existing;
            } else {
                $simulation = Simulation::create($payload);
            }

            if (! empty($validated['steps']) && is_array($validated['steps'])) {
                $simulation->steps()->delete();
                foreach (array_values($validated['steps']) as $idx => $stepData) {
                    $step = SimulationStep::create([
                        'simulation_id' => $simulation->id,
                        'step_number' => $stepData['step_number'] ?? ($idx + 1),
                        'situation_title' => $stepData['situation_title'] ?? ('Tahap '.($idx + 1)),
                        'situation_text' => $stepData['situation_text'] ?? $simulation->scenario_context,
                        'recommended_action' => $stepData['recommended_action'] ?? 'Ikuti prosedur keselamatan resmi BNPB & BMKG.',
                    ]);

                    foreach ($stepData['choices'] ?? [] as $choiceData) {
                        $isCorrect = (bool) ($choiceData['is_correct'] ?? false);
                        SimulationChoice::create([
                            'simulation_step_id' => $step->id,
                            'label' => $choiceData['label'] ?? 'A',
                            'choice_text' => $choiceData['choice_text'] ?? '-',
                            'is_correct' => $isCorrect,
                            'score' => isset($choiceData['score']) ? (int) $choiceData['score'] : ($isCorrect ? 50 : 0),
                            'assessment' => $choiceData['assessment'] ?? ($isCorrect ? 'Tepat' : 'Berbahaya'),
                            'feedback' => $choiceData['feedback'] ?? '-',
                        ]);
                    }
                }
            } elseif (! empty($validated['situation_text']) && ! empty($validated['choice_a_text'])) {
                $simulation->steps()->delete();
                $step = SimulationStep::create([
                    'simulation_id' => $simulation->id,
                    'step_number' => 1,
                    'situation_title' => $validated['situation_title'] ?: 'Tindakan Kritis Saat Kejadian',
                    'situation_text' => (string) $validated['situation_text'],
                    'recommended_action' => $validated['recommended_action'] ?: 'Utamakan keselamatan jiwa dan ikuti jalur evakuasi resmi.',
                ]);

                $correctLabel = $validated['correct_choice'] ?? 'A';
                $rawChoices = [
                    'A' => ['text' => $validated['choice_a_text'], 'feedback' => $validated['choice_a_feedback'] ?? 'Pilihan A dipilih.'],
                    'B' => ['text' => $validated['choice_b_text'] ?? 'Menunggu tanpa bertindak', 'feedback' => $validated['choice_b_feedback'] ?? 'Menunda penyelamatan diri berisiko tinggi.'],
                    'C' => ['text' => $validated['choice_c_text'] ?? 'Panik dan berlari tanpa arah', 'feedback' => $validated['choice_c_feedback'] ?? 'Kepanikan meningkatkan risiko cedera.'],
                ];

                foreach ($rawChoices as $label => $c) {
                    $isCorrect = $label === $correctLabel;
                    SimulationChoice::create([
                        'simulation_step_id' => $step->id,
                        'label' => $label,
                        'choice_text' => (string) $c['text'],
                        'is_correct' => $isCorrect,
                        'score' => $isCorrect ? 100 : 0,
                        'assessment' => $isCorrect ? 'Tepat' : 'Berbahaya',
                        'feedback' => (string) $c['feedback'],
                    ]);
                }
            }

            return $simulation->fresh(['steps.choices']);
        });
    }

    /**
     * @return array<string, mixed>
     */
    private function validateQuizPayload(Request $request): array
    {
        return $request->validate([
            'category' => ['required', Rule::in(LearningMaterial::CATEGORIES)],
            'topic' => ['nullable', 'string', 'max:200'],
            'title' => ['required', 'string', 'max:200'],
            'difficulty' => ['required', Rule::in(LearningMaterial::DIFFICULTIES)],
            'description' => ['required', 'string', 'max:1000'],
            'sort_order' => ['nullable', 'integer', 'min:0'],
            'status' => ['nullable', Rule::in(Quiz::STATUSES)],
            'questions' => ['nullable', 'array'],
            'question_text' => ['nullable', 'string'],
            'question_explanation' => ['nullable', 'string'],
            'option_a' => ['nullable', 'string'],
            'option_b' => ['nullable', 'string'],
            'option_c' => ['nullable', 'string'],
            'option_d' => ['nullable', 'string'],
            'correct_option' => ['nullable', Rule::in(['A', 'B', 'C', 'D'])],
            'recommended_material_slug' => ['nullable', 'string', 'max:250'],
        ]);
    }

    /**
     * @param  array<string, mixed>  $validated
     */
    private function persistQuiz(array $validated, ?Quiz $existing = null): Quiz
    {
        return DB::transaction(function () use ($validated, $existing) {
            $title = trim((string) $validated['title']);
            $slug = $existing && $existing->title === $title
                ? $existing->slug
                : $this->uniqueSlug(Quiz::class, $title, $existing?->id);

            $payload = [
                'category' => (string) $validated['category'],
                'topic' => $validated['topic'] ?? ('Kuis '.$validated['category']),
                'title' => $title,
                'slug' => $slug,
                'difficulty' => (string) $validated['difficulty'],
                'description' => trim((string) $validated['description']),
                'sort_order' => isset($validated['sort_order']) ? (int) $validated['sort_order'] : ($existing?->sort_order ?? 99),
                'status' => $validated['status'] ?? ($existing?->status ?? Quiz::STATUS_PUBLISHED),
            ];

            if ($existing) {
                $existing->update($payload);
                $quiz = $existing;
            } else {
                $quiz = Quiz::create($payload);
            }

            if (! empty($validated['questions']) && is_array($validated['questions'])) {
                $quiz->questions()->delete();
                foreach (array_values($validated['questions']) as $idx => $qData) {
                    $question = QuizQuestion::create([
                        'quiz_id' => $quiz->id,
                        'question_number' => $qData['question_number'] ?? ($idx + 1),
                        'subtopic' => $qData['subtopic'] ?? $quiz->topic,
                        'question_text' => $qData['question_text'] ?? '-',
                        'explanation' => $qData['explanation'] ?? '-',
                        'recommended_material_slug' => $qData['recommended_material_slug'] ?? null,
                    ]);

                    foreach ($qData['options'] ?? [] as $optData) {
                        QuizOption::create([
                            'quiz_question_id' => $question->id,
                            'option_label' => $optData['option_label'] ?? 'A',
                            'option_text' => $optData['option_text'] ?? '-',
                            'is_correct' => (bool) ($optData['is_correct'] ?? false),
                        ]);
                    }
                }
            } elseif (! empty($validated['question_text']) && ! empty($validated['option_a'])) {
                $nextNum = $quiz->questions()->count() + 1;
                $question = QuizQuestion::create([
                    'quiz_id' => $quiz->id,
                    'question_number' => $nextNum,
                    'subtopic' => $quiz->topic,
                    'question_text' => trim((string) $validated['question_text']),
                    'explanation' => trim((string) ($validated['question_explanation'] ?? 'Sesuai panduan resmi mitigasi gempa bumi dan tsunami.')),
                    'recommended_material_slug' => $validated['recommended_material_slug'] ?? null,
                ]);

                $correctOpt = $validated['correct_option'] ?? 'A';
                $opts = [
                    'A' => $validated['option_a'],
                    'B' => $validated['option_b'] ?? '-',
                    'C' => $validated['option_c'] ?? '-',
                    'D' => $validated['option_d'] ?? '-',
                ];
                foreach ($opts as $label => $text) {
                    QuizOption::create([
                        'quiz_question_id' => $question->id,
                        'option_label' => $label,
                        'option_text' => (string) $text,
                        'is_correct' => $label === $correctOpt,
                    ]);
                }
            }

            return $quiz->fresh(['questions.options']);
        });
    }

    /**
     * @return array<string, mixed>
     */
    private function validateMissionPayload(Request $request): array
    {
        return $request->validate([
            'category' => ['required', Rule::in(LearningMaterial::CATEGORIES)],
            'title' => ['required', 'string', 'max:200'],
            'description' => ['required', 'string', 'max:1000'],
            'illustration' => ['nullable', 'string', 'max:100'],
            'instructions' => ['nullable'],
            'difficulty' => ['required', Rule::in(LearningMaterial::DIFFICULTIES)],
            'points' => ['required', 'integer', 'min:5', 'max:500'],
            'sort_order' => ['nullable', 'integer', 'min:0'],
            'status' => ['nullable', Rule::in(Mission::STATUSES)],
        ]);
    }

    /**
     * @param  array<string, mixed>  $validated
     */
    private function persistMission(array $validated, ?Mission $existing = null): Mission
    {
        $title = trim((string) $validated['title']);
        $slug = $existing && $existing->title === $title
            ? $existing->slug
            : $this->uniqueSlug(Mission::class, $title, $existing?->id);

        $payload = [
            'category' => (string) $validated['category'],
            'title' => $title,
            'slug' => $slug,
            'description' => trim((string) $validated['description']),
            'illustration' => $validated['illustration'] ?? ($existing?->illustration ?? 'shield-check'),
            'instructions' => $this->parseLines($validated['instructions'] ?? ($existing?->instructions ?? [])),
            'difficulty' => (string) $validated['difficulty'],
            'points' => (int) $validated['points'],
            'sort_order' => isset($validated['sort_order']) ? (int) $validated['sort_order'] : ($existing?->sort_order ?? 99),
            'status' => $validated['status'] ?? ($existing?->status ?? Mission::STATUS_PUBLISHED),
        ];

        if ($existing) {
            $existing->update($payload);

            return $existing->fresh();
        }

        return Mission::create($payload);
    }

    /**
     * @return array<string, mixed>
     */
    public static function serializeQuizAdmin(Quiz $quiz): array
    {
        return [
            'id' => $quiz->id,
            'category' => $quiz->category,
            'topic' => $quiz->topic,
            'title' => $quiz->title,
            'slug' => $quiz->slug,
            'difficulty' => $quiz->difficulty,
            'description' => $quiz->description,
            'sort_order' => $quiz->sort_order,
            'status' => $quiz->status,
            'status_label' => $quiz->statusLabel(),
            'questions_count' => $quiz->relationLoaded('questions') ? $quiz->questions->count() : $quiz->questions()->count(),
            'questions' => $quiz->relationLoaded('questions')
                ? $quiz->questions->map(fn (QuizQuestion $q) => [
                    'id' => $q->id,
                    'question_number' => $q->question_number,
                    'subtopic' => $q->subtopic,
                    'question_text' => $q->question_text,
                    'explanation' => $q->explanation,
                    'recommended_material_slug' => $q->recommended_material_slug,
                    'options' => $q->relationLoaded('options')
                        ? $q->options->map(fn (QuizOption $opt) => [
                            'id' => $opt->id,
                            'option_label' => $opt->option_label,
                            'option_text' => $opt->option_text,
                            'is_correct' => (bool) $opt->is_correct,
                        ])->values()
                        : [],
                ])->values()
                : [],
        ];
    }

    /**
     * @return array<int, string>
     */
    private function parseLines(mixed $value): array
    {
        if (is_array($value)) {
            return array_values(array_filter(array_map(fn ($v) => trim((string) $v), $value), fn ($v) => $v !== ''));
        }
        if (is_string($value)) {
            $decoded = json_decode($value, true);
            if (is_array($decoded)) {
                return array_values(array_filter(array_map(fn ($v) => trim((string) $v), $decoded), fn ($v) => $v !== ''));
            }
            $lines = preg_split('/\r\n|\r|\n/', $value) ?: [];

            return array_values(array_filter(array_map('trim', $lines), fn ($v) => $v !== ''));
        }

        return [];
    }

    private function uniqueSlug(string $modelClass, string $title, ?int $ignoreId = null): string
    {
        $base = Str::slug($title);
        if ($base === '') {
            $base = 'edukasi-'.Str::lower(Str::random(6));
        }

        $slug = $base;
        $counter = 2;

        while ((method_exists($modelClass, 'withTrashed') ? $modelClass::withTrashed() : $modelClass::query())
            ->when($ignoreId !== null, fn ($q) => $q->where('id', '!=', $ignoreId))
            ->where('slug', $slug)
            ->exists()) {
            $slug = $base.'-'.$counter;
            $counter++;
        }

        return $slug;
    }

    private function deleteStoredImageIfLocal(?string $path): void
    {
        if (! is_string($path) || trim($path) === '') {
            return;
        }
        $trimmed = trim($path);
        if (str_starts_with(strtolower($trimmed), 'http://') || str_starts_with(strtolower($trimmed), 'https://')) {
            return;
        }
        if (str_starts_with($trimmed, 'illustrations/')) {
            return;
        }
        if (Storage::disk('public')->exists($trimmed)) {
            Storage::disk('public')->delete($trimmed);
        }
    }
}
