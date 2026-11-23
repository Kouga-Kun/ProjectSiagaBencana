import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/navigation/app_section.dart';
import '../../../app/network/api_config.dart';
import '../../../app/siaga_theme.dart';
import '../../../app/widgets/siaga_components.dart';
import '../data/news_data_service.dart';
import 'news_detail_page.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({
    required this.onOpenSection,
    this.dataService,
    super.key,
  });

  final ValueChanged<AppSection> onOpenSection;
  final NewsDataService? dataService;

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  late final NewsDataService _service;
  bool _ownsService = false;

  final TextEditingController _searchController = TextEditingController();
  String _activeSearch = '';
  String _selectedCategory = '';

  bool _loading = true;
  String? _error;
  List<NewsArticleItem> _articles = const [];
  NewsArticleItem? _featuredArticle;
  List<String> _categories = NewsCategories.all;

  @override
  void initState() {
    super.initState();
    _ownsService = widget.dataService == null;
    _service =
        widget.dataService ??
        NewsDataService(apiConfig: const ApiConfig.fromEnvironment());
    unawaited(_loadNews());
  }

  @override
  void dispose() {
    if (_ownsService) {
      _service.close();
    }
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNews() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _service.fetchNews(
        search: _activeSearch.isEmpty ? null : _activeSearch,
        category: _selectedCategory.isEmpty ? null : _selectedCategory,
      );
      if (!mounted) return;
      setState(() {
        _articles = result.articles;
        _featuredArticle = result.featured;
        _categories = result.categories;
        _loading = false;
      });
    } on NewsDataException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
    }
  }

  void _applySearch() {
    setState(() {
      _activeSearch = _searchController.text.trim();
    });
    unawaited(_loadNews());
  }

  void _selectCategory(String category) {
    if (_selectedCategory == category) return;
    setState(() {
      _selectedCategory = category;
    });
    unawaited(_loadNews());
  }

  void _resetFilters() {
    _searchController.clear();
    setState(() {
      _activeSearch = '';
      _selectedCategory = '';
    });
    unawaited(_loadNews());
  }

  void _openArticleDetail(NewsArticleItem article) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => NewsDetailPage(
          initialArticle: article,
          dataService: _service,
          onOpenEducation: () => widget.onOpenSection(AppSection.education),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = SiagaBreakpoints.pageHorizontalPadding(width);

    return ListView(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        24,
        horizontalPadding,
        44,
      ),
      children: [
        SiagaPageHeader(
          eyebrow: 'Pusat Informasi Kebencanaan',
          title: 'Berita & Edukasi Kesiapsiagaan',
          description:
              'Pembaruan resmi kebencanaan, peringatan dini, dan artikel kesiapsiagaan dari SiagaBencana.',
          icon: Icons.newspaper_outlined,
          trailing: OutlinedButton.icon(
            onPressed: () => widget.onOpenSection(AppSection.mitigation),
            icon: const Icon(Icons.health_and_safety_outlined, size: 18),
            label: const Text('Panduan Mitigasi'),
          ),
        ),
        const SizedBox(height: 22),
        _NewsEditorialToolbar(
          searchController: _searchController,
          selectedCategory: _selectedCategory,
          activeSearch: _activeSearch,
          categories: _categories,
          onSubmitSearch: _applySearch,
          onSelectCategory: _selectCategory,
          onReset: _resetFilters,
        ),
        const SizedBox(height: 24),
        if (_loading)
          const _NewsSkeletonFeed()
        else if (_error != null)
          SiagaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SiagaNotice(
                  title: 'Daftar berita belum dapat dimuat',
                  message: _error!,
                  tone: SiagaTone.warning,
                  icon: Icons.cloud_off_rounded,
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: () => unawaited(_loadNews()),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Coba lagi'),
                ),
              ],
            ),
          )
        else ...[
          if (_featuredArticle != null) ...[
            const SiagaSectionHeader(
              title: 'Headline News',
              subtitle:
                  'Sorotan utama mengenai perkembangan bencana dan kesiapsiagaan terkini.',
            ),
            const SizedBox(height: 14),
            _HeadlineEditorialFeature(
              article: _featuredArticle!,
              onTap: () => _openArticleDetail(_featuredArticle!),
            ),
            const SizedBox(height: 32),
          ],
          SiagaSectionHeader(
            title: 'Berita Bencana Lainnya',
            subtitle:
                'Menampilkan ${_articles.length} berita terpublikasi, diurutkan dari yang terbaru.',
            action: IconButton(
              tooltip: 'Muat ulang berita',
              onPressed: () => unawaited(_loadNews()),
              icon: const Icon(Icons.refresh_rounded),
            ),
          ),
          const SizedBox(height: 16),
          if (_articles.isEmpty)
            SiagaEmptyState(
              icon: Icons.article_outlined,
              title: 'Berita tidak tersedia',
              message:
                  _activeSearch.isNotEmpty || _selectedCategory.isNotEmpty
                  ? 'Tidak ditemukan berita yang sesuai dengan kata kunci atau kategori yang dipilih.'
                  : 'Belum ada artikel berita yang dipublikasikan oleh admin pada sistem.',
              action:
                  _activeSearch.isNotEmpty || _selectedCategory.isNotEmpty
                  ? OutlinedButton.icon(
                      onPressed: _resetFilters,
                      icon: const Icon(
                        Icons.filter_alt_off_outlined,
                        size: 18,
                      ),
                      label: const Text('Tampilkan semua berita'),
                    )
                  : null,
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final columnCount = switch (constraints.maxWidth) {
                  >= 1060 => 3,
                  >= 660 => 2,
                  _ => 1,
                };
                const spacing = 18.0;
                final cardWidth =
                    (constraints.maxWidth - spacing * (columnCount - 1)) /
                    columnCount;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    for (final article in _articles)
                      SizedBox(
                        width: cardWidth,
                        child: _EditorialNewsCard(
                          article: article,
                          onTap: () => _openArticleDetail(article),
                        ),
                      ),
                  ],
                );
              },
            ),
        ],
      ],
    );
  }
}

