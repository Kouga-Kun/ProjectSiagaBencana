import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
    this.educationService,
    super.key,
  });

  final ValueChanged<AppSection> onOpenSection;
  final AuthUser? user;
  final bool isLoading;
  final String? statusError;
  final VoidCallback onRetryStatus;
  final Future<void> Function() onLogout;
  final EducationDataService? educationService;

  static const _contacts = [
    _EmergencyContact('BPBD Kota Padang', '0751-778775', '0751778775'),
    _EmergencyContact('SAR Kota Padang', '0751-484534', '0751484534'),
    _EmergencyContact('Pemadam Kebakaran', '113 / 0751-28558', '113'),
    _EmergencyContact('PMI Padang', '0751-31795', '075131795'),
    _EmergencyContact('Polisi / Poltabes', '110 / 0751-33724', '110'),
    _EmergencyContact('RS M. Djamil Padang', '0751-37030', '075137030'),
  ];

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = MediaQuery.sizeOf(context).width < 600
        ? 18.0
        : 30.0;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        24,
        horizontalPadding,
        44,
      ),
      children: [
        const SiagaPageHeader(
          eyebrow: 'AKUN & KESELAMATAN',
          title: 'Profil pengguna',
          description:
              'Kelola informasi akun, pantau progres kesiapsiagaan, dan akses layanan bantuan darurat.',
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 22),

        if (isLoading)
          const SiagaCard(
            child: Row(
              children: [
                SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Expanded(child: Text('Memeriksa status sesi akun...')),
              ],
            ),
          ),

        if (statusError != null)
          SiagaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SiagaNotice(
                  title: 'Status akun belum dapat dimuat',
                  message: statusError!,
                  tone: SiagaTone.warning,
                  icon: Icons.cloud_off_outlined,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: onRetryStatus,
                  icon: const Icon(Icons.refresh_rounded, size: 17),
                  label: const Text('Coba lagi'),
                ),
              ],
            ),
          ),

        if (user != null) _buildSignedInIdentityCard(context, user!),

        if (!isLoading && statusError == null && user == null)
          _buildGuestIdentityCard(context),

        if (user != null && educationService != null) ...[
          const SizedBox(height: 22),
          _ProfileEducationProgressCard(
            service: educationService!,
            onOpenEducation: () => onOpenSection(AppSection.education),
          ),
        ],

        const SizedBox(height: 28),
        const SiagaSectionHeader(
          title: 'Layanan akun & keselamatan',
          subtitle:
              'Akses pengaturan profil, permintaan darurat SOS, dan panduan mitigasi bencana.',
        ),
        const SizedBox(height: 14),
        SiagaResponsiveGrid(
          minimumItemWidth: 260,
          spacing: 14,
          children: [
            _ProfileActionCard(
              icon: Icons.manage_accounts_outlined,
              tone: SiagaTone.info,
              title: 'Informasi profil',
              description:
                  'Lihat dan perbarui foto profil, nama lengkap, nomor telepon, serta alamat tempat tinggal.',
              actionLabel: 'Kelola profil',
              onTap: () => onOpenSection(AppSection.profileInfo),
            ),
            _ProfileActionCard(
              icon: Icons.sos_rounded,
              tone: SiagaTone.danger,
              title: 'Bantuan Darurat SOS',
              description:
                  'Kirim sinyal permintaan bantuan darurat beserta koordinat GPS dan pantau status penanganan.',
              actionLabel: 'Buka layanan SOS',
              onTap: () => onOpenSection(AppSection.sos),
            ),
            _ProfileActionCard(
              icon: Icons.health_and_safety_outlined,
              tone: SiagaTone.success,
              title: 'Panduan mitigasi & bantuan',
              description:
                  'Pelajari langkah darurat gempa bumi, tanda alami tsunami, dan checklist Tas Siaga.',
              actionLabel: 'Buka panduan',
              onTap: () => onOpenSection(AppSection.mitigation),
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
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 6,
                  ),
                  leading: const SiagaIconTile(
                    icon: Icons.call_outlined,
                    size: 42,
                    color: SiagaColors.danger,
                    backgroundColor: SiagaColors.dangerSoft,
                  ),
                  title: Text(
                    'Kontak darurat pada website sumber',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  subtitle: Text(
                    'Nomor telepon resmi instansi penanganan darurat Kota Padang.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
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
        SiagaNotice(
          title: 'Keamanan sesi & privasi akun',
          message:
              'Data profil, riwayat laporan, progres Edukasi Bencana, dan permintaan SOS tersimpan aman terpisah per akun pada server SiagaBencana.',
          tone: SiagaTone.info,
          icon: Icons.verified_user_outlined,
        ),
      ],
    );
  }

  Widget _buildSignedInIdentityCard(BuildContext context, AuthUser activeUser) {
    final hasPhone =
        activeUser.phone != null && activeUser.phone!.trim().isNotEmpty;
    final hasAddress =
        activeUser.address != null && activeUser.address!.trim().isNotEmpty;

    return SiagaCard(
      padding: const EdgeInsets.all(22),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 640;

          final avatar = _ProfileAvatar(user: activeUser, size: 64);

          final info = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    activeUser.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SiagaBadge(
                    label: activeUser.role.toUpperCase(),
                    tone: SiagaTone.info,
                    compact: true,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                activeUser.email,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 14,
                runSpacing: 6,
                children: [
                  _IdentityMeta(
                    icon: Icons.phone_outlined,
                    text: hasPhone ? activeUser.phone! : 'Telepon belum diisi',
                    muted: !hasPhone,
                  ),
                  _IdentityMeta(
                    icon: Icons.location_on_outlined,
                    text: hasAddress
                        ? activeUser.address!
                        : 'Alamat belum diisi',
                    muted: !hasAddress,
                  ),
                ],
              ),
            ],
          );

          final actions = Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: () => onOpenSection(AppSection.profileInfo),
                icon: const Icon(Icons.edit_outlined, size: 17),
                label: const Text('Edit Profil'),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: SiagaColors.danger,
                  side: const BorderSide(color: SiagaColors.dangerBorder),
                ),
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
                icon: const Icon(Icons.logout_rounded, size: 17),
                label: const Text('Keluar dari akun'),
              ),
            ],
          );

          if (!isWide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    avatar,
                    const SizedBox(width: 14),
                    Expanded(child: info),
                  ],
                ),
                const SizedBox(height: 18),
                actions,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              avatar,
              const SizedBox(width: 18),
              Expanded(child: info),
              const SizedBox(width: 16),
              actions,
            ],
          );
        },
      ),
    );
  }

  Widget _buildGuestIdentityCard(BuildContext context) {
    return SiagaCard(
      padding: const EdgeInsets.all(22),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 580;
          const avatar = SiagaIconTile(icon: Icons.person_outline_rounded, size: 58);
          final identity = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Belum masuk ke akun',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Masuk untuk mengelola informasi profil, menyimpan progres Edukasi Bencana, mengirim laporan, dan mengakses Bantuan Darurat SOS.',
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
                icon: const Icon(Icons.login_rounded, size: 17),
                label: const Text('Login'),
              ),
              OutlinedButton.icon(
                onPressed: () => onOpenSection(AppSection.registration),
                icon: const Icon(Icons.person_add_alt_1_outlined, size: 17),
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
                const SizedBox(height: 16),
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
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.user, required this.size});

  final AuthUser user;
  final double size;

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'SB';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = user.profilePhotoUrl;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: SiagaColors.border, width: 2),
        ),
        child: ClipOval(
          child: Image.network(
            photoUrl,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _fallback(),
          ),
        ),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: SiagaColors.navy,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        _initials(user.name),
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.34,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _IdentityMeta extends StatelessWidget {
  const _IdentityMeta({
    required this.icon,
    required this.text,
    this.muted = false,
  });

  final IconData icon;
  final String text;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: SiagaColors.muted),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.5,
              color: muted ? SiagaColors.textSubtle : SiagaColors.textSecondary,
              fontStyle: muted ? FontStyle.italic : FontStyle.normal,
              fontWeight: muted ? FontWeight.w400 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmergencyContact {
  const _EmergencyContact(this.name, this.number, this.dialNumber);

  final String name;
  final String number;
  final String dialNumber;
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.contact});

  final _EmergencyContact contact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SiagaColors.surfaceSubtle,
        border: Border.all(color: SiagaColors.border),
        borderRadius: BorderRadius.circular(SiagaRadius.md),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: const TextStyle(
                    color: SiagaColors.muted,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  contact.number,
                  style: const TextStyle(
                    color: SiagaColors.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Hubungi ${contact.name}',
            visualDensity: VisualDensity.compact,
            onPressed: () {
              launchUrl(Uri(scheme: 'tel', path: contact.dialNumber));
            },
            icon: const Icon(
              Icons.call_outlined,
              size: 18,
              color: SiagaColors.danger,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileActionCard extends StatelessWidget {
  const _ProfileActionCard({
    required this.icon,
    required this.tone,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onTap,
  });

  final IconData icon;
  final SiagaTone tone;
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SiagaInteractiveCard(
      padding: const EdgeInsets.all(18),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SiagaIconTile(
            icon: icon,
            size: 42,
            color: tone.accent,
            backgroundColor: tone.background,
          ),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 5),
          Text(
            description,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontSize: 13.5),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                actionLabel,
                style: TextStyle(
                  color: tone.foreground,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 5),
              Icon(
                Icons.arrow_forward_rounded,
                size: 15,
                color: tone.foreground,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileEducationProgressCard extends StatelessWidget {
  const _ProfileEducationProgressCard({
    required this.service,
    required this.onOpenEducation,
  });

  final EducationDataService service;
  final VoidCallback onOpenEducation;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: service,
      builder: (context, _) {
        final progress = service.currentProgress;
        return SiagaCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SiagaIconTile(
                    icon: Icons.school_outlined,
                    size: 42,
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
                          'Kesiapsiagaan Gempa Bumi & Tsunami · ${progress.overallPercentage}% selesai · ${progress.totalPoints} poin',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(
                      backgroundColor: SiagaColors.primarySoft,
                      foregroundColor: SiagaColors.navy,
                    ),
                    onPressed: onOpenEducation,
                    icon: const Icon(Icons.arrow_forward_rounded, size: 17),
                    label: const Text('Buka Edukasi'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(SiagaRadius.pill),
                child: LinearProgressIndicator(
                  value: (progress.overallPercentage / 100).clamp(0.0, 1.0),
                  minHeight: 7,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  SiagaBadge(
                    label:
                        'Materi Gempa: ${progress.earthquakeMaterialsCompleted}/${progress.earthquakeMaterialsTotal}',
                    tone: SiagaTone.warning,
                    compact: true,
                  ),
                  SiagaBadge(
                    label:
                        'Materi Tsunami: ${progress.tsunamiMaterialsCompleted}/${progress.tsunamiMaterialsTotal}',
                    tone: SiagaTone.info,
                    compact: true,
                  ),
                  SiagaBadge(
                    label:
                        'Simulasi: ${progress.simulationsCompleted}/${progress.simulationsTotal}',
                    tone: SiagaTone.neutral,
                    compact: true,
                  ),
                  SiagaBadge(
                    label:
                        'Misi Siaga: ${progress.missionsCompleted}/${progress.missionsTotal}',
                    tone: SiagaTone.success,
                    compact: true,
                  ),
                ],
              ),
              if (progress.badges.isNotEmpty) ...[
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final badge in progress.badges)
                      SiagaBadge(
                        label: badge.name,
                        tone: badge.isEarned
                            ? SiagaTone.warning
                            : SiagaTone.neutral,
                        icon: badge.isEarned
                            ? Icons.workspace_premium_rounded
                            : Icons.lock_outline_rounded,
                        compact: true,
                      ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
