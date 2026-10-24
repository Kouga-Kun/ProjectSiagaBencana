import 'package:flutter/material.dart';

import '../../../app/widgets/siaga_components.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({required this.onOpenLogin, super.key});

  final VoidCallback onOpenLogin;

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
          eyebrow: 'LAPORAN MASYARAKAT',
          title: 'Laporan dan riwayat bencana',
          description: 'Lihat alur laporan warga dan proses verifikasi sebelum informasi ditampilkan sebagai terkonfirmasi.',
          icon: Icons.assignment_outlined,
        ),
        const SizedBox(height: 24),
        SiagaNotice(
          title: 'Data laporan belum dimuat',
          message: 'Halaman ini belum terhubung ke API Laravel. Ini tidak berarti belum ada laporan di database.',
          tone: SiagaTone.warning,
          icon: Icons.cloud_off_outlined,
        ),
        const SizedBox(height: 26),
        const SiagaSectionHeader(
          title: 'Alur laporan',
          subtitle: 'Alur berikut mengikuti fitur laporan yang ada di Laravel.',
        ),
        const SizedBox(height: 15),
        const SiagaResponsiveGrid(
          minimumItemWidth: 300,
          children: [
            SiagaStepCard(
              number: '01',
              title: 'Warga mengirim informasi',
              description: 'Pengguna yang masuk dapat mengirim laporan dengan informasi kejadian yang diketahui.',
              tone: SiagaTone.info,
            ),
            SiagaStepCard(
              number: '02',
              title: 'Laporan menunggu verifikasi',
              description: 'Laporan baru diberi status menunggu verifikasi dan tidak ditampilkan sebagai kejadian terkonfirmasi.',
              tone: SiagaTone.warning,
            ),
            SiagaStepCard(
              number: '03',
              title: 'Petugas memeriksa laporan',
              description: 'Petugas dapat memperbarui data, memverifikasi laporan, atau menolaknya.',
              tone: SiagaTone.success,
            ),
          ],
        ),
        const SizedBox(height: 30),
        const SiagaSectionHeader(
          title: 'Arti status verifikasi',
          subtitle: 'Status laporan menjelaskan proses pemeriksaan.',
        ),
        const SizedBox(height: 15),
        const SiagaResponsiveGrid(
          minimumItemWidth: 250,
          children: [
            _ReportStatusCard(
              title: 'Menunggu verifikasi',
              explanation: 'Belum diperiksa petugas.',
              tone: SiagaTone.warning,
            ),
            _ReportStatusCard(
              title: 'Terverifikasi',
              explanation: 'Dikonfirmasi melalui proses petugas.',
              tone: SiagaTone.success,
            ),
            _ReportStatusCard(
              title: 'Ditolak',
              explanation: 'Tidak diterima sebagai laporan terverifikasi.',
              tone: SiagaTone.danger,
            ),
          ],
        ),
        const SizedBox(height: 24),
        SiagaCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SiagaBadge(
                label: 'RIWAYAT BELUM TERSEDIA DI FLUTTER',
                tone: SiagaTone.neutral,
                icon: Icons.hourglass_empty_rounded,
              ),
              const SizedBox(height: 14),
              Text(
                'Belum ada data untuk ditampilkan',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Filter jenis bencana, status, sumber, wilayah, dan tanggal tersedia di website Laravel. Filter tersebut baru akan aktif di Flutter setelah API laporan dibuat.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onOpenLogin,
                icon: const Icon(Icons.login_rounded),
                label: const Text('Masuk untuk membuat laporan'),
              ),
              const SizedBox(height: 8),
              Text(
                'Login dan pengiriman laporan di Flutter belum tersambung ke server.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReportStatusCard extends StatelessWidget {
  const _ReportStatusCard({
    required this.title,
    required this.explanation,
    required this.tone,
  });

  final String title;
  final String explanation;
  final SiagaTone tone;

  @override
  Widget build(BuildContext context) {
    return SiagaCard(
      padding: const EdgeInsets.all(19),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SiagaBadge(label: title, tone: tone),
          const SizedBox(height: 11),
          Text(explanation, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
