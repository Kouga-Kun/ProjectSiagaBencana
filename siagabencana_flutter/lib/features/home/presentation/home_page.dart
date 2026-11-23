import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/navigation/app_section.dart';
import '../../../app/network/api_config.dart';
import '../../../app/siaga_theme.dart';
import '../../../app/widgets/siaga_components.dart';
import '../../news/data/news_data_service.dart';
import '../../news/presentation/news_detail_page.dart';
import '../data/home_data_service.dart';
import '../data/open_meteo_models.dart';
import 'home_status_cards.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    required this.onOpenSection,
    this.dataService,
    this.newsDataService,
    super.key,
  });

  final ValueChanged<AppSection> onOpenSection;
  final HomeDataService? dataService;
  final NewsDataService? newsDataService;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeDataService _dataService;
  NewsDataService? _newsService;
  bool _ownsNewsService = false;

  late Future<CurrentWeather> _weatherFuture;
  late Future<CurrentAirQuality> _airQualityFuture;
  Future<NewsFeedResult>? _newsFuture;

  @override
  void initState() {
    super.initState();
    _dataService =
        widget.dataService ??
        HomeDataService(apiConfig: const ApiConfig.fromEnvironment());

    if (widget.newsDataService != null) {
      _newsService = widget.newsDataService;
    } else if (widget.dataService == null &&
        _dataService.apiConfig.baseUrl.trim().isNotEmpty) {
      _ownsNewsService = true;
      _newsService = NewsDataService(apiConfig: _dataService.apiConfig);
    }

    _loadData();
  }

  void _loadData() {
    _weatherFuture = _dataService.loadWeather();
    _airQualityFuture = _dataService.loadAirQuality();
    if (_newsService != null) {
      _newsFuture = _newsService!.fetchNews();
    }
  }

  void _retry() => setState(_loadData);

  void _openNewsDetail(NewsArticleItem article) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => NewsDetailPage(
          initialArticle: article,
          dataService: _newsService,
          onOpenEducation: () => widget.onOpenSection(AppSection.education),
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (_ownsNewsService) {
      _newsService?.close();
    }
    _dataService.close();
    super.dispose();
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
        _HomeHeroBanner(
          weatherFuture: _weatherFuture,
          airQualityFuture: _airQualityFuture,
          onOpenEvacuation: () => widget.onOpenSection(AppSection.evacuation),
          onOpenEducation: () => widget.onOpenSection(AppSection.education),
          onOpenSos: () => widget.onOpenSection(AppSection.sos),
        ),
        const SizedBox(height: 32),
        SiagaSectionHeader(
          title: 'Pemantauan kondisi terkini',
          subtitle:
              'Kondisi cuaca dan estimasi kualitas udara terkini untuk wilayah Kota Padang.',
          action: TextButton.icon(
            onPressed: _retry,
            icon: const Icon(Icons.refresh_rounded, size: 17),
            label: const Text('Perbarui data'),
          ),
        ),
        const SizedBox(height: 14),
        SiagaResponsiveGrid(
          minimumItemWidth: 300,
          children: [
            WeatherStatusCard(future: _weatherFuture, onRetry: _retry),
            AirQualityStatusCard(future: _airQualityFuture, onRetry: _retry),
          ],
        ),
        const SizedBox(height: 36),
        LayoutBuilder(
          builder: (context, constraints) {
            final newsColumn = _HomeLatestNewsColumn(
              newsFuture: _newsFuture,
              onOpenNews: () => widget.onOpenSection(AppSection.news),
              onOpenArticle: _openNewsDetail,
            );
            final readinessColumn = _HomeReadinessAndServicesColumn(
              onOpenSection: widget.onOpenSection,
            );

            if (constraints.maxWidth < 900) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  newsColumn,
                  const SizedBox(height: 32),
                  readinessColumn,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 7, child: newsColumn),
                const SizedBox(width: 24),
                Expanded(flex: 5, child: readinessColumn),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _HomeHeroBanner extends StatelessWidget {
  const _HomeHeroBanner({
    required this.weatherFuture,
    required this.airQualityFuture,
    required this.onOpenEvacuation,
    required this.onOpenEducation,
    required this.onOpenSos,
  });

  final Future<CurrentWeather> weatherFuture;
  final Future<CurrentAirQuality> airQualityFuture;
  final VoidCallback onOpenEvacuation;
  final VoidCallback onOpenEducation;
  final VoidCallback onOpenSos;

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.sizeOf(context).width < 600;

    return Container(
      decoration: BoxDecoration(
        color: SiagaColors.navy,
        borderRadius: BorderRadius.circular(SiagaRadius.xl),
        border: Border.all(color: const Color(0xFF1E3A5F)),
      ),
      padding: EdgeInsets.all(isNarrow ? 22 : 32),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 780;

          final leftContent = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF59E0B),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Flexible(
                    child: Text(
                      'SIAGABENCANA · LAYANAN KESIAPSIAGAAN KOTA PADANG',
                      style: TextStyle(
                        color: Color(0xFF93C5FD),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.9,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Kenali risiko.\nSiapkan langkah aman.',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontSize: isWide ? 34 : 26,
                  height: 1.15,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 580),
                child: const Text(
                  'Akses peta jalur evakuasi, pemantauan kondisi cuaca dan kualitas udara, edukasi mitigasi gempa bumi dan tsunami, serta pelaporan warga dalam satu platform terpadu.',
                  style: TextStyle(
                    color: Color(0xFFCBD5E1),
                    fontSize: 14.8,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
                    onPressed: onOpenEvacuation,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: SiagaColors.navy,
                    ),
                    icon: const Icon(Icons.map_outlined, size: 18),
                    label: const Text('Buka Peta Evakuasi'),
                  ),
                  OutlinedButton.icon(
                    onPressed: onOpenEducation,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0x14FFFFFF),
                      side: const BorderSide(color: Color(0x4DFFFFFF)),
                    ),
                    icon: const Icon(Icons.school_outlined, size: 18),
                    label: const Text('Edukasi Bencana'),
                  ),
                  OutlinedButton.icon(
                    onPressed: onOpenSos,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFECACA),
                      backgroundColor: const Color(0x22DC2626),
                      side: const BorderSide(color: Color(0x66F87171)),
                    ),
                    icon: const Icon(Icons.sos_rounded, size: 18),
                    label: const Text('Bantuan SOS'),
                  ),
                ],
              ),
            ],
          );

          final liveOverviewPanel = Container(
            width: isWide ? 290 : double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF14345C),
              borderRadius: BorderRadius.circular(SiagaRadius.lg),
              border: Border.all(color: const Color(0xFF234775)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.radar_rounded,
                      size: 18,
                      color: Color(0xFF93C5FD),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'RINGKASAN PEMANTAUAN',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFF93C5FD),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                FutureBuilder<CurrentWeather>(
                  future: weatherFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const _HeroMetricLine(
                        label: 'Cuaca Padang',
                        value: 'Mengambil suhu...',
                        dotColor: Color(0xFF93C5FD),
                      );
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return const _HeroMetricLine(
                        label: 'Cuaca Padang',
                        value: 'Tidak terjangkau',
                        dotColor: Color(0xFFF59E0B),
                      );
                    }
                    final w = snapshot.requireData;
                    return _HeroMetricLine(
                      label: 'Cuaca Padang',
                      value:
                          '${w.temperature.toStringAsFixed(0)}°C · ${w.condition}',
                      dotColor: const Color(0xFF60A5FA),
                    );
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 11),
                  child: Divider(color: Color(0xFF234775), height: 1),
                ),
                FutureBuilder<CurrentAirQuality>(
                  future: airQualityFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const _HeroMetricLine(
                        label: 'Kualitas Udara',
                        value: 'Mengambil estimasi...',
                        dotColor: Color(0xFF93C5FD),
                      );
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return const _HeroMetricLine(
                        label: 'Kualitas Udara',
                        value: 'Tidak terjangkau',
                        dotColor: Color(0xFFF59E0B),
                      );
                    }
                    final air = snapshot.requireData;
                    final dotColor = air.usAqi <= 50
                        ? const Color(0xFF34D399)
                        : air.usAqi <= 100
                        ? const Color(0xFFFBBF24)
                        : const Color(0xFFF87171);
                    return _HeroMetricLine(
                      label: 'Kualitas Udara',
                      value:
                          'AQI ${air.usAqi.toStringAsFixed(0)} · ${air.category}',
                      dotColor: dotColor,
                    );
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 11),
                  child: Divider(color: Color(0xFF234775), height: 1),
                ),
                const Text(
                  'Pantau kondisi lingkungan terkini dan ikuti arahan petugas BPBD setempat saat darurat.',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          );

          if (!isWide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                leftContent,
                const SizedBox(height: 20),
                liveOverviewPanel,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: leftContent),
              const SizedBox(width: 28),
              liveOverviewPanel,
            ],
          );
        },
      ),
    );
  }
}

