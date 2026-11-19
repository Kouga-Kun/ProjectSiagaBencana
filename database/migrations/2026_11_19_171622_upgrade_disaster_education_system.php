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
        Schema::table('learning_materials', function (Blueprint $table): void {
            $table->softDeletes();
        });

        Schema::table('simulations', function (Blueprint $table): void {
            $table->softDeletes();
        });

        Schema::table('quizzes', function (Blueprint $table): void {
            $table->softDeletes();
        });

        Schema::table('missions', function (Blueprint $table): void {
            $table->softDeletes();
        });

        Schema::table('learning_progress', function (Blueprint $table): void {
            $table->unsignedInteger('last_position')->default(0)->after('is_completed');
            $table->string('last_section', 100)->nullable()->after('last_position');
            $table->unsignedTinyInteger('progress_percent')->default(0)->after('last_section');
            $table->boolean('is_favorite')->default(false)->index()->after('progress_percent');
            $table->timestamp('last_read_at')->nullable()->index()->after('is_favorite');
        });

        Schema::table('simulation_results', function (Blueprint $table): void {
            $table->string('client_submission_id', 100)->nullable()->after('simulation_id');
            $table->unique(['user_id', 'client_submission_id'], 'sim_results_user_submission_unique');
        });

        Schema::table('quiz_results', function (Blueprint $table): void {
            $table->string('client_submission_id', 100)->nullable()->after('quiz_id');
            $table->unique(['user_id', 'client_submission_id'], 'quiz_results_user_submission_unique');
        });

        Schema::create('simulation_drafts', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('simulation_id')->constrained('simulations')->cascadeOnDelete();
            $table->unsignedInteger('current_step_index')->default(0);
            $table->json('selected_choices')->nullable();
            $table->timestamps();

            $table->unique(['user_id', 'simulation_id']);
        });

        Schema::create('learning_activity_logs', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('activity_type', 50)->index();
            $table->string('subject_type', 50)->nullable();
            $table->unsignedBigInteger('subject_id')->nullable();
            $table->string('subject_title', 255);
            $table->string('category', 60)->nullable();
            $table->integer('points_earned')->default(0);
            $table->json('metadata')->nullable();
            $table->timestamps();

            $table->index(['user_id', 'created_at']);
            $table->index(['activity_type', 'created_at']);
        });

        Schema::create('learning_reminder_preferences', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('user_id')->unique()->constrained('users')->cascadeOnDelete();
            $table->boolean('is_enabled')->default(false);
            $table->string('reminder_time', 5)->default('19:00');
            $table->string('frequency', 20)->default('daily');
            $table->boolean('remind_unfinished_materials')->default(true);
            $table->boolean('remind_pending_missions')->default(true);
            $table->boolean('remind_inactive_learning')->default(true);
            $table->timestamp('last_reminded_at')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('learning_reminder_preferences');
        Schema::dropIfExists('learning_activity_logs');
        Schema::dropIfExists('simulation_drafts');

        Schema::table('quiz_results', function (Blueprint $table): void {
            $table->dropUnique('quiz_results_user_submission_unique');
            $table->dropColumn('client_submission_id');
        });

        Schema::table('simulation_results', function (Blueprint $table): void {
            $table->dropUnique('sim_results_user_submission_unique');
            $table->dropColumn('client_submission_id');
        });

        Schema::table('learning_progress', function (Blueprint $table): void {
            $table->dropColumn([
                'last_position',
                'last_section',
                'progress_percent',
                'is_favorite',
                'last_read_at',
            ]);
        });

        Schema::table('missions', function (Blueprint $table): void {
            $table->dropSoftDeletes();
        });

        Schema::table('quizzes', function (Blueprint $table): void {
            $table->dropSoftDeletes();
        });

        Schema::table('simulations', function (Blueprint $table): void {
            $table->dropSoftDeletes();
        });

        Schema::table('learning_materials', function (Blueprint $table): void {
            $table->dropSoftDeletes();
        });
    }
};
