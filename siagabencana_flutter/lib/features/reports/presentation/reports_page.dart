import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/network/api_config.dart';
import '../../../app/widgets/siaga_components.dart';
import '../../auth/data/auth_session_service.dart';
import '../data/reports_data_service.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({
    this.authService,
    this.user,
    this.isAuthLoading = false,
    this.dataService,
    super.key,
  });

  final AuthSessionService? authService;
  final AuthUser? user;
  final bool isAuthLoading;
  final ReportsDataService? dataService;

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  late final ReportsDataService _service;
  bool _ownsService = false;

  Map<String, dynamic> _result = {};
  bool _loading = true;
  String? _error;
  int _page = 1;

  String _disasterType = '';
  String _status = '';
  String _sourceType = '';
  String _province = '';
  String _city = '';
  String _district = '';
  DateTime? _startDate;
  DateTime? _endDate;

  bool _showCreateForm = false;
  bool _submitting = false;
  String? _submitError;
  String? _submitSuccessMessage;

  final _createDisasterTypeController = TextEditingController();
  final _createOccurredAtController = TextEditingController();
  final _createProvinceController = TextEditingController();
  final _createCityController = TextEditingController();
  final _createDistrictController = TextEditingController();
  final _createAffectedAreaController = TextEditingController();
  final _createDescriptionController = TextEditingController();
  DateTime? _createOccurredAt;

  @override
  void initState() {
    super.initState();
    _ownsService = widget.dataService == null;
    _service =
        widget.dataService ??
        ReportsDataService(
          apiConfig: const ApiConfig.fromEnvironment(),
          authService: widget.authService,
        );
    unawaited(_loadReports());
  }

  @override
  void didUpdateWidget(covariant ReportsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.user == null && _showCreateForm) {
      _showCreateForm = false;
      _submitError = null;
    }
  }

  @override
  void dispose() {
    if (_ownsService) {
      _service.close();
    }
    _createDisasterTypeController.dispose();
    _createOccurredAtController.dispose();
    _createProvinceController.dispose();
    _createCityController.dispose();
    _createDistrictController.dispose();
    _createAffectedAreaController.dispose();
    _createDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadReports({int? page}) async {
    setState(() {
      _loading = true;
      _error = null;
      if (page != null) _page = page;
    });

    final filters = <String, String>{
      'disaster_type': _disasterType,
      'verification_status': _status,
      'source_type': _sourceType,
      'province': _province,
      'city_district': _city,
      'district': _district,
      if (_startDate != null) 'start_date': _dateString(_startDate!),
      if (_endDate != null) 'end_date': _dateString(_endDate!),
    };

    try {
      final result = await _service.loadReports(page: _page, filters: filters);

      if (!mounted) return;

      setState(() {
        _result = result;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _pickOccurredDateTime() async {
    final now = DateTime.now();
    final initial = _createOccurredAt ?? now;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (pickedTime == null || !mounted) return;

    final combined = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      _createOccurredAt = combined;
      _createOccurredAtController.text =
          '${combined.day.toString().padLeft(2, '0')}/'
          '${combined.month.toString().padLeft(2, '0')}/${combined.year} '
          '${combined.hour.toString().padLeft(2, '0')}:'
          '${combined.minute.toString().padLeft(2, '0')}';
    });
  }

  void _clearCreateForm() {
    _createDisasterTypeController.clear();
    _createOccurredAtController.clear();
    _createProvinceController.clear();
    _createCityController.clear();
    _createDistrictController.clear();
    _createAffectedAreaController.clear();
    _createDescriptionController.clear();
    _createOccurredAt = null;
  }

  Future<void> _submitReport() async {
    if (_submitting || widget.user == null || widget.isAuthLoading) {
      return;
    }

    String? nullIfEmpty(TextEditingController controller) {
      final text = controller.text.trim();
      return text.isEmpty ? null : text;
    }

    final payload = <String, dynamic>{
      'disaster_type': nullIfEmpty(_createDisasterTypeController),
      'occurred_at': _createOccurredAt?.toIso8601String(),
      'province': nullIfEmpty(_createProvinceController),
      'city_district': nullIfEmpty(_createCityController),
      'district': nullIfEmpty(_createDistrictController),
      'affected_area': nullIfEmpty(_createAffectedAreaController),
      'description': nullIfEmpty(_createDescriptionController),
    }..removeWhere((_, value) => value == null);

    if (payload.isEmpty) {
      setState(() {
        _submitError =
            'Isi minimal satu informasi kejadian sebelum menyimpan laporan.';
      });
      return;
    }

    setState(() {
      _submitting = true;
      _submitError = null;
      _submitSuccessMessage = null;
    });

    try {
      final response = await _service.createReport(data: payload);
      if (!mounted) return;

      _clearCreateForm();
      setState(() {
        _submitting = false;
        _showCreateForm = false;
        _submitSuccessMessage =
            response['message']?.toString() ??
            'Laporan berhasil dikirim dan menunggu verifikasi.';
      });

      await _loadReports(page: 1);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _submitError = error.toString();
      });
    }
  }

  String _dateString(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  String _text(dynamic value, {String fallback = '-'}) {
    if (value == null || value.toString().trim().isEmpty) {
      return fallback;
    }
    return value.toString();
  }

  String _date(dynamic value) {
    final parsed = DateTime.tryParse(value?.toString() ?? '');
    if (parsed == null) return 'Waktu kejadian tidak tersedia';
    final date = parsed.toLocal();
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> get _stats => _result['stats'] is Map
      ? Map<String, dynamic>.from(_result['stats'] as Map)
      : {};

  Map<String, dynamic> get _options => _result['options'] is Map
      ? Map<String, dynamic>.from(_result['options'] as Map)
      : {};

  List<Map<String, dynamic>> get _reports {
    final data = _result['data'];
    if (data is! List) return [];
    return data
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.sizeOf(context).width < 600 ? 18.0 : 30.0;
    final isLoggedIn = !widget.isAuthLoading && widget.user != null;

    return ListView(
      padding: EdgeInsets.fromLTRB(padding, 28, padding, 44),
      children: [
        const SiagaPageHeader(
          eyebrow: 'LAPORAN MASYARAKAT',
          title: 'Laporan dan riwayat bencana',
          description:
              'Pantau laporan kejadian, wilayah terdampak, dan status verifikasi dari server Laravel.',
          icon: Icons.assignment_outlined,
        ),
        const SizedBox(height: 18),
        if (widget.isAuthLoading) ...[
          const SiagaNotice(
            title: 'Memeriksa sesi akun',
            message: 'Sedang memastikan status login pengguna.',
            tone: SiagaTone.info,
            icon: Icons.hourglass_top_rounded,
          ),
          const SizedBox(height: 18),
        ] else if (!isLoggedIn) ...[
          const SiagaNotice(
            title: 'Login diperlukan untuk menambahkan laporan',
            message:
                'Silakan login terlebih dahulu melalui halaman Profil jika Anda ingin menambahkan laporan bencana.',
            tone: SiagaTone.warning,
            icon: Icons.lock_outline_rounded,
          ),
          const SizedBox(height: 18),
        ] else ...[
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: () {
                setState(() {
                  _showCreateForm = !_showCreateForm;
                  _submitError = null;
                });
              },
              icon: Icon(
                _showCreateForm ? Icons.close_rounded : Icons.add_rounded,
              ),
              label: Text(
                _showCreateForm ? 'Tutup form' : '+ Buat laporan',
              ),
            ),
          ),
          const SizedBox(height: 18),
        ],
        if (_submitSuccessMessage != null) ...[
          SiagaNotice(
            title: 'Laporan berhasil dikirim',
            message: _submitSuccessMessage!,
            tone: SiagaTone.success,
            icon: Icons.check_circle_outline_rounded,
          ),
          const SizedBox(height: 18),
        ],
        if (isLoggedIn && _showCreateForm) ...[
          _buildCreateReportCard(),
          const SizedBox(height: 22),
        ],
        if (_loading)
          const LinearProgressIndicator()
        else if (_error != null)
          SiagaNotice(
            title: 'Gagal memuat laporan',
            message: _error!,
            tone: SiagaTone.danger,
            icon: Icons.cloud_off_outlined,
          )
        else
          SiagaNotice(
            title: 'Data berhasil dimuat',
            message: '${_reports.length} laporan ditampilkan pada halaman ini.',
            tone: SiagaTone.success,
            icon: Icons.cloud_done_outlined,
          ),
        const SizedBox(height: 22),
        const SiagaSectionHeader(
          title: 'Ringkasan laporan',
          subtitle: 'Statistik yang dikirim oleh API Laravel.',
        ),
        const SizedBox(height: 14),
        SiagaResponsiveGrid(
          minimumItemWidth: 190,
          children: [
            _StatCard(
              title: 'Total laporan',
              value: _stats['total_reports'] ?? 0,
              icon: Icons.assignment_rounded,
            ),
            _StatCard(
              title: 'Jenis bencana',
              value: _stats['disaster_type_count'] ?? 0,
              icon: Icons.category_outlined,
            ),
            _StatCard(
              title: 'Wilayah terdampak',
              value: _stats['affected_area_count'] ?? 0,
              icon: Icons.location_on_outlined,
            ),
            _StatCard(
              title: 'Menunggu verifikasi',
              value: _stats['pending_reports'] ?? 0,
              icon: Icons.pending_actions_rounded,
            ),
          ],
        ),
        const SizedBox(height: 28),
        const SiagaSectionHeader(
          title: 'Filter laporan',
          subtitle: 'Pilih kriteria untuk mempersempit daftar laporan.',
        ),
        const SizedBox(height: 14),
        SiagaCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dropdown(
                label: 'Jenis bencana',
                value: _disasterType,
                options: _listOption('disaster_types'),
                onChanged: (v) => setState(() => _disasterType = v),
              ),
              const SizedBox(height: 14),
              _dropdown(
                label: 'Status verifikasi',
                value: _status,
                options: const {
                  'pending': 'Menunggu verifikasi',
                  'verified': 'Terverifikasi',
                  'rejected': 'Ditolak',
                },
                onChanged: (v) => setState(() => _status = v),
              ),
              const SizedBox(height: 14),
              _dropdown(
                label: 'Sumber laporan',
                value: _sourceType,
                options: const {
                  'staff': 'Petugas',
                  'official': 'Sumber resmi',
                  'community': 'Masyarakat',
                },
                onChanged: (v) => setState(() => _sourceType = v),
              ),
              const SizedBox(height: 14),
              _dropdown(
                label: 'Provinsi',
                value: _province,
                options: _listOption('provinces'),
                onChanged: (v) => setState(() => _province = v),
              ),
              const SizedBox(height: 14),
              _dropdown(
                label: 'Kabupaten/kota',
                value: _city,
                options: _listOption('cities'),
                onChanged: (v) => setState(() => _city = v),
              ),
              const SizedBox(height: 14),
              _dropdown(
                label: 'Kecamatan',
                value: _district,
                options: _listOption('districts'),
                onChanged: (v) => setState(() => _district = v),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _pickDate(isStart: true),
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: Text(
                      _startDate == null
                          ? 'Tanggal mulai'
                          : _dateString(_startDate!),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _pickDate(isStart: false),
                    icon: const Icon(Icons.event_outlined),
                    label: Text(
                      _endDate == null
                          ? 'Tanggal akhir'
                          : _dateString(_endDate!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
                    onPressed: _loading ? null : () => _loadReports(page: 1),
                    icon: const Icon(Icons.search_rounded),
                    label: const Text('Terapkan filter'),
                  ),
                  OutlinedButton(
                    onPressed: _loading
                        ? null
                        : () {
                            setState(() {
                              _disasterType = '';
                              _status = '';
                              _sourceType = '';
                              _province = '';
                              _city = '';
                              _district = '';
                              _startDate = null;
                              _endDate = null;
                            });
                            unawaited(_loadReports(page: 1));
                          },
                    child: const Text('Reset'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        SiagaSectionHeader(
          title: 'Daftar laporan bencana',
          subtitle: 'Laporan terbaru dari database.',
          action: IconButton(
            tooltip: 'Muat ulang',
            onPressed: _loading ? null : () => _loadReports(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ),
        const SizedBox(height: 14),
        if (_error != null)
          SiagaCard(
            child: FilledButton.icon(
              onPressed: () => _loadReports(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba lagi'),
            ),
          )
        else if (!_loading && _reports.isEmpty)
          const SiagaCard(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text('Tidak ada laporan yang cocok dengan filter.'),
              ),
            ),
          )
        else
          ..._reports.map(_buildReportCard),
        if (_result.isNotEmpty) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Halaman ${_result['current_page'] ?? 1} '
                'dari ${_result['last_page'] ?? 1}',
              ),
              Row(
                children: [
                  IconButton(
                    tooltip: 'Halaman sebelumnya',
                    onPressed: _loading || _page <= 1
                        ? null
                        : () => _loadReports(page: _page - 1),
                    icon: const Icon(Icons.chevron_left_rounded),
                  ),
                  IconButton(
                    tooltip: 'Halaman berikutnya',
                    onPressed:
                        _loading ||
                            _page >=
                                ((_result['last_page'] as num?)?.toInt() ?? 1)
                        ? null
                        : () => _loadReports(page: _page + 1),
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                ],
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildCreateReportCard() {
    return SiagaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Buat laporan bencana',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Isi informasi yang kamu ketahui. Semua bagian boleh dikosongkan '
            'kecuali minimal satu informasi kejadian.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: _createDisasterTypeController,
            maxLength: 100,
            decoration: const InputDecoration(
              labelText: 'Jenis bencana (opsional)',
              border: OutlineInputBorder(),
              counterText: '',
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _createOccurredAtController,
            readOnly: true,
            onTap: _pickOccurredDateTime,
            decoration: InputDecoration(
              labelText: 'Tanggal dan waktu kejadian',
              border: const OutlineInputBorder(),
              suffixIcon: _createOccurredAt != null
                  ? IconButton(
                      tooltip: 'Hapus waktu kejadian',
                      onPressed: () {
                        setState(() {
                          _createOccurredAt = null;
                          _createOccurredAtController.clear();
                        });
                      },
                      icon: const Icon(Icons.clear_rounded),
                    )
                  : const Icon(Icons.calendar_month_outlined),
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _createProvinceController,
            maxLength: 120,
            decoration: const InputDecoration(
              labelText: 'Provinsi',
              border: OutlineInputBorder(),
              counterText: '',
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _createCityController,
            maxLength: 120,
            decoration: const InputDecoration(
              labelText: 'Kota/kabupaten',
              border: OutlineInputBorder(),
              counterText: '',
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _createDistrictController,
            maxLength: 120,
            decoration: const InputDecoration(
              labelText: 'Kecamatan',
              border: OutlineInputBorder(),
              counterText: '',
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _createAffectedAreaController,
            maxLength: 180,
            decoration: const InputDecoration(
              labelText: 'Lokasi/wilayah terdampak',
              border: OutlineInputBorder(),
              counterText: '',
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _createDescriptionController,
            maxLines: 4,
            maxLength: 10000,
            decoration: const InputDecoration(
              labelText: 'Deskripsi kejadian (opsional)',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
              counterText: '',
            ),
          ),
          if (_submitError != null) ...[
            const SizedBox(height: 14),
            SiagaNotice(
              title: 'Periksa kembali data yang dimasukkan.',
              message: _submitError!,
              tone: SiagaTone.danger,
              icon: Icons.error_outline_rounded,
            ),
          ],
          const SizedBox(height: 14),
          Text(
            'Laporan baru dan laporan yang diubah akan berstatus menunggu verifikasi.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: _submitting ? null : _submitReport,
                icon: _submitting
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_submitting ? 'Menyimpan...' : 'Simpan laporan'),
              ),
              OutlinedButton(
                onPressed: _submitting
                    ? null
                    : () {
                        setState(() {
                          _showCreateForm = false;
                          _submitError = null;
                        });
                      },
                child: const Text('Batal'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Map<String, String> _listOption(String key) {
    final values = _options[key];
    if (values is! List) return {};
    return {
      for (final value in values)
        if (value != null && value.toString().trim().isNotEmpty)
          value.toString(): value.toString(),
    };
  }

  Widget _dropdown({
    required String label,
    required String value,
    required Map<String, String> options,
    required ValueChanged<String> onChanged,
  }) {
    final entries = <DropdownMenuItem<String>>[
      const DropdownMenuItem(value: '', child: Text('Semua')),
      ...options.entries.map(
        (entry) => DropdownMenuItem(value: entry.key, child: Text(entry.value)),
      ),
    ];

    final safeValue = value.isNotEmpty && options.containsKey(value)
        ? value
        : '';

    return DropdownButtonFormField<String>(
      initialValue: safeValue,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: entries,
      onChanged: (next) {
        if (next != null) onChanged(next);
      },
    );
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked == null || !mounted) return;

    setState(() {
      if (isStart) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    final location = [
      report['affected_area'],
      report['district'],
      report['city_district'],
      report['province'],
    ].where((v) => v != null && v.toString().trim().isNotEmpty).join(', ');

    final status = _text(report['verification_status'], fallback: 'unknown');

    final statusLabel = switch (status) {
      'verified' => 'Terverifikasi',
      'rejected' => 'Ditolak',
      'pending' => 'Menunggu verifikasi',
      _ => status,
    };

    final tone = switch (status) {
      'verified' => SiagaTone.success,
      'rejected' => SiagaTone.danger,
      'pending' => SiagaTone.warning,
      _ => SiagaTone.neutral,
    };

    final submitter = report['submitter'];
    final verifier = report['verifier'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SiagaCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                SiagaBadge(
                  label: _text(
                    report['disaster_type'],
                    fallback: 'Jenis bencana tidak tersedia',
                  ),
                  tone: SiagaTone.info,
                ),
                SiagaBadge(label: statusLabel, tone: tone),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _text(report['description'], fallback: 'Tanpa deskripsi'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            _detailRow(
              Icons.location_on_outlined,
              location.isEmpty ? 'Lokasi tidak tersedia' : location,
            ),
            const SizedBox(height: 7),
            _detailRow(
              Icons.calendar_month_outlined,
              _date(report['occurred_at']),
            ),
            const SizedBox(height: 7),
            _detailRow(
              Icons.source_outlined,
              'Sumber: ${_text(report['source_name'])}',
            ),
            if (submitter is Map) ...[
              const SizedBox(height: 7),
              _detailRow(
                Icons.person_outline_rounded,
                'Pelapor: ${_text(submitter['name'])}',
              ),
            ],
            if (verifier is Map) ...[
              const SizedBox(height: 7),
              _detailRow(
                Icons.verified_user_outlined,
                'Diverifikasi oleh: ${_text(verifier['name'])}',
              ),
            ],
            if (report['verified_at'] != null) ...[
              const SizedBox(height: 7),
              _detailRow(
                Icons.fact_check_outlined,
                'Waktu verifikasi: ${_date(report['verified_at'])}',
              ),
            ],
            if (report['source_url'] != null &&
                report['source_url'].toString().trim().isNotEmpty) ...[
              const SizedBox(height: 7),
              SelectableText('URL sumber: ${report['source_url']}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.blueGrey),
        const SizedBox(width: 8),
        Expanded(child: Text(value)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final dynamic value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SiagaCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text('$value', style: Theme.of(context).textTheme.headlineMedium),
        ],
      ),
    );
  }
}
