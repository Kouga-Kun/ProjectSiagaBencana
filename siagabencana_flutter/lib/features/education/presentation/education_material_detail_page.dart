import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/siaga_theme.dart';
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
      if (!mounted) {
        return;
      }
      setState(() {
        _detail = fetched;
        _lastSentPercent = fetched.progressPercent;
        _loadingDetail = false;
      });
      _scheduleScrollRestore(fetched.lastPosition);
    } on EducationDataException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadingDetail = false;
        _errorMessage = e.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
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
      if (!mounted || !_scrollController.hasClients) {
        return;
      }
      final maxExtent = _scrollController.position.maxScrollExtent;
      if (maxExtent > 100) {
        final target = ((savedPosition / 100.0) * maxExtent).clamp(
          0.0,
          maxExtent,
        );
        _scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onScrollChanged() {
    final material = _detail;
    if (material == null || !_scrollController.hasClients) {
      return;
    }
    final maxExtent = _scrollController.position.maxScrollExtent;
    if (maxExtent <= 0) {
      return;
    }

    final pct = ((_scrollController.offset / maxExtent) * 100)
        .round()
        .clamp(5, 100);

    if ((pct - _lastSentPercent).abs() < 8) {
      return;
    }
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
    if (!mounted) {
      return;
    }
    if (ok) {
      setState(() {
        _detail = _detail?.copyWith(isFavorite: target);
      });
    }
  }

  Future<void> _toggleComplete(EducationMaterialItem material) async {
    if (_togglingCompletion) {
      return;
    }
    setState(() {
      _togglingCompletion = true;
    });

    try {
      final msg = await _service.toggleMaterialCompletion(material.id);
      if (!mounted) {
        return;
      }
      final updated = _service.findMaterialBySlugOrId(_currentSlugOrId);
      setState(() {
        _detail = updated ?? _detail?.copyWith(isCompleted: !material.isCompleted);
        _togglingCompletion = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: SiagaColors.safe,
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _togglingCompletion = false;
      });
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
            appBar: AppBar(
              backgroundColor: SiagaColors.navy,
              foregroundColor: Colors.white,
              title: const Text('Memuat Materi...'),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (material == null) {
          return Scaffold(
            backgroundColor: SiagaColors.background,
            appBar: AppBar(
              backgroundColor: SiagaColors.navy,
              foregroundColor: Colors.white,
              title: const Text('Detail Materi'),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _errorMessage ?? 'Materi tidak ditemukan.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _loadRemoteDetail,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Coba Muat Ulang'),
                    ),
                  ],
                ),
              ),
            ),
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
                      ? const Color(0xFFFBBF24)
                      : Colors.white,
                ),
              ),
              const SizedBox(width: 6),
            ],
          ),
          body: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 920),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_loadingDetail) const LinearProgressIndicator(),
                    _buildSyncStatusBanner(),
                    if (material.lastPosition > 8 && !material.isCompleted) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF9C3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFDE047)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.bookmark_added_outlined,
                              color: Color(0xFFA16207),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Melanjutkan dari posisi terakhir (${material.lastPosition}% selesai dibaca).',
                                style: const TextStyle(
                                  color: Color(0xFF854D0E),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
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
                        if (material.isFavorite)
                          _buildBadge(
                            '★ Favorit',
                            const Color(0xFFFEF3C7),
                            const Color(0xFFB45309),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      material.title,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),

                    // Ilustrasi & Ringkasan Inti
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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              isGempa
                                  ? Icons.vibration_rounded
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
                                    color: Color(0xFFE2E8F0),
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  material.summary,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.5,
                                    height: 1.55,
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
                          const Text(
                            'Penjelasan Materi',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: SiagaColors.navy,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            material.content,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.7,
                              color: SiagaColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (material.keyPoints.isNotEmpty)
                      _buildListCard(
                        title: 'Poin Penting',
                        icon: Icons.push_pin_rounded,
                        bgColor: const Color(0xFFEFF6FF),
                        borderColor: const Color(0xFFBFDBFE),
                        titleColor: SiagaColors.navy,
                        items: material.keyPoints,
                      ),
                    const SizedBox(height: 14),

                    if (material.actionSteps.isNotEmpty)
                      _buildListCard(
                        title: 'Langkah yang Harus Dilakukan',
                        icon: Icons.check_circle_rounded,
                        bgColor: const Color(0xFFF0FDF4),
                        borderColor: const Color(0xFFBBF7D0),
                        titleColor: SiagaColors.safe,
                        items: material.actionSteps,
                        numbered: true,
                      ),
                    const SizedBox(height: 14),

                    if (material.thingsToAvoid.isNotEmpty)
                      _buildListCard(
                        title: 'Hal yang Harus Dihindari',
                        icon: Icons.warning_amber_rounded,
                        bgColor: const Color(0xFFFEF2F2),
                        borderColor: const Color(0xFFFECACA),
                        titleColor: SiagaColors.danger,
                        items: material.thingsToAvoid,
                      ),
                    const SizedBox(height: 16),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: SiagaColors.border),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.verified_outlined,
                            color: accentColor,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Sumber Referensi Resmi: ${material.sourceReference}\nCatatan: Informasi edukasi bukan pengganti instruksi petugas resmi saat bencana berlangsung.',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: SiagaColors.textMuted,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: material.isCompleted
                              ? SiagaColors.safe
                              : SiagaColors.navy,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _togglingCompletion
                            ? null
                            : () => unawaited(_toggleComplete(material)),
                        icon: _togglingCompletion
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                material.isCompleted
                                    ? Icons.check_circle_rounded
                                    : Icons.task_alt_rounded,
                              ),
                        label: Text(
                          _togglingCompletion
                              ? 'Menyimpan ke server...'
                              : material.isCompleted
                              ? 'Sudah Ditandai Selesai (Ketuk untuk Batalkan)'
                              : 'Tandai Materi Ini Selesai (+25 Poin)',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        if (material.previousMaterial != null)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _navigateToSibling(
                                material.previousMaterial!.slug,
                              ),
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
                              onPressed: () => _navigateToSibling(
                                material.nextMaterial!.slug,
                              ),
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
                    const SizedBox(height: 28),
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
        Icons.cloud_off_rounded,
      ),
      SaveSyncStatus.idle => (Colors.transparent, Colors.transparent, Icons.info),
    };

    return Container(
      width: double.infinity,
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
            TextButton(
              onPressed: () => unawaited(_service.retryLastSave()),
              child: const Text('Coba Lagi'),
            ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(color: fg, fontSize: 12.5, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildListCard({
    required String title,
    required IconData icon,
    required Color bgColor,
    required Color borderColor,
    required Color titleColor,
    required List<String> items,
    bool numbered = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: titleColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (int i = 0; i < items.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    numbered ? '${i + 1}. ' : '• ',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      items[i],
                      style: const TextStyle(
                        fontSize: 14.2,
                        height: 1.5,
                        color: SiagaColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
