<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Str;

class Mission extends Model
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
        'description',
        'illustration',
        'instructions',
        'difficulty',
        'points',
        'sort_order',
        'status',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'instructions' => 'array',
            'points' => 'integer',
            'sort_order' => 'integer',
        ];
    }

    public function userMissions(): HasMany
    {
        return $this->hasMany(UserMission::class, 'mission_id');
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
            $base = 'misi-siaga';
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
