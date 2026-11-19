<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Schema;
use Throwable;

class RestoreEducationDatabaseCommand extends Command
{
    /**
     * @var string
     */
    protected $signature = 'edukasi:restore {file : Path absolut file backup JSON Edukasi Bencana} {--force : Jalankan restore tanpa konfirmasi interaktif}';

    /**
     * @var string
     */
    protected $description = 'Memulihkan data tabel Edukasi Bencana dari file backup JSON dengan verifikasi checksum';

    public function handle(): int
    {
        $filePath = (string) $this->argument('file');

        if (! File::exists($filePath)) {
            $this->error('File backup tidak ditemukan: '.$filePath);

            return self::FAILURE;
        }

        $decoded = json_decode(File::get($filePath), true);
        if (! is_array($decoded) || ! isset($decoded['tables']) || ! is_array($decoded['tables'])) {
            $this->error('Format file backup tidak valid.');

            return self::FAILURE;
        }

        $expectedChecksum = (string) ($decoded['sha256_checksum'] ?? '');
        $actualChecksum = hash('sha256', (string) json_encode($decoded['tables'], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES));

        if ($expectedChecksum === '' || ! hash_equals($expectedChecksum, $actualChecksum)) {
            $this->error('Verifikasi checksum backup GAGAL. File mungkin rusak atau dimodifikasi.');

            return self::FAILURE;
        }

        if (! $this->option('force') && ! $this->confirm('Proses restore akan menimpa tabel Edukasi Bencana dengan isi backup ini. Lanjutkan?')) {
            $this->warn('Proses restore dibatalkan.');

            return self::SUCCESS;
        }

        try {
            Schema::disableForeignKeyConstraints();

            DB::transaction(function () use ($decoded): void {
                $tables = $decoded['tables'];
                $ordered = BackupEducationDatabaseCommand::EDUCATION_TABLES;

                // Clear in reverse FK order
                foreach (array_reverse($ordered) as $table) {
                    if (array_key_exists($table, $tables) && Schema::hasTable($table)) {
                        DB::table($table)->delete();
                    }
                }

                // Restore in forward FK order
                foreach ($ordered as $table) {
                    if (! array_key_exists($table, $tables) || ! Schema::hasTable($table)) {
                        continue;
                    }
                    $rows = $tables[$table];
                    if (is_array($rows) && count($rows) > 0) {
                        foreach (array_chunk($rows, 100) as $chunk) {
                            DB::table($table)->insert($chunk);
                        }
                    }
                }
            });

            Schema::enableForeignKeyConstraints();
        } catch (Throwable $e) {
            Schema::enableForeignKeyConstraints();
            $this->error('Restore gagal dan telah di-rollback: '.$e->getMessage());

            return self::FAILURE;
        }

        $this->info('Restore database Edukasi Bencana berhasil diselesaikan dengan integritas terjaga.');

        return self::SUCCESS;
    }
}
