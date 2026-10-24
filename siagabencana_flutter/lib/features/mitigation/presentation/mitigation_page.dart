import 'package:flutter/material.dart';

import '../../../app/siaga_theme.dart';
import '../../../app/widgets/siaga_components.dart';

class MitigationPage extends StatefulWidget {
  const MitigationPage({super.key});

  @override
  State<MitigationPage> createState() => _MitigationPageState();
}

class _MitigationPageState extends State<MitigationPage> {
  static const _checklistItems = [
    'Air minum',
    'Makanan tahan lama',
    'P3K dan obat pribadi',
    'Senter dan baterai cadangan',
    'Dokumen penting dalam wadah tahan air',
    'Ponsel dan pengisi daya',
    'Pakaian dan perlengkapan kebersihan',
    'Peluit',
    'Uang tunai',
  ];

  static const _earthquakeGuides = [
    _GuideGroup(
      title: 'Sebelum gempa',
      icon: Icons.home_work_outlined,
      items: [
        'Amankan lemari dan benda berat agar tidak mudah jatuh.',
        'Kenali tempat berlindung yang kokoh dan jalur keluar di rumah.',
        'Buat rencana komunikasi dan titik berkumpul keluarga.',
        'Siapkan tas siaga dan simpan nomor penting.',
      ],
    ),
    _GuideGroup(
      title: 'Saat gempa',
      icon: Icons.shield_outlined,
      items: [
        'Merunduk, berlindung di bawah meja yang kokoh, dan berpegangan.',
        'Lindungi kepala dan leher; jauhi kaca serta benda yang mudah jatuh.',
        'Jangan menggunakan lift. Jika di luar, jauhi bangunan dan kabel.',
        'Jika di pesisir dan guncangan kuat atau lama, segera menjauh dari pantai setelah guncangan mereda.',
      ],
    ),
    _GuideGroup(
      title: 'Setelah gempa',
      icon: Icons.health_and_safety_outlined,
      items: [
        'Waspadai gempa susulan dan periksa bahaya di sekitar sebelum bergerak.',
        'Tolong orang lain jika aman; hindari bangunan yang rusak.',
        'Gunakan pesan singkat untuk menghemat jaringan telepon.',
        'Ikuti informasi resmi dan jangan masuk kembali ke bangunan yang belum dinyatakan aman.',
      ],
    ),
  ];

  static const _tsunamiGuides = [
    _GuideGroup(
      title: 'Sebelum tsunami',
      icon: Icons.checklist_rounded,
      items: [
        'Kenali tanda alami tsunami dan siapkan tas siaga.',
        'Pelajari arahan evakuasi dari BPBD setempat.',
        'Sepakati rencana keluarga jika komunikasi terputus.',
      ],
    ),
    _GuideGroup(
      title: 'Saat ada tanda tsunami',
      icon: Icons.directions_run_rounded,
      items: [
        'Segera menjauh dari pantai menuju tempat tinggi atau ke arah daratan.',
        'Ikuti arahan petugas dan peringatan resmi bila tersedia.',
        'Jangan berhenti untuk mengambil barang atau mendekati laut.',
        'Bantu anak-anak, lansia, dan orang yang membutuhkan bantuan jika aman.',
      ],
    ),
    _GuideGroup(
      title: 'Setelah tsunami',
      icon: Icons.home_outlined,
      items: [
        'Tetap di tempat aman; gelombang dapat datang lebih dari satu kali.',
        'Jauhi pantai, sungai, genangan, kabel jatuh, dan bangunan rusak.',
        'Kembali hanya setelah petugas menyatakan keadaan aman.',
      ],
    ),
  ];

  late final List<bool> _checked = List<bool>.filled(
    _checklistItems.length,
    false,
  );

