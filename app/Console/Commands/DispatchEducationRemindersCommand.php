<?php

namespace App\Console\Commands;

use App\Models\LearningReminderPreference;
use App\Services\EducationProgressService;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Log;

class DispatchEducationRemindersCommand extends Command
{
    /**
     * @var string
     */
    protected $signature = 'edukasi:dispatch-reminders';

    /**
     * @var string
     */
    protected $description = 'Memeriksa jadwal pengingat belajar pengguna yang aktif tanpa spam dan melewati aktivitas yang sudah selesai';

    public function handle(EducationProgressService $progressService): int
    {
        $preferences = LearningReminderPreference::query()
            ->with('user:id,name,email')
            ->where('is_enabled', true)
            ->get();

        $dispatched = 0;

        foreach ($preferences as $pref) {
            if ($pref->user === null) {
                continue;
            }

            $minHoursBetweenReminders = match ($pref->frequency) {
                LearningReminderPreference::FREQUENCY_EVERY_3_DAYS => 68,
                LearningReminderPreference::FREQUENCY_WEEKLY => 160,
                default => 20,
            };

            if ($pref->last_reminded_at !== null && $pref->last_reminded_at->gt(now()->subHours($minHoursBetweenReminders))) {
                continue;
            }

            $pendingReminders = $progressService->buildPendingReminders($pref->user);
            if (count($pendingReminders) === 0) {
                continue;
            }

            $pref->update(['last_reminded_at' => now()]);
            $dispatched++;

            Log::info('Pengingat belajar Edukasi Bencana dijadwalkan untuk pengguna.', [
                'user_id' => $pref->user->id,
                'pending_items_count' => count($pendingReminders),
                'frequency' => $pref->frequency,
            ]);
        }

        $this->info('Pemeriksaan pengingat selesai. Pengingat aktif diproses: '.$dispatched);

        return self::SUCCESS;
    }
}
