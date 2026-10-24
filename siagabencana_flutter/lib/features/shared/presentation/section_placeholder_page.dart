import 'package:flutter/material.dart';

import '../../../app/navigation/app_section.dart';
import '../../../app/siaga_theme.dart';

class SectionPlaceholderPage extends StatelessWidget {
  const SectionPlaceholderPage({
    required this.section,
    required this.onOpenSection,
    super.key,
  });

  final AppSection section;
  final ValueChanged<AppSection> onOpenSection;

  String get _note => switch (section) {
    AppSection.evacuation => 'Peta di halaman lama memakai zona, rute, dan koordinat statis. Belum ada peta yang ditampilkan di sini sampai sumber lokasi resmi dikonfirmasi.',
    AppSection.news => 'Daftar berita di Blade masih berupa konten statis. Belum ada feed berita atau API berita yang terhubung.',
    AppSection.mitigation => 'Blade memuat panduan gempa, tsunami, dan checklist Tas Siaga. Pemindahan konten dan interaksinya akan dilanjutkan pada tahap halaman berikutnya.',
    AppSection.reports => 'Riwayat, formulir laporan warga, dan tindakan verifikasi petugas memerlukan API Laravel yang belum dibuat.',
    AppSection.profile => 'Profil, kontak darurat, dan alur akun akan dihubungkan setelah fondasi frontend selesai.',
    AppSection.login => 'Form login dan autentikasi belum diimplementasikan pada tahap fondasi ini.',
    AppSection.registration => 'Form registrasi dan autentikasi belum diimplementasikan pada tahap fondasi ini.',
    AppSection.home => '',
  };

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(section.title, style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 8),
        Text(section.description, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: SiagaColors.surface,
            border: Border.all(color: SiagaColors.border),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(section.icon, color: SiagaColors.navy),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Kerangka halaman siap dikembangkan',
                      style: TextStyle(
                        color: SiagaColors.ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(_note, style: Theme.of(context).textTheme.bodyMedium),
              if (section == AppSection.profile) ...[
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
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
                ),
              ],
              if (section == AppSection.login) ...[
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => onOpenSection(AppSection.registration),
                  child: const Text('Belum punya akun? Daftar'),
                ),
              ],
              if (section == AppSection.registration) ...[
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => onOpenSection(AppSection.login),
                  child: const Text('Sudah punya akun? Login'),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFED7AA)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, color: SiagaColors.warning),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Halaman ini belum mengambil atau mengirim data. Tidak ada koneksi langsung ke database.',
                  style: TextStyle(color: SiagaColors.ink, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
