<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SimulationChoice extends Model
{
    protected $fillable = [
        'simulation_step_id',
        'label',
        'choice_text',
        'is_correct',
        'score',
        'assessment',
        'feedback',
        'sort_order',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'is_correct' => 'boolean',
            'score' => 'integer',
            'sort_order' => 'integer',
        ];
    }

    public function step(): BelongsTo
    {
        return $this->belongsTo(SimulationStep::class, 'simulation_step_id');
    }
}

