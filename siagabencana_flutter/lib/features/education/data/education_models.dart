class EducationCategorySummary {
  const EducationCategorySummary({
    required this.name,
    required this.slug,
    required this.description,
    required this.materialsCount,
    required this.simulationsCount,
    required this.quizzesCount,
    required this.missionsCount,
  });

  final String name;
  final String slug;
  final String description;
  final int materialsCount;
  final int simulationsCount;
  final int quizzesCount;
  final int missionsCount;

  factory EducationCategorySummary.fromJson(Map<String, dynamic> json) {
    return EducationCategorySummary(
      name: (json['name'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      materialsCount: _toInt(json['materials_count'], 12),
      simulationsCount: _toInt(json['simulations_count'], 6),
      quizzesCount: _toInt(json['quizzes_count'], 2),
      missionsCount: _toInt(json['missions_count'], 7),
    );
  }
}

class EducationMaterialRef {
  const EducationMaterialRef({
    required this.id,
    required this.title,
    required this.slug,
    required this.category,
  });

  final int id;
  final String title;
  final String slug;
  final String category;

  factory EducationMaterialRef.fromJson(Map<String, dynamic> json) {
    return EducationMaterialRef(
      id: _toInt(json['id']),
      title: (json['title'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      category: (json['category'] ?? 'Gempa Bumi').toString(),
    );
  }
}

class EducationMaterialItem {
  const EducationMaterialItem({
    required this.id,
    required this.category,
    required this.title,
    required this.slug,
    required this.difficulty,
    required this.summary,
    required this.content,
    required this.keyPoints,
    required this.actionSteps,
    required this.thingsToAvoid,
    required this.sourceReference,
    this.imageUrl,
    this.sortOrder = 1,
    this.status = 'published',
    this.isCompleted = false,
    this.previousMaterial,
    this.nextMaterial,
  });

  final int id;
  final String category;
  final String title;
  final String slug;
  final String difficulty;
  final String summary;
  final String content;
  final List<String> keyPoints;
  final List<String> actionSteps;
  final List<String> thingsToAvoid;
  final String sourceReference;
  final String? imageUrl;
  final int sortOrder;
  final String status;
  final bool isCompleted;
  final EducationMaterialRef? previousMaterial;
  final EducationMaterialRef? nextMaterial;

  EducationMaterialItem copyWith({
    bool? isCompleted,
    EducationMaterialRef? previousMaterial,
    EducationMaterialRef? nextMaterial,
  }) {
    return EducationMaterialItem(
      id: id,
      category: category,
      title: title,
      slug: slug,
      difficulty: difficulty,
      summary: summary,
      content: content,
      keyPoints: keyPoints,
      actionSteps: actionSteps,
      thingsToAvoid: thingsToAvoid,
      sourceReference: sourceReference,
      imageUrl: imageUrl,
      sortOrder: sortOrder,
      status: status,
      isCompleted: isCompleted ?? this.isCompleted,
      previousMaterial: previousMaterial ?? this.previousMaterial,
      nextMaterial: nextMaterial ?? this.nextMaterial,
    );
  }

  factory EducationMaterialItem.fromJson(Map<String, dynamic> json) {
    return EducationMaterialItem(
      id: _toInt(json['id']),
      category: (json['category'] ?? 'Gempa Bumi').toString(),
      title: (json['title'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      difficulty: (json['difficulty'] ?? 'Dasar').toString(),
      summary: (json['summary'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      keyPoints: _toStringList(json['key_points']),
      actionSteps: _toStringList(json['action_steps']),
      thingsToAvoid: _toStringList(json['things_to_avoid']),
      sourceReference: (json['source_reference'] ?? 'BNPB & BMKG').toString(),
      imageUrl: json['image_url']?.toString(),
      sortOrder: _toInt(json['sort_order'], 1),
      status: (json['status'] ?? 'published').toString(),
      isCompleted: json['is_completed'] == true,
      previousMaterial: json['previous_material'] is Map<String, dynamic>
          ? EducationMaterialRef.fromJson(
              json['previous_material'] as Map<String, dynamic>,
            )
          : null,
      nextMaterial: json['next_material'] is Map<String, dynamic>
          ? EducationMaterialRef.fromJson(
              json['next_material'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class SimulationChoiceItem {
  const SimulationChoiceItem({
    required this.id,
    required this.label,
    required this.choiceText,
    required this.isCorrect,
    required this.score,
    required this.assessment,
    required this.feedback,
  });

  final int id;
  final String label;
  final String choiceText;
  final bool isCorrect;
  final int score;
  final String assessment;
  final String feedback;

  factory SimulationChoiceItem.fromJson(Map<String, dynamic> json) {
    return SimulationChoiceItem(
      id: _toInt(json['id']),
      label: (json['label'] ?? 'A').toString(),
      choiceText: (json['choice_text'] ?? '').toString(),
      isCorrect: json['is_correct'] == true,
      score: _toInt(json['score']),
      assessment: (json['assessment'] ?? 'Evaluasi').toString(),
      feedback: (json['feedback'] ?? '').toString(),
    );
  }
}

class SimulationStepItem {
  const SimulationStepItem({
    required this.id,
    required this.stepNumber,
    required this.situationTitle,
    required this.situationText,
    required this.recommendedAction,
    required this.choices,
  });

  final int id;
  final int stepNumber;
  final String situationTitle;
  final String situationText;
  final String recommendedAction;
  final List<SimulationChoiceItem> choices;

  factory SimulationStepItem.fromJson(Map<String, dynamic> json) {
    final rawChoices = json['choices'];
    final parsedChoices = rawChoices is List
        ? rawChoices
              .whereType<Map>()
              .map(
                (item) => SimulationChoiceItem.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
        : const <SimulationChoiceItem>[];

    return SimulationStepItem(
      id: _toInt(json['id']),
      stepNumber: _toInt(json['step_number'], 1),
      situationTitle: (json['situation_title'] ?? '').toString(),
      situationText: (json['situation_text'] ?? '').toString(),
      recommendedAction: (json['recommended_action'] ?? '').toString(),
      choices: parsedChoices,
    );
  }
}

class SimulationItem {
  const SimulationItem({
    required this.id,
    required this.category,
    required this.title,
    required this.slug,
    required this.difficulty,
    required this.description,
    required this.scenarioContext,
    required this.safetyReference,
    required this.steps,
    this.isCompleted = false,
    this.bestScore,
  });

  final int id;
  final String category;
  final String title;
  final String slug;
  final String difficulty;
  final String description;
  final String scenarioContext;
  final String safetyReference;
  final List<SimulationStepItem> steps;
  final bool isCompleted;
  final int? bestScore;

  SimulationItem copyWith({bool? isCompleted, int? bestScore}) {
    return SimulationItem(
      id: id,
      category: category,
      title: title,
      slug: slug,
      difficulty: difficulty,
      description: description,
      scenarioContext: scenarioContext,
      safetyReference: safetyReference,
      steps: steps,
      isCompleted: isCompleted ?? this.isCompleted,
      bestScore: bestScore ?? this.bestScore,
    );
  }

  factory SimulationItem.fromJson(Map<String, dynamic> json) {
    final rawSteps = json['steps'];
    final parsedSteps = rawSteps is List
        ? rawSteps
              .whereType<Map>()
              .map(
                (item) => SimulationStepItem.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
        : const <SimulationStepItem>[];

    return SimulationItem(
      id: _toInt(json['id']),
      category: (json['category'] ?? 'Gempa Bumi').toString(),
      title: (json['title'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      difficulty: (json['difficulty'] ?? 'Dasar').toString(),
      description: (json['description'] ?? '').toString(),
      scenarioContext: (json['scenario_context'] ?? '').toString(),
      safetyReference: (json['safety_reference'] ?? 'BNPB & BMKG').toString(),
      steps: parsedSteps,
      isCompleted: json['is_completed'] == true,
      bestScore: json['best_score'] != null ? _toInt(json['best_score']) : null,
    );
  }
}

class QuizOptionItem {
  const QuizOptionItem({
    required this.id,
    required this.optionLabel,
    required this.optionText,
    this.isCorrect = false,
  });

  final int id;
  final String optionLabel;
  final String optionText;
  final bool isCorrect;

  factory QuizOptionItem.fromJson(Map<String, dynamic> json) {
    return QuizOptionItem(
      id: _toInt(json['id']),
      optionLabel: (json['option_label'] ?? 'A').toString(),
      optionText: (json['option_text'] ?? '').toString(),
      isCorrect: json['is_correct'] == true,
    );
  }
}

class QuizQuestionItem {
  const QuizQuestionItem({
    required this.id,
    required this.questionNumber,
    required this.subtopic,
    required this.questionText,
    required this.options,
    this.explanation = '',
    this.recommendedMaterialSlug,
  });

  final int id;
  final int questionNumber;
  final String subtopic;
  final String questionText;
  final List<QuizOptionItem> options;
  final String explanation;
  final String? recommendedMaterialSlug;

  factory QuizQuestionItem.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];
    final parsedOptions = rawOptions is List
        ? rawOptions
              .whereType<Map>()
              .map(
                (item) =>
                    QuizOptionItem.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList()
        : const <QuizOptionItem>[];

    return QuizQuestionItem(
      id: _toInt(json['id']),
      questionNumber: _toInt(json['question_number'], 1),
      subtopic: (json['subtopic'] ?? '').toString(),
      questionText: (json['question_text'] ?? '').toString(),
      options: parsedOptions,
      explanation: (json['explanation'] ?? '').toString(),
      recommendedMaterialSlug: json['recommended_material_slug']?.toString(),
    );
  }
}

class QuizItem {
  const QuizItem({
    required this.id,
    required this.category,
    required this.topic,
    required this.title,
    required this.slug,
    required this.difficulty,
    required this.description,
    required this.questions,
    this.isCompleted = false,
    this.bestScore,
  });

  final int id;
  final String category;
  final String topic;
  final String title;
  final String slug;
  final String difficulty;
  final String description;
  final List<QuizQuestionItem> questions;
  final bool isCompleted;
  final int? bestScore;

  int get questionsCount => questions.length;

  QuizItem copyWith({
    List<QuizQuestionItem>? questions,
    bool? isCompleted,
    int? bestScore,
  }) {
    return QuizItem(
      id: id,
      category: category,
      topic: topic,
      title: title,
      slug: slug,
      difficulty: difficulty,
      description: description,
      questions: questions ?? this.questions,
      isCompleted: isCompleted ?? this.isCompleted,
      bestScore: bestScore ?? this.bestScore,
    );
  }

  factory QuizItem.fromJson(Map<String, dynamic> json) {
    final rawQuestions = json['questions'];
    final parsedQuestions = rawQuestions is List
        ? rawQuestions
              .whereType<Map>()
              .map(
                (item) =>
                    QuizQuestionItem.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList()
        : const <QuizQuestionItem>[];

    return QuizItem(
      id: _toInt(json['id']),
      category: (json['category'] ?? 'Gempa Bumi').toString(),
      topic: (json['topic'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      difficulty: (json['difficulty'] ?? 'Dasar').toString(),
      description: (json['description'] ?? '').toString(),
      questions: parsedQuestions,
      isCompleted: json['is_completed'] == true,
      bestScore: json['best_score'] != null ? _toInt(json['best_score']) : null,
    );
  }
}

class QuizQuestionReview {
  const QuizQuestionReview({
    required this.questionNumber,
    required this.subtopic,
    required this.questionText,
    required this.selectedOptionLabel,
    required this.selectedOptionText,
    required this.correctOptionLabel,
    required this.correctOptionText,
    required this.isCorrect,
    required this.explanation,
    this.recommendedMaterialSlug,
  });

  final int questionNumber;
  final String subtopic;
  final String questionText;
  final String selectedOptionLabel;
  final String selectedOptionText;
  final String correctOptionLabel;
  final String correctOptionText;
  final bool isCorrect;
  final String explanation;
  final String? recommendedMaterialSlug;

  factory QuizQuestionReview.fromJson(Map<String, dynamic> json) {
    return QuizQuestionReview(
      questionNumber: _toInt(json['question_number'], 1),
      subtopic: (json['subtopic'] ?? '').toString(),
      questionText: (json['question_text'] ?? '').toString(),
      selectedOptionLabel: (json['selected_option_label'] ?? '-').toString(),
      selectedOptionText: (json['selected_option_text'] ?? '-').toString(),
      correctOptionLabel: (json['correct_option_label'] ?? 'A').toString(),
      correctOptionText: (json['correct_option_text'] ?? '').toString(),
      isCorrect: json['is_correct'] == true,
      explanation: (json['explanation'] ?? '').toString(),
      recommendedMaterialSlug: json['recommended_material_slug']?.toString(),
    );
  }
}

class QuizSubmissionResult {
  const QuizSubmissionResult({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.finalScore,
    required this.percentage,
    required this.reviews,
    required this.recommendedMaterials,
  });

  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int finalScore;
  final double percentage;
  final List<QuizQuestionReview> reviews;
  final List<EducationMaterialRef> recommendedMaterials;

  factory QuizSubmissionResult.fromJson(Map<String, dynamic> json) {
    final rawReviews = json['reviews'];
    final parsedReviews = rawReviews is List
        ? rawReviews
              .whereType<Map>()
              .map(
                (item) =>
                    QuizQuestionReview.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList()
        : const <QuizQuestionReview>[];

    final rawRecs = json['recommended_materials'];
    final parsedRecs = rawRecs is List
        ? rawRecs
              .whereType<Map>()
              .map(
                (item) => EducationMaterialRef.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
        : const <EducationMaterialRef>[];

    return QuizSubmissionResult(
      totalQuestions: _toInt(json['total_questions']),
      correctAnswers: _toInt(json['correct_answers']),
      wrongAnswers: _toInt(json['wrong_answers']),
      finalScore: _toInt(json['final_score']),
      percentage: double.tryParse((json['percentage'] ?? 0).toString()) ?? 0.0,
      reviews: parsedReviews,
      recommendedMaterials: parsedRecs,
    );
  }
}

class MissionItem {
  const MissionItem({
    required this.id,
    required this.category,
    required this.title,
    required this.slug,
    required this.description,
    required this.illustration,
    required this.instructions,
    required this.difficulty,
    required this.points,
    this.userStatus = 'belum_dimulai',
    this.notes,
  });

  final int id;
  final String category;
  final String title;
  final String slug;
  final String description;
  final String illustration;
  final List<String> instructions;
  final String difficulty;
  final int points;
  final String userStatus;
  final String? notes;

  String get userStatusLabel {
    switch (userStatus) {
      case 'sedang_dikerjakan':
        return 'Sedang dikerjakan';
      case 'selesai':
        return 'Selesai';
      default:
        return 'Belum dimulai';
    }
  }

  MissionItem copyWith({String? userStatus, String? notes}) {
    return MissionItem(
      id: id,
      category: category,
      title: title,
      slug: slug,
      description: description,
      illustration: illustration,
      instructions: instructions,
      difficulty: difficulty,
      points: points,
      userStatus: userStatus ?? this.userStatus,
      notes: notes ?? this.notes,
    );
  }

  factory MissionItem.fromJson(Map<String, dynamic> json) {
    return MissionItem(
      id: _toInt(json['id']),
      category: (json['category'] ?? 'Gempa Bumi').toString(),
      title: (json['title'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      illustration: (json['illustration'] ?? 'shield').toString(),
      instructions: _toStringList(json['instructions']),
      difficulty: (json['difficulty'] ?? 'Dasar').toString(),
      points: _toInt(json['points'], 50),
      userStatus: (json['user_status'] ?? 'belum_dimulai').toString(),
      notes: json['notes']?.toString(),
    );
  }
}

class BadgeItem {
  const BadgeItem({
    required this.code,
    required this.name,
    required this.description,
    required this.criteriaDescription,
    required this.category,
    required this.pointsReward,
    this.isEarned = false,
  });

  final String code;
  final String name;
  final String description;
  final String criteriaDescription;
  final String category;
  final int pointsReward;
  final bool isEarned;

  BadgeItem copyWith({bool? isEarned}) {
    return BadgeItem(
      code: code,
      name: name,
      description: description,
      criteriaDescription: criteriaDescription,
      category: category,
      pointsReward: pointsReward,
      isEarned: isEarned ?? this.isEarned,
    );
  }

  factory BadgeItem.fromJson(Map<String, dynamic> json) {
    return BadgeItem(
      code: (json['code'] ?? json['slug'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      criteriaDescription:
          (json['criteria_description'] ?? json['criteria_text'] ?? '')
              .toString(),
      category: (json['category'] ?? 'Umum').toString(),
      pointsReward: _toInt(json['points_reward'], 100),
      isEarned: json['is_earned'] == true,
    );
  }
}

class EducationUserProgress {
  const EducationUserProgress({
    required this.authenticated,
    required this.hasActivity,
    required this.initialMessage,
    required this.overallPercentage,
    required this.totalPoints,
    required this.materialsCompleted,
    required this.materialsTotal,
    required this.earthquakeMaterialsCompleted,
    required this.earthquakeMaterialsTotal,
    required this.tsunamiMaterialsCompleted,
    required this.tsunamiMaterialsTotal,
    required this.simulationsCompleted,
    required this.simulationsTotal,
    required this.quizzesCompleted,
    required this.quizzesTotal,
    required this.earthquakeQuizAverage,
    required this.tsunamiQuizAverage,
    required this.missionsCompleted,
    required this.missionsTotal,
    required this.badges,
  });

  final bool authenticated;
  final bool hasActivity;
  final String initialMessage;
  final int overallPercentage;
  final int totalPoints;
  final int materialsCompleted;
  final int materialsTotal;
  final int earthquakeMaterialsCompleted;
  final int earthquakeMaterialsTotal;
  final int tsunamiMaterialsCompleted;
  final int tsunamiMaterialsTotal;
  final int simulationsCompleted;
  final int simulationsTotal;
  final int quizzesCompleted;
  final int quizzesTotal;
  final int earthquakeQuizAverage;
  final int tsunamiQuizAverage;
  final int missionsCompleted;
  final int missionsTotal;
  final List<BadgeItem> badges;

  int get earnedBadgesCount => badges.where((b) => b.isEarned).length;

  factory EducationUserProgress.fromJson(Map<String, dynamic> json) {
    final mat = json['materials'] is Map
        ? Map<String, dynamic>.from(json['materials'] as Map)
        : const <String, dynamic>{};
    final sim = json['simulations'] is Map
        ? Map<String, dynamic>.from(json['simulations'] as Map)
        : const <String, dynamic>{};
    final qz = json['quizzes'] is Map
        ? Map<String, dynamic>.from(json['quizzes'] as Map)
        : const <String, dynamic>{};
    final ms = json['missions'] is Map
        ? Map<String, dynamic>.from(json['missions'] as Map)
        : const <String, dynamic>{};

    List<BadgeItem> parsedBadges = const <BadgeItem>[];
    final rawBadges = json['badges'];
    if (rawBadges is Map && rawBadges['items'] is List) {
      parsedBadges = (rawBadges['items'] as List)
          .whereType<Map>()
          .map((e) => BadgeItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } else if (rawBadges is List) {
      parsedBadges = rawBadges
          .whereType<Map>()
          .map((e) => BadgeItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    return EducationUserProgress(
      authenticated: json['authenticated'] == true,
      hasActivity: json['has_activity'] == true,
      initialMessage:
          (json['initial_message'] ??
                  json['initial_state_message'] ??
                  'Belum ada aktivitas pembelajaran. Mulai pelajari materi Gempa Bumi atau Tsunami!')
              .toString(),
      overallPercentage: _toInt(
        json['overall_percentage'] ?? json['overall_progress_percentage'],
      ),
      totalPoints: _toInt(json['total_points']),
      materialsCompleted: _toInt(mat['completed'] ?? mat['completed_count']),
      materialsTotal: _toInt(mat['total'] ?? mat['total_count'], 24),
      earthquakeMaterialsCompleted: _toInt(mat['earthquake_completed']),
      earthquakeMaterialsTotal: _toInt(mat['earthquake_total'], 12),
      tsunamiMaterialsCompleted: _toInt(mat['tsunami_completed']),
      tsunamiMaterialsTotal: _toInt(mat['tsunami_total'], 12),
      simulationsCompleted: _toInt(sim['completed'] ?? sim['completed_count']),
      simulationsTotal: _toInt(sim['total'] ?? sim['total_count'], 12),
      quizzesCompleted: _toInt(
        qz['completed_quizzes'] ?? qz['completed_count'],
      ),
      quizzesTotal: _toInt(qz['total_quizzes'] ?? qz['total_count'], 4),
      earthquakeQuizAverage: _toInt(qz['earthquake_best_average']),
      tsunamiQuizAverage: _toInt(qz['tsunami_best_average']),
      missionsCompleted: _toInt(ms['completed'] ?? ms['completed_count']),
      missionsTotal: _toInt(ms['total'] ?? ms['total_count'], 14),
      badges: parsedBadges,
    );
  }
}

int _toInt(dynamic value, [int fallback = 0]) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse((value ?? '').toString()) ?? fallback;
}

List<String> _toStringList(dynamic value) {
  if (value is List) {
    return value
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
  return const <String>[];
}
