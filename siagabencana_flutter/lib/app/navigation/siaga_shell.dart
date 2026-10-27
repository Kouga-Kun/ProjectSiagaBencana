import 'dart:async';

import 'package:flutter/material.dart';

import '../../features/auth/data/auth_session_service.dart';
import '../../features/auth/presentation/auth_page.dart';
import '../../features/evacuation/presentation/evacuation_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/home/data/home_data_service.dart';
import '../../features/mitigation/presentation/mitigation_page.dart';
import '../../features/news/presentation/news_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/reports/presentation/reports_page.dart';
import '../network/api_config.dart';
import '../siaga_theme.dart';
import 'app_section.dart';

class SiagaShell extends StatefulWidget {
  const SiagaShell({this.homeDataService, this.authSessionService, super.key});

  final HomeDataService? homeDataService;
  final AuthSessionService? authSessionService;

  @override
  State<SiagaShell> createState() => _SiagaShellState();
}

class _SiagaShellState extends State<SiagaShell> {
  AppSection _currentSection = AppSection.home;
  late final AuthSessionService _authService;
  bool _ownsAuthService = false;
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
    unawaited(_refreshAuthStatus());
  }

  @override
  void dispose() {
    if (_ownsAuthService) {
      _authService.close();
    }
    super.dispose();
  }

  Future<void> _refreshAuthStatus() async {
    try {
      final user = await _authService.fetchCurrentUser();
      if (!mounted) return;
      setState(() {
        _authUser = user;
        _authStatusError = null;
        _authStatusLoading = false;
      });
    } on AuthSessionException catch (error) {
      if (!mounted) return;
      setState(() {
        _authUser = null;
        _authStatusError = error.message;
        _authStatusLoading = false;
      });
    }
  }

  void _handleAuthenticated(AuthUser user) {
    setState(() {
      _authUser = user;
      _authStatusError = null;
      _authStatusLoading = false;
    });
    _openSection(AppSection.profile);
  }

  Future<void> _handleLogout() async {
    await _authService.logout();
    if (!mounted) return;
    setState(() {
      _authUser = null;
      _authStatusError = null;
      _authStatusLoading = false;
    });
  }

  void _openSection(AppSection section) {
    Navigator.of(context).maybePop();
    setState(() {
      _currentSection = section;
    });
  }

  void _openMoreMenu() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: SiagaColors.surface,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final section in const [
                  AppSection.reports,
                  AppSection.profile,
                ])
                  ListTile(
                    leading: Icon(section.icon, color: SiagaColors.navy),
                    title: Text(section.title),
                    trailing: const Icon(Icons.arrow_forward_rounded, size: 18),
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
    ),
    AppSection.evacuation => EvacuationPage(
      onOpenMitigation: () => _openSection(AppSection.mitigation),
    ),
    AppSection.news => NewsPage(onOpenSection: _openSection),
    AppSection.mitigation => const MitigationPage(),
    AppSection.reports => ReportsPage(
      authService: _authService,
      user: _authUser,
      isAuthLoading: _authStatusLoading,
    ),
    AppSection.login => AuthPage(
      isRegistration: false,
      onOpenSection: _openSection,
      authService: _authService,
      onAuthenticated: _handleAuthenticated,
    ),
    AppSection.registration => AuthPage(
      isRegistration: true,
      onOpenSection: _openSection,
      authService: _authService,
      onAuthenticated: _handleAuthenticated,
    ),
    AppSection.profile => ProfilePage(
      onOpenSection: _openSection,
      user: _authUser,
      isLoading: _authStatusLoading,
      statusError: _authStatusError,
      onRetryStatus: () => unawaited(_refreshAuthStatus()),
      onLogout: _handleLogout,
    ),
  };

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 1100;
        final isMainMobileSection = mobileNavigationSections.contains(
          _currentSection,
        );
        final selectedNavigationIndex = isMainMobileSection
            ? mobileNavigationSections.indexOf(_currentSection)
            : mobileNavigationSections.length;

        return Scaffold(
          appBar: isCompact
              ? AppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: SiagaColors.navy,
                  foregroundColor: Colors.white,
                  titleSpacing: 20,
                  title: const _Brand(),
                  actions: [
                    IconButton(
                      tooltip: 'Buka profil',
                      onPressed: () => _openSection(AppSection.profile),
                      icon: const Icon(Icons.person_outline_rounded),
                    ),
                    const SizedBox(width: 8),
                  ],
                )
              : null,
          bottomNavigationBar: isCompact
              ? NavigationBar(
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
                        label: section.title,
                      ),
                    const NavigationDestination(
                      icon: Icon(Icons.more_horiz_rounded),
                      label: 'Lainnya',
                    ),
                  ],
                )
              : null,
          body: isCompact
              ? _PageFrame(section: _currentSection, child: _buildCurrentPage())
              : Column(
                  children: [
                    _DesktopHeader(
                      currentSection: _currentSection,
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
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1440),
        child: SizedBox.expand(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: KeyedSubtree(key: ValueKey(section), child: child),
          ),
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.shield_rounded, color: Colors.white, size: 28),
        const SizedBox(width: 9),
        Text(
          'SiagaBencana',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _DesktopHeader extends StatelessWidget {
  const _DesktopHeader({
    required this.currentSection,
    required this.onOpenSection,
  });

  final AppSection currentSection;
  final ValueChanged<AppSection> onOpenSection;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SiagaColors.navy,
      elevation: 2,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
            child: Row(
              children: [
                const _Brand(),
                const Spacer(),
                for (final section in desktopNavigationSections)
                  _DesktopNavigationButton(
                    section: section,
                    isSelected: currentSection == section,
                    onPressed: () => onOpenSection(section),
                  ),
                const SizedBox(width: 9),
                TextButton.icon(
                  onPressed: () => onOpenSection(AppSection.profile),
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  icon: const Icon(Icons.person_outline_rounded),
                  label: const Text('Profil'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DesktopNavigationButton extends StatelessWidget {
  const _DesktopNavigationButton({
    required this.section,
    required this.isSelected,
    required this.onPressed,
  });

  final AppSection section;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 11),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              section.title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 3),
            Container(
              height: 2,
              width: 28,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopFooter extends StatelessWidget {
  const _DesktopFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: SiagaColors.ink,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 19),
      child: const Text(
        'SiagaBencana · Informasi dan Mitigasi Bencana Kota Padang',
        textAlign: TextAlign.center,
        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      ),
    );
  }
}
