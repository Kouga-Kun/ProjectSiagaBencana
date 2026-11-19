<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Schema;

class BackupEducationDatabaseCommand extends Command
{
    /**
     * @var string
     */
    protected $signature = 'edukasi:backup {--path= : Direktori tujuan penyimpanan file backup}';

    /**
     * @var string
     */
    protected $description = 'Membuat backup terstruktur ber-checksum untuk seluruh tabel fitur Edukasi Bencana';

    /**
     * @var list<string>
     */
    public const EDUCATION_TABLES = [
        'learning_categories',
        'learning_materials',
        'learning_progress',
        'simulations',
        'simulation_steps',
        'simulation_choices',
        'simulation_drafts',
        'simulation_results',
        'quizzes',
        'quiz_questions',
        'quiz_options',
        'quiz_results',
        'missions',
        'user_missions',
        'badges',
        'user_badges',
        'learning_activity_logs',
        'learning_reminder_preferences',
    ];

    public function handle(): int
    {
        $targetDir = (string) ($this->option('path') ?: storage_path('app/private/backups/education'));
        File::ensureDirectoryExists($targetDir);

        $tablesData = [];
        $rowCounts = [];

        foreach (self::EDUCATION_TABLES as $table) {
            if (! Schema::hasTable($table)) {
                continue;
            }
            $rows = DB::table($table)->get()->map(fn ($row) => (array) $row)->all();
            $tablesData[$table] = $rows;
            $rowCounts[$table] = count($rows);
        }

        $payload = [
            'version' => '1.0',
            'app' => config('app.name', 'SiagaBencana'),
            'created_at' => now()->toIso8601String(),
            'connection' => config('database.default'),
            'row_counts' => $rowCounts,
            'tables' => $tablesData,
        ];

        $tablesJson = json_encode($tablesData, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        $payload['sha256_checksum'] = hash('sha256', (string) $tablesJson);

        $filename = 'education_backup_'.now()->format('Ymd_His').'.json';
        $fullPath = rtrim($targetDir, DIRECTORY_SEPARATOR).DIRECTORY_SEPARATOR.$filename;

        File::put($fullPath, (string) json_encode($payload, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES));

        $this->info('Backup Edukasi Bencana berhasil dibuat: '.$fullPath);
        $this->line('Total tabel: '.count($tablesData).' | Total baris: '.array_sum($rowCounts));

        return self::SUCCESS;
    }
}
