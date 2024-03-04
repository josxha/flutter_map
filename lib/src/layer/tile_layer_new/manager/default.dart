part of 'base.dart';

class DefaultTileManager extends TileManager {
  final Map<TileCoordinates, TileImage> _tiles =
      HashMap<TileCoordinates, TileImage>();

  DefaultTileManager();

  /// Check if the [TileImageManager] has the tile for a given tile cooridantes.
  @override
  bool hasTile(TileCoordinates coordinates) => _tiles.containsKey(coordinates);

  /// Check if all tile images are loaded
  @override
  bool get allLoaded =>
      _tiles.values.none((tile) => tile.loadFinishedAt == null);

  /// Check if all loaded tiles are within the [minZoom] and [maxZoom] level.
  bool allWithinZoomBounds(double minZoom, double maxZoom) => _tiles.values
      .map((e) => e.coordinates)
      .every((coords) => coords.z > maxZoom || coords.z < minZoom);

  @override
  void update(MapCamera camera) {
    // TODO: implement update
    throw UnimplementedError();
  }

  @override
  void reset() {
    // TODO: implement reset
  }

  @override
  List<dynamic> getTilesToRender(DiscreteTileRange visibleRange) {
    // TODO: implement getTilesToRender
    throw UnimplementedError();
  }
}