  int get _completedCount => _checked.where((isChecked) => isChecked).length;

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
          eyebrow: 'PANDUAN KESELAMATAN',
          title: 'Edukasi dan mitigasi bencana',
          description: 'Kenali langkah untuk mengurangi risiko dan menjaga keselamatan diri serta keluarga sebelum, saat, dan setelah gempa bumi atau tsunami.',
          icon: Icons.health_and_safety_outlined,
        ),
        const SizedBox(height: 24),
        const SiagaNotice(
          title: 'Ikuti informasi dan arahan resmi',
          message: 'Panduan umum ini tidak menggantikan peringatan BMKG atau instruksi petugas di lokasi.',
          tone: SiagaTone.info,
          icon: Icons.campaign_outlined,
        ),
        const SizedBox(height: 32),
        const SiagaSectionHeader(
          title: 'Kenali tanda alami tsunami',
          subtitle: 'Jika berada di pesisir, segera menjauh ketika melihat tanda berikut.',
        ),
        const SizedBox(height: 16),
        const SiagaResponsiveGrid(
          minimumItemWidth: 250,
          children: [
            _SignCard(
              icon: Icons.vibration_rounded,
              title: 'Gempa kuat atau lama',
              description: 'Jika berada di wilayah pesisir dan merasakan gempa kuat atau berlangsung lama, segera menjauh dari pantai.',
            ),
            _SignCard(
              icon: Icons.waves_rounded,
              title: 'Perubahan air laut',
              description: 'Air laut tiba-tiba surut jauh atau naik cepat dapat menjadi tanda bahaya. Jangan mendekati pantai untuk melihatnya.',
            ),
            _SignCard(
              icon: Icons.graphic_eq_rounded,
              title: 'Suara gemuruh dari laut',
              description: 'Suara gemuruh yang tidak biasa dari arah laut juga dapat menjadi tanda bahaya tsunami.',
            ),
          ],
        ),
        const SizedBox(height: 16),
        const SiagaNotice(
          title: 'Bertindak segera',
          message: 'Tinggalkan pantai dan bergerak ke tempat yang lebih tinggi atau menjauh ke daratan. Jangan menunggu peringatan resmi jika merasakan tanda alam. Ikuti petunjuk petugas dan jangan kembali sebelum dinyatakan aman.',
          tone: SiagaTone.danger,
          icon: Icons.directions_run_rounded,
        ),
        const SizedBox(height: 34),
        const SiagaSectionHeader(
          title: 'Panduan keselamatan gempa bumi',
          subtitle: 'Persiapan dan tindakan dibagi menurut tahap kejadian.',
        ),
        const SizedBox(height: 16),
        SiagaResponsiveGrid(
          minimumItemWidth: 290,
          children: [
            for (final guide in _earthquakeGuides)
              _GuideCard(group: guide, accent: SiagaColors.navyHover),
          ],
        ),
        const SizedBox(height: 34),
        const SiagaSectionHeader(
          title: 'Panduan keselamatan tsunami',
          subtitle:
              'Perhatikan tindakan sebelum, saat, dan setelah tanda tsunami.',
        ),
        const SizedBox(height: 16),
        SiagaResponsiveGrid(
          minimumItemWidth: 290,
          children: [
            for (final guide in _tsunamiGuides)
              _GuideCard(group: guide, accent: SiagaColors.warning),
          ],
        ),
        const SizedBox(height: 34),
        SiagaSectionHeader(
          title: 'Checklist Tas Siaga',
          subtitle: 'Tandai perlengkapan yang sudah disiapkan. Progres tersimpan selama halaman ini terbuka.',
          action: SiagaBadge(
            label: '$_completedCount dari ${_checklistItems.length} siap',
            tone: _completedCount == _checklistItems.length
                ? SiagaTone.success
                : SiagaTone.info,
          ),
        ),
        const SizedBox(height: 14),
        SiagaCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: _completedCount / _checklistItems.length,
                  minHeight: 9,
                  backgroundColor: const Color(0xFFE2E8F0),
                  color: SiagaColors.safe,
                ),
              ),
              const SizedBox(height: 16),
              SiagaResponsiveGrid(
                minimumItemWidth: 300,
                spacing: 10,
                children: [
                  for (var index = 0; index < _checklistItems.length; index++)
                    _ChecklistTile(
                      title: _checklistItems[index],
                      isChecked: _checked[index],
                      onChanged: (isChecked) {
                        setState(() {
                          _checked[index] = isChecked ?? false;
                        });
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GuideGroup {
  const _GuideGroup({
    required this.title,
    required this.icon,
    required this.items,
  });

  final String title;
  final IconData icon;
  final List<String> items;
}

class _SignCard extends StatelessWidget {
  const _SignCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return SiagaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SiagaIconTile(
            icon: icon,
            color: SiagaColors.warning,
            backgroundColor: const Color(0xFFFFF7ED),
          ),
          const SizedBox(height: 14),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 7),
          Text(description, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  const _GuideCard({required this.group, required this.accent});

  final _GuideGroup group;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SiagaCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SiagaIconTile(
                icon: group.icon,
                color: accent,
                backgroundColor: accent.withValues(alpha: 0.09),
                size: 42,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  group.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (final item in group.items)
            SiagaBullet(text: item, icon: Icons.check_rounded, color: accent),
        ],
      ),
    );
  }
}

class _ChecklistTile extends StatelessWidget {
  const _ChecklistTile({
    required this.title,
    required this.isChecked,
    required this.onChanged,
  });

  final String title;
  final bool isChecked;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: isChecked ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
          border: Border.all(
            color: isChecked ? const Color(0xFFBBF7D0) : SiagaColors.border,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: CheckboxListTile(
          value: isChecked,
          onChanged: onChanged,
          activeColor: SiagaColors.safe,
          controlAffinity: ListTileControlAffinity.leading,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          title: Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: SiagaColors.ink, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
