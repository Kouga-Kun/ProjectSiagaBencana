<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class LearningCategory extends Model
{
    protected $fillable = [
        'name',
        'slug',
        'description',
        'icon',
        'sort_order',
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

    public function materials(): HasMany
    {
        return $this->hasMany(LearningMaterial::class, 'learning_category_id');
    }
}

