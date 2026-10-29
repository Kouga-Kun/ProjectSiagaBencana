<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Hidden;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

#[Fillable(['name', 'email', 'password', 'phone', 'address', 'profile_photo_path'])]
#[Hidden(['password', 'remember_token'])]
class User extends Authenticatable
{
    /** @use HasFactory<UserFactory> */
    use HasFactory, Notifiable;

    public function submittedDisasterReports(): HasMany
    {
        return $this->hasMany(DisasterReport::class, 'submitted_by');
    }

    public function verifiedDisasterReports(): HasMany
    {
        return $this->hasMany(DisasterReport::class, 'verified_by');
    }

    public function sosRequests(): HasMany
    {
        return $this->hasMany(SosRequest::class, 'user_id');
    }

    public function isReportStaff(): bool
    {
        return $this->role === 'petugas';
    }

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }
}
