import 'package:flutter/material.dart';

import '../../../app/siaga_theme.dart';
import '../data/education_data_service.dart';

class EducationSimulationPage extends StatefulWidget {
  const EducationSimulationPage({
    super.key,
    required this.simulation,
    this.service,
  });

  final SimulationItem simulation;
  final EducationDataService? service;

  @override
  State<EducationSimulationPage> createState() =>
      _EducationSimulationPageState();
}

class _EducationSimulationPageState extends State<EducationSimulationPage> {
  int _currentStepIndex = 0;
  SimulationChoiceItem? _selectedChoice;
  int _accumulatedScore = 0;
  bool _isFinished = false;

  EducationDataService get _service =>
      widget.service ?? EducationDataService.instance;

  List<SimulationStepItem> get _steps => widget.simulation.steps;

  void _selectChoice(SimulationChoiceItem choice) {
    if (_selectedChoice != null) {
      return;
    }
    setState(() {
      _selectedChoice = choice;
      _accumulatedScore += choice.score;
    });
  }

  Future<void> _nextOrFinish() async {
    if (_currentStepIndex < _steps.length - 1) {
      setState(() {
        _currentStepIndex++;
        _selectedChoice = null;
      });
      return;
    }

    final normalizedScore = _steps.isNotEmpty
        ? (_accumulatedScore / _steps.length).round().clamp(0, 100)
        : 100;

    await _service.recordSimulationScore(widget.simulation.id, normalizedScore);
    if (!mounted) {
      return;
    }
    setState(() {
      _isFinished = true;
    });
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
            child: _isFinished
                ? _buildFinishedCard(sim)
                : _buildActiveScenarioCard(sim, isGempa),
          ),
        ),
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: SiagaColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isGempa
                          ? const Color(0xFFFEF3C7)
                          : const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      sim.category,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: isGempa
                            ? const Color(0xFFB45309)
                            : const Color(0xFF0369A1),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Tahap ${_currentStepIndex + 1} dari ${_steps.length}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: SiagaColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                sim.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.situationTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: SiagaColors.navy,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      step.situationText,
                      style: const TextStyle(
                        color: SiagaColors.textDark,
                        fontSize: 14.5,
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Pilih tindakan yang paling tepat:',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: SiagaColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              ...step.choices.map((choice) {
                final isSelected = _selectedChoice?.id == choice.id;
                Color borderColor = SiagaColors.border;
                Color bgColor = const Color(0xFFF8FAFC);
                if (_selectedChoice != null) {
                  if (choice.isCorrect) {
                    borderColor = SiagaColors.safe;
                    bgColor = const Color(0xFFF0FDF4);
                  } else if (isSelected) {
                    borderColor = SiagaColors.danger;
                    bgColor = const Color(0xFFFEF2F2);
                  }
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: _selectedChoice == null
                        ? () => _selectChoice(choice)
                        : null,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderColor, width: 1.5),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 15,
                            backgroundColor: SiagaColors.navy,
                            foregroundColor: Colors.white,
                            child: Text(
                              choice.label,
                              style: const TextStyle(
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
                                color: SiagaColors.textDark,
                                fontSize: 14,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),

        // Umpan Balik Setelah Pengguna Memilih
        if (_selectedChoice != null) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _selectedChoice!.isCorrect
                  ? const Color(0xFFF0FDF4)
                  : const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _selectedChoice!.isCorrect
                    ? SiagaColors.safe
                    : SiagaColors.danger,
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Penilaian Pilihan: ${_selectedChoice!.assessment}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _selectedChoice!.isCorrect
                            ? SiagaColors.safe
                            : SiagaColors.danger,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '+${_selectedChoice!.score} Poin',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: SiagaColors.navy,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Penjelasan: ${_selectedChoice!.feedback}',
                  style: const TextStyle(
                    color: SiagaColors.textDark,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tindakan yang Seharusnya Dilakukan:',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: SiagaColors.navy,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step.recommendedAction,
                        style: const TextStyle(
                          color: SiagaColors.textDark,
                          fontSize: 13.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: SiagaColors.navy,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _nextOrFinish,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(
                      _currentStepIndex < _steps.length - 1
                          ? 'Lanjutkan Skenario Berikutnya'
                          : 'Lihat Hasil Akhir Simulasi',
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

  Widget _buildFinishedCard(SimulationItem sim) {
    final finalScore = _steps.isNotEmpty
        ? (_accumulatedScore / _steps.length).round().clamp(0, 100)
        : 100;

    return Container(
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
            Icons.emoji_events_rounded,
            size: 56,
            color: SiagaColors.warning,
          ),
          const SizedBox(height: 12),
          Text(
            'Simulasi Selesai!',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 6),
          Text(
            sim.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: SiagaColors.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Skor Kesiapsiagaan: $finalScore / 100',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: SiagaColors.navy,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Catatan Keselamatan: Panduan simulasi ini merupakan sarana edukasi kesiapsiagaan berdasarkan pedoman resmi BNPB & BMKG, dan bukan pengganti instruksi otoritas resmi di lokasi bencana.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: SiagaColors.textMuted),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _currentStepIndex = 0;
                      _selectedChoice = null;
                      _accumulatedScore = 0;
                      _isFinished = false;
                    });
                  },
                  child: const Text('Ulangi Simulasi'),
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
    );
  }
}

