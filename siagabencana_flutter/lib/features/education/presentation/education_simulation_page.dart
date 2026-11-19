import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/siaga_theme.dart';
import '../data/education_data_service.dart';

class EducationSimulationPage extends StatefulWidget {
  const EducationSimulationPage({
    super.key,
    required this.simulation,
    required this.service,
  });

  final SimulationItem simulation;
  final EducationDataService service;

  @override
  State<EducationSimulationPage> createState() =>
      _EducationSimulationPageState();
}

class _EducationSimulationPageState extends State<EducationSimulationPage> {
  bool _hasStarted = false;
  int _currentStepIndex = 0;
  final Map<int, int> _selectedChoicesByStepId = <int, int>{};
  SimulationChoiceItem? _currentStepChoice;
  bool _isSubmitting = false;
  String? _submitError;
  SimulationSubmissionResult? _serverResult;
  late String _clientSubmissionId;

  EducationDataService get _service => widget.service;
  List<SimulationStepItem> get _steps => widget.simulation.steps;

  @override
  void initState() {
    super.initState();
    _clientSubmissionId = _service.generateClientSubmissionId(
      'sim',
      widget.simulation.id,
    );
    final draft = widget.simulation.draft;
    if (draft != null && draft.selectedChoices.isNotEmpty) {
      _selectedChoicesByStepId.addAll(draft.selectedChoices);
      _currentStepIndex = draft.currentStepIndex.clamp(
        0,
        _steps.isNotEmpty ? _steps.length - 1 : 0,
      );
    }
  }

  void _startOrResume({required bool reset}) {
    setState(() {
      if (reset) {
        _currentStepIndex = 0;
        _selectedChoicesByStepId.clear();
        _currentStepChoice = null;
        _clientSubmissionId = _service.generateClientSubmissionId(
          'sim',
          widget.simulation.id,
        );
      } else {
        if (_steps.isNotEmpty) {
          final step = _steps[_currentStepIndex];
          final savedChoiceId = _selectedChoicesByStepId[step.id];
          if (savedChoiceId != null) {
            for (final c in step.choices) {
              if (c.id == savedChoiceId) {
                _currentStepChoice = c;
                break;
              }
            }
          }
        }
      }
      _hasStarted = true;
      _serverResult = null;
      _submitError = null;
    });
  }

  void _selectChoice(SimulationStepItem step, SimulationChoiceItem choice) {
    if (_currentStepChoice != null) {
      return;
    }
    setState(() {
      _currentStepChoice = choice;
      _selectedChoicesByStepId[step.id] = choice.id;
      _submitError = null;
    });

    // Auto-save draft progress to Laravel DB
    _service.scheduleSimulationDraftSave(
      widget.simulation.id,
      currentStepIndex: _currentStepIndex,
      selectedChoices: Map<int, int>.from(_selectedChoicesByStepId),
    );
  }

  Future<void> _nextOrSubmit() async {
    if (_currentStepIndex < _steps.length - 1) {
      final nextIndex = _currentStepIndex + 1;
      setState(() {
        _currentStepIndex = nextIndex;
        _currentStepChoice = null;
        final saved = _selectedChoicesByStepId[_steps[nextIndex].id];
        if (saved != null) {
          for (final c in _steps[nextIndex].choices) {
            if (c.id == saved) {
              _currentStepChoice = c;
              break;
            }
          }
        }
      });
      _service.scheduleSimulationDraftSave(
        widget.simulation.id,
        currentStepIndex: nextIndex,
        selectedChoices: Map<int, int>.from(_selectedChoicesByStepId),
      );
      return;
    }

    await _submitToBackend();
  }

