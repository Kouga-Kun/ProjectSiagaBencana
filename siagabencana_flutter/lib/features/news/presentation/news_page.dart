import 'package:flutter/material.dart';

import '../../../app/navigation/app_section.dart';

import '../../../app/siaga_theme.dart';
import '../../../app/widgets/siaga_components.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({required this.onOpenSection, super.key});

  final ValueChanged<AppSection> onOpenSection;

  static const _headline = _NewsStory(
    category: 'PERINGATAN CUACA',
    title: 'Peringatan Dini Cuaca Ekstrem di Pesisir Pantai Padang',
    date: '23 Oktober 2026 • 14:30 WIB',
    description: 'BMKG merilis peringatan dini terkait potensi angin kencang dan gelombang pasang yang diperkirakan melanda pesisir barat Sumatera. Nelayan dan warga pesisir diimbau untuk tidak beraktivitas di laut hingga kondisi dinyatakan aman.',
    imageUrl: 'https://images.unsplash.com/photo-1527482797697-8795b05a13fe?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80',
    imageIcon: Icons.storm_rounded,
    categoryColor: SiagaColors.warning,
  );

  static const _stories = [
    _NewsStory(
      category: 'INFO GEMPA',
      title: 'Update Penanganan Dampak Gempa Bumi di Sektor 1 Padang',
      date: '23 Oktober 2026 • 10:15 WIB',
      imageUrl: 'https://images.unsplash.com/photo-1605814511995-10332822a106?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80',
      imageIcon: Icons.landscape_outlined,
      categoryColor: SiagaColors.danger,
    ),
    _NewsStory(
      category: 'INFO GEMPA',
      title: 'Update Penanganan Dampak Gempa Bumi di Sektor 2 Padang',
      date: '22 Oktober 2026 • 18:40 WIB',
      imageUrl: 'https://images.unsplash.com/photo-1542838321-419b4b0ed183?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80',
      imageIcon: Icons.apartment_outlined,
      categoryColor: SiagaColors.danger,
    ),
    _NewsStory(
      category: 'WASPADA',
      title: 'Erupsi Gunung Marapi, Warga Sumatera Barat Diharapkan Waspada',
      date: '21 Oktober 2026 • 09:00 WIB',
      imageUrl: 'https://images.unsplash.com/photo-1603597384797-15206016e78f?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80',
      imageIcon: Icons.volcano_outlined,
      categoryColor: SiagaColors.warning,
    ),
    _NewsStory(
      category: 'INFO BANJIR',
      title: 'Banjir Bandang di Pesisir Selatan, Akses Jalan Lintas Sumatera Terputus',
      date: '20 Oktober 2026 • 14:20 WIB',
      imageUrl: 'https://images.unsplash.com/photo-1542099981-b51fb0d31ff2?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80',
      imageIcon: Icons.water_outlined,
      categoryColor: SiagaColors.navyHover,
    ),
    _NewsStory(
      category: 'CUACA BURUK',
      title:
          'BMKG Prediksi Hujan Lebat Disertai Petir di Wilayah Padang Pariaman',
      date: '19 Oktober 2026 • 07:30 WIB',
      imageUrl: 'https://images.unsplash.com/photo-1534274988757-a28bf1a57c17?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80',
      imageIcon: Icons.thunderstorm_outlined,
      categoryColor: SiagaColors.warning,
    ),
    _NewsStory(
      category: 'BANTUAN SOSIAL',
      title: 'Distribusi Logistik dan Obat-obatan Tiba di Posko Pengungsian Bypass',
      date: '18 Oktober 2026 • 16:45 WIB',
      imageUrl: 'https://images.unsplash.com/photo-1593113630400-ea4288922497?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80',
      imageIcon: Icons.volunteer_activism_outlined,
      categoryColor: SiagaColors.safe,
    ),
    _NewsStory(
      category: 'LALU LINTAS',
      title: 'Tanah Longsor di Sitinjau Lauik, Sistem Buka Tutup Jalur Diberlakukan',
      date: '17 Oktober 2026 • 11:10 WIB',
      imageUrl: 'https://images.unsplash.com/photo-1623080775986-13a893049f50?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80',
      imageIcon: Icons.route_outlined,
      categoryColor: SiagaColors.danger,
    ),
    _NewsStory(
      category: 'INFO RESMI',
      title:
          'Status Siaga Darurat Bencana Hidrometeorologi Ditetapkan di Sumbar',
      date: '16 Oktober 2026 • 09:00 WIB',
      imageUrl: 'https://images.unsplash.com/photo-1584285422896-1b5e5233c06d?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80',
      imageIcon: Icons.campaign_outlined,
      categoryColor: SiagaColors.navyHover,
    ),
  ];

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
            title: 'Berita & Info Terkini',
            description: 'Dapatkan pembaruan terbaru mengenai peringatan cuaca, kondisi darurat, dan langkah penanganan bencana dari instansi resmi di wilayah Sumatera Barat.',
            icon: Icons.newspaper_outlined,
          ),
        ),
        const SizedBox(height: 20),
        const SiagaNotice(
          title: 'Konten demonstrasi dari website lama',
          message: 'Judul, tanggal, dan ringkasan berikut disalin dari daftar statis di Blade. Konten tersebut belum diverifikasi dan bukan feed berita resmi yang terhubung. Gambar berasal dari URL Unsplash yang dicantumkan Blade.',
          tone: SiagaTone.warning,
          icon: Icons.info_outline_rounded,
        ),
        const SizedBox(height: 24),
        const _HeadlineCard(story: _headline),
        const SizedBox(height: 36),
        const SiagaSectionHeader(
          title: 'Info Terkini',
          subtitle: 'Contoh konten statis yang ditemukan pada halaman Blade.',
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final columnCount = switch (constraints.maxWidth) {
              >= 1180 => 4,
              >= 860 => 3,
              >= 560 => 2,
              _ => 1,
            };
            final spacing = 20.0;
            final cardWidth =
                (constraints.maxWidth - spacing * (columnCount - 1)) /
                columnCount;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final story in _stories)
                  SizedBox(
                    width: cardWidth,
                    child: _NewsCard(story: story),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 28),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () => onOpenSection(AppSection.mitigation),
            icon: const Icon(Icons.health_and_safety_outlined),
            label: const Text('Baca panduan mitigasi'),
          ),
        ),
      ],
    );
  }
}

