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
        Schema::create('learning_categories', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('slug')->unique();
            $table->text('description');
            $table->string('icon')->nullable();
            $table->unsignedInteger('sort_order')->default(0);
            $table->timestamps();
        });

        Schema::create('learning_materials', function (Blueprint $table) {
            $table->id();
            $table->foreignId('learning_category_id')->nullable()->constrained('learning_categories')->nullOnDelete();
            $table->string('category')->index();
            $table->string('title');
            $table->string('slug')->unique();
            $table->string('difficulty')->default('Dasar')->index();
            $table->string('image_path')->nullable();
            $table->text('summary');
            $table->longText('content');
            $table->json('key_points');
            $table->json('action_steps');
            $table->json('things_to_avoid');
            $table->string('source_reference');
            $table->unsignedInteger('sort_order')->default(0);
            $table->string('status')->default('published')->index();
            $table->foreignId('author_id')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();
        });

        Schema::create('learning_progress', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('learning_material_id')->constrained('learning_materials')->cascadeOnDelete();
            $table->boolean('is_completed')->default(true);
            $table->timestamp('completed_at')->nullable();
            $table->timestamps();

            $table->unique(['user_id', 'learning_material_id']);
        });

        Schema::create('simulations', function (Blueprint $table) {
            $table->id();
            $table->string('category')->index();
            $table->string('title');
            $table->string('slug')->unique();
            $table->string('difficulty')->default('Dasar')->index();
            $table->text('description');
            $table->text('scenario_context');
            $table->string('safety_reference')->default('BNPB, BMKG & UNESCO-IOC');
            $table->unsignedInteger('sort_order')->default(0);
            $table->string('status')->default('published')->index();
            $table->timestamps();
        });

        Schema::create('simulation_steps', function (Blueprint $table) {
            $table->id();
            $table->foreignId('simulation_id')->constrained('simulations')->cascadeOnDelete();
            $table->unsignedInteger('step_number')->default(1);
            $table->string('situation_title');
            $table->text('situation_text');
            $table->text('recommended_action');
            $table->timestamps();
        });

        Schema::create('simulation_choices', function (Blueprint $table) {
            $table->id();
            $table->foreignId('simulation_step_id')->constrained('simulation_steps')->cascadeOnDelete();
            $table->string('label', 10)->default('A');
            $table->text('choice_text');
            $table->boolean('is_correct')->default(false);
            $table->integer('score')->default(0);
            $table->string('assessment');
            $table->text('feedback');
            $table->unsignedInteger('sort_order')->default(0);
            $table->timestamps();
        });

        Schema::create('simulation_results', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('simulation_id')->constrained('simulations')->cascadeOnDelete();
            $table->integer('score')->default(0);
            $table->integer('max_score')->default(100);
            $table->unsignedInteger('correct_choices')->default(0);
            $table->unsignedInteger('total_steps')->default(1);
            $table->json('selected_answers')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->timestamps();
        });

        Schema::create('quizzes', function (Blueprint $table) {
            $table->id();
            $table->string('category')->index();
            $table->string('topic');
            $table->string('title');
            $table->string('slug')->unique();
            $table->string('difficulty')->default('Dasar')->index();
            $table->text('description');
            $table->unsignedInteger('sort_order')->default(0);
            $table->string('status')->default('published')->index();
            $table->timestamps();
        });

        Schema::create('quiz_questions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('quiz_id')->constrained('quizzes')->cascadeOnDelete();
            $table->unsignedInteger('question_number')->default(1);
            $table->string('subtopic')->nullable();
            $table->text('question_text');
            $table->text('explanation');
            $table->string('recommended_material_slug')->nullable();
            $table->timestamps();
        });

        Schema::create('quiz_options', function (Blueprint $table) {
            $table->id();
            $table->foreignId('quiz_question_id')->constrained('quiz_questions')->cascadeOnDelete();
            $table->string('option_label', 10)->default('A');
            $table->text('option_text');
            $table->boolean('is_correct')->default(false);
            $table->unsignedInteger('sort_order')->default(0);
            $table->timestamps();
        });

        Schema::create('quiz_results', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('quiz_id')->constrained('quizzes')->cascadeOnDelete();
            $table->unsignedInteger('total_questions')->default(0);
            $table->unsignedInteger('correct_answers')->default(0);
            $table->unsignedInteger('wrong_answers')->default(0);
            $table->integer('final_score')->default(0);
            $table->decimal('percentage', 5, 2)->default(0);
            $table->json('answers_detail')->nullable();
            $table->json('recommended_materials')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->timestamps();
        });

        Schema::create('missions', function (Blueprint $table) {
            $table->id();
            $table->string('category')->index();
            $table->string('title');
            $table->string('slug')->unique();
            $table->text('description');
            $table->string('illustration')->nullable();
            $table->json('instructions');
            $table->string('difficulty')->default('Dasar')->index();
            $table->integer('points')->default(50);
            $table->unsignedInteger('sort_order')->default(0);
            $table->string('status')->default('published')->index();
            $table->timestamps();
        });

        Schema::create('user_missions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('mission_id')->constrained('missions')->cascadeOnDelete();
            $table->string('status')->default('belum_dimulai')->index();
            $table->text('notes')->nullable();
            $table->timestamp('started_at')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->timestamps();

            $table->unique(['user_id', 'mission_id']);
        });

        Schema::create('badges', function (Blueprint $table) {
            $table->id();
            $table->string('code')->unique();
            $table->string('name');
            $table->text('description');
            $table->string('criteria_description');
            $table->string('icon')->default('shield');
            $table->string('category')->nullable();
            $table->integer('points_reward')->default(100);
            $table->timestamps();
        });

        Schema::create('user_badges', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('badge_id')->constrained('badges')->cascadeOnDelete();
            $table->timestamp('awarded_at');
            $table->timestamps();

            $table->unique(['user_id', 'badge_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('user_badges');
        Schema::dropIfExists('badges');
        Schema::dropIfExists('user_missions');
        Schema::dropIfExists('missions');
        Schema::dropIfExists('quiz_results');
        Schema::dropIfExists('quiz_options');
        Schema::dropIfExists('quiz_questions');
        Schema::dropIfExists('quizzes');
        Schema::dropIfExists('simulation_results');
        Schema::dropIfExists('simulation_choices');
        Schema::dropIfExists('simulation_steps');
        Schema::dropIfExists('simulations');
        Schema::dropIfExists('learning_progress');
        Schema::dropIfExists('learning_materials');
        Schema::dropIfExists('learning_categories');
    }
};

