import 'package:flutter/material.dart';

import '../../../app/navigation/app_section.dart';
import '../../../app/siaga_theme.dart';
import '../../../app/widgets/siaga_components.dart';
import '../../auth/data/auth_session_service.dart';
import '../../education/data/education_data_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    required this.onOpenSection,
    required this.user,
    required this.isLoading,
    required this.statusError,
    required this.onRetryStatus,
    required this.onLogout,
    super.key,
  });

  final ValueChanged<AppSection> onOpenSection;
  final AuthUser? user;
  final bool isLoading;
  final String? statusError;
  final VoidCallback onRetryStatus;
  final Future<void> Function() onLogout;

  static const _contacts = [
    _EmergencyContact('BPBD Kota Padang', '0751-778775'),
    _EmergencyContact('SAR Kota Padang', '0751-484534'),
    _EmergencyContact('Pemadam Kebakaran', '113 / 0751-28558'),
    _EmergencyContact('PMI Padang', '0751-31795'),
    _EmergencyContact('Polisi / Poltabes', '110 / 0751-33724'),
    _EmergencyContact('RS M. Djamil Padang', '0751-37030'),
  ];

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
          eyebrow: 'AKUN DAN BANTUAN',
          title: 'Profil pengguna',
          description:
              'Kelola akun dan temukan informasi pendukung keselamatan.',
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 24),
        if (isLoading)
          const SiagaCard(
            child: Row(
              children: [
                SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Expanded(child: Text('Memeriksa status akun...')),
              ],
            ),
          ),
        if (statusError != null)
          SiagaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status akun belum dapat dimuat.',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  statusError!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: onRetryStatus,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        if (user != null)
          SiagaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SiagaIconTile(icon: Icons.person_rounded, size: 62),
                const SizedBox(height: 14),
                Text(user!.name, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 5),
                Text(
                  user!.email,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      await onLogout();
                    } on AuthSessionException catch (error) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(error.message)));
                      }
                    }
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Keluar dari akun'),
                ),
              ],
            ),
          ),
        if (!isLoading && statusError == null && user == null)
          SiagaCard(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 570;
                final avatar = const SiagaIconTile(
                  icon: Icons.person_rounded,
                  size: 62,
                );
                final identity = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Belum masuk ke akun',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Masuk ke akun untuk melihat informasi profil.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                );

                final buttons = Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: () => onOpenSection(AppSection.login),
                      icon: const Icon(Icons.login_rounded),
                      label: const Text('Login'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => onOpenSection(AppSection.registration),
                      icon: const Icon(Icons.person_add_alt_1_rounded),
                      label: const Text('Daftar akun'),
                    ),
                  ],
                );

                if (!isWide) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      avatar,
                      const SizedBox(height: 14),
                      identity,
                      const SizedBox(height: 18),
                      buttons,
                    ],
                  );
                }

                return Row(
                  children: [
                    avatar,
                    const SizedBox(width: 16),
                    Expanded(child: identity),
                    const SizedBox(width: 16),
                    buttons,
                  ],
                );
              },
            ),
          ),
        const SizedBox(height: 24),
        _ProfileEducationProgressCard(
          onOpenEducation: () => onOpenSection(AppSection.education),
        ),
        const SizedBox(height: 24),
        const SiagaSectionHeader(
          title: 'Pengaturan dan bantuan',
          subtitle: 'Fitur akan diaktifkan setelah tersedia di aplikasi.',
        ),
        const SizedBox(height: 14),
        const SiagaResponsiveGrid(
          minimumItemWidth: 270,
          children: [
            _ProfileFeatureCard(
              icon: Icons.manage_accounts_outlined,
              title: 'Informasi profil',
              description: 'Website sumber menyebut pengelolaan nama dan informasi akun; pengubahan profil belum tersedia di Flutter.',
            ),
            _ProfileFeatureCard(
              icon: Icons.notifications_none_rounded,
              title: 'Notifikasi',
              description: 'Pengaturan notifikasi ditampilkan di halaman lama, tetapi belum memiliki alur pengaturan.',
            ),
            _ProfileFeatureCard(
              icon: Icons.help_outline_rounded,
              title: 'Pusat bantuan',
              description:
                  'Panduan keselamatan tersedia melalui halaman Mitigasi.',
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: SiagaCard(
            padding: EdgeInsets.zero,
            child: Material(
              type: MaterialType.transparency,
              child: Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  leading: const SiagaIconTile(
                    icon: Icons.call_outlined,
                    color: SiagaColors.danger,
                    backgroundColor: Color(0xFFFEF2F2),
                  ),
                  title: Text(
                    'Kontak darurat pada website sumber',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                  children: [
                    SiagaResponsiveGrid(
                      minimumItemWidth: 230,
                      spacing: 10,
                      children: [
                        for (final contact in _contacts)
                          _ContactCard(contact: contact),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const SiagaNotice(
          title: 'Bantuan Darurat (SOS) belum aktif',
          message: 'Jangan mengandalkan halaman ini sebagai sistem permintaan bantuan. Hubungi layanan resmi atau ikuti arahan petugas.',
          tone: SiagaTone.danger,
          icon: Icons.sos_rounded,
        ),
      ],
    );
  }
}

class _EmergencyContact {
  const _EmergencyContact(this.name, this.number);

  final String name;
  final String number;
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.contact});

  final _EmergencyContact contact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: SiagaColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            contact.name,
            style: const TextStyle(
              color: SiagaColors.muted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          SelectableText(
            contact.number,
            style: const TextStyle(
              color: SiagaColors.ink,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileFeatureCard extends StatelessWidget {
  const _ProfileFeatureCard({
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
      padding: const EdgeInsets.all(19),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SiagaIconTile(icon: icon),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(description, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          const SiagaBadge(label: 'Belum tersedia', tone: SiagaTone.neutral),
        ],
      ),
    );
  }
}

class _ProfileEducationProgressCard extends StatelessWidget {
  const _ProfileEducationProgressCard({required this.onOpenEducation});

  final VoidCallback onOpenEducation;

  @override
  Widget build(BuildContext context) {
    final service = EducationDataService.instance;
    return ListenableBuilder(
      listenable: service,
      builder: (context, _) {
        final EducationUserProgress progress = service.currentProgress;
        return SiagaCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SiagaIconTile(
                    icon: Icons.school_rounded,
                    color: SiagaColors.navy,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Progres & Pencapaian Edukasi Bencana',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Progres kesiapsiagaan Gempa Bumi & Tsunami (${progress.overallPercentage}% selesai · ${progress.totalPoints} poin)',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: (progress.overallPercentage / 100).clamp(
                    0.0,
                    1.0,
                  ),
                  minHeight: 8,
                  backgroundColor: SiagaColors.border,
                  color: SiagaColors.navy,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  SiagaBadge(
                    label:
                        'Materi Gempa: ${progress.earthquakeMaterialsCompleted}/${progress.earthquakeMaterialsTotal}',
                    tone: SiagaTone.danger,
                  ),
                  SiagaBadge(
                    label:
                        'Materi Tsunami: ${progress.tsunamiMaterialsCompleted}/${progress.tsunamiMaterialsTotal}',
                    tone: SiagaTone.info,
                  ),
                  SiagaBadge(
                    label:
                        'Simulasi: ${progress.simulationsCompleted}/${progress.simulationsTotal}',
                    tone: SiagaTone.warning,
                  ),
                  SiagaBadge(
                    label:
                        'Misi Siaga: ${progress.missionsCompleted}/${progress.missionsTotal}',
                    tone: SiagaTone.success,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'Penghargaan Kesiapsiagaan:',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: SiagaColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final badge in progress.badges)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: badge.isEarned
                            ? const Color(0xFFFEF3C7)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: badge.isEarned
                              ? const Color(0xFFF59E0B)
                              : SiagaColors.border,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            badge.isEarned
                                ? Icons.workspace_premium_rounded
                                : Icons.lock_outline_rounded,
                            size: 15,
                            color: badge.isEarned
                                ? const Color(0xFFD97706)
                                : SiagaColors.muted,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            badge.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: badge.isEarned
                                  ? const Color(0xFF92400E)
                                  : SiagaColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.icon(
                  onPressed: onOpenEducation,
                  icon: const Icon(Icons.school_rounded, size: 18),
                  label: const Text('Buka Edukasi Gempa Bumi & Tsunami'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
