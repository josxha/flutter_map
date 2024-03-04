import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart' show MapEquality;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/src/layer/tile_layer/tile.dart';
import 'package:flutter_map/src/layer/tile_layer/tile_bounds/tile_bounds.dart';
import 'package:flutter_map/src/layer/tile_layer/tile_bounds/tile_bounds_at_zoom.dart';
import 'package:flutter_map/src/layer/tile_layer/tile_image_manager.dart';
import 'package:flutter_map/src/layer/tile_layer/tile_range.dart';
import 'package:flutter_map/src/layer/tile_layer/tile_range_calculator.dart';
import 'package:flutter_map/src/layer/tile_layer/tile_scale_calculator.dart';
import 'package:http/http.dart';
import 'package:http/retry.dart';
import 'package:logger/logger.dart';

part 'retina_mode.dart';
part 'tile_error_evict_callback.dart';
part 'wms_tile_layer_options.dart';

/// Describes the needed properties to create a tile-based layer. A tile is an
/// image bound to a specific geographical position.
///
/// You should read up about the options by exploring each one, or visiting
/// https://docs.fleaflet.dev/usage/layers/tile-layer. Some are important to
/// avoid issues.
@immutable
class TileLayer extends StatefulWidget {
  /// Resolved retina mode, based on the `retinaMode` passed in the constructor
  /// and the [urlTemplate]
  ///
  /// See [RetinaMode] for more information.
  late final RetinaMode resolvedRetinaMode;

  /// If a Tile was loaded with error and if strategy isn't `none` then TileProvider
  /// will be asked to evict Image based on current strategy
  /// (see #576 - even Error Images are cached in flutter)
  final EvictErrorTileStrategy evictErrorTileStrategy;

  /// This transformer modifies how/when tile updates and pruning are triggered
  /// based on [MapEvent]s. It is a StreamTransformer and therefore it is
  /// possible to filter/modify/throttle the [TileUpdateEvent]s. Defaults to
  /// [TileUpdateTransformers.ignoreTapEvents] which disables loading/pruning
  /// for map taps, secondary taps and long presses. See TileUpdateTransformers
  /// for more transformer presets or implement your own.
  ///
  /// Note: Changing the [tileUpdateTransformer] after TileLayer is created has
  /// no affect.
  final TileUpdateTransformer tileUpdateTransformer;

  /// Create a new [TileLayer] for the [FlutterMap] widget.
  TileLayer({
    super.key,
    double tileSize = 256,
    double minZoom = 0,
    double maxZoom = double.infinity,
    int minNativeZoom = 0,
    int maxNativeZoom = 19,

    /// See [RetinaMode] for more information
    ///
    /// Defaults to `false` when `null`.
    final bool? retinaMode,
    this.evictErrorTileStrategy = EvictErrorTileStrategy.none,
    TileUpdateTransformer? tileUpdateTransformer,
    String userAgentPackageName = 'unknown',
  })  : assert(
          tileDisplay.when(
            instantaneous: (_) => true,
            fadeIn: (fadeIn) => fadeIn.duration > Duration.zero,
          )!,
          'The tile fade in duration needs to be bigger than zero',
        ),
        assert(
          urlTemplate == null || wmsOptions == null,
          'Cannot specify both `urlTemplate` and `wmsOptions`',
        ),
        tileProvider = tileProvider ?? NetworkTileProvider(),
        tileUpdateTransformer =
            tileUpdateTransformer ?? TileUpdateTransformers.ignoreTapEvents {
    // Debug Logging
    if (kDebugMode &&
        urlTemplate != null &&
        urlTemplate!.contains('{s}.tile.openstreetmap.org')) {
      Logger(printer: PrettyPrinter(methodCount: 0)).w(
        '\x1B[1m\x1B[3mflutter_map\x1B[0m\nAvoid using subdomains with OSM\'s tile '
        'server. Support may be become slow or be removed in future.\nSee '
        'https://github.com/openstreetmap/operations/issues/737 for more info.',
      );
    }
    if (kDebugMode &&
        retinaMode == null &&
        urlTemplate != null &&
        urlTemplate!.contains('{r}')) {
      Logger(printer: PrettyPrinter(methodCount: 0)).w(
        '\x1B[1m\x1B[3mflutter_map\x1B[0m\nThe URL template includes a retina '
        "mode placeholder ('{r}') to retrieve native high-resolution\ntiles, "
        'which improve appearance especially on high-density displays.\n'
        'However, `TileLayer.retinaMode` was left unset, meaning flutter_map '
        'will never retrieve these tiles.\nConsider using '
        '`RetinaMode.isHighDensity` to toggle this property automatically, '
        'otherwise ensure\nit is set appropriately.\n'
        'See https://docs.fleaflet.dev/layers/tile-layer#retina-mode for '
        'more info.',
      );
    }
    if (kDebugMode && kIsWeb && tileProvider is NetworkTileProvider?) {
      Logger(printer: PrettyPrinter(methodCount: 0)).i(
        '\x1B[1m\x1B[3mflutter_map\x1B[0m\nConsider installing the official '
        "'flutter_map_cancellable_tile_provider' plugin for improved\n"
        'performance on the web.\nSee '
        'https://pub.dev/packages/flutter_map_cancellable_tile_provider for '
        'more info.',
      );
    }

    // Tile Provider Setup
    if (!kIsWeb) {
      this.tileProvider.headers.putIfAbsent(
          'User-Agent', () => 'flutter_map ($userAgentPackageName)');
    }

    // Retina Mode Setup
    resolvedRetinaMode = (retinaMode ?? false)
        ? wmsOptions == null && (urlTemplate?.contains('{r}') ?? false)
            ? RetinaMode.server
            : RetinaMode.simulation
        : RetinaMode.disabled;
    final useSimulatedRetina = resolvedRetinaMode == RetinaMode.simulation;

    this.maxZoom = useSimulatedRetina && !zoomReverse ? maxZoom - 1 : maxZoom;
    this.maxNativeZoom =
        useSimulatedRetina && !zoomReverse ? maxNativeZoom - 1 : maxNativeZoom;
    this.minZoom =
        useSimulatedRetina && zoomReverse ? max(minZoom + 1.0, 0) : minZoom;
    this.minNativeZoom = useSimulatedRetina && zoomReverse
        ? max(minNativeZoom + 1, 0)
        : minNativeZoom;
    this.zoomOffset = useSimulatedRetina
        ? (zoomReverse ? zoomOffset - 1.0 : zoomOffset + 1.0)
        : zoomOffset;
    this.tileSize =
        useSimulatedRetina ? (tileSize / 2.0).floorToDouble() : tileSize;
  }

