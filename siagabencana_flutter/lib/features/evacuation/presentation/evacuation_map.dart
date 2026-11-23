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
        borderRadius: BorderRadius.circular(SiagaRadius.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // GIS Control Bar
            Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
              decoration: const BoxDecoration(
                color: SiagaColors.surface,
                border: Border(bottom: BorderSide(color: SiagaColors.border)),
              ),
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
                          const SizedBox(height: 3),
                          Text(
                            'Cari alamat, lacak lokasi GPS, atau klik area pada peta untuk melihat zona risiko dan titik evakuasi terdekat.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      FilledButton.tonalIcon(
                        onPressed: _isLocatingUser ? null : _locateUser,
                        style: FilledButton.styleFrom(
                          backgroundColor: SiagaColors.primarySoft,
                          foregroundColor: SiagaColors.navy,
                        ),
                        icon: _isLocatingUser
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.my_location_rounded, size: 17),
                        label: Text(
                          _isLocatingUser ? 'Melacak...' : 'Lokasi Saya',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
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

            // Map Viewport + Docked Side Info Panel on Desktop
            LayoutBuilder(
              builder: (context, constraints) {
                final isSplit = constraints.maxWidth >= 980;
                final mapCanvas = SizedBox(
                  height: isSplit ? 540 : 420,
                  child: _buildMap(),
                );

                final sideInspector = _EvacuationInspectorPanel(
                  selection: _selection,
                  points: EvacuationMapData.points,
                  onFocusPoint: _selectEvacuationPoint,
                  onCloseSelection: () => setState(() => _selection = null),
                );

                if (isSplit) {
                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(flex: 7, child: mapCanvas),
                        Container(width: 1, color: SiagaColors.border),
                        SizedBox(width: 350, child: sideInspector),
                      ],
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    mapCanvas,
                    const Divider(height: 1),
                    sideInspector,
                  ],
                );
              },
            ),

            // Concise Operational Footnote
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                color: SiagaColors.surfaceSubtle,
                border: Border(top: BorderSide(color: SiagaColors.border)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 1),
                    child: Icon(
                      Icons.info_outline_rounded,
                      color: SiagaColors.muted,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Klik zona berwarna, garis jalur evakuasi, atau marker hijau untuk memeriksa detail wilayah dan jarak titik aman terdekat. Selalu patuhi arahan petugas resmi di lapangan.',
                      style: Theme.of(context).textTheme.bodySmall,
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
        final isCompact = constraints.maxWidth < 540;
        final textField = TextField(
          controller: _searchController,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => unawaited(_submitSearch()),
          decoration: InputDecoration(
            hintText:
                'Cari alamat, nama jalan, kelurahan, kecamatan, atau tempat...',
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            fillColor: SiagaColors.surfaceSubtle,
            suffixIcon:
                _searchController.text.isNotEmpty || _searchedPosition != null
                ? IconButton(
                    tooltip: 'Hapus pencarian',
                    onPressed: _clearSearch,
                    icon: const Icon(Icons.clear_rounded, size: 18),
                  )
                : null,
          ),
        );

        final searchButton = FilledButton.icon(
          onPressed: _isSearching ? null : () => unawaited(_submitSearch()),
          icon: const Icon(Icons.travel_explore_rounded, size: 17),
          label: const Text('Cari Lokasi'),
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [textField, const SizedBox(height: 8), searchButton],
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: SiagaColors.surfaceSubtle,
          borderRadius: BorderRadius.circular(SiagaRadius.md),
          border: Border.all(color: SiagaColors.border),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 10),
            Text(
              'Mencari lokasi pada peta...',
              style: TextStyle(fontSize: 13, color: SiagaColors.muted),
            ),
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: SiagaColors.surfaceSubtle,
          borderRadius: BorderRadius.circular(SiagaRadius.md),
          border: Border.all(color: SiagaColors.border),
        ),
        child: const Text(
          'Lokasi tidak ditemukan. Coba masukkan nama jalan, kelurahan, kecamatan, atau nama tempat lain.',
          style: TextStyle(color: SiagaColors.muted, fontSize: 13),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 220),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SiagaRadius.md),
        border: Border.all(color: SiagaColors.border),
        boxShadow: SiagaShadows.card,
      ),
      child: Material(
        color: SiagaColors.surface,
        borderRadius: BorderRadius.circular(SiagaRadius.md),
        clipBehavior: Clip.antiAlias,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: _searchResults.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final item = _searchResults[index];
            return ListTile(
              dense: true,
              leading: Icon(
                item.isOfficialPoint
                    ? Icons.health_and_safety_outlined
                    : Icons.place_outlined,
                color: item.isOfficialPoint
                    ? SiagaColors.safe
                    : SiagaColors.primaryBlue,
                size: 20,
              ),
              title: Text(
                item.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
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
          'Tampilan:',
          style: TextStyle(
            fontSize: 12,
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
        Container(width: 1, height: 18, color: SiagaColors.border),
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
          width: 40,
          height: 44,
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
          width: 42,
          height: 46,
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
          width: 44,
          height: 44,
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
          width: 260,
          height: 146,
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
            backgroundColor: SiagaColors.surfaceMuted,
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
                      color: zone.color.withValues(alpha: 0.16),
                      borderColor: zone.color,
                      borderStrokeWidth: 2,
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
                      strokeWidth: 3.5,
                      pattern: StrokePattern.dashed(segments: [8, 7]),
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
        const Positioned(top: 12, left: 12, child: _CompactZoneLegend()),
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
            bottom: 42,
            child: _MapLoadError(
              hasSuccessfulTile: _hasSuccessfulTile,
              onRetry: _retryTiles,
            ),
          ),
      ],
    );
  }

  void _changeZoom(double delta) {
    if (!_mapReady) return;
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

class _EvacuationInspectorPanel extends StatelessWidget {
  const _EvacuationInspectorPanel({
    required this.selection,
    required this.points,
    required this.onFocusPoint,
    required this.onCloseSelection,
  });

  final EvacuationMapSelection? selection;
  final List<EvacuationMapPoint> points;
  final ValueChanged<EvacuationMapPoint> onFocusPoint;
  final VoidCallback onCloseSelection;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SiagaColors.surface,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (selection != null) ...[
            _ZoneAndEvacuationDetailCard(
              selection: selection!,
              onFocusPoint: onFocusPoint,
              onClose: onCloseSelection,
            ),
            const SizedBox(height: 18),
            const Divider(height: 1),
            const SizedBox(height: 16),
          ],
          const Text(
            'TITIK EVAKUASI & POSKO RESMI',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
              color: SiagaColors.muted,
            ),
          ),
          const SizedBox(height: 10),
          for (final point in points)
            _OfficialPointTile(
              point: point,
              isSelected: selection?.pointName == point.name,
              onTap: () => onFocusPoint(point),
            ),
        ],
      ),
    );
  }
}

