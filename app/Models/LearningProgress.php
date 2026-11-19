<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class LearningProgress extends Model
{
    protected $table = 'learning_progress';

    protected $fillable = [
        'user_id',
        'learning_material_id',
        'is_completed',
        'last_position',
        'last_section',
        'progress_percent',
        'is_favorite',
        'last_read_at',
        'completed_at',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'is_completed' => 'boolean',
            'last_position' => 'integer',
            'progress_percent' => 'integer',
            'is_favorite' => 'boolean',
            'last_read_at' => 'datetime',
            'completed_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function material(): BelongsTo
    {
        return $this->belongsTo(LearningMaterial::class, 'learning_material_id')->withTrashed();
    }
}
