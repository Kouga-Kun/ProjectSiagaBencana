<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SimulationDraft extends Model
{
    protected $fillable = [
        'user_id',
        'simulation_id',
        'current_step_index',
        'selected_choices',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'current_step_index' => 'integer',
            'selected_choices' => 'array',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function simulation(): BelongsTo
    {
        return $this->belongsTo(Simulation::class, 'simulation_id')->withTrashed();
    }
}
