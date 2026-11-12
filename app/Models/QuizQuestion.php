<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class QuizQuestion extends Model
{
    protected $fillable = [
        'quiz_id',
        'question_number',
        'subtopic',
        'question_text',
        'explanation',
        'recommended_material_slug',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'question_number' => 'integer',
        ];
    }

    public function quiz(): BelongsTo
    {
        return $this->belongsTo(Quiz::class, 'quiz_id');
    }

    public function options(): HasMany
    {
        return $this->hasMany(QuizOption::class, 'quiz_question_id')->orderBy('sort_order')->orderBy('id');
    }
}

