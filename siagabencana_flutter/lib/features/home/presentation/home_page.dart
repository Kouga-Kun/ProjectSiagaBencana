import 'package:flutter/material.dart';

import '../../../app/network/api_config.dart';
import '../data/bmkg_models.dart';
import '../data/home_data_service.dart';
import '../data/open_meteo_models.dart';
import 'home_status_cards.dart';
import 'bmkg_status_card.dart';

import '../../../app/navigation/app_section.dart';
import '../../../app/siaga_theme.dart';
import '../../../app/widgets/siaga_components.dart';

class HomePage extends StatefulWidget {
  const HomePage({required this.onOpenSection, this.dataService, super.key});

  final ValueChanged<AppSection> onOpenSection;
  final HomeDataService? dataService;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeDataService _dataService;
  late Future<CurrentWeather> _weatherFuture;
  late Future<CurrentAirQuality> _airQualityFuture;
  late Future<BmkgAlertResponse> _alertsFuture;

  @override
  void initState() {
    super.initState();
    _dataService =
        widget.dataService ??
        HomeDataService(apiConfig: const ApiConfig.fromEnvironment());
    _loadData();
  }

  void _loadData() {
    _weatherFuture = _dataService.loadWeather();
    _airQualityFuture = _dataService.loadAirQuality();
    _alertsFuture = _dataService.loadBmkgAlerts();
  }

  void _retry() => setState(_loadData);

  @override
  void dispose() {
    _dataService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = MediaQuery.sizeOf(context).width < 600
        ? 18.0
        : 30.0;
    return ListView(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        28,
        horizontalPadding,
        44,
      ),
      children: [
        _HomeHero(
          onOpenEvacuation: () => widget.onOpenSection(AppSection.evacuation),
          onOpenReport: () => widget.onOpenSection(AppSection.reports),
        ),
        const SizedBox(height: 34),
        const SiagaSectionHeader(
          title: 'Pusat informasi kebencanaan',
          subtitle: 'Cuaca dan kualitas udara dari Open-Meteo; peringatan dini dari BMKG melalui Laravel.',
        ),
        const SizedBox(height: 16),
        SiagaResponsiveGrid(
          minimumItemWidth: 270,
          children: [
            WeatherStatusCard(future: _weatherFuture, onRetry: _retry),
            AirQualityStatusCard(future: _airQualityFuture, onRetry: _retry),
            BmkgStatusCard(future: _alertsFuture, onRetry: _retry),
          ],
        ),
        const SizedBox(height: 36),
        const SiagaSectionHeader(
          title: 'Berita pilihan',
          subtitle: 'Konten berita menunggu sumber yang dapat diverifikasi.',
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final featured = const _FeaturedNewsCard();
            final contextCard = _NewsContextCard(
              onOpenNews: () => widget.onOpenSection(AppSection.news),
            );
            if (constraints.maxWidth < 780) {
              return Column(
                children: [featured, const SizedBox(height: 16), contextCard],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: featured),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: contextCard),
              ],
            );
          },
        ),
        const SizedBox(height: 36),
        SiagaSectionHeader(
          title: 'Akses cepat',
          subtitle: 'Temukan panduan dan layanan utama SiagaBencana.',
          action: TextButton.icon(
            onPressed: () => widget.onOpenSection(AppSection.profile),
            icon: const Icon(Icons.person_outline_rounded),
            label: const Text('Profil'),
          ),
        ),
        const SizedBox(height: 16),
        SiagaResponsiveGrid(
          minimumItemWidth: 280,
          children: [
            _QuickActionCard(
              section: AppSection.reports,
              accent: SiagaColors.navyHover,
              background: const Color(0xFFEFF6FF),
              onPressed: () => widget.onOpenSection(AppSection.reports),
            ),
            _QuickActionCard(
              section: AppSection.evacuation,
              accent: SiagaColors.warning,
              background: const Color(0xFFFFF7ED),
              onPressed: () => widget.onOpenSection(AppSection.evacuation),
            ),
            _QuickActionCard(
              section: AppSection.mitigation,
              accent: SiagaColors.safe,
              background: const Color(0xFFECFDF5),
              onPressed: () => widget.onOpenSection(AppSection.mitigation),
            ),
          ],
        ),
      ],
    );
  }
}

class _HomeHero extends StatelessWidget {
  const _HomeHero({required this.onOpenEvacuation, required this.onOpenReport});

