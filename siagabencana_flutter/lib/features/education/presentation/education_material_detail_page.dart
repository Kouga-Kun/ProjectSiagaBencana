import 'package:flutter/material.dart';

import '../../../app/siaga_theme.dart';
import '../data/education_data_service.dart';

class EducationMaterialDetailPage extends StatefulWidget {
  const EducationMaterialDetailPage({
    super.key,
    required this.materialSlugOrId,
    this.service,
  });

  final String materialSlugOrId;
  final EducationDataService? service;

  @override
  State<EducationMaterialDetailPage> createState() =>
      _EducationMaterialDetailPageState();
}

class _EducationMaterialDetailPageState
    extends State<EducationMaterialDetailPage> {
  late String _currentSlugOrId;

  EducationDataService get _service =>
      widget.service ?? EducationDataService.instance;

  @override
  void initState() {
    super.initState();
    _currentSlugOrId = widget.materialSlugOrId;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _service,
      builder: (context, _) {
        final material = _service.findMaterialBySlugOrId(_currentSlugOrId);
        if (material == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detail Materi')),
            body: const Center(child: Text('Materi tidak ditemukan.')),
          );
        }

        final isGempa = material.category == 'Gempa Bumi';
        final accentColor = isGempa ? SiagaColors.warning : SiagaColors.info;

        return Scaffold(
          backgroundColor: SiagaColors.background,
          appBar: AppBar(
            backgroundColor: SiagaColors.navy,
            foregroundColor: Colors.white,
            title: Text(
              'Materi ${material.category}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 920),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kategori, Kesulitan & Status Selesai
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildBadge(
                          material.category,
                          isGempa
                              ? const Color(0xFFFEF3C7)
                              : const Color(0xFFE0F2FE),
                          isGempa
                              ? const Color(0xFFB45309)
                              : const Color(0xFF0369A1),
                        ),
                        _buildBadge(
                          'Tingkat: ${material.difficulty}',
                          const Color(0xFFF1F5F9),
                          SiagaColors.textDark,
                        ),
                        if (material.isCompleted)
                          _buildBadge(
                            '✓ Selesai Dipelajari',
                            const Color(0xFFDCFCE7),
                            SiagaColors.safe,
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      material.title,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),

                    // Ilustrasi & Ringkasan Materi
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isGempa
                              ? [SiagaColors.navy, const Color(0xFFB45309)]
                              : [const Color(0xFF0369A1), SiagaColors.navy],
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              isGempa
                                  ? Icons.crisis_alert_rounded
                                  : Icons.waves_rounded,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'RINGKASAN MATERI',
                                  style: TextStyle(
                                    color: Color(0xFFBFDBFE),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  material.summary,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.5,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Penjelasan Materi
                    _buildSectionCard(
                      title: 'Penjelasan Materi',
                      icon: Icons.menu_book_rounded,
                      accentColor: SiagaColors.navy,
                      child: Text(
                        material.content,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.7,
                          color: SiagaColors.textDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Poin Penting
                    if (material.keyPoints.isNotEmpty) ...[
                      _buildSectionCard(
                        title: 'Poin Penting',
                        icon: Icons.lightbulb_outline_rounded,
                        accentColor: accentColor,
                        backgroundColor: const Color(0xFFEFF6FF),
                        child: Column(
                          children: material.keyPoints
                              .map(
                                (pt) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        '• ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: SiagaColors.navy,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          pt,
                                          style: const TextStyle(
                                            color: SiagaColors.textDark,
                                            height: 1.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Langkah yang Harus Dilakukan
                    if (material.actionSteps.isNotEmpty) ...[
                      _buildSectionCard(
                        title: 'Langkah yang Harus Dilakukan',
                        icon: Icons.check_circle_outline_rounded,
                        accentColor: SiagaColors.safe,
                        backgroundColor: const Color(0xFFF0FDF4),
                        child: Column(
                          children: material.actionSteps
                              .asMap()
                              .entries
                              .map(
                                (entry) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${entry.key + 1}. ',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: SiagaColors.safe,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          entry.value,
                                          style: const TextStyle(
                                            color: SiagaColors.textDark,
                                            height: 1.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Hal yang Harus Dihindari
                    if (material.thingsToAvoid.isNotEmpty) ...[
                      _buildSectionCard(
                        title: 'Hal yang Harus Dihindari',
                        icon: Icons.warning_amber_rounded,
                        accentColor: SiagaColors.danger,
                        backgroundColor: const Color(0xFFFEF2F2),
                        child: Column(
                          children: material.thingsToAvoid
                              .map(
                                (av) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        '✕ ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: SiagaColors.danger,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          av,
                                          style: const TextStyle(
                                            color: Color(0xFF7F1D1D),
                                            height: 1.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Sumber Referensi
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: SiagaColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.verified_rounded,
                            color: SiagaColors.navy,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Sumber Referensi: ${material.sourceReference}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: SiagaColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tombol Tandai Selesai
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: material.isCompleted
                              ? SiagaColors.safe
                              : SiagaColors.navy,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () async {
                          final msg = await _service.toggleMaterialCompletion(
                            material.id,
                          );
                          if (!context.mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(msg)));
                        },
                        icon: Icon(
                          material.isCompleted
                              ? Icons.check_circle_rounded
                              : Icons.task_alt_rounded,
                        ),
                        label: Text(
                          material.isCompleted
                              ? 'Sudah Ditandai Selesai (Ketuk untuk Batalkan)'
                              : 'Tandai Materi Selesai',
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Navigasi Materi Sebelumnya & Berikutnya
                    Row(
                      children: [
                        if (material.previousMaterial != null)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _currentSlugOrId =
                                      material.previousMaterial!.slug;
                                });
                              },
                              icon: const Icon(Icons.arrow_back_rounded),
                              label: Text(
                                'Sebelumnya: ${material.previousMaterial!.title}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        if (material.previousMaterial != null &&
                            material.nextMaterial != null)
                          const SizedBox(width: 12),
                        if (material.nextMaterial != null)
                          Expanded(
                            child: FilledButton.tonalIcon(
                              onPressed: () {
                                setState(() {
                                  _currentSlugOrId =
                                      material.nextMaterial!.slug;
                                });
                              },
                              icon: const Icon(Icons.arrow_forward_rounded),
                              label: Text(
                                'Berikutnya: ${material.nextMaterial!.title}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBadge(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 12.5, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color accentColor,
    required Widget child,
    Color backgroundColor = Colors.white,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SiagaColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

