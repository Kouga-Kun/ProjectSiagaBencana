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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width < 600 ? 18.0 : width * 0.06;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        28,
        horizontalPadding,
        44,
      ),
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: const SiagaPageHeader(
            eyebrow: 'Pusat Informasi Kebencanaan',
            title: 'Berita & Edukasi Kesiapsiagaan',
            description:
                'Dapatkan Headline News, berita bencana terkini, peringatan dini, dan artikel edukasi kesiapsiagaan resmi dari SiagaBencana.',
            icon: Icons.newspaper_outlined,
          ),
        ),
        const SizedBox(height: 22),
        if (_loading)
          const SiagaCard(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Memuat daftar berita terbaru dari server...',
                    style: TextStyle(
                      color: SiagaColors.muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (_error != null) ...[
          _NewsSearchAndFilterCard(
            searchController: _searchController,
            selectedCategory: _selectedCategory,
            activeSearch: _activeSearch,
            categories: _categories,
            onSubmitSearch: _applySearch,
            onSelectCategory: _selectCategory,
            onReset: _resetFilters,
          ),
          const SizedBox(height: 22),
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
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => unawaited(_loadNews()),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        ] else ...[
          if (_featuredArticle != null) ...[
            const SiagaSectionHeader(
              title: 'Headline News',
              subtitle:
                  'Berita utama pilihan admin mengenai informasi dan kesiapsiagaan bencana terkini.',
            ),
            const SizedBox(height: 14),
            _HeadlineCard(
              article: _featuredArticle!,
              onTap: () => _openArticleDetail(_featuredArticle!),
            ),
            const SizedBox(height: 28),
          ],
          _NewsSearchAndFilterCard(
            searchController: _searchController,
            selectedCategory: _selectedCategory,
            activeSearch: _activeSearch,
            categories: _categories,
            onSubmitSearch: _applySearch,
            onSelectCategory: _selectCategory,
            onReset: _resetFilters,
          ),
          const SizedBox(height: 28),
          SiagaSectionHeader(
            title: 'Berita Bencana Lainnya',
            subtitle:
                'Menampilkan ${_articles.length} berita yang telah dipublikasikan, disusun berdasarkan tanggal publikasi terbaru.',
            action: IconButton(
              tooltip: 'Muat ulang berita',
              onPressed: () => unawaited(_loadNews()),
              icon: const Icon(Icons.refresh_rounded),
            ),
          ),
          const SizedBox(height: 18),
          if (_articles.isEmpty)
            SiagaCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SiagaNotice(
                    title: 'Berita tidak tersedia',
                    message:
                        _activeSearch.isNotEmpty ||
                            _selectedCategory.isNotEmpty
                        ? 'Berita yang sesuai dengan kata kunci pencarian atau kategori yang dipilih tidak tersedia. Coba ubah kata kunci pencarian atau pilih kategori lain.'
                        : 'Saat ini berita tidak tersedia atau belum ada artikel berita yang dipublikasikan oleh admin pada sistem.',
                    tone: SiagaTone.info,
                    icon: Icons.article_outlined,
                  ),
                  if (_activeSearch.isNotEmpty ||
                      _selectedCategory.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: _resetFilters,
                      icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
                      label: const Text('Tampilkan semua berita'),
                    ),
                  ],
                ],
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final columnCount = switch (constraints.maxWidth) {
                  >= 1180 => 3,
                  >= 680 => 2,
                  _ => 1,
                };
                const spacing = 20.0;
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
                        child: _NewsCard(
                          article: article,
                          onTap: () => _openArticleDetail(article),
                        ),
                      ),
                  ],
                );
              },
            ),
        ],
        const SizedBox(height: 30),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () => widget.onOpenSection(AppSection.mitigation),
            icon: const Icon(Icons.health_and_safety_outlined),
            label: const Text('Baca panduan mitigasi'),
          ),
        ),
      ],
    );
  }
}

class _NewsSearchAndFilterCard extends StatelessWidget {
  const _NewsSearchAndFilterCard({
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
      padding: const EdgeInsets.all(20),
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
                  hintText: 'Cari berita berdasarkan judul...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  isDense: true,
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: SiagaColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: SiagaColors.border),
                  ),
                ),
              );

              final actions = Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: onSubmitSearch,
                    icon: const Icon(Icons.search_rounded, size: 18),
                    label: const Text('Cari Berita'),
                  ),
                  if (hasFilter)
                    OutlinedButton.icon(
                      onPressed: onReset,
                      icon: const Icon(Icons.restart_alt_rounded, size: 18),
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
                  const SizedBox(width: 12),
                  actions,
                ],
              );
            },
          ),
          const SizedBox(height: 14),
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

class _HeadlineCard extends StatelessWidget {
  const _HeadlineCard({required this.article, required this.onTap});

  final NewsArticleItem article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 768;
        final image = Stack(
          children: [
            _NewsImage(
              imageUrl: article.imageUrl,
              icon: _categoryIcon(article.category),
              height: isWide ? 340 : 230,
            ),
            const Positioned(top: 16, left: 16, child: _HeadlineBadge()),
          ],
        );

        final details = Padding(
          padding: EdgeInsets.all(isWide ? 34 : 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SiagaBadge(
                    label: article.category,
                    tone: _categoryTone(article.category),
                    icon: _categoryIcon(article.category),
                  ),
                  Text(
                    '${article.publishedFormatted} • Sumber: ${article.source}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: SiagaColors.muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                article.title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  height: 1.3,
                  color: SiagaColors.ink,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                article.summary,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: SiagaColors.muted,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 22),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text('Baca Selengkapnya'),
                ),
              ),
            ],
          ),
        );

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: SiagaColors.border),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(flex: 52, child: image),
                          Expanded(flex: 48, child: details),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [image, details],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.article, required this.onTap});

  final NewsArticleItem article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final categoryColor = _categoryColor(article.category);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: SiagaColors.border),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _NewsImage(
                  imageUrl: article.imageUrl,
                  icon: _categoryIcon(article.category),
                  height: 185,
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.category.toUpperCase(),
                        style: TextStyle(
                          color: categoryColor,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        article.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: SiagaColors.ink,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        article.summary,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: SiagaColors.muted,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Divider(height: 1, color: SiagaColors.border),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            size: 14,
                            color: SiagaColors.muted,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${article.publishedFormatted} • ${article.source}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: SiagaColors.muted),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: SiagaColors.navyHover,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeadlineBadge extends StatelessWidget {
  const _HeadlineBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
      decoration: BoxDecoration(
        color: SiagaColors.danger,
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: const Text(
        'BERITA UTAMA',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _NewsImage extends StatelessWidget {
  const _NewsImage({required this.imageUrl, required this.icon, this.height});

  final String? imageUrl;
  final IconData icon;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      height: height,
      width: double.infinity,
      color: const Color(0xFFE2E8F0),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: 52,
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
    NewsCategories.regionalInfo => SiagaColors.navyHover,
    _ => SiagaColors.navyHover,
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
    _ => Icons.newspaper_rounded,
  };
}
