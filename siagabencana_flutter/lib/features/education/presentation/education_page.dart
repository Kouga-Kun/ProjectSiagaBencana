import 'package:flutter/material.dart';

import '../../../app/navigation/app_section.dart';
import '../../../app/siaga_theme.dart';
import '../data/education_data_service.dart';
import 'education_material_detail_page.dart';
import 'education_quiz_page.dart';
import 'education_simulation_page.dart';

class EducationPage extends StatefulWidget {
  const EducationPage({
    super.key,
    required this.onNavigate,
    this.service,
    this.initialCategoryFilter = 'Semua',
    this.initialFeatureTab = 0,
  });

  final ValueChanged<AppSection> onNavigate;
  final EducationDataService? service;
  final String initialCategoryFilter;
  final int initialFeatureTab;

  @override
  State<EducationPage> createState() => _EducationPageState();
}

class _EducationPageState extends State<EducationPage> {
  final TextEditingController _searchController = TextEditingController();
  late String _selectedCategory;
  String _selectedDifficulty = 'Semua';
  late int _selectedFeatureIndex;

  EducationDataService get _service =>
      widget.service ?? EducationDataService.instance;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategoryFilter;
    _selectedFeatureIndex = widget.initialFeatureTab;
    _service.refreshAll();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectCategoryAndJumpToLearn(String category) {
    setState(() {
      _selectedCategory = category;
      _selectedFeatureIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _service,
      builder: (context, _) {
        final progress = _service.currentProgress;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderBanner(),
            const SizedBox(height: 20),
            _buildMainCategoriesRow(),
            const SizedBox(height: 20),
            _buildProgressSummaryCard(progress),
            const SizedBox(height: 20),
            _buildFourFeatureMenus(),
            const SizedBox(height: 16),
            _buildActiveFeatureContent(progress),
          ],
        );
      },
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [SiagaColors.navy, Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: SiagaColors.navy.withValues(alpha: 0.16),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.school_rounded, color: Colors.white, size: 16),
                SizedBox(width: 6),
                Text(
                  'PUSAT EDUKASI MITIGASI SIAGABENCANA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Edukasi Gempa Bumi dan Tsunami',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '"Kenali Risikonya, Lindungi Dirimu, Selamatkan Sesama."',
            style: TextStyle(
              color: Color(0xFF93C5FD),
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Pelajari pengetahuan kesiapsiagaan resmi dari BNPB, BMKG, Basarnas, dan BPBD mengenai cara mengenali risiko, menyiapkan Tas Siaga Bencana, menerapkan prosedur Drop, Cover, and Hold On, serta mengevakuasi diri ke tempat aman sebelum, saat, dan setelah gempa bumi maupun tsunami.',
            style: TextStyle(
              color: Color(0xFFE2E8F0),
              fontSize: 13.8,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: SiagaColors.danger,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _selectedFeatureIndex = 0;
                    _selectedCategory = 'Semua';
                  });
                },
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Mulai Belajar Sekarang'),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF93C5FD)),
                ),
                onPressed: () => widget.onNavigate(AppSection.evacuation),
                icon: const Icon(Icons.map_outlined),
                label: const Text('Buka Peta Evakuasi'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainCategoriesRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 700;
        final gempaCard = _buildCategoryCard(
          label: 'A. Kategori Utama',
          title: 'Gempa Bumi',
          description:
              '12 Materi lengkap dari pengertian gempa, persiapan perabotan rumah, prosedur Drop Cover Hold On di rumah/sekolah/gedung, hingga bahaya susulan & Tas Siaga.',
          icon: Icons.vibration_rounded,
          accentColor: SiagaColors.warning,
          onTapLearn: () => _selectCategoryAndJumpToLearn('Gempa Bumi'),
        );
        final tsunamiCard = _buildCategoryCard(
          label: 'B. Kategori Utama',
          title: 'Tsunami',
          description:
              '12 Materi lengkap hubungan gempa & tsunami, 3 level peringatan dini BMKG (Awas, Siaga, Waspada), tanda alam air laut surut, dan evakuasi ke tempat tinggi.',
          icon: Icons.waves_rounded,
          accentColor: SiagaColors.info,
          onTapLearn: () => _selectCategoryAndJumpToLearn('Tsunami'),
        );

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: gempaCard),
              const SizedBox(width: 16),
              Expanded(child: tsunamiCard),
            ],
          );
        }
        return Column(
          children: [
            gempaCard,
            const SizedBox(height: 12),
            tsunamiCard,
          ],
        );
      },
    );
  }

  Widget _buildCategoryCard({
    required String label,
    required String title,
    required String description,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTapLearn,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                  ),
                ),
              ),
              Icon(icon, color: accentColor, size: 28),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: SiagaColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13.5,
              color: SiagaColors.textMuted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: onTapLearn,
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: Text('Pelajari $title'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSummaryCard(EducationUserProgress progress) {
    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Progres Pembelajaran & Kesiapsiagaan',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: SiagaColors.textDark,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${progress.overallPercentage}% · ${progress.totalPoints} Poin',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: SiagaColors.safe,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            progress.initialMessage,
            style: const TextStyle(fontSize: 13, color: SiagaColors.textMuted),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: (progress.overallPercentage / 100.0).clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: const Color(0xFFE2E8F0),
              color: SiagaColors.navy,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildStatChip(
                'Materi Selesai',
                '${progress.materialsCompleted}/${progress.materialsTotal}',
              ),
              _buildStatChip(
                'Simulasi Selesai',
                '${progress.simulationsCompleted}/${progress.simulationsTotal}',
              ),
              _buildStatChip(
                'Kuis Dikerjakan',
                '${progress.quizzesCompleted}/${progress.quizzesTotal}',
              ),
              _buildStatChip(
                'Misi Selesai',
                '${progress.missionsCompleted}/${progress.missionsTotal}',
              ),
              _buildStatChip(
                'Badge Diraih',
                '${progress.earnedBadgesCount}/${progress.badges.length}',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: progress.badges
                .map(
                  (b) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: b.isEarned
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '🏅 ${b.name}${b.isEarned ? " ✓" : ""}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: b.isEarned
                            ? SiagaColors.safe
                            : SiagaColors.textMuted,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: SiagaColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: SiagaColors.navy,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12.5, color: SiagaColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildFourFeatureMenus() {
    final tabs = [
      (0, 'Belajar', Icons.menu_book_rounded),
      (1, 'Simulasi', Icons.psychology_alt_rounded),
      (2, 'Kuis', Icons.quiz_rounded),
      (3, 'Misi Siaga', Icons.flag_circle_rounded),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: tabs.map((tab) {
        final isSelected = _selectedFeatureIndex == tab.$1;
        return ChoiceChip(
          selected: isSelected,
          onSelected: (_) {
            setState(() {
              _selectedFeatureIndex = tab.$1;
            });
          },
          avatar: Icon(
            tab.$3,
            size: 18,
            color: isSelected ? Colors.white : SiagaColors.navy,
          ),
          label: Text(tab.$2),
          selectedColor: SiagaColors.navy,
          backgroundColor: Colors.white,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : SiagaColors.textDark,
            fontWeight: FontWeight.w700,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActiveFeatureContent(EducationUserProgress progress) {
    switch (_selectedFeatureIndex) {
      case 1:
        return _buildSimulationsView();
      case 2:
        return _buildQuizzesView();
      case 3:
        return _buildMissionsView();
      case 0:
      default:
        return _buildLearnView();
    }
  }

  Widget _buildLearnView() {
    final filtered = _service.filterMaterials(
      search: _searchController.text,
      category: _selectedCategory,
      difficulty: _selectedDifficulty,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter & Pencarian Materi
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: SiagaColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Cari materi gempa bumi atau tsunami...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final cat in ['Semua', 'Gempa Bumi', 'Tsunami'])
                    FilterChip(
                      selected: _selectedCategory == cat,
                      label: Text(cat),
                      onSelected: (_) {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      },
                    ),
                  for (final diff in ['Semua', 'Dasar', 'Menengah', 'Lanjutan'])
                    FilterChip(
                      selected: _selectedDifficulty == diff,
                      label: Text(
                        diff == 'Semua' ? 'Semua Kesulitan' : 'Tingkat $diff',
                      ),
                      onSelected: (_) {
                        setState(() {
                          _selectedDifficulty = diff;
                        });
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (filtered.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Tidak ada materi yang sesuai dengan filter pencarian.',
              textAlign: TextAlign.center,
            ),
          )
        else
          ...filtered.map(
            (item) => Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: SiagaColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _buildTag(
                        item.category,
                        item.category == 'Gempa Bumi'
                            ? const Color(0xFFFEF3C7)
                            : const Color(0xFFE0F2FE),
                        item.category == 'Gempa Bumi'
                            ? const Color(0xFFB45309)
                            : const Color(0xFF0369A1),
                      ),
                      _buildTag(
                        item.difficulty,
                        const Color(0xFFF1F5F9),
                        SiagaColors.textDark,
                      ),
                      if (item.isCompleted)
                        _buildTag(
                          '✓ Selesai',
                          const Color(0xFFDCFCE7),
                          SiagaColors.safe,
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: SiagaColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.summary,
                    style: const TextStyle(
                      fontSize: 13.8,
                      color: SiagaColors.textMuted,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.sourceReference,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: SiagaColors.textMuted,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      FilledButton.tonalIcon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => EducationMaterialDetailPage(
                                materialSlugOrId: item.slug,
                                service: _service,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.menu_book_rounded, size: 18),
                        label: const Text('Baca Materi'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSimulationsView() {
    final sims = _service.simulations.where((s) {
      if (_selectedCategory != 'Semua' && s.category != _selectedCategory) {
        return false;
      }
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...sims.map(
          (sim) => Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: SiagaColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _buildTag(
                      'Simulasi ${sim.category}',
                      sim.category == 'Gempa Bumi'
                          ? const Color(0xFFFEF3C7)
                          : const Color(0xFFE0F2FE),
                      sim.category == 'Gempa Bumi'
                          ? const Color(0xFFB45309)
                          : const Color(0xFF0369A1),
                    ),
                    _buildTag(
                      sim.difficulty,
                      const Color(0xFFF1F5F9),
                      SiagaColors.textDark,
                    ),
                    if (sim.bestScore != null)
                      _buildTag(
                        'Skor Terbaik: ${sim.bestScore}/100',
                        const Color(0xFFDCFCE7),
                        SiagaColors.safe,
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  sim.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: SiagaColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  sim.scenarioContext,
                  style: const TextStyle(
                    fontSize: 13.8,
                    color: SiagaColors.textMuted,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: SiagaColors.danger,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => EducationSimulationPage(
                            simulation: sim,
                            service: _service,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.play_circle_fill_rounded, size: 18),
                    label: const Text('Mulai Simulasi'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuizzesView() {
    final quizzes = _service.quizzes.where((q) {
      if (_selectedCategory != 'Semua' && q.category != _selectedCategory) {
        return false;
      }
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...quizzes.map(
          (quiz) => Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: SiagaColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _buildTag(
                      'Kuis ${quiz.category}',
                      quiz.category == 'Gempa Bumi'
                          ? const Color(0xFFFEF3C7)
                          : const Color(0xFFE0F2FE),
                      quiz.category == 'Gempa Bumi'
                          ? const Color(0xFFB45309)
                          : const Color(0xFF0369A1),
                    ),
                    _buildTag(
                      quiz.difficulty,
                      const Color(0xFFF1F5F9),
                      SiagaColors.textDark,
                    ),
                    _buildTag(
                      '${quiz.questionsCount} Soal',
                      const Color(0xFFEFF6FF),
                      SiagaColors.navy,
                    ),
                    if (quiz.bestScore != null)
                      _buildTag(
                        'Nilai Terbaik: ${quiz.bestScore}',
                        const Color(0xFFDCFCE7),
                        SiagaColors.safe,
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  quiz.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: SiagaColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  quiz.description,
                  style: const TextStyle(
                    fontSize: 13.8,
                    color: SiagaColors.textMuted,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: SiagaColors.navy,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => EducationQuizPage(
                            quiz: quiz,
                            service: _service,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.quiz_rounded, size: 18),
                    label: const Text('Kerjakan Kuis'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMissionsView() {
    final missions = _service.missions.where((m) {
      if (_selectedCategory != 'Semua' && m.category != _selectedCategory) {
        return false;
      }
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...missions.map(
          (ms) => Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: SiagaColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _buildTag(
                      'Misi ${ms.category}',
                      ms.category == 'Gempa Bumi'
                          ? const Color(0xFFFEF3C7)
                          : const Color(0xFFE0F2FE),
                      ms.category == 'Gempa Bumi'
                          ? const Color(0xFFB45309)
                          : const Color(0xFF0369A1),
                    ),
                    _buildTag(
                      ms.difficulty,
                      const Color(0xFFF1F5F9),
                      SiagaColors.textDark,
                    ),
                    _buildTag(
                      '+${ms.points} Poin',
                      const Color(0xFFDCFCE7),
                      SiagaColors.safe,
                    ),
                    _buildTag(
                      'Status: ${ms.userStatusLabel}',
                      ms.userStatus == 'selesai'
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFF1F5F9),
                      ms.userStatus == 'selesai'
                          ? SiagaColors.safe
                          : SiagaColors.navy,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  ms.title,
                  style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: SiagaColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  ms.description,
                  style: const TextStyle(
                    fontSize: 13.8,
                    color: SiagaColors.textMuted,
                    height: 1.5,
                  ),
                ),
                if (ms.instructions.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ...ms.instructions.map(
                    (inst) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• $inst',
                        style: const TextStyle(
                          fontSize: 13,
                          color: SiagaColors.textDark,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final statusOpt in [
                      ('belum_dimulai', 'Belum dimulai'),
                      ('sedang_dikerjakan', 'Sedang dikerjakan'),
                      ('selesai', 'Selesai'),
                    ])
                      ChoiceChip(
                        selected: ms.userStatus == statusOpt.$1,
                        label: Text(statusOpt.$2),
                        onSelected: (_) async {
                          final msg = await _service.updateMissionStatus(
                            ms.id,
                            statusOpt.$1,
                          );
                          if (!mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(msg)));
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}
