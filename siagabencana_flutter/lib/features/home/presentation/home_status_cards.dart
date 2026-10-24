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
    this.updatedAt,
    this.details,
    this.onRetry,
    super.key,
  });
  final IconData icon;
  final String title;
  final String source;
  final String message;
  final String description;
  final SiagaTone tone;
  final String? updatedAt;
  final Widget? details;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final color = switch (tone) {
      SiagaTone.neutral => SiagaColors.muted,
      SiagaTone.info => SiagaColors.navyHover,
      SiagaTone.warning => SiagaColors.warning,
      SiagaTone.danger => SiagaColors.danger,
      SiagaTone.success => SiagaColors.safe,
    };
    return SiagaCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SiagaIconTile(
                icon: icon,
                size: 44,
                color: color,
                backgroundColor: color.withValues(alpha: 0.09),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SiagaBadge(label: message, tone: tone),
          const SizedBox(height: 12),
          Text(description, style: Theme.of(context).textTheme.bodyMedium),
          if (details != null) ...[const SizedBox(height: 12), details!],
          if (onRetry != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba lagi'),
              ),
            ),
          ],
          const SizedBox(height: 14),
          const Divider(height: 1, color: SiagaColors.border),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.source_outlined,
                size: 16,
                color: SiagaColors.muted,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  source,
                  style: const TextStyle(
                    color: SiagaColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (updatedAt != null && updatedAt!.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              'Diperbarui: $updatedAt',
              style: const TextStyle(color: SiagaColors.muted, fontSize: 12),
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
          details: LinearProgressIndicator(),
        );
      }
      if (snapshot.hasError || !snapshot.hasData) {
        return LiveStatusCard(
          icon: Icons.cloud_outlined,
          title: 'Cuaca Kota Padang',
          source: 'Open-Meteo Forecast',
          message: 'Belum tersedia',
          description: 'Data cuaca tidak dapat dimuat. Status ini tidak menunjukkan cuaca aman.',
          tone: SiagaTone.warning,
          onRetry: onRetry,
        );
      }
      final weather = snapshot.requireData;
      final details = <String>[
        weather.condition,
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
        message: '${weather.temperature.toStringAsFixed(0)}°C',
        description: details,
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
          title: 'Kualitas udara',
          source: 'Open-Meteo Air Quality',
          message: 'Memuat data',
          description: 'Mengambil estimasi kualitas udara.',
          tone: SiagaTone.info,
          details: LinearProgressIndicator(),
        );
      }
      if (snapshot.hasError || !snapshot.hasData) {
        return LiveStatusCard(
          icon: Icons.air_rounded,
          title: 'Kualitas udara',
          source: 'Open-Meteo Air Quality',
          message: 'Belum tersedia',
          description: 'Estimasi kualitas udara tidak dapat dimuat. Nilai kosong tidak berarti udara aman.',
          tone: SiagaTone.warning,
          onRetry: onRetry,
        );
      }
      final air = snapshot.requireData;
      final parts = <String>[
        if (air.pm25 != null) 'PM2.5 ${air.pm25!.toStringAsFixed(1)} µg/m³',
        if (air.pm10 != null) 'PM10 ${air.pm10!.toStringAsFixed(1)} µg/m³',
        'Estimasi model, bukan pengukuran sensor lokal.',
      ];
      final tone = air.usAqi <= 50
          ? SiagaTone.success
          : air.usAqi <= 100
          ? SiagaTone.warning
          : SiagaTone.danger;
      return LiveStatusCard(
        icon: Icons.air_rounded,
        title: 'Kualitas udara',
        source: 'Open-Meteo Air Quality · US AQI',
        message: 'AQI ${air.usAqi.toStringAsFixed(0)} · ${air.category}',
        description: parts.join(' · '),
        tone: tone,
        updatedAt: air.updatedAt == null ? null : '${air.updatedAt} WIB',
      );
    },
  );
}
