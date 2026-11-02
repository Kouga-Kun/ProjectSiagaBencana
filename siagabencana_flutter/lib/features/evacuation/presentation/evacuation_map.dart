import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/siaga_theme.dart';
import '../../../app/widgets/siaga_components.dart';
import '../data/evacuation_location_service.dart';
import '../data/evacuation_map_data.dart';
import '../data/evacuation_search_service.dart';

enum EvacuationMapStyle {
  street(
    label: 'Peta Jalan',
    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    attribution: '© OpenStreetMap contributors',
  ),
  voyager(
    label: 'Detail Kota',
    urlTemplate:
        'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
    attribution: '© OpenStreetMap contributors, © CARTO',
  ),
  satellite(
    label: 'Satelit',
    urlTemplate:
        'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
    attribution: 'Tiles © Esri',
  );

  const EvacuationMapStyle({
    required this.label,
    required this.urlTemplate,
    required this.attribution,
  });

  final String label;
  final String urlTemplate;
  final String attribution;
}

class EvacuationMapPanel extends StatefulWidget {
  const EvacuationMapPanel({
    this.searchService,
    this.locationFetcher = fetchEvacuationUserLocation,
    super.key,
  });

  final EvacuationSearchService? searchService;
  final EvacuationLocationFetcher locationFetcher;

  @override
  State<EvacuationMapPanel> createState() => _EvacuationMapPanelState();
}