class _NewsEditorialToolbar extends StatelessWidget {
  const _NewsEditorialToolbar({
    required this.searchController,
    required this.selectedCategory,
    required this.activeSearch,
    required this.categories,
    required this.onSubmitSearch,
    required this.onSelectCategory,
    required this.onReset,
  });

  final TextEditingController searchController;
  final String selectedCategory;
  final String activeSearch;
  final List<String> categories;
  final VoidCallback onSubmitSearch;
  final ValueChanged<String> onSelectCategory;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final hasFilter = activeSearch.isNotEmpty || selectedCategory.isNotEmpty;

    return SiagaCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 560;
              final searchField = TextField(
                controller: searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => onSubmitSearch(),
                decoration: InputDecoration(
                  hintText: 'Cari berita berdasarkan judul atau topik...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  fillColor: SiagaColors.surfaceSubtle,
                ),
              );

              final actions = Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: onSubmitSearch,
                    icon: const Icon(Icons.search_rounded, size: 17),
                    label: const Text('Cari Berita'),
                  ),
                  if (hasFilter)
                    OutlinedButton.icon(
                      onPressed: onReset,
                      icon: const Icon(Icons.restart_alt_rounded, size: 17),
                      label: const Text('Reset Filter'),
                    ),
                ],
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [searchField, const SizedBox(height: 10), actions],
                );
              }

              return Row(
                children: [
                  Expanded(child: searchField),
                  const SizedBox(width: 10),
                  actions,
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Semua Berita'),
                selected: selectedCategory.isEmpty,
                onSelected: (_) => onSelectCategory(''),
              ),
              for (final category in categories)
                ChoiceChip(
                  label: Text(category),
                  selected: selectedCategory == category,
                  onSelected: (_) => onSelectCategory(category),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeadlineEditorialFeature extends StatelessWidget {
  const _HeadlineEditorialFeature({
    required this.article,
    required this.onTap,
  });

  final NewsArticleItem article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 760;

        final imageBlock = Stack(
          children: [
            _NewsThumbnail(
              imageUrl: article.imageUrl,
              icon: _categoryIcon(article.category),
              height: isWide ? 320 : 210,
            ),
            const Positioned(top: 14, left: 14, child: _HeadlineLabel()),
          ],
        );

        final editorialBody = Padding(
          padding: EdgeInsets.all(isWide ? 28 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SiagaStatusDot(
                    label: article.category,
                    tone: _categoryTone(article.category),
                  ),
                  Text(
                    '${article.publishedFormatted} · ${article.source}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                article.title,
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(height: 1.28),
              ),
              const SizedBox(height: 10),
              Text(
                article.summary,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.arrow_forward_rounded, size: 17),
                label: const Text('Baca Selengkapnya'),
              ),
            ],
          ),
        );

        return SiagaInteractiveCard(
          padding: EdgeInsets.zero,
          onTap: onTap,
          child: isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 52, child: imageBlock),
                    Expanded(flex: 48, child: editorialBody),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [imageBlock, editorialBody],
                ),
        );
      },
    );
  }
}