  Future<void> _submitToBackend() async {
    if (_isSubmitting) {
      return;
    }
    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    try {
      final res = await _service.submitSimulation(
        widget.simulation.id,
        Map<int, int>.from(_selectedChoicesByStepId),
        clientSubmissionId: _clientSubmissionId,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _isSubmitting = false;
        _serverResult = res;
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

  @override
  Widget build(BuildContext context) {
    final sim = widget.simulation;
    final isGempa = sim.category == 'Gempa Bumi';

    return Scaffold(
      backgroundColor: SiagaColors.background,
      appBar: AppBar(
        backgroundColor: SiagaColors.navy,
        foregroundColor: Colors.white,
        title: Text(
          'Simulasi ${sim.category}',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: _serverResult != null
                ? _buildFinishedCard(sim, _serverResult!)
                : !_hasStarted
                ? _buildIntroInstructionsCard(sim, isGempa)
                : _buildActiveScenarioCard(sim, isGempa),
          ),
        ),
      ),
    );
  }

  Widget _buildIntroInstructionsCard(SimulationItem sim, bool isGempa) {
    final hasDraft =
        sim.draft != null && sim.draft!.selectedChoices.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SiagaColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isGempa
                  ? const Color(0xFFFEF3C7)
                  : const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'PETUNJUK SIMULASI · ${sim.category.toUpperCase()}',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12,
                color: isGempa
                    ? const Color(0xFFB45309)
                    : const Color(0xFF0369A1),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            sim.title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Text(
            sim.description,
            style: const TextStyle(
              fontSize: 14.8,
              height: 1.6,
              color: SiagaColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Aturan & Petunjuk Pelaksanaan:',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: SiagaColors.navy,
                  ),
                ),
                const SizedBox(height: 8),
                Text('• Skenario terdiri dari ${_steps.length} tahap keputusan keselamatan.'),
                const Text('• Setiap pilihan langsung menampilkan penilaian dan penjelasan tindakan terbaik.'),
                const Text('• Progres tahapan tersimpan otomatis ke akun Anda jika keluar di tengah jalan.'),
                const Text('• Penilaian akhir dihitung dan disimpan di server Laravel.'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Text(
              '⚠️ Referensi: ${sim.safetyReference}. Simulasi ini bersifat edukatif dan bukan pengganti instruksi resmi petugas saat bencana nyata.',
              style: const TextStyle(fontSize: 12.8, color: Color(0xFF92400E)),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              if (hasDraft)
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: SiagaColors.safe,
                  ),
                  onPressed: () => _startOrResume(reset: false),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(
                    'Lanjutkan dari Tahap ${sim.draft!.currentStepIndex + 1}',
                  ),
                ),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: SiagaColors.navy,
                ),
                onPressed: () => _startOrResume(reset: true),
                icon: const Icon(Icons.psychology_alt_rounded),
                label: Text(
                  hasDraft ? 'Mulai dari Awal' : 'Mulai Simulasi Sekarang',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveScenarioCard(SimulationItem sim, bool isGempa) {
    final step = _steps[_currentStepIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isGempa
                  ? const [SiagaColors.navy, Color(0xFFB45309)]
                  : const [Color(0xFF0369A1), SiagaColors.navy],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SKENARIO ${sim.category.toUpperCase()} · TAHAP ${_currentStepIndex + 1} DARI ${_steps.length}',
                style: const TextStyle(
                  color: Color(0xFFBAE6FD),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                sim.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (_currentStepIndex + 1) / _steps.length,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                color: const Color(0xFF38BDF8),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: SiagaColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step.situationTitle,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: SiagaColors.navy,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                step.situationText,
                style: const TextStyle(
                  fontSize: 15.2,
                  height: 1.65,
                  color: SiagaColors.textDark,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Pilih tindakan penyelamatan yang paling tepat:',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: SiagaColors.textMuted,
                ),
              ),
              const SizedBox(height: 12),
              for (final choice in step.choices) _buildChoiceTile(step, choice),
            ],
          ),
        ),

        if (_currentStepChoice != null) ...[
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _currentStepChoice!.isCorrect
                  ? const Color(0xFFF0FDF4)
                  : const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _currentStepChoice!.isCorrect
                    ? const Color(0xFF86EFAC)
                    : const Color(0xFFFCA5A5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _currentStepChoice!.isCorrect
                          ? Icons.check_circle_rounded
                          : Icons.warning_amber_rounded,
                      color: _currentStepChoice!.isCorrect
                          ? SiagaColors.safe
                          : SiagaColors.danger,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${_currentStepChoice!.assessment} (Skor tahap: ${_currentStepChoice!.score})',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _currentStepChoice!.isCorrect
                              ? SiagaColors.safe
                              : SiagaColors.danger,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _currentStepChoice!.feedback,
                  style: const TextStyle(
                    fontSize: 14.5,
                    height: 1.55,
                    color: SiagaColors.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: SiagaColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tindakan yang Seharusnya Dilakukan:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: SiagaColors.navy,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step.recommendedAction,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: SiagaColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_submitError != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: SiagaColors.danger),
                    ),
                    child: Text(
                      '⚠️ $_submitError',
                      style: const TextStyle(
                        color: SiagaColors.danger,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: SiagaColors.navy,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: _isSubmitting
                        ? null
                        : () => unawaited(_nextOrSubmit()),
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
                                : Icons.arrow_forward_rounded,
                          ),
                    label: Text(
                      _isSubmitting
                          ? 'Menyimpan hasil ke server...'
                          : _submitError != null
                          ? 'Coba Kirim Ulang Hasil Simulasi'
                          : _currentStepIndex < _steps.length - 1
                          ? 'Lanjutkan ke Tahap Berikutnya'
                          : 'Kirim & Lihat Hasil Simulasi',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildChoiceTile(
    SimulationStepItem step,
    SimulationChoiceItem choice,
  ) {
    final isPicked = _currentStepChoice?.id == choice.id;
    final hasPicked = _currentStepChoice != null;

    Color borderColor = SiagaColors.border;
    Color bgColor = const Color(0xFFF8FAFC);

    if (hasPicked) {
      if (isPicked) {
        borderColor = choice.isCorrect ? SiagaColors.safe : SiagaColors.danger;
        bgColor = choice.isCorrect
            ? const Color(0xFFDCFCE7)
            : const Color(0xFFFEE2E2);
      } else if (choice.isCorrect) {
        borderColor = SiagaColors.safe.withValues(alpha: 0.6);
        bgColor = const Color(0xFFF0FDF4);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: hasPicked ? null : () => _selectChoice(step, choice),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: isPicked ? 2 : 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: SiagaColors.navy,
                child: Text(
                  choice.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  choice.choiceText,
                  style: const TextStyle(
                    fontSize: 14.5,
                    height: 1.5,
                    color: SiagaColors.textDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinishedCard(
    SimulationItem sim,
    SimulationSubmissionResult result,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SiagaColors.border),
      ),
      child: Column(
        children: [
          Icon(
            result.score >= 80
                ? Icons.verified_user_rounded
                : Icons.school_rounded,
            size: 64,
            color: result.score >= 80 ? SiagaColors.safe : SiagaColors.warning,
          ),
          const SizedBox(height: 12),
          const Text(
            'Simulasi Selesai & Tersimpan!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: SiagaColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            sim.title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, color: SiagaColors.textMuted),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text(
                  'NILAI KESIAPSIAGAAN (TERVALIDASI SERVER)',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: SiagaColors.navy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${result.score} / ${result.maxScore}',
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: SiagaColors.navy,
                  ),
                ),
                Text(
                  'Keputusan tepat: ${result.correctChoices} dari ${result.totalSteps} tahap',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: SiagaColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Text(
              '⚠️ ${result.safetyDisclaimer}',
              style: const TextStyle(
                fontSize: 12.8,
                height: 1.5,
                color: Color(0xFF92400E),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _startOrResume(reset: true),
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Ulangi Simulasi'),
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
      ),
    );
  }
}
