import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/siaga_theme.dart';
import '../../../app/widgets/siaga_components.dart';
import '../data/education_data_service.dart';

class EducationMaterialDetailPage extends StatefulWidget {
  const EducationMaterialDetailPage({
    super.key,
    required this.materialSlugOrId,
    required this.service,
  });

  final String materialSlugOrId;
  final EducationDataService service;

  @override
  State<EducationMaterialDetailPage> createState() =>
      _EducationMaterialDetailPageState();
}

class _EducationMaterialDetailPageState
    extends State<EducationMaterialDetailPage> {
  final ScrollController _scrollController = ScrollController();

  late String _currentSlugOrId;
  EducationMaterialItem? _detail;
  bool _loadingDetail = false;
  bool _togglingCompletion = false;
  String? _errorMessage;
  int _lastSentPercent = 0;
  bool _didRestoreScroll = false;

  EducationDataService get _service => widget.service;

  @override
  void initState() {
    super.initState();
    _currentSlugOrId = widget.materialSlugOrId;
    _detail = _service.findMaterialBySlugOrId(_currentSlugOrId);
    _lastSentPercent = _detail?.progressPercent ?? 0;
    _scrollController.addListener(_onScrollChanged);
    unawaited(_loadRemoteDetail());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScrollChanged);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadRemoteDetail() async {
    setState(() {
      _loadingDetail = true;
      _errorMessage = null;
      _didRestoreScroll = false;
    });

    try {
      final fetched = await _service.fetchMaterialDetail(_currentSlugOrId);
      if (!mounted) return;
      setState(() {
        _detail = fetched;
        _lastSentPercent = fetched.progressPercent;
        _loadingDetail = false;
      });
      _scheduleScrollRestore(fetched.lastPosition);
    } on EducationDataException catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingDetail = false;
        _errorMessage = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingDetail = false;
        if (_detail == null) {
          _errorMessage = 'Gagal memuat detail materi. Periksa koneksi Anda.';
        }
      });
    }
  }

  void _scheduleScrollRestore(int savedPosition) {
    if (_didRestoreScroll || savedPosition <= 8 || savedPosition >= 98) {
      return;
    }
    _didRestoreScroll = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final maxExtent = _scrollController.position.maxScrollExtent;
      if (maxExtent > 100) {
        final target = ((savedPosition / 100.0) * maxExtent).clamp(
          0.0,
          maxExtent,
        );
        _scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _onScrollChanged() {
    final material = _detail;
    if (material == null || !_scrollController.hasClients) return;
    final maxExtent = _scrollController.position.maxScrollExtent;
    if (maxExtent <= 0) return;

    final pct = ((_scrollController.offset / maxExtent) * 100)
        .round()
        .clamp(5, 100);

    if ((pct - _lastSentPercent).abs() < 8) return;
    _lastSentPercent = pct;

    final section = pct < 35
        ? 'penjelasan'
        : pct < 65
        ? 'poin-penting'
        : pct < 88
        ? 'langkah-tindakan'
        : 'ringkasan';

    _service.scheduleMaterialProgressSave(
      material.id,
      lastPosition: pct,
      lastSection: section,
      progressPercent: pct,
    );
  }

  void _navigateToSibling(String slug) {
    setState(() {
      _currentSlugOrId = slug;
      _detail = _service.findMaterialBySlugOrId(slug);
      _lastSentPercent = _detail?.progressPercent ?? 0;
    });
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
    unawaited(_loadRemoteDetail());
  }

  Future<void> _toggleFavorite(EducationMaterialItem material) async {
    final target = !material.isFavorite;
    final ok = await _service.saveMaterialProgressNow(
      material.id,
      isFavorite: target,
    );
    if (!mounted) return;
    if (ok) {
      setState(() {
        _detail = _detail?.copyWith(isFavorite: target);
      });
    }
  }

  Future<void> _toggleComplete(EducationMaterialItem material) async {
    if (_togglingCompletion) return;
    setState(() => _togglingCompletion = true);

    try {
      final msg = await _service.toggleMaterialCompletion(material.id);
      if (!mounted) return;
      final updated = _service.findMaterialBySlugOrId(_currentSlugOrId);
      setState(() {
        _detail =
            updated ?? _detail?.copyWith(isCompleted: !material.isCompleted);
        _togglingCompletion = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: SiagaColors.safe),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _togglingCompletion = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: SiagaColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _service,
      builder: (context, _) {
        final material =
            _detail ?? _service.findMaterialBySlugOrId(_currentSlugOrId);

        if (_loadingDetail && material == null) {
          return Scaffold(
            backgroundColor: SiagaColors.background,
            appBar: AppBar(title: const Text('Memuat Materi')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (material == null) {
          return Scaffold(
            backgroundColor: SiagaColors.background,
            appBar: AppBar(title: const Text('Detail Materi')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SiagaEmptyState(
                  icon: Icons.menu_book_outlined,
                  title: 'Materi tidak ditemukan',
                  message: _errorMessage ?? 'Materi yang diminta belum tersedia.',
                  action: FilledButton.icon(
                    onPressed: _loadRemoteDetail,
                    icon: const Icon(Icons.refresh_rounded, size: 17),
                    label: const Text('Coba Muat Ulang'),
                  ),
                ),
              ),
            ),
          );
        }

        final isGempa = material.category == 'Gempa Bumi';
        final accentTone = isGempa ? SiagaTone.warning : SiagaTone.info;
        final width = MediaQuery.sizeOf(context).width;
        final horizontalPadding = SiagaBreakpoints.pageHorizontalPadding(width);

        return Scaffold(
          backgroundColor: SiagaColors.background,
          appBar: AppBar(
            title: Text('Materi ${material.category}'),
            actions: [
              IconButton(
                tooltip: material.isFavorite
                    ? 'Hapus dari Favorit'
                    : 'Tandai Favorit',
                onPressed: () => unawaited(_toggleFavorite(material)),
                icon: Icon(
                  material.isFavorite
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: material.isFavorite
                      ? SiagaColors.warning
                      : SiagaColors.muted,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              22,
              horizontalPadding,
              48,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 840),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_loadingDetail) ...[
                      const LinearProgressIndicator(),
                      const SizedBox(height: 12),
                    ],
                    _buildSyncStatusBanner(),
                    if (material.lastPosition > 8 && !material.isCompleted) ...[
                      const SizedBox(height: 10),
                      SiagaNotice(
                        title: 'Melanjutkan bacaan',
                        message:
                            'Posisi terakhir Anda tersimpan pada ${material.lastPosition}% dari materi ini.',
                        tone: SiagaTone.warning,
                        icon: Icons.bookmark_added_outlined,
                      ),
                    ],
                    const SizedBox(height: 12),

                    // Article Header
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SiagaBadge(
                          label: material.category,
                          tone: accentTone,
                          icon: isGempa
                              ? Icons.vibration_rounded
                              : Icons.waves_rounded,
                          compact: true,
                        ),
                        SiagaBadge(
                          label: 'Tingkat: ${material.difficulty}',
                          tone: SiagaTone.neutral,
                          compact: true,
                        ),
                        if (material.isCompleted)
                          const SiagaBadge(
                            label: 'Selesai Dipelajari',
                            tone: SiagaTone.success,
                            icon: Icons.check_circle_outline_rounded,
                            compact: true,
                          ),
                        if (material.isFavorite)
                          const SiagaBadge(
                            label: 'Favorit',
                            tone: SiagaTone.warning,
                            icon: Icons.star_rounded,
                            compact: true,
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      material.title,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 18),

                    // Clean Architectural Summary Callout
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: SiagaColors.navy,
                        borderRadius: BorderRadius.circular(SiagaRadius.lg),
                      ),
                      padding: const EdgeInsets.all(22),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(
                                SiagaRadius.md,
                              ),
                            ),
                            child: Icon(
                              isGempa
                                  ? Icons.vibration_rounded
                                  : Icons.waves_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'RINGKASAN MATERI',
                                  style: TextStyle(
                                    color: Color(0xFF93C5FD),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  material.summary,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.5,
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Main Reading Surface
                    SiagaCard(
                      padding: EdgeInsets.all(width < 600 ? 20 : 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Penjelasan Materi',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(color: SiagaColors.navy),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            material.content,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: SiagaColors.ink,
                                  fontSize: 15.5,
                                  height: 1.78,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (material.keyPoints.isNotEmpty) ...[
                      _buildStructuredListCard(
                        title: 'Poin Penting',
                        icon: Icons.push_pin_outlined,
                        tone: SiagaTone.info,
                        items: material.keyPoints,
                      ),
                      const SizedBox(height: 14),
                    ],

                    if (material.actionSteps.isNotEmpty) ...[
                      _buildStructuredListCard(
                        title: 'Langkah yang Harus Dilakukan',
                        icon: Icons.check_circle_outline_rounded,
                        tone: SiagaTone.success,
                        items: material.actionSteps,
                        numbered: true,
                      ),
                      const SizedBox(height: 14),
                    ],

                    if (material.thingsToAvoid.isNotEmpty) ...[
                      _buildStructuredListCard(
                        title: 'Hal yang Harus Dihindari',
                        icon: Icons.warning_amber_rounded,
                        tone: SiagaTone.danger,
                        items: material.thingsToAvoid,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Verified Reference Attribution
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: SiagaColors.surface,
                        borderRadius: BorderRadius.circular(SiagaRadius.md),
                        border: Border.all(color: SiagaColors.border),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.verified_outlined,
                            color: accentTone.accent,
                            size: 19,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Sumber Referensi Resmi: ${material.sourceReference}\nCatatan: Informasi edukasi tidak menggantikan instruksi petugas resmi saat bencana berlangsung.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Primary Completion Action
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: material.isCompleted
                              ? SiagaColors.safe
                              : SiagaColors.navy,
                        ),
                        onPressed: _togglingCompletion
                            ? null
                            : () => unawaited(_toggleComplete(material)),
                        icon: _togglingCompletion
                            ? const SizedBox.square(
                                dimension: 17,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                material.isCompleted
                                    ? Icons.check_circle_rounded
                                    : Icons.task_alt_rounded,
                                size: 19,
                              ),
                        label: Text(
                          _togglingCompletion
                              ? 'Menyimpan ke server...'
                              : material.isCompleted
                              ? 'Sudah Ditandai Selesai (Ketuk untuk Batalkan)'
                              : 'Tandai Materi Ini Selesai (+25 Poin)',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Prev / Next Lesson Navigation
                    Row(
                      children: [
                        if (material.previousMaterial != null)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _navigateToSibling(
                                material.previousMaterial!.slug,
                              ),
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                size: 17,
                              ),
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
                              onPressed: () => _navigateToSibling(
                                material.nextMaterial!.slug,
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: SiagaColors.primarySoft,
                                foregroundColor: SiagaColors.navy,
                              ),
                              icon: const Icon(
                                Icons.arrow_forward_rounded,
                                size: 17,
                              ),
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

  Widget _buildSyncStatusBanner() {
    final status = _service.saveStatus;
    if (status == SaveSyncStatus.idle) {
      return const SizedBox.shrink();
    }

    final tone = switch (status) {
      SaveSyncStatus.saving => SiagaTone.info,
      SaveSyncStatus.saved => SiagaTone.success,
      SaveSyncStatus.error => SiagaTone.danger,
      SaveSyncStatus.idle => SiagaTone.neutral,
    };
    final icon = switch (status) {
      SaveSyncStatus.saving => Icons.sync_rounded,
      SaveSyncStatus.saved => Icons.cloud_done_outlined,
      SaveSyncStatus.error => Icons.cloud_off_rounded,
      SaveSyncStatus.idle => Icons.info_outline_rounded,
    };

    return SiagaNotice(
      title: status == SaveSyncStatus.saved
          ? 'Posisi baca tersimpan'
          : status == SaveSyncStatus.saving
          ? 'Menyimpan progres baca'
          : 'Gagal menyimpan',
      message: _service.saveStatusMessage ?? '',
      tone: tone,
      icon: icon,
      trailing: status == SaveSyncStatus.error && _service.hasPendingRetry
          ? TextButton(
              onPressed: () => unawaited(_service.retryLastSave()),
              child: const Text('Coba Lagi'),
            )
          : null,
    );
  }

  Widget _buildStructuredListCard({
    required String title,
    required IconData icon,
    required SiagaTone tone,
    required List<String> items,
    bool numbered = false,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: SiagaColors.surface,
        borderRadius: BorderRadius.circular(SiagaRadius.lg),
        border: Border.all(color: tone.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(SiagaRadius.lg - 1),
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: tone.accent, width: 3.5)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: tone.accent, size: 19),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: tone.foreground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (int i = 0; i < items.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: numbered ? 22 : 16,
                        child: Text(
                          numbered ? '${i + 1}.' : '•',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: tone.accent,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          items[i],
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: SiagaColors.ink,
                                height: 1.55,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