class _EvacuationMapPanelState extends State<EvacuationMapPanel> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  late final EvacuationSearchService _searchService;
  bool _ownsSearchService = false;

  EvacuationMapStyle _mapStyle = EvacuationMapStyle.street;
  bool _showZones = true;
  bool _showRoutes = true;

  EvacuationMapSelection? _selection;
  EvacuationLocationAssessment? _locationAssessment;
  LatLng? _userPosition;
  LatLng? _searchedPosition;
  String? _searchedLabel;

  bool _isSearching = false;
  String? _searchError;
  List<EvacuationSearchResult> _searchResults = const [];
  bool _hasSearched = false;

  bool _isLocatingUser = false;
  String? _locationError;

  bool _mapReady = false;
  bool _hasSuccessfulTile = false;
  bool _hasTileError = false;
  int _tileLayerRevision = 0;

  @override
  void initState() {
    super.initState();
    _ownsSearchService = widget.searchService == null;
    _searchService = widget.searchService ?? EvacuationSearchService();
  }

  @override
  void dispose() {
    if (_ownsSearchService) {
      _searchService.close();
    }
    _searchController.dispose();
    super.dispose();
  }

  void _recordTileResult(int revision, bool succeeded) {
    if (!mounted || revision != _tileLayerRevision) {
      return;
    }
    if ((succeeded && _hasSuccessfulTile) || (!succeeded && _hasTileError)) {
      return;
    }
    setState(() {
      if (succeeded) {
        _hasSuccessfulTile = true;
      } else {
        _hasTileError = true;
      }
    });
  }

  void _retryTiles() {
    setState(() {
      _tileLayerRevision++;
      _hasSuccessfulTile = false;
      _hasTileError = false;
    });
  }

  void _selectMapStyle(EvacuationMapStyle style) {
    if (_mapStyle == style) return;
    setState(() {
      _mapStyle = style;
      _tileLayerRevision++;
      _hasSuccessfulTile = false;
      _hasTileError = false;
    });
  }

  void _moveCamera(LatLng target, double zoom) {
    if (!_mapReady) return;
    try {
      _mapController.move(target, zoom);
    } catch (_) {
      // Abaikan bila kamera belum siap pada lingkungan pengujian.
    }
  }

  void _handleMapTap(TapPosition tapPosition, LatLng position) {
    final tappedSelection = EvacuationMapData.selectionAt(position);
    final assessment = EvacuationMapData.evaluateCoordinate(
      position,
      locationLabel: tappedSelection?.title ?? 'Titik pada Peta',
    );

    setState(() {
      _selection = tappedSelection ?? assessment.selection;
      _locationAssessment = assessment;
      _locationError = null;
    });
  }

  void _selectEvacuationPoint(EvacuationMapPoint point) {
    final selection = EvacuationMapData.selectionForPoint(point);
    final assessment = EvacuationMapData.evaluateCoordinate(
      point.position,
      locationLabel: point.name,
    );

    setState(() {
      _selection = selection;
      _locationAssessment = assessment;
      _locationError = null;
      _searchResults = const [];
      _hasSearched = false;
    });
    _moveCamera(point.position, 15.0);
  }

  Future<void> _submitSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = const [];
        _searchError = null;
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchError = null;
      _hasSearched = true;
    });

    try {
      final results = await _searchService.searchLocations(query);
      if (!mounted) return;
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } on EvacuationSearchException catch (error) {
      if (!mounted) return;
      setState(() {
        _searchResults = const [];
        _searchError = error.message;
        _isSearching = false;
      });
    }
  }

  void _selectSearchResult(EvacuationSearchResult result) {
    final assessment = EvacuationMapData.evaluateCoordinate(
      result.position,
      locationLabel: result.title,
    );

    setState(() {
      _searchedPosition = result.position;
      _searchedLabel = result.title;
      _locationAssessment = assessment;
      _selection = assessment.selection;
      _searchResults = const [];
      _hasSearched = false;
      _searchError = null;
      _locationError = null;
    });

    _moveCamera(result.position, 15.5);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults = const [];
      _searchError = null;
      _hasSearched = false;
      _searchedPosition = null;
      _searchedLabel = null;
    });
  }

  Future<void> _locateUser() async {
    if (_isLocatingUser) return;

    setState(() {
      _isLocatingUser = true;
      _locationError = null;
    });

    try {
      final coords = await widget.locationFetcher();
      if (!mounted) return;

      final position = LatLng(coords.latitude, coords.longitude);
      final assessment = EvacuationMapData.evaluateCoordinate(
        position,
        locationLabel: 'Lokasi Anda',
        isUserLocation: true,
      );

      setState(() {
        _userPosition = position;
        _locationAssessment = assessment;
        _selection = assessment.selection;
        _isLocatingUser = false;
        _locationError = null;
      });

      _moveCamera(position, 15.5);
    } on EvacuationLocationException catch (error) {
      if (!mounted) return;
      setState(() {
        _isLocatingUser = false;
        _locationError = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLocatingUser = false;
        _locationError =
            'Lokasi perangkat belum dapat diambil. Pastikan izin lokasi pada browser telah diaktifkan.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SiagaCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Peta Evakuasi Interaktif Kota Padang',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(color: SiagaColors.navy),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Cari alamat atau jalan, lacak posisi Anda, dan kenali zona risiko serta titik evakuasi terdekat.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      FilledButton.tonalIcon(
                        onPressed: _isLocatingUser ? null : _locateUser,
                        icon: _isLocatingUser
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.my_location_rounded, size: 18),
                        label: Text(
                          _isLocatingUser ? 'Melacak...' : 'Lokasi Saya',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSearchBar(context),
                  if (_isSearching ||
                      _searchError != null ||
                      _searchResults.isNotEmpty ||
                      _hasSearched) ...[
                    const SizedBox(height: 10),
                    _buildSearchResultsPanel(),
                  ],
                  const SizedBox(height: 12),
                  _buildStyleAndLayerToolbar(),
                  if (_locationError != null) ...[
                    const SizedBox(height: 12),
                    SiagaNotice(
                      title: 'Lacak Lokasi Pengguna',
                      message: _locationError!,
                      tone: SiagaTone.danger,
                      icon: Icons.location_disabled_rounded,
                    ),
                  ],
                  if (_locationAssessment != null) ...[
                    const SizedBox(height: 12),
                    _ZoneStatusBanner(assessment: _locationAssessment!),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: SizedBox(
                height: 490,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFCBD5E1),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _buildMap(),
                  ),
                ),
              ),
            ),
            if (_selection != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
                child: _ZoneAndEvacuationDetailCard(
                  selection: _selection!,
                  onFocusPoint: (point) => _selectEvacuationPoint(point),
                  onClose: () => setState(() => _selection = null),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: _EvacuationQuickPointsBar(
                points: EvacuationMapData.points,
                selectedPointName: _selection?.pointName,
                onSelectPoint: _selectEvacuationPoint,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: SiagaColors.warning,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Klik pada area zona berwarna, garis jalur, atau marker titik evakuasi pada peta untuk melihat detail wilayah, tingkat risiko bencana, dan titik evakuasi terdekat. Selalu ikuti arahan petugas resmi di lapangan.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: SiagaColors.muted,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 560;
        final textField = TextField(
          controller: _searchController,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => unawaited(_submitSearch()),
          decoration: InputDecoration(
            hintText:
                'Cari alamat, nama jalan, kelurahan, kecamatan, atau tempat...',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _searchController.text.isNotEmpty ||
                    _searchedPosition != null
                ? IconButton(
                    tooltip: 'Hapus pencarian',
                    onPressed: _clearSearch,
                    icon: const Icon(Icons.clear_rounded, size: 18),
                  )
                : null,
            isDense: true,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: SiagaColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: SiagaColors.border),
            ),
          ),
        );

        final searchButton = FilledButton.icon(
          onPressed: _isSearching ? null : () => unawaited(_submitSearch()),
          icon: const Icon(Icons.travel_explore_rounded, size: 18),
          label: const Text('Cari Lokasi'),
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              textField,
              const SizedBox(height: 8),
              searchButton,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: textField),
            const SizedBox(width: 10),
            searchButton,
          ],
        );
      },
    );
  }

  Widget _buildSearchResultsPanel() {
    if (_isSearching) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: SiagaColors.border),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 10),
            Text('Mencari lokasi pada peta...'),
          ],
        ),
      );
    }

    if (_searchError != null) {
      return SiagaNotice(
        title: 'Pencarian Lokasi',
        message: _searchError!,
        tone: SiagaTone.warning,
        icon: Icons.search_off_rounded,
      );
    }

    if (_searchResults.isEmpty && _hasSearched) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: SiagaColors.border),
        ),
        child: const Text(
          'Lokasi tidak ditemukan. Coba masukkan nama jalan, kelurahan, kecamatan, atau nama tempat lain.',
          style: TextStyle(color: SiagaColors.muted, fontSize: 13),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 240),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SiagaColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: _searchResults.length,
          separatorBuilder: (context, index) =>
              const Divider(height: 1, color: SiagaColors.border),
          itemBuilder: (context, index) {
            final item = _searchResults[index];
            return ListTile(
              dense: true,
              leading: Icon(
                item.isOfficialPoint
                    ? Icons.health_and_safety_rounded
                    : Icons.place_outlined,
                color: item.isOfficialPoint
                    ? SiagaColors.safe
                    : SiagaColors.navyHover,
              ),
              title: Text(
                item.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: SiagaColors.ink,
                ),
              ),
              subtitle: Text(
                item.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: SiagaColors.muted),
              ),
              trailing: const Icon(Icons.chevron_right_rounded, size: 18),
              onTap: () => _selectSearchResult(item),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStyleAndLayerToolbar() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text(
          'Tampilan Peta:',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: SiagaColors.muted,
          ),
        ),
        for (final style in EvacuationMapStyle.values)
          ChoiceChip(
            label: Text(style.label),
            selected: _mapStyle == style,
            onSelected: (_) => _selectMapStyle(style),
          ),
        const SizedBox(width: 6),
        FilterChip(
          label: const Text('Zona Bencana'),
          selected: _showZones,
          onSelected: (value) => setState(() => _showZones = value),
        ),
        FilterChip(
          label: const Text('Jalur Evakuasi'),
          selected: _showRoutes,
          onSelected: (value) => setState(() => _showRoutes = value),
        ),
      ],
    );
  }

  Widget _buildMap() {
    final revision = _tileLayerRevision;
    final visiblePoints = EvacuationMapData.points.where(
      (point) => point.name != _selection?.pointName,
    );
    final markers = <Marker>[
      for (final point in visiblePoints)
        Marker(
          point: point.position,
          width: 42,
          height: 46,
          alignment: Alignment.bottomCenter,
          child: _EvacuationMarker(
            tooltip: point.name,
            onTap: () => _selectEvacuationPoint(point),
          ),
        ),
    ];

    if (_searchedPosition != null) {
      markers.add(
        Marker(
          point: _searchedPosition!,
          width: 44,
          height: 48,
          alignment: Alignment.bottomCenter,
          child: _SearchedLocationMarker(
            label: _searchedLabel ?? 'Hasil Pencarian',
            onTap: () {
              final assessment = EvacuationMapData.evaluateCoordinate(
                _searchedPosition!,
                locationLabel: _searchedLabel ?? 'Hasil Pencarian',
              );
              setState(() {
                _selection = assessment.selection;
                _locationAssessment = assessment;
              });
            },
          ),
        ),
      );
    }

    if (_userPosition != null) {
      markers.add(
        Marker(
          point: _userPosition!,
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: _UserLocationMarker(
            onTap: () {
              final assessment = EvacuationMapData.evaluateCoordinate(
                _userPosition!,
                locationLabel: 'Lokasi Anda',
                isUserLocation: true,
              );
              setState(() {
                _selection = assessment.selection;
                _locationAssessment = assessment;
              });
            },
          ),
        ),
      );
    }

    final selection = _selection;
    if (selection != null) {
      markers.add(
        Marker(
          point: selection.position,
          width: 280,
          height: 164,
          alignment: Alignment.bottomCenter,
          child: _SelectedMapMarker(
            selection: selection,
            onClose: () => setState(() => _selection = null),
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        FlutterMap(
          key: ValueKey('evacuation-map-${_mapStyle.name}-$_tileLayerRevision'),
          mapController: _mapController,
          options: MapOptions(
            initialCenter: EvacuationMapData.center,
            initialZoom: EvacuationMapData.initialZoom,
            minZoom: 10,
            maxZoom: 19,
            backgroundColor: const Color(0xFFF1F5F9),
            keepAlive: true,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
            onMapReady: () => setState(() => _mapReady = true),
            onTap: _handleMapTap,
          ),
          children: [
            TileLayer(
              key: ValueKey('map-tiles-${_mapStyle.name}-$_tileLayerRevision'),
              urlTemplate: _mapStyle.urlTemplate,
              maxZoom: 19,
              userAgentPackageName: 'com.example.siagabencana_flutter',
              tileBuilder: (context, tileWidget, tile) => _ObservedMapTile(
                tile: tile,
                onSettled: (succeeded) =>
                    _recordTileResult(revision, succeeded),
                child: tileWidget,
              ),
              errorTileCallback: (tile, error, stackTrace) =>
                  _recordTileResult(revision, false),
            ),
            if (_showZones)
              PolygonLayer(
                polygons: [
                  for (final zone in EvacuationMapData.zones)
                    Polygon(
                      points: [
                        zone.southWest,
                        LatLng(
                          zone.southWest.latitude,
                          zone.northEast.longitude,
                        ),
                        zone.northEast,
                        LatLng(
                          zone.northEast.latitude,
                          zone.southWest.longitude,
                        ),
                      ],
                      color: zone.color.withValues(alpha: 0.18),
                      borderColor: zone.color,
                      borderStrokeWidth: 2.5,
                    ),
                ],
              ),
            if (_showRoutes)
              PolylineLayer(
                polylines: [
                  for (final route in EvacuationMapData.routes)
                    Polyline(
                      points: route.points,
                      color: const Color(0xCCDC2626),
                      strokeWidth: 4,
                      pattern: StrokePattern.dashed(segments: [8, 8]),
                    ),
                ],
              ),
            MarkerLayer(markers: markers),
            RichAttributionWidget(
              alignment: AttributionAlignment.bottomRight,
              attributions: [
                TextSourceAttribution(
                  _mapStyle.attribution,
                  onTap: () => launchUrl(
                    Uri.parse('https://www.openstreetmap.org/copyright'),
                    mode: LaunchMode.externalApplication,
                  ),
                ),
              ],
            ),
          ],
        ),
        const Positioned(top: 12, left: 12, child: _ZoneLegend()),
        Positioned(
          top: 12,
          right: 12,
          child: _MapControls(
            enabled: _mapReady,
            onZoomIn: () => _changeZoom(1),
            onZoomOut: () => _changeZoom(-1),
            onLocateUser: _locateUser,
            onRecenter: () => _moveCamera(
              EvacuationMapData.center,
              EvacuationMapData.initialZoom,
            ),
          ),
        ),
        if (!_hasSuccessfulTile && !_hasTileError)
          const Positioned.fill(
            child: IgnorePointer(child: Center(child: _MapLoadingMessage())),
          ),
        if (_hasTileError)
          Positioned(
            left: 12,
            right: 12,
            bottom: 44,
            child: _MapLoadError(
              hasSuccessfulTile: _hasSuccessfulTile,
              onRetry: _retryTiles,
            ),
          ),
      ],
    );
  }

  void _changeZoom(double delta) {
    if (!_mapReady) {
      return;
    }
    try {
      final camera = _mapController.camera;
      _mapController.move(
        camera.center,
        (camera.zoom + delta).clamp(10.0, 19.0),
      );
    } catch (_) {
      // Abaikan bila kamera belum siap.
    }
  }
}

class _ZoneStatusBanner extends StatelessWidget {
  const _ZoneStatusBanner({required this.assessment});

  final EvacuationLocationAssessment assessment;

  @override
  Widget build(BuildContext context) {
    final zone = assessment.zone;
    final tone = switch (zone?.id) {
      'danger' => SiagaTone.danger,
      'warning' => SiagaTone.warning,
      'safe' => SiagaTone.success,
      _ => SiagaTone.info,
    };

    final icon = switch (zone?.id) {
      'danger' => Icons.warning_amber_rounded,
      'warning' => Icons.report_problem_outlined,
      'safe' => Icons.verified_user_outlined,
      _ => Icons.location_searching_rounded,
    };

    return SiagaNotice(
      title: assessment.statusTitle,
      message:
          '${assessment.statusMessage}\nTitik evakuasi terdekat: ${assessment.nearestPoint.point.name} (${assessment.nearestPoint.formattedDistance}).',
      tone: tone,
      icon: icon,
    );
  }
}

class _ZoneAndEvacuationDetailCard extends StatelessWidget {
  const _ZoneAndEvacuationDetailCard({
    required this.selection,
    required this.onFocusPoint,
    required this.onClose,
  });

  final EvacuationMapSelection selection;
  final ValueChanged<EvacuationMapPoint> onFocusPoint;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final nearest = selection.nearestPoint;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selection.color.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 14,
                height: 14,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: selection.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detail Zona & Informasi Evakuasi: ${selection.title}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: SiagaColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Koordinat: ${selection.position.latitude.toStringAsFixed(4)}, ${selection.position.longitude.toStringAsFixed(4)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: SiagaColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Tutup detail zona',
                visualDensity: VisualDensity.compact,
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: SiagaColors.border),
          const SizedBox(height: 12),
          _DetailInfoRow(
            label: 'Nama Wilayah',
            value: selection.areaName ?? selection.title,
            icon: Icons.map_outlined,
          ),
          _DetailInfoRow(
            label: 'Jenis Bencana',
            value: selection.disasterType ?? 'Potensi Bencana Wilayah',
            icon: Icons.tsunami_rounded,
          ),
          _DetailInfoRow(
            label: 'Tingkat Risiko',
            value: selection.riskLevel ?? selection.title,
            icon: Icons.shield_outlined,
          ),
          _DetailInfoRow(
            label: 'Informasi Evakuasi',
            value: selection.evacuationInfo ?? selection.description,
            icon: Icons.directions_run_rounded,
          ),
          if (nearest != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: SiagaColors.border),
              ),
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Titik Evakuasi Terdekat',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: SiagaColors.safe,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${nearest.point.name} (${nearest.formattedDistance})',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: SiagaColors.ink,
                        ),
                      ),
                      Text(
                        nearest.point.description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: SiagaColors.muted,
                        ),
                      ),
                    ],
                  ),
                  OutlinedButton.icon(
                    onPressed: () => onFocusPoint(nearest.point),
                    icon: const Icon(Icons.location_on_outlined, size: 16),
                    label: const Text('Lihat Titik Evakuasi'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailInfoRow extends StatelessWidget {
  const _DetailInfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: SiagaColors.navyHover),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: SiagaColors.ink),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EvacuationQuickPointsBar extends StatelessWidget {
  const _EvacuationQuickPointsBar({
    required this.points,
    required this.selectedPointName,
    required this.onSelectPoint,
  });

  final List<EvacuationMapPoint> points;
  final String? selectedPointName;
  final ValueChanged<EvacuationMapPoint> onSelectPoint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Titik Evakuasi & Posko Darurat Resmi:',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: SiagaColors.muted,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final point in points)
              ActionChip(
                avatar: Icon(
                  Icons.location_on_rounded,
                  size: 16,
                  color: selectedPointName == point.name
                      ? Colors.white
                      : SiagaColors.safe,
                ),
                backgroundColor: selectedPointName == point.name
                    ? SiagaColors.safe
                    : const Color(0xFFF0FDF4),
                labelStyle: TextStyle(
                  color: selectedPointName == point.name
                      ? Colors.white
                      : SiagaColors.ink,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
                label: Text(point.name),
                onPressed: () => onSelectPoint(point),
              ),
          ],
        ),
      ],
    );
  }
}

