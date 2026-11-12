<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class SimulationStep extends Model
{
    protected $fillable = [
        'simulation_id',
        'step_number',
        'situation_title',
        'situation_text',
        'recommended_action',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'step_number' => 'integer',
        ];
    }

    public function simulation(): BelongsTo
    {
        return $this->belongsTo(Simulation::class, 'simulation_id');
    }

    public function choices(): HasMany
    {
        return $this->hasMany(SimulationChoice::class, 'simulation_step_id')->orderBy('sort_order')->orderBy('id');
    }
}

