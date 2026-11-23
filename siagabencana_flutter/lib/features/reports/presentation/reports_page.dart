import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/network/api_config.dart';
import '../../../app/siaga_theme.dart';
import '../../../app/widgets/siaga_components.dart';
import '../../auth/data/auth_session_service.dart';
import '../data/reports_data_service.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({
    this.authService,
    this.user,
    this.isAuthLoading = false,
    this.dataService,
    this.onOpenLogin,
    super.key,
  });

  final AuthSessionService? authService;
  final AuthUser? user;
  final bool isAuthLoading;
  final ReportsDataService? dataService;
  final VoidCallback? onOpenLogin;

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
  bool _showFilters = false;

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

  int get _activeFilterCount {
    var count = 0;
    if (_disasterType.isNotEmpty) count++;
    if (_status.isNotEmpty) count++;
    if (_sourceType.isNotEmpty) count++;
    if (_province.isNotEmpty) count++;
    if (_city.isNotEmpty) count++;
    if (_district.isNotEmpty) count++;
    if (_startDate != null) count++;
    if (_endDate != null) count++;
    return count;
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
    final width = MediaQuery.sizeOf(context).width;
    final padding = SiagaBreakpoints.pageHorizontalPadding(width);
    final isLoggedIn = !widget.isAuthLoading && widget.user != null;

    return ListView(
      padding: EdgeInsets.fromLTRB(padding, 24, padding, 44),
      children: [
        SiagaPageHeader(
          eyebrow: 'PELAPORAN & VERIFIKASI',
          title: 'Laporan dan riwayat bencana',
          description:
              'Laporkan kejadian bencana di sekitar Anda dan pantau status verifikasi resmi oleh petugas.',
          icon: Icons.assignment_outlined,
          trailing: isLoggedIn
              ? FilledButton.icon(
                  onPressed: () {
                    setState(() {
                      _showCreateForm = !_showCreateForm;
                      _submitError = null;
                    });
                  },
                  icon: Icon(
                    _showCreateForm ? Icons.close_rounded : Icons.add_rounded,
                    size: 18,
                  ),
                  label: Text(
                    _showCreateForm ? 'Tutup form' : '+ Buat laporan',
                  ),
                )
              : null,
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
          SiagaNotice(
            title: 'Login diperlukan untuk menambahkan laporan',
            message:
                'Silakan login terlebih dahulu jika Anda ingin mengirimkan laporan kejadian bencana.',
            tone: SiagaTone.warning,
            icon: Icons.lock_outline_rounded,
            trailing: widget.onOpenLogin != null
                ? OutlinedButton(
                    onPressed: widget.onOpenLogin,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                    child: const Text('Masuk'),
                  )
                : null,
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
          const SizedBox(height: 24),
        ],

        // Operational KPI strip
        SiagaResponsiveGrid(
          minimumItemWidth: 200,
          spacing: 14,
          children: [
            SiagaMetricTile(
              label: 'Total laporan',
              value: '${_stats['total_reports'] ?? 0}',
              icon: Icons.assignment_outlined,
              tone: SiagaTone.info,
            ),
            SiagaMetricTile(
              label: 'Jenis bencana',
              value: '${_stats['disaster_type_count'] ?? 0}',
              icon: Icons.category_outlined,
              tone: SiagaTone.neutral,
            ),
            SiagaMetricTile(
              label: 'Wilayah terdampak',
              value: '${_stats['affected_area_count'] ?? 0}',
              icon: Icons.location_on_outlined,
              tone: SiagaTone.info,
            ),
            SiagaMetricTile(
              label: 'Menunggu verifikasi',
              value: '${_stats['pending_reports'] ?? 0}',
              icon: Icons.pending_actions_rounded,
              tone: SiagaTone.warning,
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Registry Header + Filter Toggle
        SiagaSectionHeader(
          title: 'Daftar laporan bencana',
          subtitle: _loading
              ? 'Memuat daftar laporan terbaru...'
              : 'Menampilkan ${_reports.length} laporan pada halaman ${_result['current_page'] ?? 1}.',
          action: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => setState(() => _showFilters = !_showFilters),
                icon: Icon(
                  _showFilters
                      ? Icons.filter_list_off_rounded
                      : Icons.filter_list_rounded,
                  size: 18,
                ),
                label: Text(
                  _activeFilterCount > 0
                      ? 'Filter ($_activeFilterCount)'
                      : 'Filter',
                ),
              ),
              IconButton(
                tooltip: 'Muat ulang',
                onPressed: _loading ? null : () => _loadReports(),
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
        ),
        if (_showFilters) ...[
          const SizedBox(height: 14),
          _buildFilterPanel(),
        ],
        const SizedBox(height: 16),

        if (_loading)
          Column(
            children: List.generate(
              3,
              (_) => const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: SiagaCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SiagaSkeletonBox(height: 14, width: 180),
                      SizedBox(height: 10),
                      SiagaSkeletonBox(height: 18),
                      SizedBox(height: 8),
                      SiagaSkeletonBox(height: 13, width: 260),
                    ],
                  ),
                ),
              ),
            ),
          )
        else if (_error != null)
          SiagaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SiagaNotice(
                  title: 'Gagal memuat laporan',
                  message: _error!,
                  tone: SiagaTone.danger,
                  icon: Icons.cloud_off_outlined,
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: () => _loadReports(),
                  icon: const Icon(Icons.refresh_rounded, size: 17),
                  label: const Text('Coba lagi'),
                ),
              ],
            ),
          )
        else if (_reports.isEmpty)
          SiagaEmptyState(
            icon: Icons.assignment_outlined,
            title: 'Tidak ada laporan ditemukan',
            message: _activeFilterCount > 0
                ? 'Tidak ada laporan yang cocok dengan kriteria filter saat ini.'
                : 'Belum ada laporan bencana yang tercatat pada sistem.',
            action: _activeFilterCount > 0
                ? OutlinedButton(
                    onPressed: _resetFilters,
                    child: const Text('Reset filter'),
                  )
                : null,
          )
        else
          ..._reports.map(_buildReportCard),

        if (_result.isNotEmpty && !_loading && _error == null) ...[
          const SizedBox(height: 12),
          SiagaCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Halaman ${_result['current_page'] ?? 1} dari ${_result['last_page'] ?? 1}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: SiagaColors.ink,
                  ),
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
          ),
        ],
      ],
    );
  }

  void _resetFilters() {
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
  }

  Widget _buildFilterPanel() {
    return SiagaCard(
      backgroundColor: SiagaColors.surfaceSubtle,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SiagaResponsiveGrid(
            minimumItemWidth: 230,
            spacing: 12,
            children: [
              _dropdown(
                label: 'Jenis bencana',
                value: _disasterType,
                options: _listOption('disaster_types'),
                onChanged: (v) => setState(() => _disasterType = v),
              ),
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
              _dropdown(
                label: 'Provinsi',
                value: _province,
                options: _listOption('provinces'),
                onChanged: (v) => setState(() => _province = v),
              ),
              _dropdown(
                label: 'Kabupaten/kota',
                value: _city,
                options: _listOption('cities'),
                onChanged: (v) => setState(() => _city = v),
              ),
              _dropdown(
                label: 'Kecamatan',
                value: _district,
                options: _listOption('districts'),
                onChanged: (v) => setState(() => _district = v),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () => _pickDate(isStart: true),
                icon: const Icon(Icons.calendar_today_outlined, size: 16),
                label: Text(
                  _startDate == null
                      ? 'Tanggal mulai'
                      : _dateString(_startDate!),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _pickDate(isStart: false),
                icon: const Icon(Icons.event_outlined, size: 16),
                label: Text(
                  _endDate == null ? 'Tanggal akhir' : _dateString(_endDate!),
                ),
              ),
              FilledButton.icon(
                onPressed: _loading ? null : () => _loadReports(page: 1),
                icon: const Icon(Icons.search_rounded, size: 17),
                label: const Text('Terapkan filter'),
              ),
              if (_activeFilterCount > 0)
                TextButton(
                  onPressed: _loading ? null : _resetFilters,
                  child: const Text('Reset'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCreateReportCard() {
    return SiagaCard(
      padding: const EdgeInsets.all(24),
      borderColor: SiagaColors.primaryBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Buat laporan bencana',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lengkapi informasi kejadian yang Anda ketahui. Minimal satu kolom informasi wajib diisi.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Tutup form',
                onPressed: () => setState(() => _showCreateForm = false),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _FormGroupTitle(
            step: '1',
            title: 'Informasi Kejadian',
          ),
          const SizedBox(height: 12),
          SiagaResponsiveGrid(
            minimumItemWidth: 280,
            spacing: 14,
            children: [
              TextFormField(
                controller: _createDisasterTypeController,
                maxLength: 100,
                decoration: const InputDecoration(
                  labelText: 'Jenis bencana (opsional)',
                  hintText: 'Contoh: Gempa Bumi, Banjir, Longsor',
                  counterText: '',
                ),
              ),
              TextFormField(
                controller: _createOccurredAtController,
                readOnly: true,
                onTap: _pickOccurredDateTime,
                decoration: InputDecoration(
                  labelText: 'Tanggal dan waktu kejadian',
                  hintText: 'Pilih tanggal dan waktu',
                  suffixIcon: _createOccurredAt != null
                      ? IconButton(
                          tooltip: 'Hapus waktu kejadian',
                          onPressed: () {
                            setState(() {
                              _createOccurredAt = null;
                              _createOccurredAtController.clear();
                            });
                          },
                          icon: const Icon(Icons.clear_rounded, size: 18),
                        )
                      : const Icon(Icons.calendar_month_outlined, size: 19),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _FormGroupTitle(
            step: '2',
            title: 'Lokasi Wilayah Terdampak',
          ),
          const SizedBox(height: 12),
          SiagaResponsiveGrid(
            minimumItemWidth: 240,
            spacing: 14,
            children: [
              TextFormField(
                controller: _createProvinceController,
                maxLength: 120,
                decoration: const InputDecoration(
                  labelText: 'Provinsi',
                  hintText: 'Sumatera Barat',
                  counterText: '',
                ),
              ),
              TextFormField(
                controller: _createCityController,
                maxLength: 120,
                decoration: const InputDecoration(
                  labelText: 'Kota/kabupaten',
                  hintText: 'Kota Padang',
                  counterText: '',
                ),
              ),
              TextFormField(
                controller: _createDistrictController,
                maxLength: 120,
                decoration: const InputDecoration(
                  labelText: 'Kecamatan',
                  counterText: '',
                ),
              ),
              TextFormField(
                controller: _createAffectedAreaController,
                maxLength: 180,
                decoration: const InputDecoration(
                  labelText: 'Lokasi / alamat spesifik',
                  counterText: '',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _FormGroupTitle(
            step: '3',
            title: 'Deskripsi & Kronologi',
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _createDescriptionController,
            maxLines: 4,
            maxLength: 10000,
            decoration: const InputDecoration(
              labelText: 'Deskripsi kejadian (opsional)',
              hintText: 'Jelaskan kondisi di lokasi, dampak, atau kebutuhan mendesak...',
              alignLabelWithHint: true,
              counterText: '',
            ),
          ),
          if (_submitError != null) ...[
            const SizedBox(height: 16),
            SiagaNotice(
              title: 'Periksa kembali data yang dimasukkan',
              message: _submitError!,
              tone: SiagaTone.danger,
              icon: Icons.error_outline_rounded,
            ),
          ],
          const SizedBox(height: 14),
          Text(
            'Laporan baru akan berstatus "Menunggu verifikasi" hingga diperiksa oleh petugas SiagaBencana.',
            style: Theme.of(context).textTheme.bodySmall,
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
                        dimension: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 17),
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
      decoration: InputDecoration(labelText: label),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: SiagaColors.surface,
          borderRadius: BorderRadius.circular(SiagaRadius.lg),
          border: Border.all(color: SiagaColors.border),
          boxShadow: SiagaShadows.subtle,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(SiagaRadius.lg - 1),
          child: Container(
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: tone.accent, width: 3.5)),
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SiagaBadge(
                          label: _text(
                            report['disaster_type'],
                            fallback: 'Kejadian Bencana',
                          ),
                          tone: SiagaTone.info,
                          compact: true,
                        ),
                        SiagaStatusDot(label: statusLabel, tone: tone),
                      ],
                    ),
                    Text(
                      _date(report['occurred_at']),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _text(report['description'], fallback: 'Tanpa deskripsi'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 18,
                  runSpacing: 8,
                  children: [
                    _metaItem(
                      Icons.location_on_outlined,
                      location.isEmpty ? 'Lokasi tidak tersedia' : location,
                    ),
                    _metaItem(
                      Icons.source_outlined,
                      'Sumber: ${_text(report['source_name'])}',
                    ),
                    if (submitter is Map)
                      _metaItem(
                        Icons.person_outline_rounded,
                        'Pelapor: ${_text(submitter['name'])}',
                      ),
                    if (verifier is Map)
                      _metaItem(
                        Icons.verified_user_outlined,
                        'Verifikator: ${_text(verifier['name'])}',
                      ),
                    if (report['verified_at'] != null)
                      _metaItem(
                        Icons.fact_check_outlined,
                        'Diverifikasi: ${_date(report['verified_at'])}',
                      ),
                  ],
                ),
                if (report['source_url'] != null &&
                    report['source_url'].toString().trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SelectableText(
                    'URL sumber: ${report['source_url']}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: SiagaColors.primaryBlue,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _metaItem(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: SiagaColors.muted),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12.5,
              color: SiagaColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _FormGroupTitle extends StatelessWidget {
  const _FormGroupTitle({required this.step, required this.title});

  final String step;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: SiagaColors.primarySoft,
            borderRadius: BorderRadius.circular(SiagaRadius.sm),
            border: Border.all(color: SiagaColors.primaryBorder),
          ),
          alignment: Alignment.center,
          child: Text(
            step,
            style: const TextStyle(
              color: SiagaColors.navy,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: SiagaColors.navy,
          ),
        ),
      ],
    );
  }
}
