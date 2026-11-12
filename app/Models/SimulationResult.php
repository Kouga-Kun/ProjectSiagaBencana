<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SimulationResult extends Model
{
    protected $fillable = [
        'user_id',
        'simulation_id',
        'score',
        'max_score',
        'correct_choices',
        'total_steps',
        'selected_answers',
        'completed_at',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'score' => 'integer',
            'max_score' => 'integer',
            'correct_choices' => 'integer',
            'total_steps' => 'integer',
            'selected_answers' => 'array',
            'completed_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function simulation(): BelongsTo
    {
        return $this->belongsTo(Simulation::class, 'simulation_id');
    }
}