class _ObservedMapTile extends StatefulWidget {
  const _ObservedMapTile({
    required this.tile,
    required this.onSettled,
    required this.child,
  });

  final TileImage tile;
  final ValueChanged<bool> onSettled;
  final Widget child;

  @override
  State<_ObservedMapTile> createState() => _ObservedMapTileState();
}

class _ObservedMapTileState extends State<_ObservedMapTile> {
  bool _reported = false;

  @override
  void initState() {
    super.initState();
    widget.tile.addListener(_handleTileChange);
    _handleTileChange();
  }

  @override
  void didUpdateWidget(_ObservedMapTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tile != widget.tile) {
      oldWidget.tile.removeListener(_handleTileChange);
      _reported = false;
      widget.tile.addListener(_handleTileChange);
      _handleTileChange();
    }
  }

  @override
  void dispose() {
    widget.tile.removeListener(_handleTileChange);
    super.dispose();
  }

  void _handleTileChange() {
    if (_reported || !widget.tile.readyToDisplay) {
      return;
    }
    _reported = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onSettled(!widget.tile.loadError);
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _EvacuationMarker extends StatelessWidget {
  const _EvacuationMarker({required this.onTap, this.tooltip});

  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: tooltip ?? 'Buka detail titik peta',
    child: GestureDetector(
      onTap: onTap,
      child: const Icon(
        Icons.location_on_rounded,
        color: Color(0xFF16A34A),
        size: 42,
        shadows: [Shadow(color: Color(0x66000000), blurRadius: 3)],
      ),
    ),
  );
}

