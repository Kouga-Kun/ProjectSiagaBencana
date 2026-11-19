<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class LearningActivityLog extends Model
{
    public const TYPE_MATERIAL_READ = 'material_read';

    public const TYPE_MATERIAL_COMPLETED = 'material_completed';

    public const TYPE_SIMULATION_COMPLETED = 'simulation_completed';

    public const TYPE_QUIZ_COMPLETED = 'quiz_completed';

    public const TYPE_MISSION_STARTED = 'mission_started';

    public const TYPE_MISSION_COMPLETED = 'mission_completed';

    public const TYPE_BADGE_AWARDED = 'badge_awarded';

    protected $fillable = [
        'user_id',
        'activity_type',
        'subject_type',
        'subject_id',
        'subject_title',
        'category',
        'points_earned',
        'metadata',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'points_earned' => 'integer',
            'metadata' => 'array',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function typeLabel(): string
    {
        return match ($this->activity_type) {
            self::TYPE_MATERIAL_READ => 'Membaca Materi',
            self::TYPE_MATERIAL_COMPLETED => 'Menyelesaikan Materi',
            self::TYPE_SIMULATION_COMPLETED => 'Menyelesaikan Simulasi',
            self::TYPE_QUIZ_COMPLETED => 'Menyelesaikan Kuis',
            self::TYPE_MISSION_STARTED => 'Memulai Misi Siaga',
            self::TYPE_MISSION_COMPLETED => 'Menyelesaikan Misi Siaga',
            self::TYPE_BADGE_AWARDED => 'Meraih Badge Kesiapsiagaan',
            default => 'Aktivitas Belajar',
        };
    }
}
