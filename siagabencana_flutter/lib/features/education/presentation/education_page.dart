import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/navigation/app_section.dart';
import '../../../app/siaga_theme.dart';
import '../../auth/data/auth_session_service.dart';
import '../data/education_data_service.dart';
import 'education_material_detail_page.dart';
import 'education_quiz_page.dart';
import 'education_simulation_page.dart';

class EducationPage extends StatefulWidget {
  const EducationPage({
    super.key,
    required this.onNavigate,
    required this.service,
    required this.user,
    required this.onRequireLogin,
    this.isAuthLoading = false,
    this.initialCategoryFilter = 'Semua',
    this.initialFeatureTab = 0,
  });

  final ValueChanged<AppSection> onNavigate;
  final EducationDataService service;
  final AuthUser? user;
  final VoidCallback onRequireLogin;
  final bool isAuthLoading;
  final String initialCategoryFilter;
  final int initialFeatureTab;

  @override
  State<EducationPage> createState() => _EducationPageState();
}

class _EducationPageState extends State<EducationPage> {
  final TextEditingController _searchController = TextEditingController();
  late String _selectedCategory;
  String _selectedDifficulty = 'Semua';
  bool _favoritesOnly = false;
  late int _selectedFeatureIndex;

  // Local editing state for Reminder tab
  bool _remEnabled = false;
  String _remTime = '19:00';
  String _remFrequency = 'daily';
  bool _remMaterials = true;
  bool _remMissions = true;
  bool _remInactive = true;
  bool _remSyncedOnce = false;
  bool _savingReminder = false;

