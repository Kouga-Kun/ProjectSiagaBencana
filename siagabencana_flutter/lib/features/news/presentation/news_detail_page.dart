import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/siaga_theme.dart';
import '../../../app/widgets/siaga_components.dart';
import '../data/news_data_service.dart';

class NewsDetailPage extends StatefulWidget {
  const NewsDetailPage({
    required this.initialArticle,
    this.dataService,
    super.key,
  });

  final NewsArticleItem initialArticle;
  final NewsDataService? dataService;

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  late NewsArticleItem _article;
  bool _loadingDetail = false;
  String? _detailError;

  @override
  void initState() {
    super.initState();
    _article = widget.initialArticle;
    if (widget.dataService != null && _article.slug.isNotEmpty) {
      unawaited(_refreshDetail());
    }
  }

  Future<void> _refreshDetail() async {
    final service = widget.dataService;
    if (service == null) return;

    setState(() {
      _loadingDetail = true;
      _detailError = null;
    });

    try {
      final latest = await service.fetchNewsDetail(_article.slug);
      if (!mounted) return;
      setState(() {
        _article = latest;
        _loadingDetail = false;
      });
    } on NewsDataException catch (error) {
      if (!mounted) return;
      setState(() {
        _loadingDetail = false;
        if (_article.content.trim().isEmpty) {
          _detailError = error.message;
        }
      });
    }
  }

  SiagaTone _toneForCategory(String category) {
    if (NewsCategories.isDisasterCategory(category)) {
      return SiagaTone.danger;
    }
    return switch (category) {
      NewsCategories.earlyWarning => SiagaTone.warning,
      NewsCategories.education => SiagaTone.success,
      NewsCategories.regionalInfo => SiagaTone.info,
      _ => SiagaTone.info,
    };
  }

  IconData _iconForCategory(String category) {
    if (NewsCategories.isDisasterCategory(category)) {
      return Icons.warning_amber_rounded;
    }
    return switch (category) {
      NewsCategories.earlyWarning => Icons.notifications_active_outlined,
      NewsCategories.education => Icons.menu_book_rounded,
      NewsCategories.regionalInfo => Icons.map_outlined,
      _ => Icons.newspaper_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width < 600 ? 18.0 : 30.0;
    final categoryTone = _toneForCategory(_article.category);
    final categoryIcon = _iconForCategory(_article.category);

    return Scaffold(
      backgroundColor: SiagaColors.background,
      appBar: AppBar(
        backgroundColor: SiagaColors.navy,
        foregroundColor: Colors.white,
        leading: IconButton(
          tooltip: 'Kembali ke Halaman Berita',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Detail Berita',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              24,
              horizontalPadding,
              44,
            ),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('Kembali ke Halaman Berita'),
                ),
              ),
              const SizedBox(height: 18),
              if (_loadingDetail) ...[
                const LinearProgressIndicator(),
                const SizedBox(height: 14),
              ],
              if (_detailError != null) ...[
                SiagaNotice(
                  title: 'Gagal memuat pembaruan detail berita',
                  message: _detailError!,
                  tone: SiagaTone.warning,
                  icon: Icons.error_outline_rounded,
                ),
                const SizedBox(height: 16),
              ],
              SiagaCard(
                padding: EdgeInsets.zero,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailHeroImage(
                        imageUrl: _article.imageUrl,
                        fallbackIcon: categoryIcon,
                        height: width < 600 ? 220 : 350,
                      ),
                      Padding(
                        padding: EdgeInsets.all(width < 600 ? 22 : 34),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 10,
                              runSpacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                SiagaBadge(
                                  label: _article.category,
                                  tone: categoryTone,
                                  icon: categoryIcon,
                                ),
                                if (_article.isFeatured)
                                  const SiagaBadge(
                                    label: 'BERITA UTAMA',
                                    tone: SiagaTone.danger,
                                    icon: Icons.star_rounded,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _article.title,
                              style: Theme.of(context).textTheme.headlineLarge
                                  ?.copyWith(
                                    fontSize: width < 600 ? 24 : 30,
                                    height: 1.28,
                                    color: SiagaColors.ink,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 13,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: SiagaColors.border),
                              ),
                              child: Wrap(
                                spacing: 20,
                                runSpacing: 10,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.calendar_today_outlined,
                                        size: 16,
                                        color: SiagaColors.muted,
                                      ),
                                      const SizedBox(width: 7),
                                      Text(
                                        _article.publishedFormatted,
                                        style: const TextStyle(
                                          color: SiagaColors.ink,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.source_outlined,
                                        size: 16,
                                        color: SiagaColors.navyHover,
                                      ),
                                      const SizedBox(width: 7),
                                      Text(
                                        'Sumber: ${_article.source}',
                                        style: const TextStyle(
                                          color: SiagaColors.navy,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (_article.summary.isNotEmpty) ...[
                              const SizedBox(height: 22),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(12),
                                  border: const Border(
                                    left: BorderSide(
                                      color: SiagaColors.navyHover,
                                      width: 4,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  _article.summary,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: SiagaColors.ink,
                                        fontWeight: FontWeight.w600,
                                        height: 1.6,
                                      ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            const Divider(height: 1, color: SiagaColors.border),
                            const SizedBox(height: 24),
                            SelectableText(
                              _article.content.isNotEmpty
                                  ? _article.content
                                  : _article.summary,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: SiagaColors.ink,
                                    fontSize: 15.5,
                                    height: 1.8,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailHeroImage extends StatelessWidget {
  const _DetailHeroImage({
    required this.imageUrl,
    required this.fallbackIcon,
    required this.height,
  });

  final String? imageUrl;
  final IconData fallbackIcon;
  final double height;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      height: height,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFDBEAFE), Color(0xFFEFF6FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        fallbackIcon,
        size: 64,
        color: SiagaColors.navy.withValues(alpha: 0.45),
      ),
    );

    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      return fallback;
    }

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallback,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : fallback,
      ),
    );
  }
}

