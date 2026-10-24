import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/siaga_theme.dart';
import '../../../app/widgets/siaga_components.dart';
import '../data/evacuation_map_data.dart';

class EvacuationMapPanel extends StatefulWidget {
  const EvacuationMapPanel({super.key});

  @override
  State<EvacuationMapPanel> createState() => _EvacuationMapPanelState();
}

class _EvacuationMapPanelState extends State<EvacuationMapPanel> {
  final MapController _mapController = MapController();
  EvacuationMapSelection? _selection;
  bool _mapReady = false;
  bool _hasSuccessfulTile = false;
  bool _hasTileError = false;
  int _tileLayerRevision = 0;

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
      _mapReady = false;
      _hasSuccessfulTile = false;
      _hasTileError = false;
    });
  }

  void _handleMapTap(TapPosition tapPosition, LatLng position) {
    setState(() {
      _selection = EvacuationMapData.selectionAt(position);
    });
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
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Peta Evakuasi Kota Padang',
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(color: SiagaColors.navy),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Peta interaktif menyalin titik, zona, dan rute yang tertulis pada halaman Blade.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: SizedBox(
                height: 450,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFCBD5E1),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _buildMap(),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: SiagaColors.warning,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Visualisasi statis dari kode Blade. Koordinat, zona, rute, dan nama titik belum diverifikasi sebagai data resmi atau petunjuk perjalanan. Ikuti arahan petugas dan kanal resmi.',
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: SiagaColors.muted, height: 1.45),
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
            onTap: () {
              setState(() {
                _selection = EvacuationMapSelection(
                  title: point.name,
                  description: point.description,
                  position: point.position,
                  color: SiagaColors.safe,
                  pointName: point.name,
                );
              });
            },
          ),
        ),
    ];

    final selection = _selection;
    if (selection != null) {
      markers.add(
        Marker(
          point: selection.position,
          width: 270,
          height: 154,
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
          key: ValueKey('evacuation-map-$_tileLayerRevision'),
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
              key: ValueKey('osm-tiles-$_tileLayerRevision'),
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
            PolygonLayer(
              polygons: [
                for (final zone in EvacuationMapData.zones)
                  Polygon(
                    points: [
                      zone.southWest,
                      LatLng(zone.southWest.latitude, zone.northEast.longitude),
                      zone.northEast,
                      LatLng(zone.northEast.latitude, zone.southWest.longitude),
                    ],
                    color: zone.color.withValues(alpha: 0.15),
                    borderColor: zone.color,
                    borderStrokeWidth: 2,
                  ),
              ],
            ),
            PolylineLayer(
              polylines: [
                for (final route in EvacuationMapData.routes)
                  Polyline(
                    points: route.points,
                    color: const Color(0xCCFF0000),
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
                  '© OpenStreetMap contributors',
                  onTap: () => launchUrl(
                    Uri.parse('https://www.openstreetmap.org/copyright'),
                    mode: LaunchMode.externalApplication,
                  ),
                ),
              ],
            ),
          ],
        ),
        Positioned(top: 12, left: 12, child: _ZoneLegend()),
        Positioned(
          top: 12,
          right: 12,
          child: _MapControls(
            enabled: _mapReady,
            onZoomIn: () => _changeZoom(1),
            onZoomOut: () => _changeZoom(-1),
            onRecenter: () => _mapController.move(
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
    final camera = _mapController.camera;
    _mapController.move(camera.center, (camera.zoom + delta).clamp(10.0, 19.0));
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
  const _EvacuationMarker({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Buka detail titik peta',
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
          constraints: const BoxConstraints(maxWidth: 254),
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
                        style: const TextStyle(
                          color: SiagaColors.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selection.description,
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
    required this.onRecenter,
  });

  final bool enabled;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
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
          tooltip: 'Pusatkan peta',
          onPressed: enabled ? onRecenter : null,
          icon: const Icon(Icons.my_location_rounded, size: 20),
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
                      color: zone.color.withValues(alpha: 0.2),
                      border: Border.all(color: zone.color),
                    ),
                  ),
                  const SizedBox(width: 7),
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
                'Titik pada Blade',
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
