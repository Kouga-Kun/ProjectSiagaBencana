import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/navigation/app_section.dart';
import '../../../app/network/api_config.dart';
import '../../../app/siaga_theme.dart';
import '../../../app/widgets/siaga_components.dart';
import '../../auth/data/auth_session_service.dart';
import '../data/sos_data_service.dart';
import '../data/sos_location_service.dart';

class SosPage extends StatefulWidget {
  const SosPage({
    required this.user,
    required this.authService,
    required this.onBack,
    required this.onOpenSection,
    this.sosDataService,
    this.locationFetcher = fetchCurrentDeviceLocation,
    super.key,
  });

  final AuthUser? user;
  final AuthSessionService? authService;
  final VoidCallback onBack;
  final ValueChanged<AppSection> onOpenSection;
  final SosDataService? sosDataService;
  final SosLocationFetcher locationFetcher;

  @override
  State<SosPage> createState() => _SosPageState();
}

class _SosPageState extends State<SosPage> {
  static const LatLng _padangCenter = LatLng(-0.9471, 100.4172);

  late final SosDataService _service;
  bool _ownsService = false;

  final _manualFormKey = GlobalKey<FormState>();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _addressController = TextEditingController();
  final MapController _mapController = MapController();

  double? _latitude;
  double? _longitude;
  double? _accuracyMeters;
  bool _isLocating = false;
  String? _locationError;
  bool _showManualInput = false;

  bool _isSubmitting = false;
  String? _submitSuccessMessage;
  String? _submitErrorMessage;

  List<SosRequestItem> _history = const [];
  bool _isLoadingHistory = false;
  String? _historyError;

  @override
  void initState() {
    super.initState();
    _ownsService = widget.sosDataService == null;
    _service =
        widget.sosDataService ??
        SosDataService(
          apiConfig:
              widget.authService?.apiConfig ??
              const ApiConfig.fromEnvironment(),
          authService: widget.authService,
        );

    _addressController.text = widget.user?.address ?? '';

    if (widget.user != null) {
      unawaited(_detectLocation());
      unawaited(_loadHistory());
    }
  }