class _OfficialPointTile extends StatelessWidget {
  const _OfficialPointTile({
    required this.point,
    required this.isSelected,
    required this.onTap,
  });

  final EvacuationMapPoint point;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isSelected ? SiagaColors.safeSoft : SiagaColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(SiagaRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(SiagaRadius.md),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SiagaRadius.md),
              border: Border.all(
                color: isSelected ? SiagaColors.safe : SiagaColors.border,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: 18,
                  color: isSelected ? SiagaColors.safe : SiagaColors.muted,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        point.name,
                        style: TextStyle(
                          fontSize: 13.2,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? SiagaColors.safeText
                              : SiagaColors.ink,
                        ),
                      ),
                      Text(
                        point.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.8,
                          color: SiagaColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: SiagaColors.textSubtle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SiagaColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(SiagaRadius.md),
        border: Border.all(color: selection.color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                  color: selection.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detail Zona & Informasi Evakuasi: ${selection.title}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${selection.position.latitude.toStringAsFixed(4)}, ${selection.position.longitude.toStringAsFixed(4)}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: SiagaColors.muted,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Tutup detail zona',
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded, size: 17),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          _DetailInfoRow(
            label: 'Wilayah',
            value: selection.areaName ?? selection.title,
          ),
          _DetailInfoRow(
            label: 'Potensi',
            value: selection.disasterType ?? 'Potensi Bencana Wilayah',
          ),
          _DetailInfoRow(
            label: 'Risiko',
            value: selection.riskLevel ?? selection.title,
          ),
          _DetailInfoRow(
            label: 'Arahan',
            value: selection.evacuationInfo ?? selection.description,
          ),
          if (nearest != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: SiagaColors.surface,
                borderRadius: BorderRadius.circular(SiagaRadius.md),
                border: Border.all(color: SiagaColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Titik Evakuasi Terdekat',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: SiagaColors.safe,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${nearest.point.name} (${nearest.formattedDistance})',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: SiagaColors.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => onFocusPoint(nearest.point),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 34),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    icon: const Icon(Icons.location_on_outlined, size: 15),
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
  const _DetailInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: SiagaColors.textSecondary,
            height: 1.45,
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: SiagaColors.ink,
              ),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
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
    if (_reported || !widget.tile.readyToDisplay) return;
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
        color: Color(0xFF059669),
        size: 38,
        shadows: [Shadow(color: Color(0x55000000), blurRadius: 3)],
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
        color: SiagaColors.navy,
        size: 40,
        shadows: [Shadow(color: Color(0x55000000), blurRadius: 4)],
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
          color: SiagaColors.primaryBlue.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(7),
        child: Container(
          decoration: BoxDecoration(
            color: SiagaColors.primaryBlue,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: const [
              BoxShadow(color: Color(0x44000000), blurRadius: 5),
            ],
          ),
          child: const Icon(
            Icons.my_location_rounded,
            color: Colors.white,
            size: 14,
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
        color: SiagaColors.surface,
        elevation: 4,
        borderRadius: BorderRadius.circular(SiagaRadius.md),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 244),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SiagaRadius.md),
            border: Border.all(color: SiagaColors.border),
          ),
          padding: const EdgeInsets.fromLTRB(11, 7, 4, 7),
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
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      selection.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: SiagaColors.muted,
                        fontSize: 11.5,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Tutup detail peta',
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded, size: 16),
              ),
            ],
          ),
        ),
      ),
      Icon(
        Icons.location_on_rounded,
        color: selection.pointName == null ? selection.color : SiagaColors.safe,
        size: 38,
        shadows: const [Shadow(color: Color(0x55000000), blurRadius: 3)],
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
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: SiagaColors.surface,
      borderRadius: BorderRadius.circular(SiagaRadius.md),
      border: Border.all(color: SiagaColors.border),
      boxShadow: SiagaShadows.card,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Perbesar peta',
          visualDensity: VisualDensity.compact,
          onPressed: enabled ? onZoomIn : null,
          icon: const Icon(Icons.add_rounded, size: 19),
        ),
        const SizedBox(width: 24, child: Divider(height: 1)),
        IconButton(
          tooltip: 'Perkecil peta',
          visualDensity: VisualDensity.compact,
          onPressed: enabled ? onZoomOut : null,
          icon: const Icon(Icons.remove_rounded, size: 19),
        ),
        const SizedBox(width: 24, child: Divider(height: 1)),
        IconButton(
          tooltip: 'Lokasi Saya',
          visualDensity: VisualDensity.compact,
          onPressed: onLocateUser,
          icon: const Icon(
            Icons.my_location_rounded,
            size: 18,
            color: SiagaColors.primaryBlue,
          ),
        ),
        const SizedBox(width: 24, child: Divider(height: 1)),
        IconButton(
          tooltip: 'Pusatkan peta',
          visualDensity: VisualDensity.compact,
          onPressed: enabled ? onRecenter : null,
          icon: const Icon(Icons.center_focus_strong_rounded, size: 18),
        ),
      ],
    ),
  );
}