class _HeroMetricLine extends StatelessWidget {
  const _HeroMetricLine({
    required this.label,
    required this.value,
    required this.dotColor,
  });

  final String label;
  final String value;
  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HomeLatestNewsColumn extends StatelessWidget {
  const _HomeLatestNewsColumn({
    required this.newsFuture,
    required this.onOpenNews,
    required this.onOpenArticle,
  });

  final Future<NewsFeedResult>? newsFuture;
  final VoidCallback onOpenNews;
  final ValueChanged<NewsArticleItem> onOpenArticle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SiagaSectionHeader(
          title: 'Berita & pembaruan terbaru',
          subtitle: 'Informasi resmi kebencanaan dan artikel kesiapsiagaan.',
          action: TextButton.icon(
            onPressed: onOpenNews,
            icon: const Icon(Icons.arrow_forward_rounded, size: 17),
            label: const Text('Semua berita'),
          ),
        ),
        const SizedBox(height: 14),
        if (newsFuture == null)
          _NewsPortalGatewayCard(onOpenNews: onOpenNews)
        else
          FutureBuilder<NewsFeedResult>(
            future: newsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SiagaCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SiagaSkeletonBox(height: 16, width: 140),
                      SizedBox(height: 12),
                      SiagaSkeletonBox(height: 22),
                      SizedBox(height: 8),
                      SiagaSkeletonBox(height: 14, width: 280),
                      SizedBox(height: 18),
                      Divider(height: 1),
                      SizedBox(height: 14),
                      SiagaSkeletonBox(height: 16),
                      SizedBox(height: 10),
                      SiagaSkeletonBox(height: 16),
                    ],
                  ),
                );
              }

              if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.requireData.articles.isEmpty) {
                return _NewsPortalGatewayCard(onOpenNews: onOpenNews);
              }

              final feed = snapshot.requireData;
              final lead = feed.featured ?? feed.articles.first;
              final secondary = feed.articles
                  .where((item) => item.id != lead.id)
                  .take(3)
                  .toList();

              return SiagaCard(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => onOpenArticle(lead),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(SiagaRadius.lg),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SiagaBadge(
                                  label: lead.category,
                                  tone:
                                      NewsCategories.isDisasterCategory(
                                        lead.category,
                                      )
                                      ? SiagaTone.danger
                                      : SiagaTone.info,
                                  compact: true,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    '${lead.publishedFormatted} · ${lead.source}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              lead.title,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              lead.summary,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (secondary.isNotEmpty) ...[
                      const Divider(height: 1),
                      for (var i = 0; i < secondary.length; i++) ...[
                        InkWell(
                          onTap: () => onOpenArticle(secondary[i]),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        secondary[i].title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleSmall,
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        '${secondary[i].category} · ${secondary[i].publishedFormatted}',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  size: 18,
                                  color: SiagaColors.muted,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (i < secondary.length - 1)
                          const Divider(height: 1, indent: 20, endIndent: 20),
                      ],
                    ],
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

class _NewsPortalGatewayCard extends StatelessWidget {
  const _NewsPortalGatewayCard({required this.onOpenNews});

  final VoidCallback onOpenNews;

  @override
  Widget build(BuildContext context) {
    return SiagaCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SiagaStatusDot(
            label: 'Portal Informasi Resmi SiagaBencana',
            tone: SiagaTone.info,
          ),
          const SizedBox(height: 12),
          Text(
            'Pantau berita dan pembaruan kebencanaan',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Utamakan informasi dari kanal resmi pemerintah dan BPBD Kota Padang serta perhatikan waktu publikasi sebelum bertindak.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          const SiagaBullet(
            text:
                'Periksa sumber resmi dan waktu publikasi setiap informasi kebencanaan.',
            icon: Icons.access_time_rounded,
            color: SiagaColors.warning,
          ),
          const SiagaBullet(
            text: 'Ikuti arahan petugas dan rambu evakuasi resmi di lapangan.',
            icon: Icons.verified_outlined,
            color: SiagaColors.safe,
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onOpenNews,
            icon: const Icon(Icons.newspaper_outlined, size: 18),
            label: const Text('Buka halaman berita'),
          ),
        ],
      ),
    );
  }
}

