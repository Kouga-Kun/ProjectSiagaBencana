<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class LearningReminderPreference extends Model
{
    public const FREQUENCY_DAILY = 'daily';

    public const FREQUENCY_EVERY_3_DAYS = 'every_3_days';

    public const FREQUENCY_WEEKLY = 'weekly';

    public const FREQUENCIES = [
        self::FREQUENCY_DAILY,
        self::FREQUENCY_EVERY_3_DAYS,
        self::FREQUENCY_WEEKLY,
    ];

    protected $fillable = [
        'user_id',
        'is_enabled',
        'reminder_time',
        'frequency',
        'remind_unfinished_materials',
        'remind_pending_missions',
        'remind_inactive_learning',
        'last_reminded_at',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'is_enabled' => 'boolean',
            'remind_unfinished_materials' => 'boolean',
            'remind_pending_missions' => 'boolean',
            'remind_inactive_learning' => 'boolean',
            'last_reminded_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public static function frequencyLabel(string $frequency): string
    {
        return match ($frequency) {
            self::FREQUENCY_EVERY_3_DAYS => 'Setiap 3 Hari',
            self::FREQUENCY_WEEKLY => 'Mingguan',
            default => 'Harian',
        };
    }
}
