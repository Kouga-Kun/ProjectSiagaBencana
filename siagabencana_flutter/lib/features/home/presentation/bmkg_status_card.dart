import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/siaga_theme.dart';
import '../../../app/widgets/siaga_components.dart';
import '../data/bmkg_models.dart';
import 'home_status_cards.dart';

class BmkgStatusCard extends StatelessWidget {
  const BmkgStatusCard({
    required this.future,
    required this.onRetry,
    super.key,
  });
  final Future<BmkgAlertResponse> future;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => FutureBuilder<BmkgAlertResponse>(
    future: future,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const LiveStatusCard(
          icon: Icons.notifications_active_outlined,
          title: 'Peringatan BMKG',
          source: 'Laravel · BMKG',
          message: 'Memuat data',
          description: 'Mengambil peringatan dari layanan BMKG.',
          tone: SiagaTone.info,
          details: LinearProgressIndicator(),
        );
      }
      if (snapshot.hasError || !snapshot.hasData) {
        return LiveStatusCard(
          icon: Icons.notifications_active_outlined,
          title: 'Peringatan BMKG',
          source: 'Laravel · BMKG',
          message: 'Belum tersedia',
          description: 'Peringatan tidak dapat dimuat. Ini bukan tanda bahwa keadaan aman.',
          tone: SiagaTone.warning,
          onRetry: onRetry,
        );
      }

      final response = snapshot.requireData;
      if (response.alerts.isEmpty) {
        return LiveStatusCard(
          icon: Icons.notifications_active_outlined,
          title: 'Peringatan BMKG',
          source: response.source,
          message: 'Tidak ada peringatan dalam feed',
          description: 'Ketiadaan data bukan jaminan keadaan aman. Periksa kanal resmi BMKG.',
          tone: SiagaTone.neutral,
          updatedAt: response.checkedAt?.toIso8601String(),
        );
      }

      return LiveStatusCard(
        icon: Icons.notifications_active_outlined,
        title: 'Peringatan BMKG',
        source: response.source,
        message: '${response.alerts.length} informasi peringatan',
        description: 'Periksa cakupan dan waktu publikasi setiap informasi.',
        tone: SiagaTone.warning,
        updatedAt: response.checkedAt?.toIso8601String(),
        details: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final alert in response.alerts) _BmkgAlertTile(alert: alert),
          ],
        ),
      );
    },
  );
}

class _BmkgAlertTile extends StatelessWidget {
  const _BmkgAlertTile({required this.alert});
  final BmkgAlert alert;

  Future<void> _openLink(BuildContext context, Uri uri) async {
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tautan BMKG tidak dapat dibuka.')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tautan BMKG tidak dapat dibuka.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final link = alert.officialLink;
    final locationLabel = alert.isSpecificToPadang
        ? 'Peringatan khusus Kota Padang'
        : alert.coverage.label;
    final locationTone = alert.isSpecificToPadang
        ? SiagaTone.danger
        : alert.coverage == AlertCoverage.tidakDiketahui
        ? SiagaTone.warning
        : SiagaTone.neutral;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAF5),
        border: Border.all(color: SiagaColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SiagaBadge(label: locationLabel, tone: locationTone),
          const SizedBox(height: 10),
          Text(
            alert.title.isEmpty ? 'Peringatan dini cuaca' : alert.title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (alert.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              alert.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          if (alert.publishedFormatted.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Publikasi: ${alert.publishedFormatted}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (link != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => _openLink(context, link),
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('Detail resmi BMKG'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
