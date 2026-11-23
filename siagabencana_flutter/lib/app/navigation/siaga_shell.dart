import 'dart:async';

import 'package:flutter/material.dart';

import '../../features/auth/data/auth_session_service.dart';
import '../../features/auth/presentation/auth_page.dart';
import '../../features/education/data/education_data_service.dart';
import '../../features/education/presentation/education_page.dart';
import '../../features/evacuation/presentation/evacuation_page.dart';
import '../../features/home/data/home_data_service.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/mitigation/presentation/mitigation_page.dart';
import '../../features/news/data/news_data_service.dart';
import '../../features/news/presentation/news_page.dart';
import '../../features/profile/presentation/profile_info_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/reports/presentation/reports_page.dart';
import '../../features/sos/data/sos_data_service.dart';
import '../../features/sos/presentation/sos_page.dart';
import '../network/api_config.dart';
import '../siaga_theme.dart';
import 'app_section.dart';

class SiagaShell extends StatefulWidget {
  const SiagaShell({
    this.homeDataService,
    this.authSessionService,
    this.educationDataService,
    this.newsDataService,
    this.sosDataService,
    super.key,
  });

  final HomeDataService? homeDataService;
  final AuthSessionService? authSessionService;
  final EducationDataService? educationDataService;
  final NewsDataService? newsDataService;
  final SosDataService? sosDataService;

  @override
  State<SiagaShell> createState() => _SiagaShellState();
}