class _EditorialNewsCard extends StatelessWidget {
  const _EditorialNewsCard({required this.article, required this.onTap});

  final NewsArticleItem article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final categoryColor = _categoryColor(article.category);

    return SiagaInteractiveCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _NewsThumbnail(
            imageUrl: article.imageUrl,
            icon: _categoryIcon(article.category),
            height: 176,
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: categoryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      article.category.toUpperCase(),
                      style: TextStyle(
                        color: categoryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  article.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  article.summary,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontSize: 13.5),
                ),
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 11),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: SiagaColors.textSubtle,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        '${article.publishedFormatted} · ${article.source}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: SiagaColors.primaryBlue,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NewsSkeletonFeed extends StatelessWidget {
  const _NewsSkeletonFeed();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SiagaCard(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SiagaSkeletonBox(height: 180),
              SizedBox(height: 16),
              SiagaSkeletonBox(height: 14, width: 140),
              SizedBox(height: 10),
              SiagaSkeletonBox(height: 22),
              SizedBox(height: 8),
              SiagaSkeletonBox(height: 14, width: 320),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SiagaResponsiveGrid(
          minimumItemWidth: 300,
          children: List.generate(
            3,
            (_) => const SiagaCard(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SiagaSkeletonBox(height: 130),
                  SizedBox(height: 12),
                  SiagaSkeletonBox(height: 12, width: 90),
                  SizedBox(height: 8),
                  SiagaSkeletonBox(height: 18),
                  SizedBox(height: 6),
                  SiagaSkeletonBox(height: 12, width: 200),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeadlineLabel extends StatelessWidget {
  const _HeadlineLabel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: SiagaColors.danger,
        borderRadius: BorderRadius.circular(SiagaRadius.sm),
      ),
      child: const Text(
        'BERITA UTAMA',
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _NewsThumbnail extends StatelessWidget {
  const _NewsThumbnail({
    required this.imageUrl,
    required this.icon,
    this.height,
  });

  final String? imageUrl;
  final IconData icon;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      height: height,
      width: double.infinity,
      color: SiagaColors.surfaceMuted,
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: 44,
        color: SiagaColors.navy.withValues(alpha: 0.28),
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
        errorBuilder: (_, _, _) => fallback,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : fallback,
      ),
    );
  }
}

SiagaTone _categoryTone(String category) {
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

Color _categoryColor(String category) {
  if (NewsCategories.isDisasterCategory(category)) {
    return SiagaColors.danger;
  }
  return switch (category) {
    NewsCategories.earlyWarning => SiagaColors.warning,
    NewsCategories.education => SiagaColors.safe,
    NewsCategories.regionalInfo => SiagaColors.primaryBlue,
    _ => SiagaColors.primaryBlue,
  };
}

IconData _categoryIcon(String category) {
  if (NewsCategories.isDisasterCategory(category)) {
    return Icons.warning_amber_rounded;
  }
  return switch (category) {
    NewsCategories.earlyWarning => Icons.notifications_active_outlined,
    NewsCategories.education => Icons.menu_book_rounded,
    NewsCategories.regionalInfo => Icons.map_outlined,
    _ => Icons.newspaper_outlined,
  };
}
