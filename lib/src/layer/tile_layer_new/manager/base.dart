import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter_map/src/layer/tile_layer_new/tile/tile_coordinates.dart';
import 'package:flutter_map/src/layer/tile_layer_new/tile_range.dart';
import 'package:flutter_map/src/map/camera/camera.dart';

part 'default.dart';

abstract class TileManager {
  const TileManager();

  void update(MapCamera camera);

  /// Stream to notify the [TileLayer] that it needs resetting
  ///
  /// The tile layer will not listen to this stream if it is not specified on
  /// initial building, then later specified.
  void reset();

  List<Tile> getTilesToRender(DiscreteTileRange visibleRange);

  bool hasTile(TileCoordinates coordinates);

  bool allLoaded;
}
