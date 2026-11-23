import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/siaga_theme.dart';
import '../../../app/widgets/siaga_components.dart';
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
    if (_currentStepChoice != null) return;
    setState(() {
      _currentStepChoice = choice;
      _selectedChoicesByStepId[step.id] = choice.id;
      _submitError = null;
    });

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
    if (_isSubmitting) return;
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
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _serverResult = res;
      });
    } catch (e) {
      if (!mounted) return;
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
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = SiagaBreakpoints.pageHorizontalPadding(width);

    return Scaffold(
      backgroundColor: SiagaColors.background,
      appBar: AppBar(title: Text('Simulasi ${sim.category}')),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          22,
          horizontalPadding,
          48,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
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

    return SiagaCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SiagaBadge(
            label: 'PETUNJUK SIMULASI · ${sim.category.toUpperCase()}',
            tone: isGempa ? SiagaTone.warning : SiagaTone.info,
            icon: isGempa ? Icons.vibration_rounded : Icons.waves_rounded,
            compact: true,
          ),
          const SizedBox(height: 14),
          Text(sim.title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 10),
          Text(
            sim.description,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: SiagaColors.ink),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SiagaColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(SiagaRadius.md),
              border: Border.all(color: SiagaColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aturan & Petunjuk Pelaksanaan',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: SiagaColors.navy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                SiagaBullet(
                  text:
                      'Skenario terdiri dari ${_steps.length} tahap keputusan keselamatan.',
                  icon: Icons.layers_outlined,
                  color: SiagaColors.primaryBlue,
                ),
                const SiagaBullet(
                  text:
                      'Setiap pilihan langsung menampilkan evaluasi dan penjelasan tindakan terbaik.',
                  icon: Icons.fact_check_outlined,
                  color: SiagaColors.safe,
                ),
                const SiagaBullet(
                  text:
                      'Progres tahapan tersimpan otomatis ke akun Anda jika keluar di tengah jalan.',
                  icon: Icons.cloud_done_outlined,
                  color: SiagaColors.info,
                ),
                const SiagaBullet(
                  text: 'Penilaian akhir dihitung dan disimpan di server.',
                  icon: Icons.verified_outlined,
                  color: SiagaColors.navy,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SiagaNotice(
            title: 'Catatan Referensi Keselamatan',
            message:
                'Referensi: ${sim.safetyReference}. Simulasi ini bersifat edukatif dan tidak menggantikan instruksi petugas resmi saat bencana nyata.',
            tone: SiagaTone.warning,
            icon: Icons.info_outline_rounded,
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (hasDraft)
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: SiagaColors.safe,
                  ),
                  onPressed: () => _startOrResume(reset: false),
                  icon: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: Text(
                    'Lanjutkan dari Tahap ${sim.draft!.currentStepIndex + 1}',
                  ),
                ),
              FilledButton.icon(
                onPressed: () => _startOrResume(reset: true),
                icon: const Icon(Icons.psychology_alt_outlined, size: 18),
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
            color: SiagaColors.navy,
            borderRadius: BorderRadius.circular(SiagaRadius.lg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SKENARIO ${sim.category.toUpperCase()} · TAHAP ${_currentStepIndex + 1} DARI ${_steps.length}',
                style: const TextStyle(
                  color: Color(0xFF93C5FD),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.7,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                sim.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(SiagaRadius.pill),
                child: LinearProgressIndicator(
                  value: (_currentStepIndex + 1) / _steps.length,
                  minHeight: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.16),
                  color: const Color(0xFF38BDF8),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        SiagaCard(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step.situationTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: SiagaColors.navy,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                step.situationText,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: SiagaColors.ink,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Pilih tindakan penyelamatan yang paling tepat:',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: SiagaColors.muted,
                ),
              ),
              const SizedBox(height: 12),
              for (final choice in step.choices) _buildChoiceTile(step, choice),
            ],
          ),
        ),

        if (_currentStepChoice != null) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: _currentStepChoice!.isCorrect
                  ? SiagaColors.safeSoft
                  : SiagaColors.dangerSoft,
              borderRadius: BorderRadius.circular(SiagaRadius.lg),
              border: Border.all(
                color: _currentStepChoice!.isCorrect
                    ? SiagaColors.safeBorder
                    : SiagaColors.dangerBorder,
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _currentStepChoice!.isCorrect
                          ? Icons.check_circle_outline_rounded
                          : Icons.warning_amber_rounded,
                      color: _currentStepChoice!.isCorrect
                          ? SiagaColors.safe
                          : SiagaColors.danger,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        '${_currentStepChoice!.assessment} (Skor tahap: ${_currentStepChoice!.score})',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _currentStepChoice!.isCorrect
                              ? SiagaColors.safeText
                              : SiagaColors.dangerText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _currentStepChoice!.feedback,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: SiagaColors.ink,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: SiagaColors.surface,
                    borderRadius: BorderRadius.circular(SiagaRadius.md),
                    border: Border.all(color: SiagaColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tindakan yang Seharusnya Dilakukan',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: SiagaColors.navy,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step.recommendedAction,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: SiagaColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_submitError != null) ...[
                  const SizedBox(height: 12),
                  SiagaNotice(
                    title: 'Gagal menyimpan hasil simulasi',
                    message: _submitError!,
                    tone: SiagaTone.danger,
                    icon: Icons.error_outline_rounded,
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: FilledButton.icon(
                    onPressed: _isSubmitting
                        ? null
                        : () => unawaited(_nextOrSubmit()),
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
                                : Icons.arrow_forward_rounded,
                            size: 18,
                          ),
                    label: Text(
                      _isSubmitting
                          ? 'Menyimpan hasil ke server...'
                          : _submitError != null
                          ? 'Coba Kirim Ulang Hasil Simulasi'
                          : _currentStepIndex < _steps.length - 1
                          ? 'Lanjutkan ke Tahap Berikutnya'
                          : 'Kirim & Lihat Hasil Simulasi',
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
    Color bgColor = SiagaColors.surfaceSubtle;

    if (hasPicked) {
      if (isPicked) {
        borderColor = choice.isCorrect ? SiagaColors.safe : SiagaColors.danger;
        bgColor = choice.isCorrect
            ? SiagaColors.safeSoft
            : SiagaColors.dangerSoft;
      } else if (choice.isCorrect) {
        borderColor = SiagaColors.safeBorder;
        bgColor = SiagaColors.safeSoft;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(SiagaRadius.md),
          onTap: hasPicked ? null : () => _selectChoice(step, choice),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(SiagaRadius.md),
              border: Border.all(
                color: borderColor,
                width: isPicked ? 1.6 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: SiagaColors.navy,
                    borderRadius: BorderRadius.circular(SiagaRadius.sm),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    choice.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    choice.choiceText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: SiagaColors.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFinishedCard(
    SimulationItem sim,
    SimulationSubmissionResult result,
  ) {
    final highScore = result.score >= 80;

    return SiagaCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          SiagaIconTile(
            icon: highScore
                ? Icons.verified_user_outlined
                : Icons.school_outlined,
            size: 56,
            color: highScore ? SiagaColors.safe : SiagaColors.warning,
            backgroundColor: highScore
                ? SiagaColors.safeSoft
                : SiagaColors.warningSoft,
          ),
          const SizedBox(height: 14),
          Text(
            'Simulasi Selesai & Tersimpan',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Text(
            sim.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            decoration: BoxDecoration(
              color: SiagaColors.primarySoft,
              borderRadius: BorderRadius.circular(SiagaRadius.lg),
              border: Border.all(color: SiagaColors.primaryBorder),
            ),
            child: Column(
              children: [
                const Text(
                  'NILAI KESIAPSIAGAAN (TERVALIDASI SERVER)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: SiagaColors.navy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${result.score} / ${result.maxScore}',
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: SiagaColors.navy,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                Text(
                  'Keputusan tepat: ${result.correctChoices} dari ${result.totalSteps} tahap',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SiagaNotice(
            title: 'Catatan Edukasi',
            message: result.safetyDisclaimer,
            tone: SiagaTone.warning,
            icon: Icons.info_outline_rounded,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _startOrResume(reset: true),
                  icon: const Icon(Icons.replay_rounded, size: 17),
                  label: const Text('Ulangi Simulasi'),
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
      ),
    );
  }
}
