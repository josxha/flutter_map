import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/src/layer/tile_layer_new/tile/tile_coordinates.dart';

/// The [TileImageCache] stores all loaded [TileImage]s with their
/// [TileCoordinates].
final class TileImageCache {
  final Map<TileCoordinates, TileImage> _images = {};

  /// Create a new [TileImageCache] instance.
  TileImageCache();
}
