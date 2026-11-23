import 'package:flutter/material.dart';

enum AppSection {
  home,
  evacuation,
  news,
  education,
  mitigation,
  reports,
  sos,
  login,
  registration,
  profile,
  profileInfo,
}

extension AppSectionPresentation on AppSection {
  String get title => switch (this) {
    AppSection.home => 'Beranda',
    AppSection.evacuation => 'Peta Evakuasi',
    AppSection.news => 'Berita',
    AppSection.education => 'Edukasi Bencana',
    AppSection.mitigation => 'Mitigasi',
    AppSection.reports => 'Laporan',
    AppSection.sos => 'Bantuan SOS',
    AppSection.login => 'Login',
    AppSection.registration => 'Registrasi',
    AppSection.profile => 'Profil',
    AppSection.profileInfo => 'Informasi Profil',
  };

  String get shortLabel => switch (this) {
    AppSection.evacuation => 'Evakuasi',
    AppSection.education => 'Edukasi',
    AppSection.sos => 'SOS',
    _ => title,
  };

  IconData get icon => switch (this) {
    AppSection.home => Icons.home_outlined,
    AppSection.evacuation => Icons.map_outlined,
    AppSection.news => Icons.newspaper_outlined,
    AppSection.education => Icons.school_outlined,
    AppSection.mitigation => Icons.health_and_safety_outlined,
    AppSection.reports => Icons.assignment_outlined,
    AppSection.sos => Icons.sos_rounded,
    AppSection.login => Icons.login_rounded,
    AppSection.registration => Icons.person_add_alt_1_outlined,
    AppSection.profile => Icons.person_outline_rounded,
    AppSection.profileInfo => Icons.manage_accounts_outlined,
  };

  IconData get activeIcon => switch (this) {
    AppSection.home => Icons.home_rounded,
    AppSection.evacuation => Icons.map_rounded,
    AppSection.news => Icons.newspaper_rounded,
    AppSection.education => Icons.school_rounded,
    AppSection.mitigation => Icons.health_and_safety_rounded,
    AppSection.reports => Icons.assignment_rounded,
    AppSection.sos => Icons.sos_rounded,
    AppSection.login => Icons.login_rounded,
    AppSection.registration => Icons.person_add_alt_1_rounded,
    AppSection.profile => Icons.person_rounded,
    AppSection.profileInfo => Icons.manage_accounts_rounded,
  };

  String get description => switch (this) {
    AppSection.home =>
      'Pusat pemantauan cuaca, kualitas udara, berita terbaru, dan kesiapsiagaan bencana Kota Padang.',
    AppSection.evacuation =>
      'Peta zona risiko, jalur evakuasi, dan titik kumpul resmi Kota Padang.',
    AppSection.news =>
      'Berita kebencanaan, peringatan dini, dan artikel kesiapsiagaan resmi.',
    AppSection.education =>
      'Modul pembelajaran, simulasi, kuis, dan Misi Siaga gempa bumi serta tsunami.',
    AppSection.mitigation =>
      'Panduan keselamatan gempa bumi, tsunami, dan persiapan Tas Siaga Bencana.',
    AppSection.reports =>
      'Pelaporan kejadian bencana warga dan riwayat status verifikasi petugas.',
    AppSection.sos =>
      'Kirim sinyal permintaan bantuan darurat beserta koordinat GPS Anda.',
    AppSection.login => 'Masuk ke akun warga atau petugas SiagaBencana.',
    AppSection.registration => 'Buat akun warga SiagaBencana.',
    AppSection.profile =>
      'Kelola akun, progres edukasi, dan kontak instansi darurat.',
    AppSection.profileInfo =>
      'Perbarui foto profil, nama lengkap, nomor telepon, dan alamat akun.',
  };
}

const mobileNavigationSections = <AppSection>[
  AppSection.home,
  AppSection.news,
  AppSection.evacuation,
  AppSection.education,
];

const desktopPrimaryNavigationSections = <AppSection>[
  AppSection.home,
  AppSection.news,
  AppSection.evacuation,
  AppSection.education,
  AppSection.reports,
  AppSection.mitigation,
];

const desktopSecondaryNavigationSections = <AppSection>[
  AppSection.sos,
  AppSection.profile,
];

const desktopNavigationSections = <AppSection>[
  AppSection.home,
  AppSection.news,
  AppSection.evacuation,
  AppSection.education,
  AppSection.reports,
];