class _NewsStory {
  const _NewsStory({
    required this.category,
    required this.title,
    required this.date,
    required this.imageUrl,
    required this.imageIcon,
    required this.categoryColor,
    this.description,
  });

  final String category;
  final String title;
  final String date;
  final String imageUrl;
  final IconData imageIcon;
  final Color categoryColor;
  final String? description;
}

class _HeadlineCard extends StatelessWidget {
  const _HeadlineCard({required this.story});

  final _NewsStory story;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 768;
        final image = _NewsImage(
          imageUrl: story.imageUrl,
          icon: story.imageIcon,
          height: isWide ? null : 240,
        );
        final details = Padding(
          padding: EdgeInsets.all(isWide ? 38 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                story.date,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: SiagaColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 13),
              Text(
                story.title,
                style: Theme.of(context).textTheme.headlineMedium
                    ?.copyWith(height: 1.3, color: SiagaColors.ink),
              ),
              const SizedBox(height: 12),
              Text(
                story.description ?? '',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: SiagaColors.muted, height: 1.6),
              ),
              const SizedBox(height: 22),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Tautan sumber berita belum tersedia. Konten ini hanya demonstrasi lokal.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: const Text('Baca Selengkapnya'),
                ),
              ),
            ],
          ),
        );

        return ClipRRect(
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
            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 55, child: image),
                      Expanded(flex: 45, child: details),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Stack(
                        children: [
                          image,
                          const Positioned(
                            top: 16,
                            left: 16,
                            child: _HeadlineBadge(),
                          ),
                        ],
                      ),
                      details,
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.story});

  final _NewsStory story;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: SiagaColors.border),
          borderRadius: BorderRadius.circular(10),
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
            Stack(
              children: [
                _NewsImage(
                  imageUrl: story.imageUrl,
                  icon: story.imageIcon,
                  height: 180,
                ),
                const Positioned(top: 16, left: 16, child: _DemoImageMarker()),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story.category,
                    style: TextStyle(
                      color: story.categoryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.35,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    story.title,
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(color: SiagaColors.ink, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    story.date,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: SiagaColors.muted),
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

class _HeadlineBadge extends StatelessWidget {
  const _HeadlineBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
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
        'HEADLINE',
        style: TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _DemoImageMarker extends StatelessWidget {
  const _DemoImageMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'DEMO',
        style: TextStyle(
          color: SiagaColors.navy,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _NewsImage extends StatelessWidget {
  const _NewsImage({required this.imageUrl, required this.icon, this.height});

  final String imageUrl;
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
        size: 54,
        color: SiagaColors.navy.withValues(alpha: 0.5),
      ),
    );

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallback,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : fallback,
      ),
    );
  }
}
