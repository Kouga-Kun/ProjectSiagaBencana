<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Str;

class Simulation extends Model
{
    use SoftDeletes;

    public const STATUS_PUBLISHED = 'published';

    public const STATUS_DRAFT = 'draft';

    public const STATUSES = [
        self::STATUS_PUBLISHED,
        self::STATUS_DRAFT,
    ];

    protected $fillable = [
        'category',
        'title',
        'slug',
        'difficulty',
        'description',
        'scenario_context',
        'safety_reference',
        'sort_order',
        'status',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'sort_order' => 'integer',
        ];
    }

    public function steps(): HasMany
    {
        return $this->hasMany(SimulationStep::class, 'simulation_id')->orderBy('step_number')->orderBy('id');
    }

    public function results(): HasMany
    {
        return $this->hasMany(SimulationResult::class, 'simulation_id');
    }

    public function drafts(): HasMany
    {
        return $this->hasMany(SimulationDraft::class, 'simulation_id');
    }

    public function isPublished(): bool
    {
        return $this->status === self::STATUS_PUBLISHED;
    }

    public function statusLabel(): string
    {
        return $this->isPublished() ? 'Dipublikasikan' : 'Draf';
    }

    public static function generateUniqueSlug(string $title, ?int $ignoreId = null): string
    {
        $base = Str::slug($title);
        if ($base === '') {
            $base = 'simulasi-bencana';
        }

        $slug = $base;
        $counter = 2;

        while (
            static::withTrashed()
                ->where('slug', $slug)
                ->when($ignoreId !== null, fn ($query) => $query->where('id', '!=', $ignoreId))
                ->exists()
        ) {
            $slug = $base.'-'.$counter;
            $counter++;
        }

        return $slug;
    }
}
