import 'package:flutter/material.dart';

enum AppSection {
  home,
  evacuation,
  news,
  mitigation,
  reports,
  login,
  registration,
  profile,
}

extension AppSectionPresentation on AppSection {
  String get title => switch (this) {
    AppSection.home => 'Beranda',
    AppSection.evacuation => 'Evakuasi',
    AppSection.news => 'Berita',
    AppSection.mitigation => 'Mitigasi',
    AppSection.reports => 'Laporan',
    AppSection.login => 'Login',
    AppSection.registration => 'Registrasi',
    AppSection.profile => 'Profil',
  };

  IconData get icon => switch (this) {
    AppSection.home => Icons.home_rounded,
    AppSection.evacuation => Icons.directions_walk_rounded,
    AppSection.news => Icons.newspaper_rounded,
    AppSection.mitigation => Icons.health_and_safety_rounded,
    AppSection.reports => Icons.assignment_rounded,
    AppSection.login => Icons.login_rounded,
    AppSection.registration => Icons.person_add_alt_1_rounded,
    AppSection.profile => Icons.person_rounded,
  };

  String get description => switch (this) {
    AppSection.home =>
      'Informasi dan mitigasi bencana untuk masyarakat Kota Padang.',
    AppSection.evacuation =>
      'Informasi langkah evakuasi dan sumber lokasi yang terverifikasi.',
    AppSection.news =>
      'Pembaruan bencana dan kesiapsiagaan dari sumber yang dapat diperiksa.',
    AppSection.mitigation =>
      'Panduan keselamatan gempa, tsunami, dan persiapan Tas Siaga.',
    AppSection.reports =>
      'Riwayat laporan warga dan informasi verifikasi petugas.',
    AppSection.login => 'Masuk ke akun SiagaBencana.',
    AppSection.registration => 'Buat akun warga SiagaBencana.',
    AppSection.profile => 'Profil, bantuan, dan kontak darurat.',
  };
}

const mobileNavigationSections = <AppSection>[
  AppSection.home,
  AppSection.evacuation,
  AppSection.news,
  AppSection.mitigation,
];

const desktopNavigationSections = <AppSection>[
  AppSection.home,
  AppSection.evacuation,
  AppSection.news,
  AppSection.mitigation,
  AppSection.reports,
];