class _SearchedLocationMarker extends StatelessWidget {
  const _SearchedLocationMarker({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Marker lokasi pencarian: $label',
    child: GestureDetector(
      onTap: onTap,
      child: const Icon(
        Icons.place_rounded,
        color: Color(0xFF7C3AED),
        size: 44,
        shadows: [Shadow(color: Color(0x66000000), blurRadius: 4)],
      ),
    ),
  );
}

class _UserLocationMarker extends StatelessWidget {
  const _UserLocationMarker({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Marker posisi pengguna saat ini',
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2563EB).withValues(alpha: 0.22),
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(8),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: const [
              BoxShadow(color: Color(0x55000000), blurRadius: 6),
            ],
          ),
          child: const Icon(
            Icons.my_location_rounded,
            color: Colors.white,
            size: 16,
          ),
        ),
      ),
    ),
  );
}

class _SelectedMapMarker extends StatelessWidget {
  const _SelectedMapMarker({required this.selection, required this.onClose});

  final EvacuationMapSelection selection;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Material(
        color: Colors.white,
        elevation: 5,
        borderRadius: BorderRadius.circular(10),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 264),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selection.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: SiagaColors.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selection.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: SiagaColors.muted,
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Tutup detail peta',
                  visualDensity: VisualDensity.compact,
                  onPressed: onClose,
                  icon: const Icon(Icons.close_rounded, size: 18),
                ),
              ],
            ),
          ),
        ),
      ),
      Icon(
        Icons.location_on_rounded,
        color: selection.pointName == null
            ? selection.color
            : const Color(0xFF16A34A),
        size: 42,
        shadows: const [Shadow(color: Color(0x66000000), blurRadius: 3)],
      ),
    ],
  );
}

