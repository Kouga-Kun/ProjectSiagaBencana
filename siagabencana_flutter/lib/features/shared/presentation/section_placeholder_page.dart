import 'package:flutter/material.dart';

import '../../../app/navigation/app_section.dart';
import '../../../app/widgets/siaga_components.dart';

class SectionPlaceholderPage extends StatelessWidget {
  const SectionPlaceholderPage({
    required this.section,
    required this.onOpenSection,
    super.key,
  });

  final AppSection section;
  final ValueChanged<AppSection> onOpenSection;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        SiagaPageHeader(
          eyebrow: 'SIAGABENCANA',
          title: section.title,
          description: section.description,
          icon: section.icon,
        ),
        const SizedBox(height: 24),
        SiagaEmptyState(
          icon: section.icon,
          title: section.title,
          message: section.description,
          action: FilledButton.icon(
            onPressed: () => onOpenSection(AppSection.home),
            icon: const Icon(Icons.home_outlined, size: 18),
            label: const Text('Kembali ke Beranda'),
          ),
        ),
      ],
    );
  }
}