  @override
  State<StatefulWidget> createState() => _TileLayerState();
}

class _TileLayerState extends State<TileLayer> with TickerProviderStateMixin {
  bool _initializedFromMapCamera = false;

  late TileBounds _tileBounds;
  late var _tileRangeCalculator =
      TileRangeCalculator(tileSize: widget.tileSize);
  late TileScaleCalculator _tileScaleCalculator;

  // We have to hold on to the mapController hashCode to determine whether we
  // need to reinitialize the listeners. didChangeDependencies is called on
  // every map movement and if we unsubscribe and resubscribe every time we
  // miss events.
  int? _mapControllerHashCode;

  StreamSubscription<TileUpdateEvent>? _tileUpdateSubscription;
  Timer? _pruneLater;

  late final _resetSub = widget.reset?.listen((_) {
    _tileImageManager.removeAll(widget.evictErrorTileStrategy);
    _loadAndPruneInVisibleBounds(MapCamera.of(context));
  });

  // This is called on every map movement so we should avoid expensive logic
  // where possible.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final camera = MapCamera.of(context);
    final mapController = MapController.of(context);

    if (_mapControllerHashCode != mapController.hashCode) {
      _tileUpdateSubscription?.cancel();

      _mapControllerHashCode = mapController.hashCode;
      _tileUpdateSubscription = mapController.mapEventStream
          .map((mapEvent) => TileUpdateEvent(mapEvent: mapEvent))
          .transform(widget.tileUpdateTransformer)
          .listen(_onTileUpdateEvent);
    }

    var reloadTiles = false;
    if (!_initializedFromMapCamera ||
        _tileBounds.shouldReplace(
            camera.crs, widget.tileSize, widget.tileBounds)) {
      reloadTiles = true;
      _tileBounds = TileBounds(
        crs: camera.crs,
        tileSize: widget.tileSize,
        latLngBounds: widget.tileBounds,
      );
    }

    if (!_initializedFromMapCamera ||
        _tileScaleCalculator.shouldReplace(camera.crs, widget.tileSize)) {
      reloadTiles = true;
      _tileScaleCalculator = TileScaleCalculator(
        crs: camera.crs,
        tileSize: widget.tileSize,
      );
    }

    if (reloadTiles) _loadAndPruneInVisibleBounds(camera);

