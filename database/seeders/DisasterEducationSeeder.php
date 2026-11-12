<?php

namespace Database\Seeders;

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
use Database\Seeders\Data\EarthquakeMaterialsData;
use Database\Seeders\Data\QuizzesAndMissionsData;
use Database\Seeders\Data\SimulationsData;
use Database\Seeders\Data\TsunamiMaterialsData;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Schema;

require_once __DIR__.'/data/EarthquakeMaterialsData.php';
require_once __DIR__.'/data/TsunamiMaterialsData.php';
require_once __DIR__.'/data/SimulationsData.php';
require_once __DIR__.'/data/QuizzesAndMissionsData.php';

class DisasterEducationSeeder extends Seeder
{
    public static function ensureSeeded(): void
    {
        if (! Schema::hasTable('learning_categories') || ! Schema::hasTable('learning_materials')) {
            return;
        }

        if (
            LearningCategory::query()->count() === 0 &&
            LearningMaterial::query()->count() === 0 &&
            Simulation::query()->count() === 0 &&
            Quiz::query()->count() === 0 &&
            Mission::query()->count() === 0
        ) {
            (new self)->run();
        }
    }

    /**
     * Seed the disaster education tables.
     */
    public function run(): void
    {
        $earthquakeCat = LearningCategory::query()->updateOrCreate(
            ['slug' => 'gempa-bumi'],
            [
                'name' => LearningMaterial::CATEGORY_EARTHQUAKE,
                'description' => 'Pelajari pengertian, penyebab, tanda-tanda, persiapan sebelum bencana, tindakan penyelamatan diri (Drop, Cover, and Hold On) saat gempa di berbagai lokasi, hingga penanganan bahaya ikutan setelah gempa bumi.',
                'icon' => 'vibration',
                'sort_order' => 1,
            ]
        );

        $tsunamiCat = LearningCategory::query()->updateOrCreate(
            ['slug' => 'tsunami'],
            [
                'name' => LearningMaterial::CATEGORY_TSUNAMI,
                'description' => 'Kenali pengertian tsunami, hubungan gempa bumi dengan tsunami, sistem peringatan dini resmi BMKG, tanda alam bahaya tsunami, jalur evakuasi menuju tempat tinggi/shelter vertikal, hingga prosedur kembali dengan aman.',
                'icon' => 'waves',
                'sort_order' => 2,
            ]
        );

        foreach (EarthquakeMaterialsData::get() as $item) {
            LearningMaterial::query()->updateOrCreate(
                ['slug' => $item['slug']],
                array_merge($item, [
                    'learning_category_id' => $earthquakeCat->id,
                    'category' => LearningMaterial::CATEGORY_EARTHQUAKE,
                    'status' => LearningMaterial::STATUS_PUBLISHED,
                ])
            );
        }

        foreach (TsunamiMaterialsData::get() as $item) {
            LearningMaterial::query()->updateOrCreate(
                ['slug' => $item['slug']],
                array_merge($item, [
                    'learning_category_id' => $tsunamiCat->id,
                    'category' => LearningMaterial::CATEGORY_TSUNAMI,
                    'status' => LearningMaterial::STATUS_PUBLISHED,
                ])
            );
        }

        foreach (SimulationsData::get() as $simData) {
            $steps = $simData['steps'] ?? [];
            unset($simData['steps']);

            $simulation = Simulation::query()->updateOrCreate(
                ['slug' => $simData['slug']],
                array_merge($simData, ['status' => Simulation::STATUS_PUBLISHED])
            );

            foreach ($steps as $stepData) {
                $choices = $stepData['choices'] ?? [];
                unset($stepData['choices']);

                $step = SimulationStep::query()->updateOrCreate(
                    [
                        'simulation_id' => $simulation->id,
                        'step_number' => $stepData['step_number'],
                    ],
                    $stepData
                );

                foreach ($choices as $index => $choiceData) {
                    SimulationChoice::query()->updateOrCreate(
                        [
                            'simulation_step_id' => $step->id,
                            'label' => $choiceData['label'],
                        ],
                        array_merge($choiceData, ['sort_order' => $index + 1])
                    );
                }
            }
        }

        foreach (QuizzesAndMissionsData::quizzes() as $quizData) {
            $questions = $quizData['questions'] ?? [];
            unset($quizData['questions']);

            $quiz = Quiz::query()->updateOrCreate(
                ['slug' => $quizData['slug']],
                array_merge($quizData, ['status' => Quiz::STATUS_PUBLISHED])
            );

            foreach ($questions as $qData) {
                $options = $qData['options'] ?? [];
                unset($qData['options']);

                $question = QuizQuestion::query()->updateOrCreate(
                    [
                        'quiz_id' => $quiz->id,
                        'question_number' => $qData['question_number'],
                    ],
                    $qData
                );

                foreach ($options as $idx => $optData) {
                    QuizOption::query()->updateOrCreate(
                        [
                            'quiz_question_id' => $question->id,
                            'option_label' => $optData['label'],
                        ],
                        [
                            'option_text' => $optData['text'],
                            'is_correct' => (bool) $optData['is_correct'],
                            'sort_order' => $idx + 1,
                        ]
                    );
                }
            }
        }

        foreach (QuizzesAndMissionsData::missions() as $missionData) {
            Mission::query()->updateOrCreate(
                ['slug' => $missionData['slug']],
                array_merge($missionData, ['status' => Mission::STATUS_PUBLISHED])
            );
        }

        foreach (QuizzesAndMissionsData::badges() as $badgeData) {
            Badge::query()->updateOrCreate(
                ['code' => $badgeData['code']],
                $badgeData
            );
        }
    }
}

