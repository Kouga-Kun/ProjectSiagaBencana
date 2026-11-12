<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Str;

class Quiz extends Model
{
    public const STATUS_PUBLISHED = 'published';

    public const STATUS_DRAFT = 'draft';

    public const STATUSES = [
        self::STATUS_PUBLISHED,
        self::STATUS_DRAFT,
    ];

    protected $fillable = [
        'category',
        'topic',
        'title',
        'slug',
        'difficulty',
        'description',
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

    public function questions(): HasMany
    {
        return $this->hasMany(QuizQuestion::class, 'quiz_id')->orderBy('question_number')->orderBy('id');
    }

    public function results(): HasMany
    {
        return $this->hasMany(QuizResult::class, 'quiz_id');
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
            $base = 'kuis-edukasi';
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
