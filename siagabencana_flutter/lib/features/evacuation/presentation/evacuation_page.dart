import 'package:flutter/material.dart';

import '../../../app/siaga_theme.dart';
import '../../../app/widgets/siaga_components.dart';
import 'evacuation_map.dart';

class EvacuationPage extends StatelessWidget {
  const EvacuationPage({
    required this.onOpenMitigation,
    this.onOpenEducation,
    super.key,
  });

  final VoidCallback onOpenMitigation;
  final VoidCallback? onOpenEducation;

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
          eyebrow: 'PANDUAN DARURAT & GIS',
          title: 'Peta dan informasi evakuasi',
          description:
              'Telusuri zona risiko pesisir, jalur evakuasi resmi, dan titik kumpul terdekat di Kota Padang.',
          icon: Icons.map_outlined,
          trailing: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: onOpenMitigation,
                icon: const Icon(Icons.health_and_safety_outlined, size: 17),
                label: const Text('Buka panduan mitigasi'),
              ),
              if (onOpenEducation != null)
                FilledButton.icon(
                  onPressed: onOpenEducation,
                  icon: const Icon(Icons.school_outlined, size: 17),
                  label: const Text('Pelajari Cara Evakuasi Tsunami'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Map-First GIS Workspace positioned immediately above the fold
        const EvacuationMapPanel(),
        const SizedBox(height: 32),
        const SiagaSectionHeader(
          title: 'Memahami status zona',
          subtitle:
              'Klasifikasi zona berikut mengikuti rujukan umum kesiapsiagaan Kota Padang untuk membantu orientasi awal.',
        ),
        const SizedBox(height: 14),
        const SiagaResponsiveGrid(
          minimumItemWidth: 260,
          children: [
            _ZoneReferenceCard(
              title: 'Zona aman',
              subtitle: 'Koridor Bypass & Dataran Tinggi',
              message:
                  'Area tujuan pengungsian akhir yang ditetapkan aman berdasarkan arahan pihak berwenang.',
              tone: SiagaTone.success,
              icon: Icons.verified_user_outlined,
            ),
            _ZoneReferenceCard(
              title: 'Zona waspada',
              subtitle: 'Area Tengah Kota',
              message:
                  'Pantau informasi resmi BMKG/BPBD, siapkan Tas Siaga, dan ikuti rambu evakuasi ke arah Timur.',
              tone: SiagaTone.warning,
              icon: Icons.visibility_outlined,
            ),
            _ZoneReferenceCard(
              title: 'Zona bahaya',
              subtitle: 'Wilayah Pesisir Pantai',
              message:
                  'Risiko tinggi gelombang pasang dan tsunami. Lakukan evakuasi segera apabila merasakan tanda bahaya.',
              tone: SiagaTone.danger,
              icon: Icons.warning_amber_rounded,
            ),
          ],
        ),
        const SizedBox(height: 32),
        const SiagaSectionHeader(
          title: 'Langkah kritis saat evakuasi',
          subtitle:
              'Urutan tindakan prioritas keselamatan yang direkomendasikan saat menghadapi ancaman gempa bumi dan tsunami.',
        ),
        const SizedBox(height: 14),
        const SiagaResponsiveGrid(
          minimumItemWidth: 340,
          children: [
            SiagaStepCard(
              number: '01',
              title: 'Kenali tanda dan segera evakuasi',
              description:
                  'Jika merasakan guncangan kuat atau gempa yang terasa lemah tetapi berlangsung lama, segera lakukan evakuasi mandiri dari pantai tanpa menunggu perintah.',
              tone: SiagaTone.danger,
            ),
            SiagaStepCard(
              number: '02',
              title: 'Bawa Tas Siaga saja',
              description:
                  'Bawa dokumen penting, obat pribadi, senter, dan pakaian secukupnya. Jangan menunda evakuasi demi barang berat.',
              tone: SiagaTone.info,
            ),
            SiagaStepCard(
              number: '03',
              title: 'Ikuti arahan evakuasi resmi',
              description:
                  'Ikuti rambu resmi dan petunjuk petugas menjauh dari pantai menuju dataran tinggi; hindari lembah dan alur sungai.',
              tone: SiagaTone.info,
            ),
            SiagaStepCard(
              number: '04',
              title: 'Prioritaskan kelompok rentan',
              description:
                  'Bantu anak-anak, ibu hamil, lansia, dan penyandang disabilitas bergerak menuju titik kumpul aman.',
              tone: SiagaTone.success,
            ),
            SiagaStepCard(
              number: '05',
              title: 'Jangan kembali sebelum dinyatakan aman',
              description:
                  'Tetap di zona aman sampai terdapat pengumuman resmi dari BMKG atau pemerintah bahwa ancaman tsunami benar-benar berakhir.',
              tone: SiagaTone.danger,
            ),
          ],
        ),
      ],
    );
  }
}

class _ZoneReferenceCard extends StatelessWidget {
  const _ZoneReferenceCard({
    required this.title,
    required this.subtitle,
    required this.message,
    required this.tone,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String message;
  final SiagaTone tone;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SiagaColors.surface,
        borderRadius: BorderRadius.circular(SiagaRadius.lg),
        border: Border.all(color: SiagaColors.border),
        boxShadow: SiagaShadows.subtle,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(SiagaRadius.lg - 1),
        child: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: tone.accent, width: 3)),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: tone.accent, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  color: tone.foreground,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontSize: 13.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
