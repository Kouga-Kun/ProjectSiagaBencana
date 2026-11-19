enum SaveSyncStatus {
  idle,
  saving,
  saved,
  error,
}

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
    this.isFavorite = false,
    this.lastPosition = 0,
    this.lastSection,
    this.progressPercent = 0,
    this.lastReadAt,
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
  final bool isFavorite;
  final int lastPosition;
  final String? lastSection;
  final int progressPercent;
  final String? lastReadAt;
  final EducationMaterialRef? previousMaterial;
  final EducationMaterialRef? nextMaterial;

  EducationMaterialItem copyWith({
    bool? isCompleted,
    bool? isFavorite,
    int? lastPosition,
    String? lastSection,
    int? progressPercent,
    String? lastReadAt,
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
      isFavorite: isFavorite ?? this.isFavorite,
      lastPosition: lastPosition ?? this.lastPosition,
      lastSection: lastSection ?? this.lastSection,
      progressPercent: progressPercent ?? this.progressPercent,
      lastReadAt: lastReadAt ?? this.lastReadAt,
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
      isFavorite: json['is_favorite'] == true,
      lastPosition: _toInt(json['last_position']),
      lastSection: json['last_section']?.toString(),
      progressPercent: _toInt(json['progress_percent']),
      lastReadAt: json['last_read_at']?.toString(),
      previousMaterial: json['previous_material'] is Map
          ? EducationMaterialRef.fromJson(
              Map<String, dynamic>.from(json['previous_material'] as Map),
            )
          : null,
      nextMaterial: json['next_material'] is Map
          ? EducationMaterialRef.fromJson(
              Map<String, dynamic>.from(json['next_material'] as Map),
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

class SimulationDraftData {
  const SimulationDraftData({
    required this.currentStepIndex,
    required this.selectedChoices,
    this.updatedAt,
  });

  final int currentStepIndex;
  final Map<int, int> selectedChoices;
  final String? updatedAt;

  factory SimulationDraftData.fromJson(Map<String, dynamic> json) {
    final parsed = <int, int>{};
    final raw = json['selected_choices'];
    if (raw is Map) {
      raw.forEach((key, value) {
        final k = int.tryParse(key.toString());
        final v = _toInt(value, -1);
        if (k != null && v > 0) {
          parsed[k] = v;
        }
      });
    }
    return SimulationDraftData(
      currentStepIndex: _toInt(json['current_step_index']),
      selectedChoices: parsed,
      updatedAt: json['updated_at']?.toString(),
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
    this.latestScore,
    this.attemptsCount = 0,
    this.draft,
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
  final int? latestScore;
  final int attemptsCount;
  final SimulationDraftData? draft;

  SimulationItem copyWith({
    bool? isCompleted,
    int? bestScore,
    int? latestScore,
    int? attemptsCount,
    SimulationDraftData? draft,
    bool clearDraft = false,
  }) {
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
      latestScore: latestScore ?? this.latestScore,
      attemptsCount: attemptsCount ?? this.attemptsCount,
      draft: clearDraft ? null : (draft ?? this.draft),
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
      latestScore:
          json['latest_score'] != null ? _toInt(json['latest_score']) : null,
      attemptsCount: _toInt(json['attempts_count']),
      draft: json['draft'] is Map
          ? SimulationDraftData.fromJson(
              Map<String, dynamic>.from(json['draft'] as Map),
            )
          : null,
    );
  }
}

class SimulationStepReview {
  const SimulationStepReview({
    required this.stepNumber,
    required this.situationTitle,
    required this.selectedChoiceLabel,
    required this.selectedChoiceText,
    required this.isCorrect,
    required this.scoreEarned,
    required this.assessment,
    required this.feedback,
    required this.recommendedAction,
  });

  final int stepNumber;
  final String situationTitle;
  final String selectedChoiceLabel;
  final String selectedChoiceText;
  final bool isCorrect;
  final int scoreEarned;
  final String assessment;
  final String feedback;
  final String recommendedAction;

  factory SimulationStepReview.fromJson(Map<String, dynamic> json) {
    return SimulationStepReview(
      stepNumber: _toInt(json['step_number'], 1),
      situationTitle: (json['situation_title'] ?? '').toString(),
      selectedChoiceLabel: (json['selected_choice_label'] ?? '-').toString(),
      selectedChoiceText: (json['selected_choice_text'] ?? '-').toString(),
      isCorrect: json['is_correct'] == true,
      scoreEarned: _toInt(json['score_earned']),
      assessment: (json['assessment'] ?? '').toString(),
      feedback: (json['feedback'] ?? '').toString(),
      recommendedAction: (json['recommended_action'] ?? '').toString(),
    );
  }
}

class SimulationSubmissionResult {
  const SimulationSubmissionResult({
    required this.score,
    required this.maxScore,
    required this.correctChoices,
    required this.totalSteps,
    required this.reviews,
    required this.safetyDisclaimer,
    this.idempotentReplay = false,
  });

  final int score;
  final int maxScore;
  final int correctChoices;
  final int totalSteps;
  final List<SimulationStepReview> reviews;
  final String safetyDisclaimer;
  final bool idempotentReplay;

  factory SimulationSubmissionResult.fromJson(
    Map<String, dynamic> json, {
    bool idempotentReplay = false,
  }) {
    final rawReviews = json['reviews'];
    final reviews = rawReviews is List
        ? rawReviews
              .whereType<Map>()
              .map(
                (r) => SimulationStepReview.fromJson(
                  Map<String, dynamic>.from(r),
                ),
              )
              .toList()
        : const <SimulationStepReview>[];

    return SimulationSubmissionResult(
      score: _toInt(json['score']),
      maxScore: _toInt(json['max_score'], 100),
      correctChoices: _toInt(json['correct_choices']),
      totalSteps: _toInt(json['total_steps']),
      reviews: reviews,
      safetyDisclaimer:
          (json['safety_disclaimer'] ??
                  'Panduan simulasi ini merupakan sarana edukasi kesiapsiagaan dan bukan pengganti instruksi petugas maupun otoritas resmi di lokasi bencana.')
              .toString(),
      idempotentReplay: idempotentReplay,
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
    this.declaredQuestionsCount,
    this.isCompleted = false,
    this.bestScore,
    this.latestScore,
    this.attemptsCount = 0,
  });

  final int id;
  final String category;
  final String topic;
  final String title;
  final String slug;
  final String difficulty;
  final String description;
  final List<QuizQuestionItem> questions;
  final int? declaredQuestionsCount;
  final bool isCompleted;
  final int? bestScore;
  final int? latestScore;
  final int attemptsCount;

  int get questionsCount =>
      questions.isNotEmpty ? questions.length : (declaredQuestionsCount ?? 0);

  QuizItem copyWith({
    List<QuizQuestionItem>? questions,
    bool? isCompleted,
    int? bestScore,
    int? latestScore,
    int? attemptsCount,
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
      declaredQuestionsCount: declaredQuestionsCount,
      isCompleted: isCompleted ?? this.isCompleted,
      bestScore: bestScore ?? this.bestScore,
      latestScore: latestScore ?? this.latestScore,
      attemptsCount: attemptsCount ?? this.attemptsCount,
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
      declaredQuestionsCount: json['questions_count'] != null
          ? _toInt(json['questions_count'])
          : null,
      isCompleted: json['is_completed'] == true,
      bestScore: json['best_score'] != null ? _toInt(json['best_score']) : null,
      latestScore:
          json['latest_score'] != null ? _toInt(json['latest_score']) : null,
      attemptsCount: _toInt(json['attempts_count']),
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
    this.bestScore,
    this.latestScore,
    this.attemptsCount = 1,
  });

  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int finalScore;
  final double percentage;
  final List<QuizQuestionReview> reviews;
  final List<EducationMaterialRef> recommendedMaterials;
  final int? bestScore;
  final int? latestScore;
  final int attemptsCount;

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
      bestScore: json['best_score'] != null ? _toInt(json['best_score']) : null,
      latestScore:
          json['latest_score'] != null ? _toInt(json['latest_score']) : null,
      attemptsCount: _toInt(json['attempts_count'], 1),
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
    this.startedAt,
    this.completedAt,
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
  final String? startedAt;
  final String? completedAt;

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

  MissionItem copyWith({
    String? userStatus,
    String? notes,
    String? startedAt,
    String? completedAt,
  }) {
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
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
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
      startedAt: json['started_at']?.toString(),
      completedAt: json['completed_at']?.toString(),
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
    this.awardedAt,
  });

  final String code;
  final String name;
  final String description;
  final String criteriaDescription;
  final String category;
  final int pointsReward;
  final bool isEarned;
  final String? awardedAt;

  BadgeItem copyWith({bool? isEarned, String? awardedAt}) {
    return BadgeItem(
      code: code,
      name: name,
      description: description,
      criteriaDescription: criteriaDescription,
      category: category,
      pointsReward: pointsReward,
      isEarned: isEarned ?? this.isEarned,
      awardedAt: awardedAt ?? this.awardedAt,
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
      awardedAt: json['awarded_at']?.toString(),
    );
  }
}

class UserLevelInfo {
  const UserLevelInfo({
    this.levelNumber = 1,
    this.levelName = 'Pemula Siaga',
    this.currentPoints = 0,
    this.nextLevelPoints = 200,
    this.levelProgressPercent = 0,
  });

  final int levelNumber;
  final String levelName;
  final int currentPoints;
  final int nextLevelPoints;
  final int levelProgressPercent;

  factory UserLevelInfo.fromJson(Map<String, dynamic> json) {
    return UserLevelInfo(
      levelNumber: _toInt(json['level_number'], 1),
      levelName: (json['level_name'] ?? 'Pemula Siaga').toString(),
      currentPoints: _toInt(json['current_points']),
      nextLevelPoints: _toInt(json['next_level_points'], 200),
      levelProgressPercent: _toInt(json['level_progress_percent']),
    );
  }
}

class ActivityLogItem {
  const ActivityLogItem({
    required this.id,
    required this.activityType,
    required this.typeLabel,
    required this.subjectTitle,
    this.category,
    this.pointsEarned = 0,
    this.createdAt,
  });

  final int id;
  final String activityType;
  final String typeLabel;
  final String subjectTitle;
  final String? category;
  final int pointsEarned;
  final String? createdAt;

  factory ActivityLogItem.fromJson(Map<String, dynamic> json) {
    return ActivityLogItem(
      id: _toInt(json['id']),
      activityType: (json['activity_type'] ?? '').toString(),
      typeLabel: (json['type_label'] ?? 'Aktivitas').toString(),
      subjectTitle: (json['subject_title'] ?? '').toString(),
      category: json['category']?.toString(),
      pointsEarned: _toInt(json['points_earned']),
      createdAt: json['created_at']?.toString(),
    );
  }
}

class DailyActivityPoint {
  const DailyActivityPoint({
    required this.date,
    required this.label,
    required this.count,
  });

  final String date;
  final String label;
  final int count;

  factory DailyActivityPoint.fromJson(Map<String, dynamic> json) {
    return DailyActivityPoint(
      date: (json['date'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
      count: _toInt(json['count']),
    );
  }
}

class ReminderItem {
  const ReminderItem({
    required this.type,
    required this.title,
    required this.message,
    required this.targetType,
    this.targetSlug,
    this.category,
    this.progressPercent = 0,
  });

  final String type;
  final String title;
  final String message;
  final String targetType;
  final String? targetSlug;
  final String? category;
  final int progressPercent;

  factory ReminderItem.fromJson(Map<String, dynamic> json) {
    return ReminderItem(
      type: (json['type'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      targetType: (json['target_type'] ?? 'material').toString(),
      targetSlug: json['target_slug']?.toString(),
      category: json['category']?.toString(),
      progressPercent: _toInt(json['progress_percent']),
    );
  }
}

class ReminderPreference {
  const ReminderPreference({
    this.isEnabled = false,
    this.reminderTime = '19:00',
    this.frequency = 'daily',
    this.remindUnfinishedMaterials = true,
    this.remindPendingMissions = true,
    this.remindInactiveLearning = true,
    this.lastRemindedAt,
  });

  final bool isEnabled;
  final String reminderTime;
  final String frequency;
  final bool remindUnfinishedMaterials;
  final bool remindPendingMissions;
  final bool remindInactiveLearning;
  final String? lastRemindedAt;

  ReminderPreference copyWith({
    bool? isEnabled,
    String? reminderTime,
    String? frequency,
    bool? remindUnfinishedMaterials,
    bool? remindPendingMissions,
    bool? remindInactiveLearning,
  }) {
    return ReminderPreference(
      isEnabled: isEnabled ?? this.isEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      frequency: frequency ?? this.frequency,
      remindUnfinishedMaterials:
          remindUnfinishedMaterials ?? this.remindUnfinishedMaterials,
      remindPendingMissions:
          remindPendingMissions ?? this.remindPendingMissions,
      remindInactiveLearning:
          remindInactiveLearning ?? this.remindInactiveLearning,
      lastRemindedAt: lastRemindedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'is_enabled': isEnabled,
    'reminder_time': reminderTime,
    'frequency': frequency,
    'remind_unfinished_materials': remindUnfinishedMaterials,
    'remind_pending_missions': remindPendingMissions,
    'remind_inactive_learning': remindInactiveLearning,
  };

  factory ReminderPreference.fromJson(Map<String, dynamic> json) {
    return ReminderPreference(
      isEnabled: json['is_enabled'] == true,
      reminderTime: (json['reminder_time'] ?? '19:00').toString(),
      frequency: (json['frequency'] ?? 'daily').toString(),
      remindUnfinishedMaterials: json['remind_unfinished_materials'] != false,
      remindPendingMissions: json['remind_pending_missions'] != false,
      remindInactiveLearning: json['remind_inactive_learning'] != false,
      lastRemindedAt: json['last_reminded_at']?.toString(),
    );
  }
}

class QuizHistoryEntry {
  const QuizHistoryEntry({
    required this.id,
    required this.quizTitle,
    required this.category,
    required this.finalScore,
    required this.correctAnswers,
    required this.totalQuestions,
    this.completedAt,
  });

  final int id;
  final String quizTitle;
  final String category;
  final int finalScore;
  final int correctAnswers;
  final int totalQuestions;
  final String? completedAt;

  factory QuizHistoryEntry.fromJson(Map<String, dynamic> json) {
    return QuizHistoryEntry(
      id: _toInt(json['id']),
      quizTitle: (json['quiz_title'] ?? 'Kuis').toString(),
      category: (json['category'] ?? 'Gempa Bumi').toString(),
      finalScore: _toInt(json['final_score']),
      correctAnswers: _toInt(json['correct_answers']),
      totalQuestions: _toInt(json['total_questions']),
      completedAt: json['completed_at']?.toString(),
    );
  }
}

class SimulationHistoryEntry {
  const SimulationHistoryEntry({
    required this.id,
    required this.simulationTitle,
    required this.category,
    required this.score,
    required this.correctChoices,
    required this.totalSteps,
    this.completedAt,
  });

  final int id;
  final String simulationTitle;
  final String category;
  final int score;
  final int correctChoices;
  final int totalSteps;
  final String? completedAt;

  factory SimulationHistoryEntry.fromJson(Map<String, dynamic> json) {
    return SimulationHistoryEntry(
      id: _toInt(json['id']),
      simulationTitle: (json['simulation_title'] ?? 'Simulasi').toString(),
      category: (json['category'] ?? 'Gempa Bumi').toString(),
      score: _toInt(json['score']),
      correctChoices: _toInt(json['correct_choices']),
      totalSteps: _toInt(json['total_steps']),
      completedAt: json['completed_at']?.toString(),
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
    this.level = const UserLevelInfo(),
    this.earthquakePercentage = 0,
    this.tsunamiPercentage = 0,
    this.quizAverageScore = 0,
    this.quizBestScore = 0,
    this.quizLatestScore,
    this.recentActivities = const <ActivityLogItem>[],
    this.activityChart = const <DailyActivityPoint>[],
    this.quizHistory = const <QuizHistoryEntry>[],
    this.simulationHistory = const <SimulationHistoryEntry>[],
    this.reminderPreference = const ReminderPreference(),
    this.pendingReminders = const <ReminderItem>[],
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
  final UserLevelInfo level;
  final int earthquakePercentage;
  final int tsunamiPercentage;
  final int quizAverageScore;
  final int quizBestScore;
  final int? quizLatestScore;
  final List<ActivityLogItem> recentActivities;
  final List<DailyActivityPoint> activityChart;
  final List<QuizHistoryEntry> quizHistory;
  final List<SimulationHistoryEntry> simulationHistory;
  final ReminderPreference reminderPreference;
  final List<ReminderItem> pendingReminders;

  int get earnedBadgesCount => badges.where((b) => b.isEarned).length;

  static const EducationUserProgress empty = EducationUserProgress(
    authenticated: false,
    hasActivity: false,
    initialMessage:
        'Masuk ke akun SiagaBencana untuk memuat progres belajar dan pencapaian Anda.',
    overallPercentage: 0,
    totalPoints: 0,
    materialsCompleted: 0,
    materialsTotal: 24,
    earthquakeMaterialsCompleted: 0,
    earthquakeMaterialsTotal: 12,
    tsunamiMaterialsCompleted: 0,
    tsunamiMaterialsTotal: 12,
    simulationsCompleted: 0,
    simulationsTotal: 12,
    quizzesCompleted: 0,
    quizzesTotal: 4,
    earthquakeQuizAverage: 0,
    tsunamiQuizAverage: 0,
    missionsCompleted: 0,
    missionsTotal: 14,
    badges: <BadgeItem>[],
  );

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

    final parsedActivities = json['recent_activities'] is List
        ? (json['recent_activities'] as List)
              .whereType<Map>()
              .map(
                (e) => ActivityLogItem.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList()
        : const <ActivityLogItem>[];

    final parsedChart = json['activity_chart'] is List
        ? (json['activity_chart'] as List)
              .whereType<Map>()
              .map(
                (e) =>
                    DailyActivityPoint.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList()
        : const <DailyActivityPoint>[];

    final parsedQuizHistory = qz['history'] is List
        ? (qz['history'] as List)
              .whereType<Map>()
              .map(
                (e) => QuizHistoryEntry.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList()
        : const <QuizHistoryEntry>[];

    final parsedSimHistory = sim['history'] is List
        ? (sim['history'] as List)
              .whereType<Map>()
              .map(
                (e) => SimulationHistoryEntry.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList()
        : const <SimulationHistoryEntry>[];

    final parsedReminders = json['pending_reminders'] is List
        ? (json['pending_reminders'] as List)
              .whereType<Map>()
              .map((e) => ReminderItem.fromJson(Map<String, dynamic>.from(e)))
              .toList()
        : const <ReminderItem>[];

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
      earthquakePercentage: _toInt(mat['earthquake_percentage']),
      tsunamiPercentage: _toInt(mat['tsunami_percentage']),
      simulationsCompleted: _toInt(sim['completed'] ?? sim['completed_count']),
      simulationsTotal: _toInt(sim['total'] ?? sim['total_count'], 12),
      quizzesCompleted: _toInt(
        qz['completed_quizzes'] ?? qz['completed_count'],
      ),
      quizzesTotal: _toInt(qz['total_quizzes'] ?? qz['total_count'], 4),
      quizAverageScore: _toInt(qz['average_score']),
      quizBestScore: _toInt(qz['best_score']),
      quizLatestScore:
          qz['latest_score'] != null ? _toInt(qz['latest_score']) : null,
      earthquakeQuizAverage: _toInt(qz['earthquake_best_average']),
      tsunamiQuizAverage: _toInt(qz['tsunami_best_average']),
      missionsCompleted: _toInt(ms['completed'] ?? ms['completed_count']),
      missionsTotal: _toInt(ms['total'] ?? ms['total_count'], 14),
      badges: parsedBadges,
      level: json['level'] is Map
          ? UserLevelInfo.fromJson(
              Map<String, dynamic>.from(json['level'] as Map),
            )
          : const UserLevelInfo(),
      recentActivities: parsedActivities,
      activityChart: parsedChart,
      quizHistory: parsedQuizHistory,
      simulationHistory: parsedSimHistory,
      reminderPreference: json['reminder_preference'] is Map
          ? ReminderPreference.fromJson(
              Map<String, dynamic>.from(json['reminder_preference'] as Map),
            )
          : const ReminderPreference(),
      pendingReminders: parsedReminders,
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