class _SiagaShellState extends State<SiagaShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  AppSection _currentSection = AppSection.home;
  AppSection? _intendedSection;
  String? _authRedirectNotice;
  late final AuthSessionService _authService;
  late final EducationDataService _educationService;
  bool _ownsAuthService = false;
  bool _ownsEducationService = false;
  AuthUser? _authUser;
  bool _authStatusLoading = true;
  String? _authStatusError;

  @override
  void initState() {
    super.initState();
    _ownsAuthService = widget.authSessionService == null;
    _authService =
        widget.authSessionService ??
        AuthSessionService(apiConfig: const ApiConfig.fromEnvironment());
    _ownsEducationService = widget.educationDataService == null;
    _educationService =
        widget.educationDataService ??
        EducationDataService(
          apiConfig: _authService.apiConfig,
          authService: _authService,
          onUnauthorized: _handleEducationUnauthorized,
        );
    unawaited(_refreshAuthStatus());
  }

  @override
  void dispose() {
    if (_ownsEducationService) {
      _educationService.dispose();
    }
    if (_ownsAuthService) {
      _authService.close();
    }
    super.dispose();
  }

  void _handleEducationUnauthorized() {
    if (!mounted) {
      return;
    }
    setState(() {
      _authUser = null;
      _intendedSection = AppSection.education;
      _authRedirectNotice =
          'Sesi login Anda berakhir. Silakan masuk kembali untuk mengakses Edukasi Bencana.';
      if (_currentSection == AppSection.education) {
        _currentSection = AppSection.login;
      }
    });
  }

  Future<void> _refreshAuthStatus() async {
    try {
      final user = await _authService.fetchCurrentUser();
      if (!mounted) return;
      _educationService.bindUser(user);
      setState(() {
        _authUser = user;
        _authStatusError = null;
        _authStatusLoading = false;
        if (user == null && _currentSection == AppSection.education) {
          _intendedSection = AppSection.education;
          _authRedirectNotice =
              'Silakan masuk ke akun SiagaBencana untuk mengakses fitur Edukasi Bencana.';
          _currentSection = AppSection.login;
        }
      });
    } on AuthSessionException catch (error) {
      if (!mounted) return;
      _educationService.clearSession();
      setState(() {
        _authUser = null;
        _authStatusError = error.message;
        _authStatusLoading = false;
        if (_currentSection == AppSection.education) {
          _intendedSection = AppSection.education;
          _authRedirectNotice =
              'Silakan masuk ke akun SiagaBencana untuk mengakses fitur Edukasi Bencana.';
          _currentSection = AppSection.login;
        }
      });
    }
  }

  void _handleAuthenticated(AuthUser user) {
    final targetSection = _intendedSection ?? AppSection.profile;
    _educationService.bindUser(user);
    setState(() {
      _authUser = user;
      _authStatusError = null;
      _authStatusLoading = false;
      _intendedSection = null;
      _authRedirectNotice = null;
    });
    _openSection(targetSection);
  }

  void _handleUserUpdated(AuthUser user) {
    if (!mounted) return;
    setState(() {
      _authUser = user;
    });
  }

  Future<void> _handleLogout() async {
    await _authService.logout();
    _educationService.clearSession();
    if (!mounted) return;
    setState(() {
      _authUser = null;
      _authStatusError = null;
      _authStatusLoading = false;
      _intendedSection = null;
      _authRedirectNotice = null;
      if (_currentSection == AppSection.education ||
          _currentSection == AppSection.profileInfo) {
        _currentSection = AppSection.login;
      }
    });
  }

  void _openSection(AppSection section) {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).maybePop();
    }

    if (section == AppSection.education &&
        !_authStatusLoading &&
        _authUser == null) {
      setState(() {
        _intendedSection = AppSection.education;
        _authRedirectNotice =
            'Edukasi Bencana hanya dapat diakses setelah login. Setelah masuk, Anda akan langsung diarahkan ke halaman Edukasi Bencana.';
        _currentSection = AppSection.login;
      });
      return;
    }

    setState(() {
      if (section != AppSection.login && section != AppSection.registration) {
        _authRedirectNotice = null;
        if (section != AppSection.education) {
          _intendedSection = null;
        }
      }
      _currentSection = section;
    });
  }

  void _openMoreMenu() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: SiagaColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SiagaRadius.xl),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                  child: Text(
                    'LAYANAN LAINNYA',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
                for (final section in const [
                  AppSection.reports,
                  AppSection.mitigation,
                  AppSection.sos,
                  AppSection.profile,
                ])
                  _MoreSheetTile(
                    section: section,
                    isSelected: _currentSection == section,
                    onTap: () {
                      Navigator.of(context).pop();
                      _openSection(section);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrentPage() => switch (_currentSection) {
    AppSection.home => HomePage(
      onOpenSection: _openSection,
      dataService: widget.homeDataService,
      newsDataService: widget.newsDataService,
    ),
    AppSection.evacuation => EvacuationPage(
      onOpenMitigation: () => _openSection(AppSection.mitigation),
      onOpenEducation: () => _openSection(AppSection.education),
    ),
    AppSection.news => NewsPage(
      onOpenSection: _openSection,
      dataService: widget.newsDataService,
    ),
    AppSection.education => EducationPage(
      onNavigate: _openSection,
      service: _educationService,
      user: _authUser,
      isAuthLoading: _authStatusLoading,
      onRequireLogin: () {
        setState(() {
          _intendedSection = AppSection.education;
          _authRedirectNotice =
              'Edukasi Bencana hanya dapat diakses setelah login. Setelah masuk, Anda akan langsung diarahkan ke halaman Edukasi Bencana.';
          _currentSection = AppSection.login;
        });
      },
    ),
    AppSection.mitigation => const MitigationPage(),
    AppSection.reports => ReportsPage(
      authService: _authService,
      user: _authUser,
      isAuthLoading: _authStatusLoading,
      onOpenLogin: () => _openSection(AppSection.login),
    ),
    AppSection.sos => SosPage(
      user: _authUser,
      authService: _authService,
      sosDataService: widget.sosDataService,
      onBack: () => _openSection(AppSection.profile),
      onOpenSection: _openSection,
    ),
    AppSection.login => AuthPage(
      isRegistration: false,
      onOpenSection: _openSection,
      authService: _authService,
      onAuthenticated: _handleAuthenticated,
      noticeMessage: _authRedirectNotice,
    ),
    AppSection.registration => AuthPage(
      isRegistration: true,
      onOpenSection: _openSection,
      authService: _authService,
      onAuthenticated: _handleAuthenticated,
      noticeMessage: _authRedirectNotice,
    ),
    AppSection.profile => ProfilePage(
      onOpenSection: _openSection,
      user: _authUser,
      isLoading: _authStatusLoading,
      statusError: _authStatusError,
      onRetryStatus: () => unawaited(_refreshAuthStatus()),
      onLogout: _handleLogout,
      educationService: _educationService,
    ),
    AppSection.profileInfo => ProfileInfoPage(
      user: _authUser,
      authService: _authService,
      onUserUpdated: _handleUserUpdated,
      onBack: () => _openSection(AppSection.profile),
      onOpenSection: _openSection,
    ),
  };

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < SiagaBreakpoints.desktop;
        final isMainMobileSection = mobileNavigationSections.contains(
          _currentSection,
        );
        final selectedNavigationIndex = isMainMobileSection
            ? mobileNavigationSections.indexOf(_currentSection)
            : mobileNavigationSections.length;

        if (isCompact) {
          return Scaffold(
            key: _scaffoldKey,
            backgroundColor: SiagaColors.background,
            drawer: Drawer(
              width: 280,
              backgroundColor: SiagaColors.surface,
              surfaceTintColor: Colors.transparent,
              shape: const RoundedRectangleBorder(),
              child: SafeArea(
                child: _SidebarContent(
                  currentSection: _currentSection,
                  user: _authUser,
                  onOpenSection: _openSection,
                ),
              ),
            ),
            appBar: AppBar(
              backgroundColor: SiagaColors.surface,
              foregroundColor: SiagaColors.ink,
              titleSpacing: 6,
              leading: IconButton(
                tooltip: 'Buka menu navigasi',
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                icon: const Icon(Icons.menu_rounded),
              ),
              title: const _Brand(compact: true),
              actions: [
                IconButton(
                  tooltip: 'Bantuan Darurat SOS',
                  onPressed: () => _openSection(AppSection.sos),
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: SiagaColors.dangerSoft,
                      borderRadius: BorderRadius.circular(SiagaRadius.md),
                      border: Border.all(color: SiagaColors.dangerBorder),
                    ),
                    child: const Icon(
                      Icons.sos_rounded,
                      color: SiagaColors.danger,
                      size: 18,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Buka profil',
                  onPressed: () => _openSection(AppSection.profile),
                  icon: _UserMiniAvatar(user: _authUser, size: 30),
                ),
                const SizedBox(width: 6),
              ],
            ),
            bottomNavigationBar: DecoratedBox(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: SiagaColors.border)),
              ),
              child: NavigationBar(
                selectedIndex: selectedNavigationIndex,
                onDestinationSelected: (index) {
                  if (index < mobileNavigationSections.length) {
                    _openSection(mobileNavigationSections[index]);
                  } else {
                    _openMoreMenu();
                  }
                },
                destinations: [
                  for (final section in mobileNavigationSections)
                    NavigationDestination(
                      icon: Icon(section.icon),
                      selectedIcon: Icon(section.activeIcon),
                      label: section.shortLabel,
                    ),
                  const NavigationDestination(
                    icon: Icon(Icons.more_horiz_rounded),
                    label: 'Lainnya',
                  ),
                ],
              ),
            ),
            body: _PageFrame(
              section: _currentSection,
              child: _buildCurrentPage(),
            ),
          );
        }

        // Desktop: Clean Enterprise Sidebar + Top Context Bar + Content Canvas
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: SiagaColors.background,
          body: Row(
            children: [
              Container(
                width: 252,
                decoration: const BoxDecoration(
                  color: SiagaColors.surface,
                  border: Border(right: BorderSide(color: SiagaColors.border)),
                ),
                child: _SidebarContent(
                  currentSection: _currentSection,
                  user: _authUser,
                  onOpenSection: _openSection,
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    _DesktopContextBar(
                      currentSection: _currentSection,
                      user: _authUser,
                      onOpenSection: _openSection,
                    ),
                    Expanded(
                      child: _PageFrame(
                        section: _currentSection,
                        child: _buildCurrentPage(),
                      ),
                    ),
                    const _DesktopFooter(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PageFrame extends StatelessWidget {
  const _PageFrame({required this.child, required this.section});

  final Widget child;
  final AppSection section;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: SiagaBreakpoints.maxContentWidth,
        ),
        child: SizedBox.expand(
          child: AnimatedSwitcher(
            duration: reduceMotion
                ? Duration.zero
                : const Duration(milliseconds: 170),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: KeyedSubtree(key: ValueKey(section), child: child),
          ),
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 32 : 36,
          height: compact ? 32 : 36,
          decoration: BoxDecoration(
            color: SiagaColors.navy,
            borderRadius: BorderRadius.circular(SiagaRadius.md),
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.shield_rounded,
            color: Colors.white,
            size: compact ? 18 : 20,
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SiagaBencana',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: SiagaColors.navy,
                  fontSize: compact ? 16 : 16.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              if (!compact)
                const Text(
                  'Kota Padang',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: SiagaColors.muted,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SidebarContent extends StatelessWidget {
  const _SidebarContent({
    required this.currentSection,
    required this.user,
    required this.onOpenSection,
  });

  final AppSection currentSection;
  final AuthUser? user;
  final ValueChanged<AppSection> onOpenSection;

  bool _isSectionActive(AppSection section) {
    if (section == AppSection.profile &&
        currentSection == AppSection.profileInfo) {
      return true;
    }
    return currentSection == section;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => onOpenSection(AppSection.home),
          child: const Padding(
            padding: EdgeInsets.fromLTRB(20, 18, 20, 16),
            child: _Brand(),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 8),
                  child: Text(
                    'NAVIGASI UTAMA',
                    style: TextStyle(
                      color: SiagaColors.textSubtle,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.7,
                    ),
                  ),
                ),
                for (final section in desktopPrimaryNavigationSections)
                  _SidebarNavTile(
                    section: section,
                    isSelected: _isSectionActive(section),
                    showLockCue:
                        section == AppSection.education && user == null,
                    onTap: () => onOpenSection(section),
                  ),
                const SizedBox(height: 18),
                const Padding(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 8),
                  child: Text(
                    'DARURAT & AKUN',
                    style: TextStyle(
                      color: SiagaColors.textSubtle,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.7,
                    ),
                  ),
                ),
                for (final section in desktopSecondaryNavigationSections)
                  _SidebarNavTile(
                    section: section,
                    isSelected: _isSectionActive(section),
                    isEmergency: section == AppSection.sos,
                    onTap: () => onOpenSection(section),
                  ),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(14),
          child: user != null
              ? _SidebarAccountCard(
                  user: user!,
                  onTap: () => onOpenSection(AppSection.profile),
                )
              : _SidebarGuestCard(
                  onLogin: () => onOpenSection(AppSection.login),
                ),
        ),
      ],
    );
  }
}

class _SidebarNavTile extends StatefulWidget {
  const _SidebarNavTile({
    required this.section,
    required this.isSelected,
    required this.onTap,
    this.isEmergency = false,
    this.showLockCue = false,
  });

  final AppSection section;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isEmergency;
  final bool showLockCue;

  @override
  State<_SidebarNavTile> createState() => _SidebarNavTileState();
}

class _SidebarNavTileState extends State<_SidebarNavTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final selectedBg = widget.isEmergency
        ? SiagaColors.dangerSoft
        : SiagaColors.primarySoft;
    final selectedFg = widget.isEmergency
        ? SiagaColors.dangerText
        : SiagaColors.navy;
    final selectedAccent = widget.isEmergency
        ? SiagaColors.danger
        : SiagaColors.navy;

    final bgColor = widget.isSelected
        ? selectedBg
        : _hovered
        ? SiagaColors.surfaceSubtle
        : Colors.transparent;

    final iconColor = widget.isSelected
        ? selectedAccent
        : widget.isEmergency
        ? SiagaColors.danger
        : _hovered
        ? SiagaColors.ink
        : SiagaColors.muted;

    final textColor = widget.isSelected
        ? selectedFg
        : _hovered
        ? SiagaColors.ink
        : SiagaColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(SiagaRadius.md),
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 140),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(SiagaRadius.md),
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: reduceMotion
                        ? Duration.zero
                        : const Duration(milliseconds: 140),
                    width: 3,
                    height: 18,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: widget.isSelected
                          ? selectedAccent
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Icon(
                    widget.isSelected
                        ? widget.section.activeIcon
                        : widget.section.icon,
                    size: 19,
                    color: iconColor,
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      widget.section.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.8,
                        fontWeight: widget.isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                  ),
                  if (widget.showLockCue)
                    const Icon(
                      Icons.lock_outline_rounded,
                      size: 14,
                      color: SiagaColors.textSubtle,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarAccountCard extends StatelessWidget {
  const _SidebarAccountCard({required this.user, required this.onTap});

  final AuthUser user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SiagaColors.surfaceSubtle,
      borderRadius: BorderRadius.circular(SiagaRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(SiagaRadius.md),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SiagaRadius.md),
            border: Border.all(color: SiagaColors.border),
          ),
          child: Row(
            children: [
              _UserMiniAvatar(user: user, size: 34),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      user.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: SiagaColors.ink,
                      ),
                    ),
                    Text(
                      user.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: SiagaColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: SiagaColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarGuestCard extends StatelessWidget {
  const _SidebarGuestCard({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SiagaColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(SiagaRadius.md),
        border: Border.all(color: SiagaColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Akses Akun Warga',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: SiagaColors.ink,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Simpan progres edukasi, kirim laporan, dan akses SOS.',
            style: TextStyle(
              fontSize: 11.5,
              color: SiagaColors.muted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: onLogin,
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              textStyle: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Masuk Akun'),
          ),
        ],
      ),
    );
  }
}

class _DesktopContextBar extends StatelessWidget {
  const _DesktopContextBar({
    required this.currentSection,
    required this.user,
    required this.onOpenSection,
  });

  final AppSection currentSection;
  final AuthUser? user;
  final ValueChanged<AppSection> onOpenSection;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: SiagaColors.surface,
        border: Border(bottom: BorderSide(color: SiagaColors.border)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: SiagaBreakpoints.maxContentWidth,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              children: [
                Icon(currentSection.icon, size: 18, color: SiagaColors.muted),
                const SizedBox(width: 8),
                Text(
                  currentSection.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 10),
                Container(width: 1, height: 14, color: SiagaColors.border),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    currentSection.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () => onOpenSection(AppSection.sos),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SiagaColors.danger,
                    side: const BorderSide(color: SiagaColors.dangerBorder),
                    backgroundColor: SiagaColors.dangerSoft,
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  icon: const Icon(Icons.sos_rounded, size: 16),
                  label: const Text('Darurat SOS'),
                ),
                const SizedBox(width: 10),
                Tooltip(
                  message: 'Buka profil',
                  child: InkWell(
                    borderRadius: BorderRadius.circular(SiagaRadius.pill),
                    onTap: () => onOpenSection(AppSection.profile),
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: _UserMiniAvatar(user: user, size: 32),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UserMiniAvatar extends StatelessWidget {
  const _UserMiniAvatar({required this.user, required this.size});

  final AuthUser? user;
  final double size;

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'SB';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = user?.profilePhotoUrl;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          photoUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _fallback(),
        ),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    if (user == null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: SiagaColors.surfaceMuted,
          shape: BoxShape.circle,
          border: Border.all(color: SiagaColors.border),
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.person_outline_rounded,
          size: size * 0.54,
          color: SiagaColors.muted,
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: SiagaColors.navy,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        _initials(user!.name),
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.36,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MoreSheetTile extends StatelessWidget {
  const _MoreSheetTile({
    required this.section,
    required this.isSelected,
    required this.onTap,
  });

  final AppSection section;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSos = section == AppSection.sos;
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SiagaRadius.md),
      ),
      tileColor: isSelected ? SiagaColors.primarySoft : null,
      leading: Icon(
        isSelected ? section.activeIcon : section.icon,
        color: isSos ? SiagaColors.danger : SiagaColors.navy,
      ),
      title: Text(
        section.title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          color: isSos ? SiagaColors.dangerText : SiagaColors.ink,
        ),
      ),
      subtitle: Text(
        section.description,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        size: 18,
        color: SiagaColors.muted,
      ),
      onTap: onTap,
    );
  }
}

class _DesktopFooter extends StatelessWidget {
  const _DesktopFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: SiagaColors.surface,
        border: Border(top: BorderSide(color: SiagaColors.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 11),
      child: const Row(
        children: [
          Expanded(
            child: Text(
              'SiagaBencana · Layanan Informasi & Mitigasi Bencana Kota Padang',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: SiagaColors.muted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 16),
          Flexible(
            child: Text(
              'Sumber data: BMKG · Open-Meteo · BPBD',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: SiagaColors.textSubtle,
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