class _CompactZoneLegend extends StatelessWidget {
  const _CompactZoneLegend();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: SiagaColors.surface.withValues(alpha: 0.94),
      borderRadius: BorderRadius.circular(SiagaRadius.md),
      border: Border.all(color: SiagaColors.border),
      boxShadow: SiagaShadows.subtle,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final zone in EvacuationMapData.zones)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: zone.color.withValues(alpha: 0.25),
                    border: Border.all(color: zone.color, width: 1.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  zone.title,
                  style: const TextStyle(
                    color: SiagaColors.ink,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on_rounded,
                color: SiagaColors.safe,
                size: 12,
              ),
              SizedBox(width: 4),
              Text(
                'Titik Evakuasi',
                style: TextStyle(
                  color: SiagaColors.ink,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _MapLoadingMessage extends StatelessWidget {
  const _MapLoadingMessage();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: SiagaColors.surface.withValues(alpha: 0.96),
      borderRadius: BorderRadius.circular(SiagaRadius.md),
      border: Border.all(color: SiagaColors.border),
      boxShadow: SiagaShadows.card,
    ),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        SizedBox(width: 10),
        Text(
          'Memuat peta...',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}

class _MapLoadError extends StatelessWidget {
  const _MapLoadError({required this.hasSuccessfulTile, required this.onRetry});

  final bool hasSuccessfulTile;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
    decoration: BoxDecoration(
      color: SiagaColors.surface,
      borderRadius: BorderRadius.circular(SiagaRadius.md),
      border: Border.all(color: SiagaColors.dangerBorder),
      boxShadow: SiagaShadows.card,
    ),
    child: Row(
      children: [
        const Icon(
          Icons.cloud_off_outlined,
          color: SiagaColors.danger,
          size: 18,
        ),
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
  );
}
