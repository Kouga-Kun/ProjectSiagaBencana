<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class QuizResult extends Model
{
    protected $fillable = [
        'user_id',
        'quiz_id',
        'total_questions',
        'correct_answers',
        'wrong_answers',
        'final_score',
        'percentage',
        'answers_detail',
        'recommended_materials',
        'completed_at',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'total_questions' => 'integer',
            'correct_answers' => 'integer',
            'wrong_answers' => 'integer',
            'final_score' => 'integer',
            'percentage' => 'float',
            'answers_detail' => 'array',
            'recommended_materials' => 'array',
            'completed_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function quiz(): BelongsTo
    {
        return $this->belongsTo(Quiz::class, 'quiz_id');
    }
}

