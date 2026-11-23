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
    'Air minum untuk 3 hari',
    'Makanan tahan lama',
    'P3K dan obat pribadi',
    'Senter dan baterai cadangan',
    'Dokumen penting dalam wadah tahan air',
    'Ponsel dan powerbank / pengisi daya',
    'Pakaian dan perlengkapan kebersihan',
    'Peluit darurat',
    'Uang tunai secukupnya',
  ];

  static const _earthquakeGuides = [
    _GuideGroup(
      phase: 'TAHAP 01',
      title: 'Sebelum gempa',
      icon: Icons.home_work_outlined,
      items: [
        'Amankan lemari dan benda berat agar tidak mudah jatuh.',
        'Kenali tempat berlindung yang kokoh dan jalur keluar di rumah.',
        'Buat rencana komunikasi dan titik berkumpul keluarga.',
        'Siapkan Tas Siaga Bencana dan simpan nomor darurat.',
      ],
    ),
    _GuideGroup(
      phase: 'TAHAP 02',
      title: 'Saat gempa',
      icon: Icons.shield_outlined,
      items: [
        'Merunduk, berlindung di bawah meja yang kokoh, dan berpegangan (Drop, Cover, Hold On).',
        'Lindungi kepala dan leher; jauhi kaca serta benda yang mudah jatuh.',
        'Jangan menggunakan lift. Jika di luar, jauhi bangunan dan tiang kabel.',
        'Jika di pesisir dan guncangan kuat atau lama, segera menjauh dari pantai setelah guncangan mereda.',
      ],
    ),
    _GuideGroup(
      phase: 'TAHAP 03',
      title: 'Setelah gempa',
      icon: Icons.health_and_safety_outlined,
      items: [
        'Waspadai gempa susulan dan periksa bahaya di sekitar sebelum bergerak.',
        'Tolong orang lain jika aman; hindari bangunan yang retak atau rusak.',
        'Gunakan pesan singkat untuk menghemat kapasitas jaringan telepon.',
        'Ikuti informasi resmi dan jangan masuk kembali ke bangunan sebelum dinyatakan aman.',
      ],
    ),
  ];

  static const _tsunamiGuides = [
    _GuideGroup(
      phase: 'TAHAP 01',
      title: 'Sebelum tsunami',
      icon: Icons.checklist_rounded,
      items: [
        'Kenali tanda alami tsunami dan siapkan Tas Siaga Bencana.',
        'Pelajari jalur dan rambu evakuasi resmi dari BPBD setempat.',
        'Sepakati titik berkumpul keluarga jika komunikasi terputus.',
      ],
    ),
    _GuideGroup(
      phase: 'TAHAP 02',
      title: 'Saat ada tanda tsunami',
      icon: Icons.directions_run_rounded,
      items: [
        'Segera menjauh dari pantai menuju tempat tinggi atau ke arah daratan.',
        'Ikuti arahan petugas dan peringatan resmi bila tersedia.',
        'Jangan berhenti untuk mengambil barang atau mendekati pantai.',
        'Bantu anak-anak, lansia, dan kelompok rentan jika situasi memungkinkan.',
      ],
    ),
    _GuideGroup(
      phase: 'TAHAP 03',
      title: 'Setelah tsunami',
      icon: Icons.home_outlined,
      items: [
        'Tetap di tempat aman; gelombang tsunami dapat datang lebih dari satu kali.',
        'Jauhi pantai, sungai, genangan air, kabel jatuh, dan bangunan rusak.',
        'Kembali ke rumah hanya setelah petugas menyatakan keadaan benar-benar aman.',
      ],
    ),
  ];

  late final List<bool> _checked = List<bool>.filled(
    _checklistItems.length,
    false,
  );
  int _selectedGuideIndex = 0;

  int get _completedCount => _checked.where((isChecked) => isChecked).length;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = SiagaBreakpoints.pageHorizontalPadding(width);
    final activeGuides = _selectedGuideIndex == 0
        ? _earthquakeGuides
        : _tsunamiGuides;
    final activeAccent = _selectedGuideIndex == 0
        ? SiagaColors.navy
        : SiagaColors.info;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        24,
        horizontalPadding,
        44,
      ),
      children: [
        const SiagaPageHeader(
          eyebrow: 'PANDUAN KESELAMATAN',
          title: 'Mitigasi & kesiapsiagaan bencana',
          description:
              'Ringkasan praktis tanda bahaya alami, prosedur keselamatan gempa bumi dan tsunami, serta daftar periksa Tas Siaga Bencana.',
          icon: Icons.health_and_safety_outlined,
        ),
        const SizedBox(height: 18),
        const SiagaNotice(
          title: 'Ikuti informasi dan arahan resmi',
          message:
              'Panduan ringkas ini mendukung kesiapsiagaan masyarakat dan tidak menggantikan peringatan BMKG atau instruksi petugas di lapangan.',
          tone: SiagaTone.info,
          icon: Icons.campaign_outlined,
        ),
        const SizedBox(height: 28),

        const SiagaSectionHeader(
          title: 'Kenali tanda alami tsunami',
          subtitle:
              'Apabila berada di wilayah pesisir dan merasakan salah satu tanda berikut, segera bergerak menuju tempat tinggi.',
        ),
        const SizedBox(height: 14),
        const SiagaResponsiveGrid(
          minimumItemWidth: 260,
          children: [
            _NaturalSignCard(
              icon: Icons.vibration_rounded,
              title: 'Gempa kuat atau lama',
              description:
                  'Guncangan gempa yang terasa kuat atau berlangsung lebih dari 20 detik di wilayah pesisir adalah peringatan alami utama.',
            ),
            _NaturalSignCard(
              icon: Icons.waves_rounded,
              title: 'Perubahan air laut mendadak',
              description:
                  'Air laut tiba-tiba surut jauh atau naik cepat adalah tanda bahaya. Jangan mendekati pantai untuk melihatnya.',
            ),
            _NaturalSignCard(
              icon: Icons.graphic_eq_rounded,
              title: 'Suara gemuruh dari laut',
              description:
                  'Suara gemuruh keras yang tidak biasa dari arah laut dapat menandakan kedatangan gelombang besar.',
            ),
          ],
        ),
        const SizedBox(height: 14),
        const SiagaNotice(
          title: 'Evakuasi mandiri tanpa menunggu sirine',
          message:
              'Tinggalkan pantai dan bergerak ke tempat tinggi atau ke arah daratan segera setelah merasakan tanda alam. Jangan kembali sebelum ada pengumuman aman resmi.',
          tone: SiagaTone.danger,
          icon: Icons.directions_run_rounded,
        ),
        const SizedBox(height: 32),

        // Segmented Earthquake vs Tsunami procedural phases
        const SiagaSectionHeader(
          title: 'Prosedur keselamatan berdasarkan tahap',
          subtitle: 'Pilih jenis bencana untuk melihat panduan sebelum, saat, dan setelah kejadian.',
        ),
        const SizedBox(height: 14),
        SiagaSegmentedTabs(
          selectedIndex: _selectedGuideIndex,
          onSelected: (index) => setState(() => _selectedGuideIndex = index),
          items: const [
            SiagaSegmentedTabItem(
              label: 'Panduan Gempa Bumi',
              icon: Icons.vibration_rounded,
            ),
            SiagaSegmentedTabItem(
              label: 'Panduan Tsunami',
              icon: Icons.waves_rounded,
            ),
          ],
        ),
        const SizedBox(height: 16),
        SiagaResponsiveGrid(
          minimumItemWidth: 290,
          spacing: 14,
          children: [
            for (final guide in activeGuides)
              _GuidePhaseCard(group: guide, accent: activeAccent),
          ],
        ),
        const SizedBox(height: 32),

        // Emergency Go-Bag Checklist
        SiagaSectionHeader(
          title: 'Checklist Tas Siaga Bencana',
          subtitle:
              'Tandai perlengkapan darurat yang telah Anda siapkan di rumah.',
          action: SiagaBadge(
            label: '$_completedCount dari ${_checklistItems.length} siap',
            tone: _completedCount == _checklistItems.length
                ? SiagaTone.success
                : SiagaTone.info,
          ),
        ),
        const SizedBox(height: 14),
        SiagaCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(SiagaRadius.pill),
                child: LinearProgressIndicator(
                  value: _completedCount / _checklistItems.length,
                  minHeight: 7,
                  backgroundColor: SiagaColors.surfaceMuted,
                  color: SiagaColors.safe,
                ),
              ),
              const SizedBox(height: 16),
              SiagaResponsiveGrid(
                minimumItemWidth: 280,
                spacing: 10,
                children: [
                  for (var index = 0; index < _checklistItems.length; index++)
                    _ChecklistTile(
                      title: _checklistItems[index],
                      isChecked: _checked[index],
                      onChanged: (isChecked) {
                        setState(() => _checked[index] = isChecked ?? false);
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
    required this.phase,
    required this.title,
    required this.icon,
    required this.items,
  });

  final String phase;
  final String title;
  final IconData icon;
  final List<String> items;
}

class _NaturalSignCard extends StatelessWidget {
  const _NaturalSignCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

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
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: SiagaColors.warning, width: 3)),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SiagaIconTile(
                icon: icon,
                size: 40,
                color: SiagaColors.warning,
                backgroundColor: SiagaColors.warningSoft,
              ),
              const SizedBox(height: 12),
              Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuidePhaseCard extends StatelessWidget {
  const _GuidePhaseCard({required this.group, required this.accent});

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
                backgroundColor: accent.withValues(alpha: 0.1),
                size: 40,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.phase,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.7,
                        color: accent,
                      ),
                    ),
                    Text(
                      group.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
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
          color: isChecked ? SiagaColors.safeSoft : SiagaColors.surfaceSubtle,
          border: Border.all(
            color: isChecked ? SiagaColors.safeBorder : SiagaColors.border,
          ),
          borderRadius: BorderRadius.circular(SiagaRadius.md),
        ),
        child: CheckboxListTile(
          value: isChecked,
          onChanged: onChanged,
          activeColor: SiagaColors.safe,
          controlAffinity: ListTileControlAffinity.leading,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SiagaRadius.md),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          title: Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: SiagaColors.ink,
              fontWeight: FontWeight.w600,
              decoration: isChecked ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
      ),
    );
  }
}
