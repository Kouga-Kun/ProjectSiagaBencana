<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserMission extends Model
{
    public const STATUS_NOT_STARTED = 'belum_dimulai';

    public const STATUS_IN_PROGRESS = 'sedang_dikerjakan';

    public const STATUS_COMPLETED = 'selesai';

    public const STATUSES = [
        self::STATUS_NOT_STARTED,
        self::STATUS_IN_PROGRESS,
        self::STATUS_COMPLETED,
    ];

    protected $fillable = [
        'user_id',
        'mission_id',
        'status',
        'notes',
        'started_at',
        'completed_at',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'started_at' => 'datetime',
            'completed_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function mission(): BelongsTo
    {
        return $this->belongsTo(Mission::class, 'mission_id');
    }

    public static function labelForStatus(?string $status): string
    {
        return match ($status) {
            self::STATUS_IN_PROGRESS => 'Sedang dikerjakan',
            self::STATUS_COMPLETED => 'Selesai',
            default => 'Belum dimulai',
        };
    }
}

