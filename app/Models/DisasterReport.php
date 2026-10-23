<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class DisasterReport extends Model
{
    use HasFactory;

    public const STATUS_PENDING = 'pending';

    public const STATUS_VERIFIED = 'verified';

    public const STATUS_REJECTED = 'rejected';

    public const SOURCE_STAFF = 'staff';

    public const SOURCE_OFFICIAL = 'official';

    protected $fillable = [
        'occurred_at',
        'disaster_type',
        'province',
        'city_district',
        'district',
        'affected_area',
        'description',
        'source_type',
        'source_name',
        'source_url',
    ];

    protected function casts(): array
    {
        return [
            'occurred_at' => 'datetime',
            'verified_at' => 'datetime',
            'source_retrieved_at' => 'datetime',
        ];
    }

    public function submitter(): BelongsTo
    {
        return $this->belongsTo(User::class, 'submitted_by');
    }

    public function verifier(): BelongsTo
    {
        return $this->belongsTo(User::class, 'verified_by');
    }
}
