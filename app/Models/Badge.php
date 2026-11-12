<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Badge extends Model
{
    protected $fillable = [
        'code',
        'name',
        'description',
        'criteria_description',
        'icon',
        'category',
        'points_reward',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'points_reward' => 'integer',
        ];
    }

    public function userBadges(): HasMany
    {
        return $this->hasMany(UserBadge::class, 'badge_id');
    }
}