  EducationDataService get _service => widget.service;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategoryFilter;
    _selectedFeatureIndex = widget.initialFeatureTab;
    if (widget.user != null) {
      _service.bindUser(widget.user);
      if (_service.materials.isEmpty && !_service.isLoading) {
        unawaited(_service.refreshAll());
      }
    }
  }

  @override
  void didUpdateWidget(covariant EducationPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user?.id != widget.user?.id) {
      _remSyncedOnce = false;
      _service.bindUser(widget.user);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _syncReminderFormFromProgress(ReminderPreference pref) {
    if (_remSyncedOnce) {
      return;
    }
    _remSyncedOnce = true;
    _remEnabled = pref.isEnabled;
    _remTime = pref.reminderTime;
    _remFrequency = pref.frequency;
    _remMaterials = pref.remindUnfinishedMaterials;
    _remMissions = pref.remindPendingMissions;
    _remInactive = pref.remindInactiveLearning;
  }

  void _selectCategoryAndJumpToLearn(String category) {
    setState(() {
      _selectedCategory = category;
      _selectedFeatureIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = MediaQuery.sizeOf(context).width < 600
        ? 18.0
        : 30.0;

    if (widget.isAuthLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Memeriksa sesi login akun SiagaBencana...'),
          ],
        ),
      );
    }

    if (widget.user == null) {
      return ListView(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          32,
          horizontalPadding,
          44,
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: SiagaColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  size: 48,
                  color: SiagaColors.navy,
                ),
                const SizedBox(height: 14),
                Text(
                  'Login Diperlukan untuk Edukasi Bencana',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Fitur Edukasi Gempa Bumi dan Tsunami menyimpan progres membaca, hasil simulasi, nilai kuis, Misi Siaga, badge, serta pengaturan pengingat secara terpisah untuk setiap akun di database. Silakan masuk terlebih dahulu.',
                  style: TextStyle(
                    color: SiagaColors.textMuted,
                    fontSize: 14.5,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: SiagaColors.navy,
                  ),
                  onPressed: widget.onRequireLogin,
                  icon: const Icon(Icons.login_rounded),
                  label: const Text('Masuk ke Akun SiagaBencana'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListenableBuilder(
      listenable: _service,
      builder: (context, _) {
        final progress = _service.currentProgress;
        if (progress.authenticated) {
          _syncReminderFormFromProgress(progress.reminderPreference);
        }

        return ListView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            24,
            horizontalPadding,
            44,
          ),
          children: [
            _buildHeaderBanner(),
            if (_service.isLoading) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
            ],
            if (_service.loadError != null) ...[
              const SizedBox(height: 12),
              _buildErrorBanner(_service.loadError!),
            ],
            if (_service.saveStatus != SaveSyncStatus.idle) ...[
              const SizedBox(height: 12),
              _buildSaveStatusBanner(),
            ],
            if (progress.pendingReminders.isNotEmpty) ...[
              const SizedBox(height: 14),
              _buildPendingRemindersBanner(progress.pendingReminders),
            ],
            const SizedBox(height: 20),
            _buildMainCategoriesRow(),
            const SizedBox(height: 20),
            _buildProgressSummaryCard(progress),
            const SizedBox(height: 20),
            _buildFeatureMenus(),
            const SizedBox(height: 16),
            _buildActiveFeatureContent(progress),
          ],
        );
      },
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, color: SiagaColors.danger),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: SiagaColors.danger,
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
              ),
            ),
          ),
          TextButton(
            onPressed: () => unawaited(_service.refreshAll()),
            child: const Text('Muat Ulang'),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveStatusBanner() {
    final status = _service.saveStatus;
    final (Color bg, Color fg, IconData icon) = switch (status) {
      SaveSyncStatus.saving => (
        const Color(0xFFEFF6FF),
        SiagaColors.navy,
        Icons.sync_rounded,
      ),
      SaveSyncStatus.saved => (
        const Color(0xFFDCFCE7),
        SiagaColors.safe,
        Icons.cloud_done_outlined,
      ),
      SaveSyncStatus.error => (
        const Color(0xFFFEF2F2),
        SiagaColors.danger,
        Icons.error_outline_rounded,
      ),
      SaveSyncStatus.idle => (Colors.transparent, Colors.transparent, Icons.info),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _service.saveStatusMessage ?? '',
              style: TextStyle(
                color: fg,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (status == SaveSyncStatus.error && _service.hasPendingRetry)
            FilledButton.tonal(
              onPressed: () => unawaited(_service.retryLastSave()),
              child: const Text('Coba Lagi'),
            ),
        ],
      ),
    );
  }

  Widget _buildPendingRemindersBanner(List<ReminderItem> reminders) {
    final first = reminders.first;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.notifications_active_outlined,
            color: Color(0xFFB45309),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  first.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF92400E),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  first.message,
                  style: const TextStyle(
                    color: Color(0xFF78350F),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.tonal(
            onPressed: () {
              if (first.targetType == 'material' && first.targetSlug != null) {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => EducationMaterialDetailPage(
                      materialSlugOrId: first.targetSlug!,
                      service: _service,
                    ),
                  ),
                );
              } else if (first.targetType == 'simulation') {
                setState(() => _selectedFeatureIndex = 1);
              } else {
                setState(() => _selectedFeatureIndex = 3);
              }
            },
            child: const Text('Lanjutkan'),
          ),
        ],
      ),
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.school_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  'PUSAT EDUKASI MITIGASI · ${widget.user!.name.toUpperCase()}',
                  style: const TextStyle(
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
            'Pelajari pengetahuan kesiapsiagaan resmi dari BNPB, BMKG, Basarnas, dan BPBD mengenai cara mengenali risiko, menyiapkan Tas Siaga Bencana, menerapkan prosedur Drop, Cover, and Hold On, serta mengevakuasi diri ke tempat aman.',
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
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF93C5FD)),
                ),
                onPressed: () => unawaited(_service.refreshAll()),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Sinkronkan Data'),
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
              '12 Materi lengkap dari pengertian gempa, persiapan rumah, Drop Cover Hold On di rumah/sekolah/gedung, hingga bahaya susulan & Tas Siaga.',
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
          children: [gempaCard, const SizedBox(height: 12), tsunamiCard],
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
          Wrap(
            spacing: 10,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'Ringkasan Progres & Level Kesiapsiagaan',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: SiagaColors.textDark,
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _buildTag(
                    '🎖️ Level ${progress.level.levelNumber} · ${progress.level.levelName}',
                    const Color(0xFFE0F2FE),
                    const Color(0xFF0369A1),
                  ),
                  _buildTag(
                    '${progress.overallPercentage}% · ${progress.totalPoints} Poin',
                    const Color(0xFFDCFCE7),
                    SiagaColors.safe,
                  ),
                ],
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
                'Simulasi',
                '${progress.simulationsCompleted}/${progress.simulationsTotal}',
              ),
              _buildStatChip(
                'Kuis (Rata² ${progress.quizAverageScore})',
                '${progress.quizzesCompleted}/${progress.quizzesTotal}',
              ),
              _buildStatChip(
                'Misi Siaga',
                '${progress.missionsCompleted}/${progress.missionsTotal}',
              ),
              _buildStatChip(
                'Badge Diraih',
                '${progress.earnedBadgesCount}/${progress.badges.length}',
              ),
            ],
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

  Widget _buildFeatureMenus() {
    final tabs = [
      (0, 'Belajar', Icons.menu_book_rounded),
      (1, 'Simulasi', Icons.psychology_alt_rounded),
      (2, 'Kuis', Icons.quiz_rounded),
      (3, 'Misi Siaga', Icons.flag_circle_rounded),
      (4, 'Progres & Riwayat', Icons.insights_rounded),
      (5, 'Pengingat', Icons.notifications_active_outlined),
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
        return _buildSimulationsView(progress);
      case 2:
        return _buildQuizzesView(progress);
      case 3:
        return _buildMissionsView();
      case 4:
        return _buildProgressDashboardView(progress);
      case 5:
        return _buildRemindersSettingsView(progress);
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
      favoritesOnly: _favoritesOnly,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                      onSelected: (_) => setState(() => _selectedCategory = cat),
                    ),
                  for (final diff in ['Semua', 'Dasar', 'Menengah', 'Lanjutan'])
                    FilterChip(
                      selected: _selectedDifficulty == diff,
                      label: Text(
                        diff == 'Semua' ? 'Semua Kesulitan' : 'Tingkat $diff',
                      ),
                      onSelected: (_) =>
                          setState(() => _selectedDifficulty = diff),
                    ),
                  FilterChip(
                    selected: _favoritesOnly,
                    avatar: const Icon(Icons.star_rounded, size: 16),
                    label: const Text('Favorit Saya'),
                    onSelected: (v) => setState(() => _favoritesOnly = v),
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
                        )
                      else if (item.progressPercent > 0)
                        _buildTag(
                          'Lanjutkan · ${item.progressPercent}%',
                          const Color(0xFFFEF9C3),
                          const Color(0xFFA16207),
                        ),
                      if (item.isFavorite)
                        _buildTag(
                          '★ Favorit',
                          const Color(0xFFFEF3C7),
                          const Color(0xFFB45309),
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
                          'Ref: ${item.sourceReference}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: SiagaColors.textMuted,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: SiagaColors.navy,
                        ),
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
                        label: Text(
                          item.progressPercent > 0 && !item.isCompleted
                              ? 'Lanjutkan Membaca'
                              : 'Baca Materi',
                        ),
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

  Widget _buildSimulationsView(EducationUserProgress progress) {
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
                    if (sim.draft != null)
                      _buildTag(
                        '⏸️ Tersimpan di Tahap ${sim.draft!.currentStepIndex + 1}',
                        const Color(0xFFFEF9C3),
                        const Color(0xFFA16207),
                      ),
                    if (sim.bestScore != null)
                      _buildTag(
                        'Terbaik: ${sim.bestScore}/100 · ${sim.attemptsCount}x main',
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
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(
                      sim.draft != null
                          ? 'Lanjutkan Simulasi'
                          : 'Mulai Simulasi',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (progress.simulationHistory.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text(
            'Riwayat Simulasi Terbaru',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          for (final h in progress.simulationHistory.take(6))
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SiagaColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${h.simulationTitle} (${h.category})',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  _buildTag(
                    'Skor ${h.score}/100',
                    const Color(0xFFEFF6FF),
                    SiagaColors.navy,
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildQuizzesView(EducationUserProgress progress) {
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
                        'Terbaik: ${quiz.bestScore} · Terakhir: ${quiz.latestScore ?? quiz.bestScore} (${quiz.attemptsCount}x)',
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
                          builder: (_) =>
                              EducationQuizPage(quiz: quiz, service: _service),
                        ),
                      );
                    },
                    icon: const Icon(Icons.quiz_rounded, size: 18),
                    label: Text(
                      quiz.attemptsCount > 0 ? 'Kerjakan Ulang Kuis' : 'Kerjakan Kuis',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (progress.quizHistory.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text(
            'Riwayat Percobaan Kuis',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          for (final h in progress.quizHistory.take(8))
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SiagaColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          h.quizTitle,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'Benar ${h.correctAnswers}/${h.totalQuestions} · ${h.category}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: SiagaColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildTag(
                    'Nilai ${h.finalScore}',
                    const Color(0xFFDCFCE7),
                    SiagaColors.safe,
                  ),
                ],
              ),
            ),
        ],
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
                      '+${ms.points} Poin',
                      const Color(0xFFDCFCE7),
                      SiagaColors.safe,
                    ),
                    _buildTag(
                      ms.userStatusLabel,
                      ms.userStatus == 'selesai'
                          ? const Color(0xFFDCFCE7)
                          : ms.userStatus == 'sedang_dikerjakan'
                          ? const Color(0xFFFEF9C3)
                          : const Color(0xFFF1F5F9),
                      ms.userStatus == 'selesai'
                          ? SiagaColors.safe
                          : SiagaColors.textDark,
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
                const SizedBox(height: 10),
                for (final inst in ms.instructions)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• $inst',
                      style: const TextStyle(
                        fontSize: 13.2,
                        color: SiagaColors.textDark,
                      ),
                    ),
                  ),
                if (ms.startedAt != null || ms.completedAt != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    [
                      if (ms.startedAt != null)
                        'Dimulai: ${_shortDate(ms.startedAt!)}',
                      if (ms.completedAt != null)
                        'Selesai: ${_shortDate(ms.completedAt!)}',
                    ].join(' · '),
                    style: const TextStyle(
                      fontSize: 12,
                      color: SiagaColors.textMuted,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _missionActionButton(ms, 'belum_dimulai', 'Belum Dimulai'),
                    _missionActionButton(
                      ms,
                      'sedang_dikerjakan',
                      'Sedang Dikerjakan',
                    ),
                    _missionActionButton(ms, 'selesai', 'Selesai ✓'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _missionActionButton(MissionItem ms, String status, String label) {
    final active = ms.userStatus == status;
    return ChoiceChip(
      selected: active,
      label: Text(label),
      selectedColor: status == 'selesai' ? SiagaColors.safe : SiagaColors.navy,
      labelStyle: TextStyle(
        color: active ? Colors.white : SiagaColors.textDark,
        fontWeight: FontWeight.w700,
        fontSize: 12.5,
      ),
      onSelected: (_) async {
        try {
          final msg = await _service.updateMissionStatus(ms.id, status);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg), backgroundColor: SiagaColors.safe),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString()),
                backgroundColor: SiagaColors.danger,
              ),
            );
          }
        }
      },
    );
  }

  Widget _buildProgressDashboardView(EducationUserProgress progress) {
    final maxChartCount = progress.activityChart.fold<int>(
      1,
      (prev, e) => e.count > prev ? e.count : prev,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Gempa vs Tsunami Progress + Level
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
              const Text(
                'Dashboard Progres Pembelajaran',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              _categoryBar(
                'Kategori Gempa Bumi',
                '${progress.earthquakeMaterialsCompleted}/${progress.earthquakeMaterialsTotal} materi (${progress.earthquakePercentage}%)',
                progress.earthquakePercentage / 100.0,
                SiagaColors.warning,
              ),
              const SizedBox(height: 12),
              _categoryBar(
                'Kategori Tsunami',
                '${progress.tsunamiMaterialsCompleted}/${progress.tsunamiMaterialsTotal} materi (${progress.tsunamiPercentage}%)',
                progress.tsunamiPercentage / 100.0,
                SiagaColors.info,
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildStatChip('Rata-rata Kuis', '${progress.quizAverageScore}'),
                  _buildStatChip('Nilai Kuis Terbaik', '${progress.quizBestScore}'),
                  _buildStatChip(
                    'Level ${progress.level.levelNumber}',
                    progress.level.levelName,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 7-day learning activity bar chart
        if (progress.activityChart.isNotEmpty) ...[
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
                const Text(
                  'Grafik Aktivitas Belajar (7 Hari Terakhir)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 130,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: progress.activityChart.map((pt) {
                      final h = (pt.count / maxChartCount) * 86.0;
                      return Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '${pt.count}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: SiagaColors.navy,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 22,
                              height: h < 6 ? 6 : h,
                              decoration: BoxDecoration(
                                color: pt.count > 0
                                    ? SiagaColors.navy
                                    : const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              pt.label,
                              style: const TextStyle(
                                fontSize: 11,
                                color: SiagaColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Badges & Achievements
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
                'Pencapaian & Badge (${progress.earnedBadgesCount}/${progress.badges.length})',
                style: const TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              for (final b in progress.badges)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: b.isEarned
                        ? const Color(0xFFF0FDF4)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: b.isEarned
                          ? const Color(0xFF86EFAC)
                          : SiagaColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        b.isEarned
                            ? Icons.workspace_premium_rounded
                            : Icons.lock_outline_rounded,
                        color: b.isEarned
                            ? SiagaColors.safe
                            : SiagaColors.textMuted,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${b.name} (+${b.pointsReward} Poin)',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14.5,
                              ),
                            ),
                            Text(
                              b.description,
                              style: const TextStyle(
                                fontSize: 13,
                                color: SiagaColors.textMuted,
                              ),
                            ),
                            Text(
                              'Syarat: ${b.criteriaDescription}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: SiagaColors.navy,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildTag(
                        b.isEarned ? 'Diraih ✓' : 'Terkunci',
                        b.isEarned
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFE2E8F0),
                        b.isEarned ? SiagaColors.safe : SiagaColors.textMuted,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Chronological Activity History
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
              const Text(
                'Riwayat Aktivitas Pembelajaran',
                style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              if (progress.recentActivities.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Belum ada riwayat aktivitas. Mulailah membaca materi Gempa Bumi atau Tsunami pertama Anda!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: SiagaColors.textMuted),
                  ),
                )
              else
                for (final act in progress.recentActivities)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFEFF6FF),
                      child: const Icon(
                        Icons.history_edu_rounded,
                        color: SiagaColors.navy,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      '${act.typeLabel}: ${act.subjectTitle}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      [
                        if (act.category != null) act.category!,
                        if (act.createdAt != null) _shortDate(act.createdAt!),
                      ].join(' · '),
                      style: const TextStyle(fontSize: 12.5),
                    ),
                    trailing: act.pointsEarned > 0
                        ? _buildTag(
                            '+${act.pointsEarned} Poin',
                            const Color(0xFFDCFCE7),
                            SiagaColors.safe,
                          )
                        : null,
                  ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRemindersSettingsView(EducationUserProgress progress) {
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
          const Text(
            'Pengaturan Pengingat Belajar',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'Preferensi pengingat disimpan ke akun Anda di database Laravel. Pengingat tampil di dalam aplikasi (in-app) dan dijadwalkan di server Laravel tanpa spam — aktivitas yang sudah selesai dilewati secara otomatis.',
            style: TextStyle(
              fontSize: 13.5,
              color: SiagaColors.textMuted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Aktifkan Pengingat Belajar',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            value: _remEnabled,
            onChanged: (val) => setState(() => _remEnabled = val),
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Waktu Pengingat'),
            subtitle: Text(_remTime),
            trailing: OutlinedButton.icon(
              onPressed: () async {
                final parts = _remTime.split(':');
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                    hour: int.tryParse(parts.first) ?? 19,
                    minute: parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0,
                  ),
                );
                if (picked != null) {
                  setState(() {
                    _remTime =
                        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                  });
                }
              },
              icon: const Icon(Icons.access_time_rounded),
              label: const Text('Ubah Waktu'),
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: _remFrequency,
            decoration: const InputDecoration(
              labelText: 'Frekuensi Pengingat',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'daily', child: Text('Harian')),
              DropdownMenuItem(
                value: 'every_3_days',
                child: Text('Setiap 3 Hari'),
              ),
              DropdownMenuItem(value: 'weekly', child: Text('Mingguan')),
            ],
            onChanged: (v) {
              if (v != null) {
                setState(() => _remFrequency = v);
              }
            },
          ),
          const SizedBox(height: 10),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Ingatkan materi yang belum selesai dibaca'),
            value: _remMaterials,
            onChanged: (v) => setState(() => _remMaterials = v ?? true),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Ingatkan Misi Siaga yang masih tertunda'),
            value: _remMissions,
            onChanged: (v) => setState(() => _remMissions = v ?? true),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Ingatkan untuk melanjutkan belajar jika belum aktif'),
            value: _remInactive,
            onChanged: (v) => setState(() => _remInactive = v ?? true),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: SiagaColors.navy),
            onPressed: _savingReminder
                ? null
                : () async {
                    setState(() => _savingReminder = true);
                    try {
                      final msg = await _service.updateReminderPreference(
                        ReminderPreference(
                          isEnabled: _remEnabled,
                          reminderTime: _remTime,
                          frequency: _remFrequency,
                          remindUnfinishedMaterials: _remMaterials,
                          remindPendingMissions: _remMissions,
                          remindInactiveLearning: _remInactive,
                        ),
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(msg),
                            backgroundColor: SiagaColors.safe,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString()),
                            backgroundColor: SiagaColors.danger,
                          ),
                        );
                      }
                    } finally {
                      if (mounted) {
                        setState(() => _savingReminder = false);
                      }
                    }
                  },
            icon: _savingReminder
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(
              _savingReminder ? 'Menyimpan...' : 'Simpan Pengaturan Pengingat',
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryBar(
    String title,
    String subtitle,
    double ratio,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12.5,
                color: SiagaColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: ratio.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: const Color(0xFFE2E8F0),
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

  String _shortDate(String iso) {
    final dt = DateTime.tryParse(iso)?.toLocal();
    if (dt == null) {
      return iso;
    }
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
