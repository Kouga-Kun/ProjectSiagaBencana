import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/siaga_theme.dart';
import '../../../app/widgets/siaga_components.dart';
import '../data/education_data_service.dart';
import 'education_material_detail_page.dart';

class EducationQuizPage extends StatefulWidget {
  const EducationQuizPage({
    super.key,
    required this.quiz,
    required this.service,
  });

  final QuizItem quiz;
  final EducationDataService service;

  @override
  State<EducationQuizPage> createState() => _EducationQuizPageState();
}

class _EducationQuizPageState extends State<EducationQuizPage> {
  QuizItem? _loadedQuiz;
  bool _loadingQuestions = true;
  String? _loadError;
  int _currentIndex = 0;
  final Map<int, int> _selectedOptionIds = <int, int>{};
  QuizSubmissionResult? _submissionResult;
  bool _isSubmitting = false;
  String? _submitError;
  late String _clientSubmissionId;

  EducationDataService get _service => widget.service;

  @override
  void initState() {
    super.initState();
    _clientSubmissionId = _service.generateClientSubmissionId(
      'quiz',
      widget.quiz.id,
    );
    unawaited(_loadQuestions());
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _loadingQuestions = true;
      _loadError = null;
    });
    try {
      final fetched = await _service.fetchQuizDetail(widget.quiz.slug);
      if (!mounted) return;
      setState(() {
        _loadedQuiz = fetched;
        _loadingQuestions = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingQuestions = false;
        _loadError = e.toString();
      });
    }
  }

  Future<void> _submitQuiz() async {
    final quiz = _loadedQuiz;
    if (quiz == null || _isSubmitting) return;

    if (_selectedOptionIds.length < quiz.questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Jawab seluruh pertanyaan kuis terlebih dahulu sebelum mengirim.',
          ),
          backgroundColor: SiagaColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    try {
      final result = await _service.submitQuiz(
        quiz,
        Map<int, int>.from(_selectedOptionIds),
        clientSubmissionId: _clientSubmissionId,
      );
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _submissionResult = result;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _submitError = e.toString();
      });
    }
  }

  void _restartQuiz() {
    setState(() {
      _currentIndex = 0;
      _selectedOptionIds.clear();
      _submissionResult = null;
      _submitError = null;
      _clientSubmissionId = _service.generateClientSubmissionId(
        'quiz',
        widget.quiz.id,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final qz = _loadedQuiz ?? widget.quiz;
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = SiagaBreakpoints.pageHorizontalPadding(width);

    return Scaffold(
      backgroundColor: SiagaColors.background,
      appBar: AppBar(title: Text('Kuis ${qz.category}')),
      body: _loadingQuestions
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SiagaEmptyState(
                  icon: Icons.quiz_outlined,
                  title: 'Gagal memuat soal kuis',
                  message: _loadError!,
                  action: FilledButton.icon(
                    onPressed: _loadQuestions,
                    icon: const Icon(Icons.refresh_rounded, size: 17),
                    label: const Text('Muat Ulang Kuis'),
                  ),
                ),
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                22,
                horizontalPadding,
                48,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: _submissionResult != null
                      ? _buildResultView(_submissionResult!)
                      : _buildQuestionView(qz),
                ),
              ),
            ),
    );
  }

  Widget _buildQuestionView(QuizItem qz) {
    if (qz.questions.isEmpty) {
      return const SiagaEmptyState(
        icon: Icons.quiz_outlined,
        title: 'Soal kuis belum tersedia',
        message: 'Belum ada pertanyaan yang terdaftar pada kuis ini.',
      );
    }

    final question = qz.questions[_currentIndex];
    final total = qz.questions.length;
    final answeredCount = _selectedOptionIds.length;
    final selectedOptId = _selectedOptionIds[question.id];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SiagaCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Soal ${_currentIndex + 1} dari $total',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: SiagaColors.navy,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SiagaStatusDot(
                    label: 'Terjawab $answeredCount/$total',
                    tone: answeredCount == total
                        ? SiagaTone.success
                        : SiagaTone.info,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(SiagaRadius.pill),
                child: LinearProgressIndicator(
                  value: total > 0 ? answeredCount / total : 0,
                  minHeight: 7,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${qz.title} · Tingkat ${qz.difficulty}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        SiagaCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (question.subtopic.isNotEmpty) ...[
                SiagaBadge(
                  label: question.subtopic,
                  tone: SiagaTone.info,
                  compact: true,
                ),
                const SizedBox(height: 12),
              ],
              Text(
                question.questionText,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              for (final opt in question.options)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(SiagaRadius.md),
                      onTap: () {
                        setState(() {
                          _selectedOptionIds[question.id] = opt.id;
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: selectedOptId == opt.id
                              ? SiagaColors.primarySoft
                              : SiagaColors.surfaceSubtle,
                          borderRadius: BorderRadius.circular(SiagaRadius.md),
                          border: Border.all(
                            color: selectedOptId == opt.id
                                ? SiagaColors.navy
                                : SiagaColors.border,
                            width: selectedOptId == opt.id ? 1.6 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: selectedOptId == opt.id
                                    ? SiagaColors.navy
                                    : SiagaColors.surface,
                                borderRadius: BorderRadius.circular(
                                  SiagaRadius.sm,
                                ),
                                border: Border.all(
                                  color: selectedOptId == opt.id
                                      ? SiagaColors.navy
                                      : SiagaColors.borderStrong,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                opt.optionLabel,
                                style: TextStyle(
                                  color: selectedOptId == opt.id
                                      ? Colors.white
                                      : SiagaColors.ink,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                opt.optionText,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: SiagaColors.ink,
                                      fontWeight: selectedOptId == opt.id
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        if (_submitError != null) ...[
          const SizedBox(height: 14),
          SiagaNotice(
            title: 'Pengiriman jawaban belum berhasil',
            message: _submitError!,
            tone: SiagaTone.danger,
            icon: Icons.error_outline_rounded,
          ),
        ],

        const SizedBox(height: 18),
        Row(
          children: [
            if (_currentIndex > 0)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _currentIndex--),
                  icon: const Icon(Icons.arrow_back_rounded, size: 17),
                  label: const Text('Soal Sebelumnya'),
                ),
              ),
            if (_currentIndex > 0) const SizedBox(width: 12),
            Expanded(
              child: _currentIndex < total - 1
                  ? FilledButton.icon(
                      onPressed: () => setState(() => _currentIndex++),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 17),
                      label: const Text('Soal Berikutnya'),
                    )
                  : FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: SiagaColors.safe,
                      ),
                      onPressed: _isSubmitting ? null : _submitQuiz,
                      icon: _isSubmitting
                          ? const SizedBox.square(
                              dimension: 17,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              _submitError != null
                                  ? Icons.refresh_rounded
                                  : Icons.check_circle_outline_rounded,
                              size: 18,
                            ),
                      label: Text(
                        _isSubmitting
                            ? 'Menilai di Server...'
                            : _submitError != null
                            ? 'Coba Kirim Ulang Kuis'
                            : 'Selesai & Kirim Jawaban',
                      ),
                    ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Kunci jawaban dan pembahasan ditampilkan setelah seluruh jawaban dikirim dan divalidasi oleh server.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildResultView(QuizSubmissionResult result) {
    final passed = result.finalScore >= 75;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SiagaCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              SiagaBadge(
                label: 'TERVALIDASI SERVER',
                tone: passed ? SiagaTone.success : SiagaTone.warning,
                icon: Icons.verified_outlined,
                compact: true,
              ),
              const SizedBox(height: 12),
              Text(
                'Hasil Akhir Kuis',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 10),
              Text(
                '${result.finalScore}',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: passed ? SiagaColors.safe : SiagaColors.warning,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                'Keberhasilan: ${result.percentage}% · Percobaan ke-${result.attemptsCount}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (result.bestScore != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Nilai Terbaik: ${result.bestScore} · Nilai Terakhir: ${result.latestScore ?? result.finalScore}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: SiagaColors.navy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SiagaResponsiveGrid(
                minimumItemWidth: 160,
                spacing: 12,
                children: [
                  SiagaMetricTile(
                    label: 'Jumlah Soal',
                    value: '${result.totalQuestions}',
                    tone: SiagaTone.info,
                  ),
                  SiagaMetricTile(
                    label: 'Jawaban Benar',
                    value: '${result.correctAnswers}',
                    tone: SiagaTone.success,
                  ),
                  SiagaMetricTile(
                    label: 'Jawaban Salah',
                    value: '${result.wrongAnswers}',
                    tone: SiagaTone.danger,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        if (result.recommendedMaterials.isNotEmpty) ...[
          SiagaCard(
            backgroundColor: SiagaColors.primarySoft,
            borderColor: SiagaColors.primaryBorder,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.menu_book_rounded,
                      size: 18,
                      color: SiagaColors.navy,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Rekomendasi Materi untuk Dipelajari Kembali',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: SiagaColors.navy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                for (final rec in result.recommendedMaterials)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => EducationMaterialDetailPage(
                              materialSlugOrId: rec.slug,
                              service: _service,
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 15,
                            color: SiagaColors.primaryBlue,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              rec.title,
                              style: const TextStyle(
                                color: SiagaColors.navy,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
        ],

        Text(
          'Pembahasan Jawaban',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        for (final rev in result.reviews)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: SiagaColors.surface,
                borderRadius: BorderRadius.circular(SiagaRadius.md),
                border: Border.all(
                  color: rev.isCorrect
                      ? SiagaColors.safeBorder
                      : SiagaColors.dangerBorder,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(SiagaRadius.md - 1),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: rev.isCorrect
                            ? SiagaColors.safe
                            : SiagaColors.danger,
                        width: 3.5,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            rev.isCorrect
                                ? Icons.check_circle_outline_rounded
                                : Icons.cancel_outlined,
                            size: 17,
                            color: rev.isCorrect
                                ? SiagaColors.safe
                                : SiagaColors.danger,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Soal ${rev.questionNumber} · ${rev.isCorrect ? "Benar" : "Kurang Tepat"}',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                              color: rev.isCorrect
                                  ? SiagaColors.safeText
                                  : SiagaColors.dangerText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        rev.questionText,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Jawaban Kamu: (${rev.selectedOptionLabel}) ${rev.selectedOptionText}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: SiagaColors.ink,
                        ),
                      ),
                      if (!rev.isCorrect) ...[
                        const SizedBox(height: 3),
                        Text(
                          'Jawaban Benar: (${rev.correctOptionLabel}) ${rev.correctOptionText}',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: SiagaColors.safeText,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        'Pembahasan: ${rev.explanation}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _restartQuiz,
                icon: const Icon(Icons.replay_rounded, size: 17),
                label: const Text('Ulangi Kuis'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.check_rounded, size: 17),
                label: const Text('Kembali ke Edukasi'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
