import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/siaga_theme.dart';
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
      if (!mounted) {
        return;
      }
      setState(() {
        _loadedQuiz = fetched;
        _loadingQuestions = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadingQuestions = false;
        _loadError = e.toString();
      });
    }
  }

  Future<void> _submitQuiz() async {
    final quiz = _loadedQuiz;
    if (quiz == null || _isSubmitting) {
      return;
    }

    if (_selectedOptionIds.length < quiz.questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Jawab seluruh pertanyaan kuis terlebih dahulu sebelum melihat nilai akhir.',
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

      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
        _submissionResult = result;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
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

    return Scaffold(
      backgroundColor: SiagaColors.background,
      appBar: AppBar(
        backgroundColor: SiagaColors.navy,
        foregroundColor: Colors.white,
        title: Text(
          'Kuis ${qz.category}',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: _loadingQuestions
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_loadError!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _loadQuestions,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Muat Ulang Kuis'),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 860),
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
      return const Center(child: Text('Soal kuis belum tersedia.'));
    }

    final question = qz.questions[_currentIndex];
    final total = qz.questions.length;
    final answeredCount = _selectedOptionIds.length;
    final selectedOptId = _selectedOptionIds[question.id];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: SiagaColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Soal ${_currentIndex + 1} dari $total',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: SiagaColors.navy,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    'Terjawab: $answeredCount/$total',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: SiagaColors.safe,
                      fontSize: 13.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: total > 0 ? answeredCount / total : 0,
                  minHeight: 8,
                  backgroundColor: const Color(0xFFE2E8F0),
                  color: SiagaColors.navy,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${qz.title} · Tingkat ${qz.difficulty}',
                style: const TextStyle(
                  fontSize: 13,
                  color: SiagaColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: SiagaColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (question.subtopic.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    question.subtopic,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: SiagaColors.navy,
                    ),
                  ),
                ),
              Text(
                question.questionText,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                  color: SiagaColors.textDark,
                ),
              ),
              const SizedBox(height: 16),
              for (final opt in question.options)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
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
                            ? const Color(0xFFEFF6FF)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selectedOptId == opt.id
                              ? SiagaColors.navy
                              : SiagaColors.border,
                          width: selectedOptId == opt.id ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: selectedOptId == opt.id
                                ? SiagaColors.navy
                                : const Color(0xFFCBD5E1),
                            child: Text(
                              opt.optionLabel,
                              style: TextStyle(
                                color: selectedOptId == opt.id
                                    ? Colors.white
                                    : SiagaColors.textDark,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              opt.optionText,
                              style: const TextStyle(
                                fontSize: 14.5,
                                height: 1.45,
                                color: SiagaColors.textDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        if (_submitError != null) ...[
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SiagaColors.danger),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: SiagaColors.danger),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _submitError!,
                    style: const TextStyle(
                      color: SiagaColors.danger,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 18),
        Row(
          children: [
            if (_currentIndex > 0)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _currentIndex--;
                    });
                  },
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Soal Sebelumnya'),
                ),
              ),
            if (_currentIndex > 0) const SizedBox(width: 12),
            Expanded(
              child: _currentIndex < total - 1
                  ? FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: SiagaColors.navy,
                      ),
                      onPressed: () {
                        setState(() {
                          _currentIndex++;
                        });
                      },
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('Soal Berikutnya'),
                    )
                  : FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: SiagaColors.safe,
                      ),
                      onPressed: _isSubmitting ? null : _submitQuiz,
                      icon: _isSubmitting
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              _submitError != null
                                  ? Icons.refresh_rounded
                                  : Icons.check_circle_rounded,
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
        const SizedBox(height: 10),
        const Text(
          'Kunci jawaban dan pembahasan hanya ditampilkan setelah kuis selesai dikirim dan dinilai oleh server.',
          style: TextStyle(fontSize: 12.5, color: SiagaColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildResultView(QuizSubmissionResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: SiagaColors.border),
          ),
          child: Column(
            children: [
              const Text(
                'Hasil Akhir Kuis (Tervalidasi Server)',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: SiagaColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${result.finalScore}',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: result.finalScore >= 75
                      ? SiagaColors.safe
                      : SiagaColors.warning,
                ),
              ),
              Text(
                'Keberhasilan: ${result.percentage}% · Percobaan ke-${result.attemptsCount}',
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: SiagaColors.textMuted,
                ),
              ),
              if (result.bestScore != null) ...[
                const SizedBox(height: 6),
                Text(
                  'Nilai Terbaik: ${result.bestScore} · Nilai Terakhir: ${result.latestScore ?? result.finalScore}',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: SiagaColors.navy,
                  ),
                ),
              ],
              const SizedBox(height: 18),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  _statBox(
                    'Jumlah Soal',
                    '${result.totalQuestions}',
                    SiagaColors.navy,
                  ),
                  _statBox(
                    'Jawaban Benar',
                    '${result.correctAnswers}',
                    SiagaColors.safe,
                  ),
                  _statBox(
                    'Jawaban Salah',
                    '${result.wrongAnswers}',
                    SiagaColors.danger,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        if (result.recommendedMaterials.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📚 Rekomendasi Materi untuk Dipelajari Kembali',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: SiagaColors.navy,
                  ),
                ),
                const SizedBox(height: 10),
                for (final rec in result.recommendedMaterials)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
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
                            Icons.menu_book_rounded,
                            size: 18,
                            color: SiagaColors.navy,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              rec.title,
                              style: const TextStyle(
                                color: SiagaColors.navy,
                                fontWeight: FontWeight.w700,
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

        const Text(
          'Pembahasan Jawaban',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: SiagaColors.textDark,
          ),
        ),
        const SizedBox(height: 10),
        for (final rev in result.reviews)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: rev.isCorrect
                    ? const Color(0xFF86EFAC)
                    : const Color(0xFFFCA5A5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Soal ${rev.questionNumber} · ${rev.isCorrect ? "✓ Benar" : "✗ Kurang Tepat"}',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: rev.isCorrect
                        ? SiagaColors.safe
                        : SiagaColors.danger,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  rev.questionText,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: SiagaColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Jawaban Kamu: (${rev.selectedOptionLabel}) ${rev.selectedOptionText}',
                  style: const TextStyle(fontSize: 13.5),
                ),
                if (!rev.isCorrect)
                  Text(
                    'Jawaban Benar: (${rev.correctOptionLabel}) ${rev.correctOptionText}',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: SiagaColors.safe,
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  'Pembahasan: ${rev.explanation}',
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: SiagaColors.textMuted,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _restartQuiz,
                icon: const Icon(Icons.replay_rounded),
                label: const Text('Ulangi Kuis'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.check_rounded),
                label: const Text('Kembali ke Edukasi'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statBox(String label, String value, Color color) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SiagaColors.border),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: SiagaColors.textMuted),
          ),
        ],
      ),
    );
  }
}
