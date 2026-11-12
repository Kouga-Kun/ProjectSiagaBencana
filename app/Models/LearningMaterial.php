<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Str;

class LearningMaterial extends Model
{
    public const CATEGORY_EARTHQUAKE = 'Gempa Bumi';

    public const CATEGORY_TSUNAMI = 'Tsunami';

    public const CATEGORIES = [
        self::CATEGORY_EARTHQUAKE,
        self::CATEGORY_TSUNAMI,
    ];

    public const DIFFICULTY_BASIC = 'Dasar';

    public const DIFFICULTY_INTERMEDIATE = 'Menengah';

    public const DIFFICULTY_ADVANCED = 'Lanjutan';

    public const DIFFICULTIES = [
        self::DIFFICULTY_BASIC,
        self::DIFFICULTY_INTERMEDIATE,
        self::DIFFICULTY_ADVANCED,
    ];

    public const STATUS_PUBLISHED = 'published';

    public const STATUS_DRAFT = 'draft';

    public const STATUSES = [
        self::STATUS_PUBLISHED,
        self::STATUS_DRAFT,
    ];

    protected $fillable = [
        'learning_category_id',
        'category',
        'title',
        'slug',
        'difficulty',
        'image_path',
        'summary',
        'content',
        'key_points',
        'action_steps',
        'things_to_avoid',
        'source_reference',
        'sort_order',
        'status',
        'author_id',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'key_points' => 'array',
            'action_steps' => 'array',
            'things_to_avoid' => 'array',
            'sort_order' => 'integer',
        ];
    }

    public function learningCategory(): BelongsTo
    {
        return $this->belongsTo(LearningCategory::class, 'learning_category_id');
    }

    public function author(): BelongsTo
    {
        return $this->belongsTo(User::class, 'author_id');
    }

    public function progressRecords(): HasMany
    {
        return $this->hasMany(LearningProgress::class, 'learning_material_id');
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
            $base = 'materi-edukasi';
        }

        $slug = $base;
        $counter = 2;

        while (
            static::query()
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
