<?php

namespace Database\Factories;

use App\Models\NewsArticle;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

/**
 * @extends Factory<NewsArticle>
 */
class NewsArticleFactory extends Factory
{
    protected $model = NewsArticle::class;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $title = fake()->sentence(6);

        return [
            'title' => $title,
            'slug' => Str::slug($title).'-'.fake()->unique()->numberBetween(100, 99999),
            'category' => fake()->randomElement(NewsArticle::CATEGORIES),
            'image_path' => null,
            'summary' => fake()->paragraph(2),
            'content' => fake()->paragraphs(4, true),
            'source' => 'BPBD Kota Padang',
            'status' => NewsArticle::STATUS_PUBLISHED,
            'is_featured' => false,
            'published_at' => now(),
            'author_id' => null,
        ];
    }

    public function published(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => NewsArticle::STATUS_PUBLISHED,
            'published_at' => $attributes['published_at'] ?? now(),
        ]);
    }

    public function draft(): static
    {
        return $this->state(fn () => [
            'status' => NewsArticle::STATUS_DRAFT,
            'published_at' => null,
        ]);
    }

    public function headline(): static
    {
        return $this->state(fn () => [
            'is_featured' => true,
        ]);
    }
}

