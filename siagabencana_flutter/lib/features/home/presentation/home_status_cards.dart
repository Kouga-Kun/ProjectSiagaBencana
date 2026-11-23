import 'package:flutter/material.dart';

import '../../../app/siaga_theme.dart';
import '../../../app/widgets/siaga_components.dart';
import '../data/open_meteo_models.dart';

class LiveStatusCard extends StatelessWidget {
  const LiveStatusCard({
    required this.icon,
    required this.title,
    required this.source,
    required this.message,
    required this.description,
    required this.tone,
    this.headlineValue,
    this.updatedAt,
    this.details,
    this.onRetry,
    this.isLoading = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final String source;
  final String message;
  final String description;
  final SiagaTone tone;
  final String? headlineValue;
  final String? updatedAt;
  final Widget? details;
  final VoidCallback? onRetry;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SiagaCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SiagaIconTile(
                icon: icon,
                size: 38,
                color: tone.accent,
                backgroundColor: tone.background,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      source,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 11.5,
                        color: SiagaColors.textSubtle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (headlineValue != null) ...[
            Text(
              headlineValue!,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontSize: 26,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 8),
          ],
          SiagaBadge(label: message, tone: tone, compact: true),
          const SizedBox(height: 10),
          Text(
            description,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontSize: 13.5),
          ),
          if (isLoading) ...[
            const SizedBox(height: 12),
            const SiagaSkeletonBox(height: 10, width: 160),
            const SizedBox(height: 6),
            const SiagaSkeletonBox(height: 10, width: 110),
          ],
          if (details != null) ...[const SizedBox(height: 12), details!],
          if (onRetry != null) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Coba lagi'),
              ),
            ),
          ],
          if (updatedAt != null && updatedAt!.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 13,
                  color: SiagaColors.textSubtle,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Diperbarui: $updatedAt',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: SiagaColors.textSubtle,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class WeatherStatusCard extends StatelessWidget {
  const WeatherStatusCard({
    required this.future,
    required this.onRetry,
    super.key,
  });

  final Future<CurrentWeather> future;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => FutureBuilder<CurrentWeather>(
    future: future,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const LiveStatusCard(
          icon: Icons.cloud_outlined,
          title: 'Cuaca Kota Padang',
          source: 'Open-Meteo Forecast',
          message: 'Memuat data',
          description: 'Mengambil kondisi cuaca terkini.',
          tone: SiagaTone.info,
          isLoading: true,
        );
      }
      if (snapshot.hasError || !snapshot.hasData) {
        return LiveStatusCard(
          icon: Icons.cloud_outlined,
          title: 'Cuaca Kota Padang',
          source: 'Open-Meteo Forecast',
          message: 'Belum tersedia',
          description:
              'Data cuaca tidak dapat dimuat. Status ini tidak menunjukkan cuaca aman.',
          tone: SiagaTone.warning,
          onRetry: onRetry,
        );
      }
      final weather = snapshot.requireData;
      final details = <String>[
        if (weather.apparentTemperature != null)
          'Terasa ${weather.apparentTemperature!.toStringAsFixed(0)}°C',
        if (weather.humidity != null)
          'Kelembapan ${weather.humidity!.toStringAsFixed(0)}%',
        if (weather.windSpeed != null)
          'Angin ${weather.windSpeed!.toStringAsFixed(0)} km/jam',
      ].join(' · ');
      return LiveStatusCard(
        icon: Icons.cloud_outlined,
        title: 'Cuaca Kota Padang',
        source: 'Open-Meteo Forecast',
        headlineValue: '${weather.temperature.toStringAsFixed(0)}°C',
        message: weather.condition,
        description: details.isEmpty ? weather.condition : details,
        tone: SiagaTone.info,
        updatedAt: weather.updatedAt == null
            ? null
            : '${weather.updatedAt} WIB',
      );
    },
  );
}

class AirQualityStatusCard extends StatelessWidget {
  const AirQualityStatusCard({
    required this.future,
    required this.onRetry,
    super.key,
  });

  final Future<CurrentAirQuality> future;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => FutureBuilder<CurrentAirQuality>(
    future: future,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const LiveStatusCard(
          icon: Icons.air_rounded,
          title: 'Kualitas Udara',
          source: 'Open-Meteo Air Quality',
          message: 'Memuat data',
          description: 'Mengambil estimasi kualitas udara.',
          tone: SiagaTone.info,
          isLoading: true,
        );
      }
      if (snapshot.hasError || !snapshot.hasData) {
        return LiveStatusCard(
          icon: Icons.air_rounded,
          title: 'Kualitas Udara',
          source: 'Open-Meteo Air Quality',
          message: 'Belum tersedia',
          description:
              'Estimasi kualitas udara tidak dapat dimuat. Nilai kosong tidak berarti udara aman.',
          tone: SiagaTone.warning,
          onRetry: onRetry,
        );
      }
      final air = snapshot.requireData;
      final parts = <String>[
        if (air.pm25 != null) 'PM2.5 ${air.pm25!.toStringAsFixed(1)} µg/m³',
        if (air.pm10 != null) 'PM10 ${air.pm10!.toStringAsFixed(1)} µg/m³',
        'Estimasi model, bukan sensor lokal.',
      ];
      final tone = air.usAqi <= 50
          ? SiagaTone.success
          : air.usAqi <= 100
          ? SiagaTone.warning
          : SiagaTone.danger;
      return LiveStatusCard(
        icon: Icons.air_rounded,
        title: 'Kualitas Udara',
        source: 'Open-Meteo Air Quality · US AQI',
        headlineValue: 'AQI ${air.usAqi.toStringAsFixed(0)}',
        message: air.category,
        description: parts.join(' · '),
        tone: tone,
        updatedAt: air.updatedAt == null ? null : '${air.updatedAt} WIB',
      );
    },
  );
}