  final VoidCallback onOpenEvacuation;
  final VoidCallback onOpenReport;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 22 : 34),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [SiagaColors.navy, Color(0xFF1E40AF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x261E3A8A),
            blurRadius: 26,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 760;
          final introduction = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x1FFFFFFF),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0x33FFFFFF)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_outlined, color: Colors.white, size: 16),
                    SizedBox(width: 7),
                    Text(
                      'SIAGABENCANA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Kenali risiko.\nSiapkan langkah aman.',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontSize: isWide ? 38 : 32,
                  height: 1.12,
                ),
              ),
              const SizedBox(height: 13),
              const Text(
                'SiagaBencana membantu masyarakat Kota Padang memahami informasi kebencanaan dan mempersiapkan diri menghadapi keadaan darurat.',
                style: TextStyle(
                  color: Color(0xFFE0E7FF),
                  fontSize: 15,
                  height: 1.65,
                ),
              ),
              const SizedBox(height: 22),
              Wrap(
                spacing: 11,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
                    onPressed: onOpenEvacuation,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: SiagaColors.navy,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
                      ),
                    ),
                    icon: const Icon(Icons.directions_walk_rounded),
                    label: const Text('Panduan evakuasi'),
                  ),
                  OutlinedButton.icon(
                    onPressed: onOpenReport,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0x88FFFFFF)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
                      ),
                    ),
                    icon: const Icon(Icons.assignment_outlined),
                    label: const Text('Lihat laporan'),
                  ),
                ],
              ),
            ],
          );

          final statusPanel = Container(
            width: isWide ? 270 : double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0x16FFFFFF),
              border: Border.all(color: const Color(0x35FFFFFF)),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.radar_rounded, size: 30, color: Color(0xFFE0E7FF)),
                SizedBox(height: 16),
                Text(
                  'Status informasi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 10),
                SiagaBadge(
                  label: 'Memuat sumber data',
                  tone: SiagaTone.warning,
                  icon: Icons.schedule_rounded,
                ),
                SizedBox(height: 10),
                Text(
                  'Data cuaca, kualitas udara, dan peringatan dimuat dari sumber masing-masing.',
                  style: TextStyle(
                    color: Color(0xFFE0E7FF),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          );

          if (!isWide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [introduction, const SizedBox(height: 22), statusPanel],
            );
          }

          return Row(
            children: [
              Expanded(child: introduction),
              const SizedBox(width: 30),
              statusPanel,
            ],
          );
        },
      ),
    );
  }
}

class _FeaturedNewsCard extends StatelessWidget {
  const _FeaturedNewsCard();

  @override
  Widget build(BuildContext context) {
    return SiagaCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 116,
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFEFF6FF), Color(0xFFF8FAFC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Align(
                alignment: Alignment.topLeft,
                child: SiagaBadge(
                  label: 'PILIHAN INFORMASI',
                  tone: SiagaTone.info,
                  icon: Icons.auto_awesome_outlined,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SiagaBadge(
                    label: 'BELUM ADA ARTIKEL TERVERIFIKASI',
                    tone: SiagaTone.neutral,
                  ),
                  const SizedBox(height: 13),
                  Text(
                    'Berita terbaru belum tersedia',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Judul di halaman website lama ditulis statis dan tidak terhubung ke feed sumber. Berita akan ditampilkan setelah sumber dan waktu publikasinya dapat diperiksa.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewsContextCard extends StatelessWidget {
  const _NewsContextCard({required this.onOpenNews});

  final VoidCallback onOpenNews;

  @override
  Widget build(BuildContext context) {
    return SiagaCard(
      backgroundColor: const Color(0xFFF8FAFC),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SiagaIconTile(
            icon: Icons.fact_check_outlined,
            color: SiagaColors.navy,
          ),
          const SizedBox(height: 14),
          Text(
            'Mencari informasi?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 7),
          Text(
            'Utamakan pembaruan dari kanal resmi dan perhatikan waktu berlaku informasi.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          const SiagaBullet(
            text: 'Peringatan dini perlu dibaca bersama wilayah dan masa berlaku.',
            icon: Icons.access_time_rounded,
            color: SiagaColors.warning,
          ),
          const SiagaBullet(
            text: 'Ikuti arahan petugas dan pemerintah setempat.',
            icon: Icons.verified_outlined,
            color: SiagaColors.safe,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onOpenNews,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Buka halaman berita'),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.section,
    required this.accent,
    required this.background,
    required this.onPressed,
  });

  final AppSection section;
  final Color accent;
  final Color background;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onPressed,
        child: SiagaCard(
          padding: const EdgeInsets.all(20),
          backgroundColor: Colors.white,
          child: Row(
            children: [
              SiagaIconTile(
                icon: section.icon,
                color: accent,
                backgroundColor: background,
                size: 52,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      section.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, color: accent),
            ],
          ),
        ),
      ),
    );
  }
}
