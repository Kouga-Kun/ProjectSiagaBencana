import 'package:flutter/material.dart';

import '../../../app/siaga_theme.dart';
import '../../../app/widgets/siaga_components.dart';
import 'evacuation_map.dart';

class EvacuationPage extends StatelessWidget {
  const EvacuationPage({required this.onOpenMitigation, super.key});

  final VoidCallback onOpenMitigation;

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
        const SiagaPageHeader(
          eyebrow: 'PANDUAN DARURAT',
          title: 'Peta dan informasi evakuasi',
          description: 'Kenali tanda bahaya, pahami langkah evakuasi, dan ikuti informasi dari petugas serta kanal resmi.',
          icon: Icons.directions_walk_rounded,
        ),
        const SiagaSectionHeader(
          title: 'Memahami status zona',
          subtitle: 'Istilah berikut mengikuti penjelasan umum di website sumber; tidak menunjukkan batas wilayah tertentu.',
        ),
        const SizedBox(height: 15),
        const SiagaResponsiveGrid(
          minimumItemWidth: 250,
          children: [
            _ZoneCard(
              title: 'Zona aman',
              message: 'Area yang ditetapkan aman berdasarkan informasi dan arahan pihak berwenang.',
              tone: SiagaTone.success,
              icon: Icons.verified_user_outlined,
            ),
            _ZoneCard(
              title: 'Zona waspada',
              message: 'Pantau informasi resmi dan siapkan rencana evakuasi.',
              tone: SiagaTone.warning,
              icon: Icons.visibility_outlined,
            ),
            _ZoneCard(
              title: 'Zona bahaya',
              message: 'Ikuti peringatan resmi dan lakukan evakuasi apabila diperintahkan.',
              tone: SiagaTone.danger,
              icon: Icons.warning_amber_rounded,
            ),
          ],
        ),
        const SizedBox(height: 30),
        const EvacuationMapPanel(),
        const SizedBox(height: 34),
        const SiagaSectionHeader(
          title: 'Langkah kritis saat evakuasi',
          subtitle: 'Panduan keselamatan yang tercantum pada halaman Evakuasi.',
        ),
        const SizedBox(height: 15),
        const SiagaResponsiveGrid(
          minimumItemWidth: 340,
          children: [
            SiagaStepCard(
              number: '01',
              title: 'Kenali tanda dan segera evakuasi',
              description: 'Jika merasakan guncangan kuat atau gempa yang terasa lemah tetapi berlangsung lama, segera lakukan evakuasi mandiri dari pantai tanpa menunggu peringatan atau perintah evakuasi.',
              tone: SiagaTone.danger,
            ),
            SiagaStepCard(
              number: '02',
              title: 'Bawa Tas Siaga saja',
              description: 'Bawa dokumen penting, obat pribadi, senter, dan pakaian secukupnya. Jangan membuang waktu untuk menyelamatkan harta benda berat.',
              tone: SiagaTone.info,
            ),
            SiagaStepCard(
              number: '03',
              title: 'Ikuti arahan evakuasi resmi',
              description: 'Ikuti petunjuk petugas dan rambu resmi. Jika merasakan tanda alami tsunami, menjauh dari pantai ke tempat tinggi atau ke arah daratan; hindari lembah dan alur sungai.',
              tone: SiagaTone.info,
            ),
            SiagaStepCard(
              number: '04',
              title: 'Prioritaskan kelompok rentan',
              description: 'Bantu anak-anak, ibu hamil, lansia, dan penyandang disabilitas bergerak menuju titik kumpul jika situasi memungkinkan.',
              tone: SiagaTone.success,
            ),
            SiagaStepCard(
              number: '05',
              title: 'Jangan kembali sebelum dinyatakan aman',
              description: 'Jangan kembali ke zona bahaya sebelum ada pengumuman resmi dari BMKG atau pemerintah bahwa potensi tsunami benar-benar berakhir.',
              tone: SiagaTone.danger,
            ),
          ],
        ),
        const SizedBox(height: 22),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: onOpenMitigation,
            icon: const Icon(Icons.health_and_safety_outlined),
            label: const Text('Buka panduan mitigasi'),
          ),
        ),
      ],
    );
  }
}

class _ZoneCard extends StatelessWidget {
  const _ZoneCard({
    required this.title,
    required this.message,
    required this.tone,
    required this.icon,
  });

  final String title;
  final String message;
  final SiagaTone tone;
  final IconData icon;

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
              Icon(icon, color: color, size: 23),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SiagaBadge(label: 'Pengertian umum', tone: tone),
          const SizedBox(height: 10),
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
