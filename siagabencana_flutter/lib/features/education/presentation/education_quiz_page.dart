import 'package:flutter/material.dart';

import '../../../app/siaga_theme.dart';
import '../data/education_data_service.dart';
import 'education_material_detail_page.dart';

class EducationQuizPage extends StatefulWidget {
  const EducationQuizPage({
    super.key,
    required this.quiz,
    this.service,
  });

  final QuizItem quiz;
  final EducationDataService? service;

  @override
  State<EducationQuizPage> createState() => _EducationQuizPageState();
}

class _EducationQuizPageState extends State<EducationQuizPage> {
  int _currentIndex = 0;
  final Map<int, int> _selectedOptionIds = <int, int>{};
  QuizSubmissionResult? _submissionResult;
  bool _isSubmitting = false;

  EducationDataService get _service =>
      widget.service ?? EducationDataService.instance;

  List<QuizQuestionItem> get _questions => widget.quiz.questions;

  Future<void> _submitQuiz() async {
    if (_selectedOptionIds.length < _questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Jawab seluruh soal terlebih dahulu sebelum menyelesaikan kuis.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final result = await _service.evaluateAndSubmitQuiz(
      widget.quiz,
      _selectedOptionIds,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
      _submissionResult = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final qz = widget.quiz;

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
      body: SingleChildScrollView(
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

  Widget _buildQuestionView(QuizItem quiz) {
    final question = _questions[_currentIndex];
    final answeredCount = _selectedOptionIds.length;
    final progressValue = _questions.isNotEmpty
        ? answeredCount / _questions.length
        : 0.0;

    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Soal ${_currentIndex + 1} dari ${_questions.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: SiagaColors.navy,
                  fontSize: 14,
                ),
              ),
              Text(
                'Progres: $answeredCount/${_questions.length} Terjawab',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: SiagaColors.textMuted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progressValue,
              minHeight: 8,
              backgroundColor: const Color(0xFFE2E8F0),
              color: SiagaColors.navy,
            ),
          ),
          const SizedBox(height: 16),

          // Indikator Nomor Soal
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_questions.length, (idx) {
              final qId = _questions[idx].id;
              final isAnswered = _selectedOptionIds.containsKey(qId);
              final isCurrent = idx == _currentIndex;

              return InkWell(
                onTap: () => setState(() => _currentIndex = idx),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? SiagaColors.navy
                        : (isAnswered
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${idx + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: isCurrent
                          ? Colors.white
                          : (isAnswered
                                ? SiagaColors.safe
                                : SiagaColors.textDark),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 18),

          Text(
            'Subtopik: ${question.subtopic}',
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: SiagaColors.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            question.questionText,
            style: const TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
              color: SiagaColors.textDark,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),

          // Pilihan Jawaban (Tanpa Menampilkan Kunci Jawaban Sebelum Selesai)
          ...question.options.map((opt) {
            final isSelected = _selectedOptionIds[question.id] == opt.id;
            return Padding(
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
                    color: isSelected
                        ? const Color(0xFFEFF6FF)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? SiagaColors.navy : SiagaColors.border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 15,
                        backgroundColor: isSelected
                            ? SiagaColors.navy
                            : const Color(0xFFCBD5E1),
                        foregroundColor: isSelected
                            ? Colors.white
                            : SiagaColors.textDark,
                        child: Text(
                          opt.optionLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          opt.optionText,
                          style: TextStyle(
                            color: SiagaColors.textDark,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 18),

          // Tombol Sebelumnya & Berikutnya / Selesai
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
                    label: const Text('Sebelumnya'),
                  ),
                ),
              if (_currentIndex > 0) const SizedBox(width: 12),
              Expanded(
                child: _currentIndex < _questions.length - 1
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
                        label: const Text('Berikutnya'),
                      )
                    : FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: SiagaColors.safe,
                        ),
                        onPressed: _isSubmitting ? null : _submitQuiz,
                        icon: const Icon(Icons.check_circle_rounded),
                        label: const Text('Selesaikan & Nilai Kuis'),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultView(QuizSubmissionResult res) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: SiagaColors.border),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.workspace_premium_rounded,
                size: 52,
                color: SiagaColors.navy,
              ),
              const SizedBox(height: 10),
              Text(
                'Hasil Evaluasi Kuis',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  _buildMetricPill('Jumlah Soal', '${res.totalQuestions}'),
                  _buildMetricPill('Jawaban Benar', '${res.correctAnswers}'),
                  _buildMetricPill('Jawaban Salah', '${res.wrongAnswers}'),
                  _buildMetricPill('Nilai Akhir', '${res.finalScore}'),
                  _buildMetricPill('Persentase', '${res.percentage}%'),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _selectedOptionIds.clear();
                          _currentIndex = 0;
                          _submissionResult = null;
                        });
                      },
                      child: const Text('Kerjakan Ulang'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: SiagaColors.navy,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Kembali ke Edukasi'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Pembahasan Jawaban
        Text(
          'Pembahasan Jawaban',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        ...res.reviews.map(
          (rev) => Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: rev.isCorrect ? SiagaColors.safe : SiagaColors.danger,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Soal ${rev.questionNumber}: ${rev.questionText}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: SiagaColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Jawabanmu (${rev.selectedOptionLabel}): ${rev.selectedOptionText} — ${rev.isCorrect ? "Benar ✓" : "Salah ✗"}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: rev.isCorrect
                        ? SiagaColors.safe
                        : SiagaColors.danger,
                  ),
                ),
                if (!rev.isCorrect) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Jawaban Benar (${rev.correctOptionLabel}): ${rev.correctOptionText}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: SiagaColors.safe,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Pembahasan: ${rev.explanation}',
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: SiagaColors.textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Rekomendasi Materi untuk Dipelajari Kembali
        if (res.recommendedMaterials.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Rekomendasi Materi untuk Dipelajari Kembali',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: res.recommendedMaterials
                .map(
                  (rec) => ActionChip(
                    avatar: const Icon(
                      Icons.menu_book_rounded,
                      size: 18,
                      color: SiagaColors.navy,
                    ),
                    label: Text(rec.title),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => EducationMaterialDetailPage(
                            materialSlugOrId: rec.slug,
                            service: _service,
                          ),
                        ),
                      );
                    },
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildMetricPill(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SiagaColors.border),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: SiagaColors.navy,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: SiagaColors.textMuted),
          ),
        ],
      ),
    );
  }
}

