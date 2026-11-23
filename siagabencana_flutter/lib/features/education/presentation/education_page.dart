import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/navigation/app_section.dart';
import '../../../app/siaga_theme.dart';
import '../../../app/widgets/siaga_components.dart';
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
    if (_remSyncedOnce) return;
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
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = SiagaBreakpoints.pageHorizontalPadding(width);

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
          36,
          horizontalPadding,
          44,
        ),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: SiagaCard(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SiagaIconTile(
                      icon: Icons.lock_outline_rounded,
                      size: 52,
                      color: SiagaColors.navy,
                      backgroundColor: SiagaColors.primarySoft,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Login Diperlukan untuk Edukasi Bencana',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Fitur Edukasi Gempa Bumi dan Tsunami menyimpan progres membaca, hasil simulasi, nilai kuis, Misi Siaga, badge, serta pengaturan pengingat secara terpisah untuk setiap akun.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 18),
                    const SiagaBullet(
                      text:
                          'Progres belajar dan posisi membaca tersimpan otomatis di server.',
                      icon: Icons.cloud_done_outlined,
                      color: SiagaColors.primaryBlue,
                    ),
                    const SiagaBullet(
                      text:
                          'Akses 24 materi resmi, 12 skenario simulasi, kuis, dan Misi Siaga.',
                      icon: Icons.school_outlined,
                      color: SiagaColors.safe,
                    ),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: widget.onRequireLogin,
                      icon: const Icon(Icons.login_rounded, size: 18),
                      label: const Text('Masuk ke Akun SiagaBencana'),
                    ),
                  ],
                ),
              ),
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
            _buildHeaderBanner(progress),
            if (_service.isLoading) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
            ],
            if (_service.loadError != null) ...[
              const SizedBox(height: 12),
              SiagaNotice(
                title: 'Gagal menyinkronkan data edukasi',
                message: _service.loadError!,
                tone: SiagaTone.danger,
                icon: Icons.cloud_off_rounded,
                trailing: TextButton(
                  onPressed: () => unawaited(_service.refreshAll()),
                  child: const Text('Muat Ulang'),
                ),
              ),
            ],
            if (_service.saveStatus != SaveSyncStatus.idle) ...[
              const SizedBox(height: 12),
              _buildSaveStatusBanner(),
            ],
            if (progress.pendingReminders.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildPendingRemindersBanner(progress.pendingReminders),
            ],
            const SizedBox(height: 20),
            _buildMainCategoriesRow(progress),
            const SizedBox(height: 20),
            _buildCompactProgressStrip(progress),
            const SizedBox(height: 22),
            SiagaSegmentedTabs(
              selectedIndex: _selectedFeatureIndex,
              onSelected: (index) =>
                  setState(() => _selectedFeatureIndex = index),
              items: [
                SiagaSegmentedTabItem(
                  label: 'Belajar',
                  icon: Icons.menu_book_outlined,
                  badgeText: '${progress.materialsCompleted}/${progress.materialsTotal}',
                ),
                SiagaSegmentedTabItem(
                  label: 'Simulasi',
                  icon: Icons.psychology_alt_outlined,
                  badgeText:
                      '${progress.simulationsCompleted}/${progress.simulationsTotal}',
                ),
                SiagaSegmentedTabItem(
                  label: 'Kuis',
                  icon: Icons.quiz_outlined,
                  badgeText: '${progress.quizzesCompleted}/${progress.quizzesTotal}',
                ),
                SiagaSegmentedTabItem(
                  label: 'Misi Siaga',
                  icon: Icons.flag_outlined,
                  badgeText:
                      '${progress.missionsCompleted}/${progress.missionsTotal}',
                ),
                const SiagaSegmentedTabItem(
                  label: 'Progres & Riwayat',
                  icon: Icons.insights_rounded,
                ),
                const SiagaSegmentedTabItem(
                  label: 'Pengingat',
                  icon: Icons.notifications_none_rounded,
                ),
              ],
            ),
            const SizedBox(height: 18),
            _buildActiveFeatureContent(progress),
          ],
        );
      },
    );
  }

  Widget _buildSaveStatusBanner() {
    final status = _service.saveStatus;
    final tone = switch (status) {
      SaveSyncStatus.saving => SiagaTone.info,
      SaveSyncStatus.saved => SiagaTone.success,
      SaveSyncStatus.error => SiagaTone.danger,
      SaveSyncStatus.idle => SiagaTone.neutral,
    };
    final icon = switch (status) {
      SaveSyncStatus.saving => Icons.sync_rounded,
      SaveSyncStatus.saved => Icons.cloud_done_outlined,
      SaveSyncStatus.error => Icons.error_outline_rounded,
      SaveSyncStatus.idle => Icons.info_outline_rounded,
    };

    return SiagaNotice(
      title: status == SaveSyncStatus.saved
          ? 'Progres tersimpan'
          : status == SaveSyncStatus.saving
          ? 'Menyimpan progres'
          : 'Gagal menyimpan progres',
      message: _service.saveStatusMessage ?? '',
      tone: tone,
      icon: icon,
      trailing: status == SaveSyncStatus.error && _service.hasPendingRetry
          ? OutlinedButton(
              onPressed: () => unawaited(_service.retryLastSave()),
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 34)),
              child: const Text('Coba Lagi'),
            )
          : null,
    );
  }

  Widget _buildPendingRemindersBanner(List<ReminderItem> reminders) {
    final first = reminders.first;
    return SiagaNotice(
      title: first.title,
      message: first.message,
      tone: SiagaTone.warning,
      icon: Icons.notifications_active_outlined,
      trailing: OutlinedButton(
        style: OutlinedButton.styleFrom(minimumSize: const Size(0, 36)),
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
    );
  }

  Widget _buildHeaderBanner(EducationUserProgress progress) {
    final isNarrow = MediaQuery.sizeOf(context).width < 600;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isNarrow ? 20 : 28),
      decoration: BoxDecoration(
        color: SiagaColors.navy,
        borderRadius: BorderRadius.circular(SiagaRadius.xl),
        border: Border.all(color: const Color(0xFF1E3A5F)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 780;

          final left = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.school_outlined,
                    color: Color(0xFF93C5FD),
                    size: 15,
                  ),
                  const SizedBox(width: 7),
                  Flexible(
                    child: Text(
                      'PUSAT EDUKASI MITIGASI · ${widget.user!.name.toUpperCase()}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF93C5FD),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Edukasi Gempa Bumi dan Tsunami',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontSize: isWide ? 28 : 23,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                '"Kenali Risikonya, Lindungi Dirimu, Selamatkan Sesama."',
                style: TextStyle(
                  color: Color(0xFFFBBF24),
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: const Text(
                  'Pelajari pengetahuan kesiapsiagaan resmi dari BNPB, BMKG, Basarnas, dan BPBD mengenai pengenalan risiko, Tas Siaga Bencana, prosedur Drop, Cover, and Hold On, serta evakuasi mandiri.',
                  style: TextStyle(
                    color: Color(0xFFCBD5E1),
                    fontSize: 13.8,
                    height: 1.55,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: SiagaColors.navy,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedFeatureIndex = 0;
                        _selectedCategory = 'Semua';
                      });
                    },
                    icon: const Icon(Icons.play_arrow_rounded, size: 19),
                    label: const Text('Mulai Belajar Sekarang'),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0x14FFFFFF),
                      side: const BorderSide(color: Color(0x4DFFFFFF)),
                    ),
                    onPressed: () => widget.onNavigate(AppSection.evacuation),
                    icon: const Icon(Icons.map_outlined, size: 17),
                    label: const Text('Buka Peta Evakuasi'),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0x14FFFFFF),
                      side: const BorderSide(color: Color(0x4DFFFFFF)),
                    ),
                    onPressed: () => unawaited(_service.refreshAll()),
                    icon: const Icon(Icons.refresh_rounded, size: 17),
                    label: const Text('Sinkronkan Data'),
                  ),
                ],
              ),
            ],
          );

          final readinessBox = Container(
            width: isWide ? 280 : double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF14345C),
              borderRadius: BorderRadius.circular(SiagaRadius.lg),
              border: Border.all(color: const Color(0xFF234775)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.military_tech_rounded,
                      color: Color(0xFFFBBF24),
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Level ${progress.level.levelNumber} · ${progress.level.levelName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${progress.overallPercentage}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${progress.totalPoints} Poin',
                      style: const TextStyle(
                        color: Color(0xFF93C5FD),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(SiagaRadius.pill),
                  child: LinearProgressIndicator(
                    value: (progress.overallPercentage / 100.0).clamp(0.0, 1.0),
                    minHeight: 7,
                    backgroundColor: const Color(0xFF234775),
                    color: const Color(0xFF38BDF8),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  progress.initialMessage,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          );

          if (!isWide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [left, const SizedBox(height: 18), readinessBox],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: left),
              const SizedBox(width: 24),
              readinessBox,
            ],
          );
        },
      ),
    );
  }

  Widget _buildMainCategoriesRow(EducationUserProgress progress) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 700;
        final gempaCard = _CategoryTrackCard(
          eyebrow: 'KATEGORI UTAMA A',
          title: 'Gempa Bumi',
          description:
              '12 materi terstruktur mulai dari pengenalan risiko, pengamanan rumah, prosedur Drop, Cover, and Hold On, hingga Tas Siaga.',
          completed: progress.earthquakeMaterialsCompleted,
          total: progress.earthquakeMaterialsTotal,
          icon: Icons.vibration_rounded,
          accentColor: SiagaColors.warning,
          onTapLearn: () => _selectCategoryAndJumpToLearn('Gempa Bumi'),
        );
        final tsunamiCard = _CategoryTrackCard(
          eyebrow: 'KATEGORI UTAMA B',
          title: 'Tsunami',
          description:
              '12 materi lengkap mengenai hubungan gempa & tsunami, 3 level peringatan dini BMKG, tanda alam pesisir, dan evakuasi mandiri.',
          completed: progress.tsunamiMaterialsCompleted,
          total: progress.tsunamiMaterialsTotal,
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

  Widget _buildCompactProgressStrip(EducationUserProgress progress) {
    return SiagaCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Wrap(
        spacing: 20,
        runSpacing: 12,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _InlineMetric(
            icon: Icons.menu_book_outlined,
            label: 'Materi Selesai',
            value: '${progress.materialsCompleted}/${progress.materialsTotal}',
            color: SiagaColors.navy,
          ),
          _InlineMetric(
            icon: Icons.psychology_alt_outlined,
            label: 'Simulasi',
            value:
                '${progress.simulationsCompleted}/${progress.simulationsTotal}',
            color: SiagaColors.warning,
          ),
          _InlineMetric(
            icon: Icons.quiz_outlined,
            label: 'Kuis (Rata-rata ${progress.quizAverageScore})',
            value: '${progress.quizzesCompleted}/${progress.quizzesTotal}',
            color: SiagaColors.info,
          ),
          _InlineMetric(
            icon: Icons.flag_outlined,
            label: 'Misi Siaga',
            value: '${progress.missionsCompleted}/${progress.missionsTotal}',
            color: SiagaColors.safe,
          ),
          _InlineMetric(
            icon: Icons.workspace_premium_outlined,
            label: 'Badge Diraih',
            value: '${progress.earnedBadgesCount}/${progress.badges.length}',
            color: SiagaColors.warning,
          ),
        ],
      ),
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
        SiagaCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Cari materi gempa bumi atau tsunami...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  fillColor: SiagaColors.surfaceSubtle,
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
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
                      onSelected: (_) =>
                          setState(() => _selectedCategory = cat),
                    ),
                  for (final diff in ['Semua', 'Dasar', 'Menengah', 'Lanjutan'])
                    FilterChip(
                      selected: _selectedDifficulty == diff,
                      label: Text(
                        diff == 'Semua' ? 'Semua Tingkat' : 'Tingkat $diff',
                      ),
                      onSelected: (_) =>
                          setState(() => _selectedDifficulty = diff),
                    ),
                  FilterChip(
                    selected: _favoritesOnly,
                    avatar: const Icon(Icons.star_rounded, size: 15),
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
          const SiagaEmptyState(
            icon: Icons.menu_book_outlined,
            title: 'Materi tidak ditemukan',
            message:
                'Tidak ada materi yang sesuai dengan kata kunci atau filter yang dipilih.',
          )
        else
          SiagaResponsiveGrid(
            minimumItemWidth: 380,
            spacing: 14,
            children: [
              for (final item in filtered) _buildMaterialCard(item),
            ],
          ),
      ],
    );
  }

  Widget _buildMaterialCard(EducationMaterialItem item) {
    final isGempa = item.category == 'Gempa Bumi';
    final catTone = isGempa ? SiagaTone.warning : SiagaTone.info;

    return SiagaInteractiveCard(
      padding: const EdgeInsets.all(18),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => EducationMaterialDetailPage(
              materialSlugOrId: item.slug,
              service: _service,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SiagaBadge(label: item.category, tone: catTone, compact: true),
              const SizedBox(width: 6),
              SiagaBadge(
                label: item.difficulty,
                tone: SiagaTone.neutral,
                compact: true,
              ),
              const Spacer(),
              if (item.isFavorite)
                const Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: Icon(
                    Icons.star_rounded,
                    size: 17,
                    color: SiagaColors.warning,
                  ),
                ),
              if (item.isCompleted)
                const SiagaStatusDot(label: 'Selesai', tone: SiagaTone.success)
              else if (item.progressPercent > 0)
                SiagaStatusDot(
                  label: '${item.progressPercent}%',
                  tone: SiagaTone.warning,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            item.summary,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontSize: 13.5),
          ),
          if (item.progressPercent > 0 && !item.isCompleted) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(SiagaRadius.pill),
              child: LinearProgressIndicator(
                value: (item.progressPercent / 100.0).clamp(0.0, 1.0),
                minHeight: 5,
              ),
            ),
          ],
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Ref: ${item.sourceReference}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                item.progressPercent > 0 && !item.isCompleted
                    ? 'Lanjutkan'
                    : 'Baca Materi',
                style: const TextStyle(
                  color: SiagaColors.primaryBlue,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 15,
                color: SiagaColors.primaryBlue,
              ),
            ],
          ),
        ],
      ),
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
        if (sims.isEmpty)
          const SiagaEmptyState(
            icon: Icons.psychology_alt_outlined,
            title: 'Belum ada simulasi tersedia',
            message: 'Skenario simulasi untuk kategori yang dipilih belum tersedia.',
          )
        else
          SiagaResponsiveGrid(
            minimumItemWidth: 380,
            spacing: 14,
            children: [
              for (final sim in sims)
                SiagaCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          SiagaBadge(
                            label: 'Simulasi ${sim.category}',
                            tone: sim.category == 'Gempa Bumi'
                                ? SiagaTone.warning
                                : SiagaTone.info,
                            compact: true,
                          ),
                          SiagaBadge(
                            label: sim.difficulty,
                            tone: SiagaTone.neutral,
                            compact: true,
                          ),
                          if (sim.draft != null)
                            SiagaBadge(
                              label:
                                  'Tersimpan di Tahap ${sim.draft!.currentStepIndex + 1}',
                              tone: SiagaTone.warning,
                              icon: Icons.pause_circle_outline_rounded,
                              compact: true,
                            ),
                          if (sim.bestScore != null)
                            SiagaBadge(
                              label:
                                  'Terbaik: ${sim.bestScore}/100 (${sim.attemptsCount}x)',
                              tone: SiagaTone.success,
                              compact: true,
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        sim.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        sim.scenarioContext,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(fontSize: 13.5),
                      ),
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.icon(
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
                          icon: const Icon(Icons.play_arrow_rounded, size: 18),
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
            ],
          ),
        if (progress.simulationHistory.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            'Riwayat Simulasi Terbaru',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          SiagaCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < progress.simulationHistory.take(6).length; i++) ...[
                  Builder(
                    builder: (context) {
                      final h = progress.simulationHistory[i];
                      return ListTile(
                        leading: const SiagaIconTile(
                          icon: Icons.psychology_alt_outlined,
                          size: 36,
                        ),
                        title: Text(
                          h.simulationTitle,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        subtitle: Text(
                          h.category,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        trailing: SiagaBadge(
                          label: 'Skor ${h.score}/100',
                          tone: h.score >= 75
                              ? SiagaTone.success
                              : SiagaTone.info,
                          compact: true,
                        ),
                      );
                    },
                  ),
                  if (i < progress.simulationHistory.take(6).length - 1)
                    const Divider(height: 1, indent: 16, endIndent: 16),
                ],
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
        if (quizzes.isEmpty)
          const SiagaEmptyState(
            icon: Icons.quiz_outlined,
            title: 'Belum ada kuis tersedia',
            message: 'Kuis evaluasi untuk kategori yang dipilih belum tersedia.',
          )
        else
          SiagaResponsiveGrid(
            minimumItemWidth: 380,
            spacing: 14,
            children: [
              for (final quiz in quizzes)
                SiagaCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          SiagaBadge(
                            label: 'Kuis ${quiz.category}',
                            tone: quiz.category == 'Gempa Bumi'
                                ? SiagaTone.warning
                                : SiagaTone.info,
                            compact: true,
                          ),
                          SiagaBadge(
                            label: quiz.difficulty,
                            tone: SiagaTone.neutral,
                            compact: true,
                          ),
                          SiagaBadge(
                            label: '${quiz.questionsCount} Soal',
                            tone: SiagaTone.info,
                            compact: true,
                          ),
                          if (quiz.bestScore != null)
                            SiagaBadge(
                              label:
                                  'Terbaik: ${quiz.bestScore} · Terakhir: ${quiz.latestScore ?? quiz.bestScore} (${quiz.attemptsCount}x)',
                              tone: SiagaTone.success,
                              compact: true,
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        quiz.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        quiz.description,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(fontSize: 13.5),
                      ),
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.icon(
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
                          icon: const Icon(Icons.quiz_outlined, size: 17),
                          label: Text(
                            quiz.attemptsCount > 0
                                ? 'Kerjakan Ulang Kuis'
                                : 'Kerjakan Kuis',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        if (progress.quizHistory.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            'Riwayat Percobaan Kuis',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          SiagaCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < progress.quizHistory.take(8).length; i++) ...[
                  Builder(
                    builder: (context) {
                      final h = progress.quizHistory[i];
                      return ListTile(
                        leading: const SiagaIconTile(
                          icon: Icons.fact_check_outlined,
                          size: 36,
                        ),
                        title: Text(
                          h.quizTitle,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        subtitle: Text(
                          'Benar ${h.correctAnswers}/${h.totalQuestions} · ${h.category}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        trailing: SiagaBadge(
                          label: 'Nilai ${h.finalScore}',
                          tone: h.finalScore >= 75
                              ? SiagaTone.success
                              : SiagaTone.warning,
                          compact: true,
                        ),
                      );
                    },
                  ),
                  if (i < progress.quizHistory.take(8).length - 1)
                    const Divider(height: 1, indent: 16, endIndent: 16),
                ],
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

    if (missions.isEmpty) {
      return const SiagaEmptyState(
        icon: Icons.flag_outlined,
        title: 'Belum ada Misi Siaga',
        message: 'Daftar Misi Siaga untuk kategori yang dipilih belum tersedia.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final ms in missions)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SiagaCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SiagaBadge(
                        label: 'Misi ${ms.category}',
                        tone: ms.category == 'Gempa Bumi'
                            ? SiagaTone.warning
                            : SiagaTone.info,
                        compact: true,
                      ),
                      SiagaBadge(
                        label: '+${ms.points} Poin',
                        tone: SiagaTone.success,
                        compact: true,
                      ),
                      SiagaStatusDot(
                        label: ms.userStatusLabel,
                        tone: ms.userStatus == 'selesai'
                            ? SiagaTone.success
                            : ms.userStatus == 'sedang_dikerjakan'
                            ? SiagaTone.warning
                            : SiagaTone.neutral,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    ms.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    ms.description,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(fontSize: 13.5),
                  ),
                  const SizedBox(height: 12),
                  for (var idx = 0; idx < ms.instructions.length; idx++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${idx + 1}. ',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: SiagaColors.navy,
                              fontSize: 13.2,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              ms.instructions[idx],
                              style: const TextStyle(
                                fontSize: 13.2,
                                color: SiagaColors.textSecondary,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
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
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _missionActionButton(
                        ms,
                        'belum_dimulai',
                        'Belum Dimulai',
                      ),
                      _missionActionButton(
                        ms,
                        'sedang_dikerjakan',
                        'Sedang Dikerjakan',
                      ),
                      _missionActionButton(ms, 'selesai', 'Selesai'),
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
        color: active ? Colors.white : SiagaColors.textSecondary,
        fontWeight: FontWeight.w600,
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
        LayoutBuilder(
          builder: (context, constraints) {
            final masteryCard = SiagaCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Progres Penguasaan Materi',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _categoryBar(
                    'Kategori Gempa Bumi',
                    '${progress.earthquakeMaterialsCompleted}/${progress.earthquakeMaterialsTotal} materi (${progress.earthquakePercentage}%)',
                    progress.earthquakePercentage / 100.0,
                    SiagaColors.warning,
                  ),
                  const SizedBox(height: 14),
                  _categoryBar(
                    'Kategori Tsunami',
                    '${progress.tsunamiMaterialsCompleted}/${progress.tsunamiMaterialsTotal} materi (${progress.tsunamiPercentage}%)',
                    progress.tsunamiPercentage / 100.0,
                    SiagaColors.info,
                  ),
                  const SizedBox(height: 18),
                  const Divider(height: 1),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 20,
                    runSpacing: 10,
                    children: [
                      _InlineMetric(
                        icon: Icons.bar_chart_rounded,
                        label: 'Rata-rata Kuis',
                        value: '${progress.quizAverageScore}',
                        color: SiagaColors.navy,
                      ),
                      _InlineMetric(
                        icon: Icons.emoji_events_outlined,
                        label: 'Nilai Terbaik',
                        value: '${progress.quizBestScore}',
                        color: SiagaColors.safe,
                      ),
                      _InlineMetric(
                        icon: Icons.military_tech_outlined,
                        label: 'Level ${progress.level.levelNumber}',
                        value: progress.level.levelName,
                        color: SiagaColors.warning,
                      ),
                    ],
                  ),
                ],
              ),
            );

            final chartCard = progress.activityChart.isEmpty
                ? null
                : SiagaCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Aktivitas Belajar (7 Hari Terakhir)',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          height: 136,
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
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: SiagaColors.navy,
                                        fontFeatures: [
                                          FontFeature.tabularFigures(),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Container(
                                      width: 24,
                                      height: h < 6 ? 6 : h,
                                      decoration: BoxDecoration(
                                        color: pt.count > 0
                                            ? SiagaColors.navy
                                            : SiagaColors.surfaceMuted,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(height: 7),
                                    Text(
                                      pt.label,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: SiagaColors.muted,
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
                  );

            if (chartCard == null) return masteryCard;

            if (constraints.maxWidth < 860) {
              return Column(
                children: [masteryCard, const SizedBox(height: 14), chartCard],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: masteryCard),
                const SizedBox(width: 16),
                Expanded(child: chartCard),
              ],
            );
          },
        ),
        const SizedBox(height: 20),

        // Badges Grid
        SiagaCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SiagaSectionHeader(
                title:
                    'Pencapaian & Badge (${progress.earnedBadgesCount}/${progress.badges.length})',
                subtitle:
                    'Raih penghargaan dengan menyelesaikan materi, simulasi, kuis, dan Misi Siaga.',
              ),
              const SizedBox(height: 14),
              SiagaResponsiveGrid(
                minimumItemWidth: 280,
                spacing: 12,
                children: [
                  for (final b in progress.badges)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: b.isEarned
                            ? SiagaColors.safeSoft
                            : SiagaColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(SiagaRadius.md),
                        border: Border.all(
                          color: b.isEarned
                              ? SiagaColors.safeBorder
                              : SiagaColors.border,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SiagaIconTile(
                            icon: b.isEarned
                                ? Icons.workspace_premium_rounded
                                : Icons.lock_outline_rounded,
                            size: 38,
                            color: b.isEarned
                                ? SiagaColors.safe
                                : SiagaColors.muted,
                            backgroundColor: b.isEarned
                                ? Colors.white
                                : SiagaColors.surfaceMuted,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  b.name,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  b.description,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${b.isEarned ? "Diraih" : "Syarat"}: ${b.criteriaDescription} (+${b.pointsReward} Poin)',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: b.isEarned
                                        ? SiagaColors.safeText
                                        : SiagaColors.navy,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Chronological Activity Log
        SiagaCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Riwayat Aktivitas Pembelajaran',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (progress.recentActivities.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: SiagaColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(SiagaRadius.md),
                  ),
                  child: const Text(
                    'Belum ada riwayat aktivitas. Mulailah membaca materi Gempa Bumi atau Tsunami pertama Anda.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: SiagaColors.muted, fontSize: 13.5),
                  ),
                )
              else
                for (var i = 0; i < progress.recentActivities.length; i++) ...[
                  Builder(
                    builder: (context) {
                      final act = progress.recentActivities[i];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const SiagaIconTile(
                          icon: Icons.history_edu_outlined,
                          size: 36,
                        ),
                        title: Text(
                          '${act.typeLabel}: ${act.subjectTitle}',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        subtitle: Text(
                          [
                            if (act.category != null) act.category!,
                            if (act.createdAt != null)
                              _shortDate(act.createdAt!),
                          ].join(' · '),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        trailing: act.pointsEarned > 0
                            ? SiagaBadge(
                                label: '+${act.pointsEarned} Poin',
                                tone: SiagaTone.success,
                                compact: true,
                              )
                            : null,
                      );
                    },
                  ),
                  if (i < progress.recentActivities.length - 1)
                    const Divider(height: 1),
                ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRemindersSettingsView(EducationUserProgress progress) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: SiagaCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pengaturan Pengingat Belajar',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'Preferensi pengingat disimpan ke akun Anda di server. Pengingat ditampilkan di dalam aplikasi dan secara otomatis melewati aktivitas yang sudah selesai.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Aktifkan Pengingat Belajar',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: const Text(
                  'Terima pengingat berkala untuk melanjutkan kesiapsiagaan.',
                ),
                value: _remEnabled,
                onChanged: (val) => setState(() => _remEnabled = val),
              ),
              const Divider(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Waktu Pengingat',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text('Setiap pukul $_remTime WIB'),
                trailing: OutlinedButton.icon(
                  onPressed: () async {
                    final parts = _remTime.split(':');
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                        hour: int.tryParse(parts.first) ?? 19,
                        minute: parts.length > 1
                            ? (int.tryParse(parts[1]) ?? 0)
                            : 0,
                      ),
                    );
                    if (picked != null) {
                      setState(() {
                        _remTime =
                            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                      });
                    }
                  },
                  icon: const Icon(Icons.access_time_rounded, size: 17),
                  label: const Text('Ubah Waktu'),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _remFrequency,
                decoration: const InputDecoration(
                  labelText: 'Frekuensi Pengingat',
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
                  if (v != null) setState(() => _remFrequency = v);
                },
              ),
              const SizedBox(height: 14),
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
                title: const Text(
                  'Ingatkan untuk melanjutkan belajar jika belum aktif',
                ),
                value: _remInactive,
                onChanged: (v) => setState(() => _remInactive = v ?? true),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
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
                        dimension: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined, size: 18),
                label: Text(
                  _savingReminder
                      ? 'Menyimpan...'
                      : 'Simpan Pengaturan Pengingat',
                ),
              ),
            ],
          ),
        ),
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
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12.5, color: SiagaColors.muted),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(SiagaRadius.pill),
          child: LinearProgressIndicator(
            value: ratio.clamp(0.0, 1.0),
            minHeight: 7,
            backgroundColor: SiagaColors.surfaceMuted,
            color: color,
          ),
        ),
      ],
    );
  }

  String _shortDate(String iso) {
    final dt = DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return iso;
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _CategoryTrackCard extends StatelessWidget {
  const _CategoryTrackCard({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.completed,
    required this.total,
    required this.icon,
    required this.accentColor,
    required this.onTapLearn,
  });

  final String eyebrow;
  final String title;
  final String description;
  final int completed;
  final int total;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTapLearn;

  @override
  Widget build(BuildContext context) {
    final ratio = total > 0 ? (completed / total).clamp(0.0, 1.0) : 0.0;

    return SiagaInteractiveCard(
      padding: EdgeInsets.zero,
      onTap: onTapLearn,
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: accentColor, width: 3.5)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SiagaIconTile(
                  icon: icon,
                  size: 40,
                  color: accentColor,
                  backgroundColor: accentColor.withValues(alpha: 0.1),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eyebrow,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.7,
                          color: accentColor,
                        ),
                      ),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
                Text(
                  '$completed/$total',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: SiagaColors.muted,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontSize: 13.5),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(SiagaRadius.pill),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 5,
                backgroundColor: SiagaColors.surfaceMuted,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onTapLearn,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
              ),
              icon: const Icon(Icons.arrow_forward_rounded, size: 17),
              label: Text('Pelajari $title'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineMetric extends StatelessWidget {
  const _InlineMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: color),
        const SizedBox(width: 7),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: SiagaColors.ink,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 11.5, color: SiagaColors.muted),
            ),
          ],
        ),
      ],
    );
  }
}
