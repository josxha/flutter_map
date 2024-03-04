import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart' hide TileLayer;
import 'package:flutter_map/src/layer/tile_layer_new/bounds/tile_bounds.dart';
import 'package:flutter_map/src/layer/tile_layer_new/bounds/tile_bounds_at_zoom.dart';
import 'package:flutter_map/src/layer/tile_layer_new/manager/base.dart';
import 'package:flutter_map/src/layer/tile_layer_new/providers/base.dart';
import 'package:flutter_map/src/layer/tile_layer_new/tile/tile_builders.dart';

class TileLayer extends StatefulWidget {
  /// Size for the tile.
  ///
  /// Default is 256.
  final double tileSize;

  /// The minimum zoom level down to which this layer will be displayed
  /// (inclusive)
  ///
  /// This should usually be 0 (as default).
  final double minZoom;

  /// The maximum zoom level up to which this layer will be displayed
  /// (inclusive).
  ///
  /// Prefer [maxNativeZoom] for setting the maximum zoom level supported by the
  /// tile source. The main usage for this is to display a different [TileLayer]
  /// when zoomed far in.
  ///
  /// Otherwise, this should usually be infinite (as default), so that there are
  /// tiles always displayed.
  final double maxZoom;

  /// Minimum zoom level supported by the tile source
  ///
  /// Tiles from below this zoom level will not be displayed, instead tiles at
  /// this zoom level will be displayed and scaled.
  ///
  /// This should usually be 0 (as default), as most tile sources will support
  /// zoom levels onwards from this.
  final int minNativeZoom;

  /// Maximum zoom number supported by the tile source has available.
  ///
  /// Tiles from above this zoom level will not be displayed, instead tiles at
  /// this zoom level will be displayed and scaled.
  ///
  /// Most tile servers support up to zoom level 19, which is the default.
  /// Otherwise, this should be specified.
  final int maxNativeZoom;

  /// Provider with which to load map tiles
  ///
  /// The default is [NetworkTileProvider] which supports both IO and web
  /// platforms, with basic session-only caching. It uses a [RetryClient] backed
  /// by a standard [Client] to retry failed requests.
  ///
  /// `userAgentPackageName` is a [TileLayer] parameter, which should be passed
  /// the application's correct package name, such as 'com.example.app'. See
  /// https://docs.fleaflet.dev/layers/tile-layer#useragentpackagename for
  /// more information.
  ///
  /// For information about other prebuilt tile providers, see
  /// https://docs.fleaflet.dev/layers/tile-layer/tile-providers.
  final TileProvider tileProvider;

  /// If `true`, inverses Y axis numbering for tiles (turn this on for
  /// [TMS](https://en.wikipedia.org/wiki/Tile_Map_Service) services).
  final bool tms;

  final Duration fadeInDuration;
  final double fadeInStartOpacity;
  final double fadeInEndOpacity;

  /// When panning the map, keep this many rows and columns of tiles before
  /// unloading them.
  final int keepBuffer;

  /// When loading tiles only visible tiles are loaded by default. This option
  /// increases the loaded tiles by the given number on both axis which can help
  /// prevent the user from seeing loading tiles whilst panning. Setting the
  /// pan buffer too high can impact performance, typically this is set to zero
  /// or one.
  final int panBuffer;

  /// If set to true, the zoom number used in tile URLs will be reversed
  /// (`maxZoom - zoom` instead of `zoom`)
  final bool zoomReverse;

  /// The zoom number used in tile URLs will be offset with this value.
  final double zoomOffset;

  /// Only load tiles that are within these bounds
  final LatLngBounds? tileBounds;

  final TileManager tileManager;

  /// Tile image to show in place of the tile that failed to load.
  final ImageProvider Function(
    Object error,
    StackTrace? stackTrace,
    Tile tile,
  )? errorTileBuilder;

  /// Function which may Wrap Tile with custom Widget
  /// There are predefined examples in 'tile_builder.dart'
  final TileBuilder? tileBuilder;

  const TileLayer({
    super.key,
    this.minZoom = 0,
    this.maxZoom = double.infinity,
    required this.tileSize,
    this.minNativeZoom = 0,
    this.maxNativeZoom = 19,
    this.tileBounds,
    this.zoomReverse = false,
    this.zoomOffset = 0.0,
    this.tms = false,
    this.fadeInDuration = Duration.zero,
    this.fadeInStartOpacity = 0.0,
    this.fadeInEndOpacity = 1.0,
    required this.tileProvider,
    this.tileManager = const DefaultTileManager(),
  }) : assert(
          (maxZoom == double.infinity) ^ zoomReverse,
          'maxZoom needs to be set for the TileLayer when zoomReverse is true.',
        );

  @override
  State<TileLayer> createState() => _TileLayerState();
}

class _TileLayerState extends State<TileLayer> {
  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);
    final zoom = camera.zoom;

    // check if outside the zoom limits
    if (zoom < widget.minZoom || zoom > widget.maxZoom) {
      return const SizedBox.shrink();
    }

    final tileZoom = _clampToNativeZoom(zoom);

    widget.tileManager.update(camera);

    // Note: `renderTiles` filters out all tiles that are either off-screen or
    // tiles at non-target zoom levels that are would be completely covered by
    // tiles that are *ready* and at the target zoom level.
    // We're happy to do a bit of diligent work here, since tiles not
    // rendered are cycles saved later on in the render pipeline.
    final tiles = widget.tileManager
        .getTilesToRender(visibleRange: visibleTileRange)
        .map((tileImage) => Tile(
              // Must be an ObjectKey, not a ValueKey using the coordinates, in
              // case we remove and replace the TileImage with a different one.
              key: ObjectKey(tileImage),
              scaledTileSize: _tileScaleCalculator.scaledTileSize(
                camera.zoom,
                tileImage.coordinates.z,
              ),
              currentPixelOrigin: camera.pixelOrigin,
              tileImage: tileImage,
              tileBuilder: widget.tileBuilder,
            ))
        .toList();

    // Sort in render order. In reverse:
    //   1. Tiles at the current zoom.
    //   2. Tiles at the current zoom +/- 1.
    //   3. Tiles at the current zoom +/- 2.
    //   4. ...etc
    int renderOrder(Tile a, Tile b) {
      final za = a.tileImage.coordinates.z;
      final zb = b.tileImage.coordinates.z;
      final cmp = (zb - tileZoom).abs().compareTo((za - tileZoom).abs());
      if (cmp == 0) {
        // When compare parent/child tiles of equal distance,
        // prefer higher res images.
        return za.compareTo(zb);
      }
      return cmp;
    }

    return MobileLayerTransformer(
      child: Stack(children: tiles..sort(renderOrder)),
    );
  }

  /// Rounds the zoom to the nearest int and clamps it to the native zoom limits
  /// if there are any.
  int _clampToNativeZoom(double zoom) =>
      zoom.clamp(widget.minNativeZoom, widget.maxNativeZoom).round();
}
