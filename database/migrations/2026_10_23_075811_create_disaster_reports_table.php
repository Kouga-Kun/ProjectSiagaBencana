<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('disaster_reports', function (Blueprint $table) {
            $table->id();
            $table->timestamp('occurred_at')->nullable();
            $table->string('disaster_type', 100)->index();
            $table->string('province', 120)->nullable();
            $table->string('city_district', 120)->nullable()->index();
            $table->string('district', 120)->nullable();
            $table->string('affected_area', 180)->nullable();
            $table->text('description');
            $table->string('source_type', 20)->default('staff')->index();
            $table->string('source_name', 255);
            $table->string('source_url', 2048)->nullable();
            $table->string('external_id', 255)->nullable();
            $table->string('verification_status', 20)->default('pending')->index();
            $table->foreignId('submitted_by')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignId('verified_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamp('verified_at')->nullable();
            $table->timestamp('source_retrieved_at')->nullable();
            $table->timestamps();

            $table->unique(['source_type', 'external_id']);
            $table->index(['occurred_at', 'disaster_type']);
            $table->index(['province', 'city_district', 'district']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('disaster_reports');
    }
};
