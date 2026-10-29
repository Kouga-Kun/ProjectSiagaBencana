<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Str;

class NewsArticle extends Model
{
    use HasFactory;

    public const CATEGORY_DISASTER = 'Berita Bencana';
    public const CATEGORY_EARLY_WARNING = 'Peringatan Dini';
    public const CATEGORY_EDUCATION = 'Edukasi Kebencanaan';
    public const CATEGORY_REGIONAL_INFO = 'Informasi Wilayah';

    public const CATEGORIES = [
        self::CATEGORY_DISASTER,
        self::CATEGORY_EARLY_WARNING,
        self::CATEGORY_EDUCATION,
        self::CATEGORY_REGIONAL_INFO,
    ];

    public const STATUS_DRAFT = 'draft';
    public const STATUS_PUBLISHED = 'published';

    protected $fillable = [
        'title',
        'slug',
        'category',
        'image_path',
        'summary',
        'content',
        'source',
        'status',
        'is_featured',
        'published_at',
        'author_id',
    ];

    protected function casts(): array
    {
        return [
            'is_featured' => 'boolean',
            'published_at' => 'datetime',
        ];
    }

    public function author(): BelongsTo
    {
        return $this->belongsTo(User::class, 'author_id');
    }

    public function isPublished(): bool
    {
        return $this->status === self::STATUS_PUBLISHED;
    }

    public function statusLabel(): string
    {
        return match ($this->status) {
            self::STATUS_PUBLISHED => 'Dipublikasikan',
            default => 'Draf',
        };
    }

    public static function generateUniqueSlug(string $title, ?int $ignoreId = null): string
    {
        $base = Str::slug($title);
        if ($base === '') {
            $base = 'berita';
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