  @override
  void dispose() {
    if (_ownsService) {
      _service.close();
    }
    _latController.dispose();
    _lngController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _detectLocation() async {
    if (_isLocating) return;

    setState(() {
      _isLocating = true;
      _locationError = null;
    });

    try {
      final coords = await widget.locationFetcher();
      if (!mounted) return;

      setState(() {
        _latitude = coords.latitude;
        _longitude = coords.longitude;
        _accuracyMeters = coords.accuracyMeters;
        _latController.text = coords.latitude.toStringAsFixed(6);
        _lngController.text = coords.longitude.toStringAsFixed(6);
        _isLocating = false;
        _locationError = null;
      });
      _moveMapSafely(LatLng(coords.latitude, coords.longitude));
    } on SosLocationException catch (error) {
      if (!mounted) return;
      setState(() {
        _isLocating = false;
        _locationError = error.message;
        _showManualInput = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLocating = false;
        _locationError =
            'Lokasi tidak berhasil diperoleh dari perangkat. Silakan masukkan koordinat lokasi secara manual.';
        _showManualInput = true;
      });
    }
  }

  void _moveMapSafely(LatLng target) {
    try {
      _mapController.move(target, 15);
    } catch (_) {
      // Peta belum siap pada ukuran layar saat ini.
    }
  }

  Future<void> _loadHistory() async {
    if (widget.user == null) return;

    setState(() {
      _isLoadingHistory = true;
      _historyError = null;
    });

    try {
      final items = await _service.fetchUserHistory();
      if (!mounted) return;
      setState(() {
        _history = items;
        _isLoadingHistory = false;
      });
    } on SosDataException catch (error) {
      if (!mounted) return;
      setState(() {
        _historyError = error.message;
        _isLoadingHistory = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _historyError = 'Riwayat permintaan SOS belum dapat dimuat.';
        _isLoadingHistory = false;
      });
    }
  }

  bool _syncManualCoordinates() {
    if (_showManualInput) {
      if (!(_manualFormKey.currentState?.validate() ?? false)) {
        return false;
      }
      final parsedLat = double.tryParse(
        _latController.text.trim().replaceAll(',', '.'),
      );
      final parsedLng = double.tryParse(
        _lngController.text.trim().replaceAll(',', '.'),
      );
      if (parsedLat == null || parsedLng == null) return false;
      setState(() {
        _latitude = parsedLat;
        _longitude = parsedLng;
      });
      return true;
    }

    if (_latitude != null && _longitude != null) return true;

    final parsedLat = double.tryParse(
      _latController.text.trim().replaceAll(',', '.'),
    );
    final parsedLng = double.tryParse(
      _lngController.text.trim().replaceAll(',', '.'),
    );
    if (parsedLat != null &&
        parsedLng != null &&
        parsedLat >= -90 &&
        parsedLat <= 90 &&
        parsedLng >= -180 &&
        parsedLng <= 180) {
      setState(() {
        _latitude = parsedLat;
        _longitude = parsedLng;
      });
      return true;
    }

    setState(() {
      _showManualInput = true;
      _submitErrorMessage =
          'Lokasi pengguna belum tersedia. Ambil lokasi GPS atau isi koordinat lokasi secara manual terlebih dahulu.';
    });
    return false;
  }

  Future<void> _onSosButtonPressed() async {
    FocusScope.of(context).unfocus();
    final user = widget.user;
    if (user == null || _isSubmitting) return;

    setState(() {
      _submitErrorMessage = null;
      _submitSuccessMessage = null;
    });

    if (!_syncManualCoordinates()) return;

    final lat = _latitude!;
    final lng = _longitude!;
    final effectiveAddress = _addressController.text.trim().isNotEmpty
        ? _addressController.text.trim()
        : (user.address ?? 'Menggunakan titik koordinat lokasi');

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: SiagaColors.danger,
                size: 24,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Konfirmasi Permintaan SOS',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pastikan data pemohon dan titik koordinat di bawah sudah sesuai sebelum mengirimkan sinyal darurat:',
                  style: TextStyle(
                    color: SiagaColors.textSecondary,
                    height: 1.5,
                    fontSize: 13.8,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: SiagaColors.dangerSoft,
                    borderRadius: BorderRadius.circular(SiagaRadius.md),
                    border: Border.all(color: SiagaColors.dangerBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DialogDetailRow(label: 'Nama', value: user.name),
                      const SizedBox(height: 6),
                      _DialogDetailRow(
                        label: 'Telepon',
                        value: (user.phone != null && user.phone!.isNotEmpty)
                            ? user.phone!
                            : 'Belum diatur pada profil',
                      ),
                      const SizedBox(height: 6),
                      _DialogDetailRow(
                        label: 'Koordinat',
                        value:
                            '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}',
                      ),
                      const SizedBox(height: 6),
                      _DialogDetailRow(label: 'Lokasi', value: effectiveAddress),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton.icon(
              key: const Key('confirm_send_sos_button'),
              style: FilledButton.styleFrom(
                backgroundColor: SiagaColors.danger,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              icon: const Icon(Icons.sos_rounded, size: 18),
              label: const Text('Ya, Kirim SOS'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    await _sendSosRequest(
      latitude: lat,
      longitude: lng,
      address: _addressController.text.trim(),
    );
  }

  Future<void> _sendSosRequest({
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    setState(() {
      _isSubmitting = true;
      _submitErrorMessage = null;
      _submitSuccessMessage = null;
    });

    try {
      final result = await _service.submitSosRequest(
        latitude: latitude,
        longitude: longitude,
        address: address.isEmpty ? null : address,
      );
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _submitSuccessMessage = result.message;
        _history = [result.item, ..._history];
      });
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            backgroundColor: SiagaColors.safe,
            content: Text(result.message),
          ),
        );
    } on SosDataException catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _submitErrorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _submitErrorMessage =
            'Permintaan SOS belum berhasil dikirim. Periksa koneksi dan coba lagi.';
      });
    }
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) return 'Waktu tidak tersedia';
    final local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = SiagaBreakpoints.pageHorizontalPadding(width);
    final user = widget.user;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        24,
        horizontalPadding,
        44,
      ),
      children: [
        const SiagaPageHeader(
          eyebrow: 'BANTUAN DARURAT',
          title: 'Bantuan Darurat SOS',
          description:
              'Kirimkan sinyal permintaan bantuan darurat beserta koordinat GPS Anda dan pantau status penanganannya oleh petugas.',
          icon: Icons.sos_rounded,
        ),
        const SizedBox(height: 22),
        if (user == null)
          SiagaEmptyState(
            icon: Icons.sos_rounded,
            title: 'Login diperlukan untuk mengirim permintaan SOS',
            message:
                'Identitas pemohon serta riwayat permintaan bantuan darurat diambil langsung dari akun yang sedang login.',
            action: Wrap(
              spacing: 10,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: () => widget.onOpenSection(AppSection.login),
                  icon: const Icon(Icons.login_rounded, size: 17),
                  label: const Text('Login'),
                ),
                OutlinedButton.icon(
                  onPressed: () =>
                      widget.onOpenSection(AppSection.registration),
                  icon: const Icon(Icons.person_add_alt_1_outlined, size: 17),
                  label: const Text('Daftar akun'),
                ),
              ],
            ),
          )
        else ...[
          if (_submitSuccessMessage != null) ...[
            SiagaNotice(
              title: 'Permintaan SOS Tersimpan',
              message: _submitSuccessMessage!,
              tone: SiagaTone.success,
              icon: Icons.check_circle_outline_rounded,
            ),
            const SizedBox(height: 16),
          ],
          if (_submitErrorMessage != null) ...[
            SiagaNotice(
              title: 'Permintaan SOS Gagal Dikirim',
              message: _submitErrorMessage!,
              tone: SiagaTone.danger,
              icon: Icons.error_outline_rounded,
            ),
            const SizedBox(height: 16),
          ],
          LayoutBuilder(
            builder: (context, constraints) {
              final sosActionCard = _buildSosActionCard(user);
              final locationCard = _buildLocationCard();

              if (constraints.maxWidth < 920) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    sosActionCard,
                    const SizedBox(height: 18),
                    locationCard,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: sosActionCard),
                  const SizedBox(width: 20),
                  Expanded(flex: 6, child: locationCard),
                ],
              );
            },
          ),
          const SizedBox(height: 30),
          _buildHistorySection(),
        ],
      ],
    );
  }

  Widget _buildSosActionCard(AuthUser user) {
    final hasCoordinates = _latitude != null && _longitude != null;

    return SiagaCard(
      borderColor: SiagaColors.dangerBorder,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SiagaBadge(
            label: 'SINYAL DARURAT SIAGABENCANA',
            tone: SiagaTone.danger,
            icon: Icons.emergency_share_outlined,
            compact: true,
          ),
          const SizedBox(height: 14),
          Text(
            'Kirim Sinyal Bantuan SOS',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'Tekan tombol darurat untuk mengirimkan permintaan bantuan menggunakan identitas akun dan koordinat lokasi Anda.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 26),
          Semantics(
            button: true,
            label: 'Tombol Bantuan Darurat SOS',
            child: InkWell(
              key: const Key('main_sos_button'),
              onTap: _isSubmitting ? null : _onSosButtonPressed,
              customBorder: const CircleBorder(),
              child: Container(
                width: 180,
                height: 180,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: SiagaColors.dangerSoft,
                  border: Border.all(
                    color: SiagaColors.dangerBorder,
                    width: 2.5,
                  ),
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: SiagaColors.danger,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isSubmitting)
                        const SizedBox.square(
                          dimension: 34,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      else
                        const Icon(
                          Icons.sos_rounded,
                          color: Colors.white,
                          size: 56,
                        ),
                      const SizedBox(height: 4),
                      Text(
                        _isSubmitting ? 'MENGIRIM...' : 'TEKAN SOS',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: SiagaColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(SiagaRadius.md),
              border: Border.all(color: SiagaColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DATA PEMOHON',
                  style: TextStyle(
                    color: SiagaColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.7,
                  ),
                ),
                const SizedBox(height: 10),
                _IdentityRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Nama',
                  value: user.name,
                ),
                const SizedBox(height: 7),
                _IdentityRow(
                  icon: Icons.phone_outlined,
                  label: 'Telepon',
                  value: (user.phone != null && user.phone!.trim().isNotEmpty)
                      ? user.phone!
                      : 'Belum diatur pada profil',
                ),
                const SizedBox(height: 7),
                _IdentityRow(
                  icon: Icons.my_location_rounded,
                  label: 'Koordinat',
                  value: hasCoordinates
                      ? '${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}'
                      : 'Belum tersedia',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    final hasCoordinates = _latitude != null && _longitude != null;
    final currentPoint = hasCoordinates
        ? LatLng(_latitude!, _longitude!)
        : _padangCenter;

    return SiagaCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SiagaIconTile(
                icon: Icons.location_on_outlined,
                color: SiagaColors.danger,
                backgroundColor: SiagaColors.dangerSoft,
                size: 40,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lokasi Permintaan SOS',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      'Gunakan GPS perangkat, ketuk peta, atau masukkan koordinat manual.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_isLocating) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: 8),
            const Text(
              'Mengambil titik koordinat GPS perangkat...',
              style: TextStyle(color: SiagaColors.muted, fontSize: 12.5),
            ),
            const SizedBox(height: 12),
          ],
          if (_locationError != null) ...[
            SiagaNotice(
              title: 'Lokasi GPS belum diperoleh',
              message: _locationError!,
              tone: SiagaTone.warning,
              icon: Icons.location_off_outlined,
            ),
            const SizedBox(height: 12),
          ],
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: hasCoordinates
                  ? SiagaColors.safeSoft
                  : SiagaColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(SiagaRadius.md),
              border: Border.all(
                color: hasCoordinates
                    ? SiagaColors.safeBorder
                    : SiagaColors.border,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SiagaStatusDot(
                  label: hasCoordinates
                      ? 'Koordinat lokasi siap dikirim'
                      : 'Koordinat lokasi belum ditentukan',
                  tone: hasCoordinates ? SiagaTone.success : SiagaTone.neutral,
                ),
                const SizedBox(height: 6),
                SelectableText(
                  hasCoordinates
                      ? 'Lat: ${_latitude!.toStringAsFixed(6)} · Lng: ${_longitude!.toStringAsFixed(6)}'
                      : 'Lat: - · Lng: -',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: SiagaColors.ink,
                    fontSize: 13.5,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                if (_accuracyMeters != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    'Estimasi akurasi: ±${_accuracyMeters!.toStringAsFixed(0)} m',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                key: const Key('detect_gps_button'),
                onPressed: _isLocating ? null : _detectLocation,
                icon: const Icon(Icons.my_location_rounded, size: 17),
                label: Text(
                  _isLocating ? 'Mengambil GPS...' : 'Ambil Lokasi GPS',
                ),
              ),
              TextButton.icon(
                key: const Key('toggle_manual_location_button'),
                onPressed: () {
                  setState(() {
                    _showManualInput = !_showManualInput;
                    if (_showManualInput && _latitude != null) {
                      _latController.text = _latitude!.toStringAsFixed(6);
                      _lngController.text = _longitude!.toStringAsFixed(6);
                    }
                  });
                },
                icon: Icon(
                  _showManualInput
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.edit_location_alt_outlined,
                  size: 17,
                ),
                label: Text(
                  _showManualInput
                      ? 'Sembunyikan Input Manual'
                      : 'Masukkan Lokasi Manual',
                ),
              ),
            ],
          ),
          if (_showManualInput) ...[
            const SizedBox(height: 12),
            Form(
              key: _manualFormKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      key: const Key('sos_latitude_field'),
                      controller: _latController,
                      keyboardType: const TextInputType.numberWithOptions(
                        signed: true,
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                        hintText: '-0.947100',
                      ),
                      onChanged: (value) {
                        final parsed = double.tryParse(
                          value.trim().replaceAll(',', '.'),
                        );
                        if (parsed != null && parsed >= -90 && parsed <= 90) {
                          setState(() => _latitude = parsed);
                        }
                      },
                      validator: (value) {
                        final raw = value?.trim().replaceAll(',', '.') ?? '';
                        if (raw.isEmpty) return 'Wajib diisi.';
                        final parsed = double.tryParse(raw);
                        if (parsed == null || parsed < -90 || parsed > 90) {
                          return 'Rentang -90 s/d 90.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      key: const Key('sos_longitude_field'),
                      controller: _lngController,
                      keyboardType: const TextInputType.numberWithOptions(
                        signed: true,
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        hintText: '100.417200',
                      ),
                      onChanged: (value) {
                        final parsed = double.tryParse(
                          value.trim().replaceAll(',', '.'),
                        );
                        if (parsed != null && parsed >= -180 && parsed <= 180) {
                          setState(() => _longitude = parsed);
                        }
                      },
                      validator: (value) {
                        final raw = value?.trim().replaceAll(',', '.') ?? '';
                        if (raw.isEmpty) return 'Wajib diisi.';
                        final parsed = double.tryParse(raw);
                        if (parsed == null || parsed < -180 || parsed > 180) {
                          return 'Rentang -180 s/d 180.';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          TextFormField(
            key: const Key('sos_address_field'),
            controller: _addressController,
            maxLines: 2,
            maxLength: 500,
            decoration: const InputDecoration(
              labelText: 'Alamat atau patokan lokasi (opsional)',
              hintText: 'Contoh: Jl. Khatib Sulaiman No. 10, Padang',
              counterText: '',
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(SiagaRadius.md),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: SiagaColors.border),
                  borderRadius: BorderRadius.circular(SiagaRadius.md),
                ),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: currentPoint,
                    initialZoom: 14,
                    onTap: (_, latLng) {
                      setState(() {
                        _latitude = latLng.latitude;
                        _longitude = latLng.longitude;
                        _latController.text = latLng.latitude.toStringAsFixed(
                          6,
                        );
                        _lngController.text = latLng.longitude.toStringAsFixed(
                          6,
                        );
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.siagabencana_flutter',
                    ),
                    if (hasCoordinates)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: currentPoint,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_on_rounded,
                              color: SiagaColors.danger,
                              size: 38,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Ketuk area pada peta untuk menetapkan koordinat secara langsung.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SiagaSectionHeader(
          title: 'Riwayat Permintaan SOS Saya',
          subtitle:
              'Pantau waktu pengiriman dan status penanganan oleh petugas (Menunggu, Diproses, Selesai).',
          action: OutlinedButton.icon(
            onPressed: _isLoadingHistory ? null : _loadHistory,
            icon: const Icon(Icons.refresh_rounded, size: 17),
            label: const Text('Muat Ulang'),
          ),
        ),
        const SizedBox(height: 14),
        if (_isLoadingHistory)
          const SiagaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SiagaSkeletonBox(height: 16, width: 180),
                SizedBox(height: 10),
                SiagaSkeletonBox(height: 13, width: 260),
              ],
            ),
          )
        else if (_historyError != null)
          SiagaNotice(
            title: 'Gagal memuat riwayat SOS',
            message: _historyError!,
            tone: SiagaTone.danger,
            icon: Icons.cloud_off_outlined,
          )
        else if (_history.isEmpty)
          const SiagaEmptyState(
            icon: Icons.sos_rounded,
            title: 'Belum ada riwayat permintaan SOS',
            message:
                'Permintaan SOS yang Anda kirimkan akan tercatat di sini beserta status penanganannya.',
          )
        else
          Column(
            children: [
              for (final item in _history) ...[
                _SosHistoryCard(
                  item: item,
                  formattedTime: _formatDateTime(item.createdAt),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
      ],
    );
  }
}

class _SosHistoryCard extends StatelessWidget {
  const _SosHistoryCard({required this.item, required this.formattedTime});

  final SosRequestItem item;
  final String formattedTime;

  SiagaTone get _statusTone => switch (item.status) {
    'selesai' => SiagaTone.success,
    'diproses' => SiagaTone.warning,
    _ => SiagaTone.danger,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
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
            border: Border(
              left: BorderSide(color: _statusTone.accent, width: 3.5),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Permintaan SOS #${item.id}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SiagaBadge(
                    label: item.statusLabel,
                    tone: _statusTone,
                    compact: true,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                runSpacing: 6,
                children: [
                  Text(
                    'Waktu: $formattedTime',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    'Koordinat: ${item.latitude.toStringAsFixed(6)}, ${item.longitude.toStringAsFixed(6)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: SiagaColors.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (item.address != null && item.address!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Lokasi: ${item.address}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: SiagaColors.textSecondary,
                  ),
                ),
              ],
              if (item.handlerName != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Ditangani oleh petugas: ${item.handlerName}',
                  style: const TextStyle(
                    color: SiagaColors.safeText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _IdentityRow extends StatelessWidget {
  const _IdentityRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: SiagaColors.muted),
        const SizedBox(width: 7),
        SizedBox(
          width: 74,
          child: Text(
            label,
            style: const TextStyle(
              color: SiagaColors.muted,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: SiagaColors.ink,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _DialogDetailRow extends StatelessWidget {
  const _DialogDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 82,
          child: Text(
            label,
            style: const TextStyle(
              color: SiagaColors.dangerText,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: SiagaColors.ink,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