    _initializedFromMapCamera = true;
  }

  @override
  void didUpdateWidget(TileLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    var reloadTiles = false;

    // There is no caching in TileRangeCalculator so we can just replace it.
    _tileRangeCalculator = TileRangeCalculator(tileSize: widget.tileSize);

    if (_tileBounds.shouldReplace(
        _tileBounds.crs, widget.tileSize, widget.tileBounds)) {
      _tileBounds = TileBounds(
        crs: _tileBounds.crs,
        tileSize: widget.tileSize,
        latLngBounds: widget.tileBounds,
      );
      reloadTiles = true;
    }

    if (_tileScaleCalculator.shouldReplace(
        _tileScaleCalculator.crs, widget.tileSize)) {
      _tileScaleCalculator = TileScaleCalculator(
        crs: _tileScaleCalculator.crs,
        tileSize: widget.tileSize,
      );
    }

    if (oldWidget.resolvedRetinaMode != widget.resolvedRetinaMode) {
      reloadTiles = true;
    }

    if (oldWidget.minZoom != widget.minZoom ||
        oldWidget.maxZoom != widget.maxZoom) {
      reloadTiles |=
          !_tileImageManager.allWithinZoom(widget.minZoom, widget.maxZoom);
    }

    if (!reloadTiles) {
      final oldUrl =
          oldWidget.wmsOptions?._encodedBaseUrl ?? oldWidget.urlTemplate;
      final newUrl = widget.wmsOptions?._encodedBaseUrl ?? widget.urlTemplate;

      final oldOptions = oldWidget.additionalOptions;
      final newOptions = widget.additionalOptions;

      if (oldUrl != newUrl ||
          !(const MapEquality<String, String>())
              .equals(oldOptions, newOptions)) {
        _tileImageManager.reloadImages(widget, _tileBounds);
      }
    }

    if (reloadTiles) {
      _tileImageManager.removeAll(widget.evictErrorTileStrategy);
      _loadAndPruneInVisibleBounds(MapCamera.maybeOf(context)!);
    } else if (oldWidget.tileDisplay != widget.tileDisplay) {
      _tileImageManager.updateTileDisplay(widget.tileDisplay);
    }
  }

  @override
  void dispose() {
    _tileUpdateSubscription?.cancel();
    _tileImageManager.removeAll(widget.evictErrorTileStrategy);
    _resetSub?.cancel();
    _pruneLater?.cancel();
    widget.tileProvider.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tileZoom = _clampToNativeZoom(map.zoom);
    final tileBoundsAtZoom = _tileBounds.atZoom(tileZoom);
    final visibleTileRange = _tileRangeCalculator.calculate(
      camera: map,
      tileZoom: tileZoom,
    );

    // For a given map event both this rebuild method and the tile
    // loading/pruning logic will be fired. Any TileImages which are not
    // rendered in a corresponding Tile after this build will not become
    // visible until the next build. Therefore, in case this build is executed
    // before the loading/updating, we must pre-create the missing TileImages
    // and add them to the widget tree so that when they are loaded they notify
    // the Tile and become visible. We don't need to prune here as any new tiles
    // will be pruned when the map event triggers tile loading.
    _tileImageManager.createMissingTiles(
      visibleTileRange,
      tileBoundsAtZoom,
      createTile: (coordinates) => _createTileImage(
        coordinates: coordinates,
        tileBoundsAtZoom: tileBoundsAtZoom,
        pruneAfterLoad: false,
      ),
    );

    _tileScaleCalculator.clearCacheUnlessZoomMatches(map.zoom);
  }

  TileImage _createTileImage({
    required TileCoordinates coordinates,
    required TileBoundsAtZoom tileBoundsAtZoom,
    required bool pruneAfterLoad,
  }) {
    final cancelLoading = Completer<void>();

    final imageProvider = widget.tileProvider.supportsCancelLoading
        ? widget.tileProvider.getImageWithCancelLoadingSupport(
            tileBoundsAtZoom.wrap(coordinates),
            widget,
            cancelLoading.future,
          )
        : widget.tileProvider.getImage(
            tileBoundsAtZoom.wrap(coordinates),
            widget,
          );

    return TileImage(
      vsync: this,
      coordinates: coordinates,
      imageProvider: imageProvider,
      onLoadError: _onTileLoadError,
      onLoadComplete: (coordinates) {
        if (pruneAfterLoad) _pruneIfAllTilesLoaded(coordinates);
      },
      tileDisplay: widget.tileDisplay,
      errorImage: widget.errorImage,
      cancelLoading: cancelLoading,
    );
  }

  /// Load and/or prune tiles according to the visible bounds of the [event]
  /// center/zoom, or the current center/zoom if not specified.
  void _onTileUpdateEvent(TileUpdateEvent event) {
    final tileZoom = _clampToNativeZoom(event.zoom);
    final visibleTileRange = _tileRangeCalculator.calculate(
      camera: event.camera,
      tileZoom: tileZoom,
      center: event.center,
      viewingZoom: event.zoom,
    );

    if (event.load && !_outsideZoomLimits(tileZoom)) {
      _loadTiles(visibleTileRange, pruneAfterLoad: event.prune);
    }

    if (event.prune) {
      _tileImageManager.evictAndPrune(
        visibleRange: visibleTileRange,
        pruneBuffer: widget.panBuffer + widget.keepBuffer,
        evictStrategy: widget.evictErrorTileStrategy,
      );
    }
  }

  /// Load new tiles in the visible bounds and prune those outside.
  void _loadAndPruneInVisibleBounds(MapCamera camera) {
    final tileZoom = _clampToNativeZoom(camera.zoom);
    final visibleTileRange = _tileRangeCalculator.calculate(
      camera: camera,
      tileZoom: tileZoom,
    );

    if (!_outsideZoomLimits(tileZoom)) {
      _loadTiles(
        visibleTileRange,
        pruneAfterLoad: true,
      );
    }

    _tileImageManager.evictAndPrune(
      visibleRange: visibleTileRange,
      pruneBuffer: max(widget.panBuffer, widget.keepBuffer),
      evictStrategy: widget.evictErrorTileStrategy,
    );
  }

  // For all valid TileCoordinates in the [tileLoadRange], expanded by the
  // [TileLayer.panBuffer], this method will do the following depending on
  // whether a matching TileImage already exists or not:
  //   * Exists: Mark it as current and initiate image loading if it has not
  //     already been initiated.
  //   * Does not exist: Creates the TileImage (they are current when created)
  //     and initiates loading.
  //
  // Additionally, any current TileImages outside of the [tileLoadRange],
  // expanded by the [TileLayer.panBuffer] + [TileLayer.keepBuffer], are marked
  // as not current.
  void _loadTiles(
    DiscreteTileRange tileLoadRange, {
    required bool pruneAfterLoad,
  }) {
    final tileZoom = tileLoadRange.zoom;
    final expandedTileLoadRange = tileLoadRange.expand(widget.panBuffer);

    // Build the queue of tiles to load. Marks all tiles with valid coordinates
    // in the tileLoadRange as current.
    final tileBoundsAtZoom = _tileBounds.atZoom(tileZoom);
    final tilesToLoad = _tileImageManager.createMissingTiles(
      expandedTileLoadRange,
      tileBoundsAtZoom,
      createTile: (coordinates) => _createTileImage(
        coordinates: coordinates,
        tileBoundsAtZoom: tileBoundsAtZoom,
        pruneAfterLoad: pruneAfterLoad,
      ),
    );

    // Re-order the tiles by their distance to the center of the range.
    final tileCenter = expandedTileLoadRange.center;
    tilesToLoad.sort(
      (a, b) => _distanceSq(a.coordinates, tileCenter)
          .compareTo(_distanceSq(b.coordinates, tileCenter)),
    );

    // Create the new Tiles.
    for (final tile in tilesToLoad) {
      tile.load();
    }
  }

  /// Rounds the zoom to the nearest int and clamps it to the native zoom limits
  /// if there are any.
  int _clampToNativeZoom(double zoom) =>
      zoom.round().clamp(widget.minNativeZoom, widget.maxNativeZoom);

  void _onTileLoadError(TileImage tile, Object error, StackTrace? stackTrace) {
    debugPrint(error.toString());
    widget.errorTileCallback?.call(tile, error, stackTrace);
  }

  void _pruneIfAllTilesLoaded(TileCoordinates coordinates) {
    if (!_tileImageManager.containsTileAt(coordinates) ||
        !_tileImageManager.allLoaded) {
      return;
    }

    widget.tileDisplay.when(instantaneous: (_) {
      _pruneWithCurrentCamera();
    }, fadeIn: (fadeIn) {
      // Wait a bit more than tileFadeInDuration to trigger a pruning so that
      // we don't see tile removal under a fading tile.
      _pruneLater?.cancel();
      _pruneLater = Timer(
        fadeIn.duration + const Duration(milliseconds: 50),
        _pruneWithCurrentCamera,
      );
    });
  }

  void _pruneWithCurrentCamera() {
    final camera = MapCamera.of(context);
    final visibleTileRange = _tileRangeCalculator.calculate(
      camera: camera,
      tileZoom: _clampToNativeZoom(camera.zoom),
      center: camera.center,
      viewingZoom: camera.zoom,
    );
    _tileImageManager.prune(
      visibleRange: visibleTileRange,
      pruneBuffer: max(widget.panBuffer, widget.keepBuffer),
      evictStrategy: widget.evictErrorTileStrategy,
    );
  }
}

double _distanceSq(TileCoordinates coord, Point<double> center) {
  final dx = center.x - coord.x;
  final dy = center.y - coord.y;
  return dx * dx + dy * dy;
}