class _HomeReadinessAndServicesColumn extends StatelessWidget {
  const _HomeReadinessAndServicesColumn({required this.onOpenSection});

  final ValueChanged<AppSection> onOpenSection;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SiagaSectionHeader(
          title: 'Edukasi & kesiapsiagaan',
          subtitle: 'Pelajari prosedur keselamatan gempa bumi dan tsunami.',
          action: TextButton(
            onPressed: () => onOpenSection(AppSection.education),
            child: const Text('Buka Edukasi'),
          ),
        ),
        const SizedBox(height: 14),
        _EducationTrackRow(
          accentColor: SiagaColors.warning,
          icon: Icons.vibration_rounded,
          tag: 'GEMPA BUMI',
          title: 'Drop, Cover, and Hold On',
          subtitle: 'Prosedur lindungi diri di rumah, sekolah, dan gedung.',
          onTap: () => onOpenSection(AppSection.education),
        ),
        const SizedBox(height: 10),
        _EducationTrackRow(
          accentColor: SiagaColors.info,
          icon: Icons.waves_rounded,
          tag: 'TSUNAMI',
          title: 'Evakuasi Mandiri Pesisir',
          subtitle: 'Kenali tanda alam & evakuasi ke tempat tinggi segera.',
          onTap: () => onOpenSection(AppSection.education),
        ),
        const SizedBox(height: 24),
        Text('Akses cepat layanan', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        SiagaCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _CompactServiceRow(
                section: AppSection.reports,
                accent: SiagaColors.primaryBlue,
                onTap: () => onOpenSection(AppSection.reports),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _CompactServiceRow(
                section: AppSection.mitigation,
                accent: SiagaColors.safe,
                onTap: () => onOpenSection(AppSection.mitigation),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _CompactServiceRow(
                section: AppSection.sos,
                accent: SiagaColors.danger,
                onTap: () => onOpenSection(AppSection.sos),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _CompactServiceRow(
                section: AppSection.profile,
                accent: SiagaColors.navy,
                onTap: () => onOpenSection(AppSection.profile),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EducationTrackRow extends StatelessWidget {
  const _EducationTrackRow({
    required this.accentColor,
    required this.icon,
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final Color accentColor;
  final IconData icon;
  final String tag;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SiagaInteractiveCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: accentColor, width: 3.5)),
        ),
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            SiagaIconTile(
              icon: icon,
              size: 40,
              color: accentColor,
              backgroundColor: accentColor.withValues(alpha: 0.1),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tag,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.7,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_rounded,
              size: 18,
              color: SiagaColors.muted,
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactServiceRow extends StatelessWidget {
  const _CompactServiceRow({
    required this.section,
    required this.accent,
    required this.onTap,
  });

  final AppSection section;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Icon(section.icon, size: 19, color: accent),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    section.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: SiagaColors.textSubtle,
            ),
          ],
        ),
      ),
    );
  }
}