class _MapControls extends StatelessWidget {
  const _MapControls({
    required this.enabled,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onLocateUser,
    required this.onRecenter,
  });

  final bool enabled;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onLocateUser;
  final VoidCallback onRecenter;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    elevation: 3,
    borderRadius: BorderRadius.circular(8),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Perbesar peta',
          onPressed: enabled ? onZoomIn : null,
          icon: const Icon(Icons.add_rounded),
        ),
        const Divider(height: 1),
        IconButton(
          tooltip: 'Perkecil peta',
          onPressed: enabled ? onZoomOut : null,
          icon: const Icon(Icons.remove_rounded),
        ),
        const Divider(height: 1),
        IconButton(
          tooltip: 'Lokasi Saya',
          onPressed: onLocateUser,
          icon: const Icon(
            Icons.my_location_rounded,
            size: 20,
            color: SiagaColors.navyHover,
          ),
        ),
        const Divider(height: 1),
        IconButton(
          tooltip: 'Pusatkan peta',
          onPressed: enabled ? onRecenter : null,
          icon: const Icon(Icons.center_focus_strong_rounded, size: 20),
        ),
      ],
    ),
  );
}

class _ZoneLegend extends StatelessWidget {
  const _ZoneLegend();

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white.withValues(alpha: 0.94),
    elevation: 2,
    borderRadius: BorderRadius.circular(8),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final zone in EvacuationMapData.zones)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: zone.color.withValues(alpha: 0.25),
                      border: Border.all(color: zone.color),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    '${zone.title} (${zone.riskLevel})',
                    style: const TextStyle(
                      color: SiagaColors.ink,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 2),
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on_rounded,
                color: Color(0xFF16A34A),
                size: 14,
              ),
              SizedBox(width: 5),
              Text(
                'Titik Evakuasi Resmi',
                style: TextStyle(color: SiagaColors.ink, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _MapLoadingMessage extends StatelessWidget {
  const _MapLoadingMessage();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.95),
      borderRadius: BorderRadius.circular(10),
      boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 8)],
    ),
    child: const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 10),
          Text('Memuat peta…'),
        ],
      ),
    ),
  );
}

class _MapLoadError extends StatelessWidget {
  const _MapLoadError({required this.hasSuccessfulTile, required this.onRetry});

  final bool hasSuccessfulTile;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    elevation: 3,
    borderRadius: BorderRadius.circular(10),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_outlined, color: SiagaColors.danger),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              hasSuccessfulTile
                  ? 'Sebagian tile peta gagal dimuat.'
                  : 'Peta gagal dimuat. Periksa koneksi internet.',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Coba lagi')),
        ],
      ),
    ),
  );
}
