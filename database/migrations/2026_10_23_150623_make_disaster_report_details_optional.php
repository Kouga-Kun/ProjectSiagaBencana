<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('disaster_reports', function (Blueprint $table) {
            $table->string('disaster_type', 100)->nullable()->change();
            $table->text('description')->nullable()->change();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        DB::table('disaster_reports')->whereNull('disaster_type')->update([
            'disaster_type' => 'Tidak diketahui',
        ]);
        DB::table('disaster_reports')->whereNull('description')->update([
            'description' => 'Informasi kejadian belum tersedia.',
        ]);

        Schema::table('disaster_reports', function (Blueprint $table) {
            $table->string('disaster_type', 100)->nullable(false)->change();
            $table->text('description')->nullable(false)->change();
        });
    }
};
