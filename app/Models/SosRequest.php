<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SosRequest extends Model
{
    use HasFactory;

    public const STATUS_WAITING = 'menunggu';

    public const STATUS_PROCESSING = 'diproses';

    public const STATUS_COMPLETED = 'selesai';

    protected $fillable = [
        'user_id',
        'user_name',
        'user_phone',
        'latitude',
        'longitude',
        'address',
        'status',
    ];

    protected function casts(): array
    {
        return [
            'latitude' => 'float',
            'longitude' => 'float',
            'handled_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function handler(): BelongsTo
    {
        return $this->belongsTo(User::class, 'handled_by');
    }

    public function statusLabel(): string
    {
        return match ($this->status) {
            self::STATUS_WAITING => 'Menunggu',
            self::STATUS_PROCESSING => 'Diproses',
            self::STATUS_COMPLETED => 'Selesai',
            default => ucfirst((string) $this->status),
        };
    }
}

