import 'dart:math' as math hide Point;
import 'dart:math' show Point;

import 'package:flutter_map/flutter_map.dart';
import 'package:meta/meta.dart';

/// A range of tiles, this is normally a [DiscreteTileRange] and sometimes
/// a [EmptyTileRange].
@immutable
abstract class TileRange {
  /// The zoom level
  final int zoom;

  /// The base constructor the the abstract [TileRange] class.
  const TileRange(this.zoom);

  /// Get the list of coordinates for the range of tiles.
  Iterable<TileCoordinates> get coordinates;
}

/// A subclass of [TileRange] that just returns an empty [Iterable] if the
/// [coordinates] getter gets used.
@immutable
class EmptyTileRange extends TileRange {
  const EmptyTileRange._(super.zoom);

  @override
  Iterable<TileCoordinates> get coordinates =>
      const Iterable<TileCoordinates>.empty();
}

/// Every [TileRange] is a [DiscreteTileRange] if it's not an [EmptyTileRange].
@immutable
class DiscreteTileRange extends TileRange {
  /// Bounds are inclusive
  final Bounds<int> _bounds;

  /// Create a new [DiscreteTileRange] by setting it's values.
  const DiscreteTileRange(super.zoom, this._bounds);

  /// Calculate a [DiscreteTileRange] by using the pixel bounds.
  factory DiscreteTileRange.fromPixelBounds({
    required int zoom,
    required double tileSize,
    required Bounds<double> pixelBounds,
  }) {
    final Bounds<int> bounds;
    if (pixelBounds.min == pixelBounds.max) {
      final minAndMax = (pixelBounds.min / tileSize).floor();
      bounds = Bounds<int>(minAndMax, minAndMax);
    } else {
      bounds = Bounds<int>(
        (pixelBounds.min / tileSize).floor(),
        (pixelBounds.max / tileSize).ceil() - const Point(1, 1),
      );
    }

    return DiscreteTileRange(zoom, bounds);
  }

  /// Expand the [DiscreteTileRange] by a given amount in every direction.
  DiscreteTileRange expand(int count) {
    if (count == 0) return this;

    return DiscreteTileRange(
      zoom,
      _bounds
          .extend(Point<int>(_bounds.minX - count, _bounds.minY - count))
          .extend(Point<int>(_bounds.maxX + count, _bounds.maxY + count)),
    );
  }

  /// return the [TileRange] after this tile range got intersected with an
  /// [other] tile range.
  TileRange intersect(DiscreteTileRange other) {
    final boundsIntersection = _bounds.intersect(other._bounds);

    if (boundsIntersection == null) return EmptyTileRange._(zoom);

    return DiscreteTileRange(zoom, boundsIntersection);
  }

  /// Inclusive
  TileRange intersectX(int minX, int maxX) {
    if (_bounds.minX > maxX || _bounds.maxX < minX) {
      return EmptyTileRange._(zoom);
    }

    return DiscreteTileRange(
      zoom,
      Bounds<int>(
        Point<int>(math.max(min.x, minX), min.y),
        Point<int>(math.min(max.x, maxX), max.y),
      ),
    );
  }

  /// Inclusive
  TileRange intersectY(int minY, int maxY) {
    if (_bounds.minY > maxY || _bounds.maxY < minY) {
      return EmptyTileRange._(zoom);
    }

    return DiscreteTileRange(
      zoom,
      Bounds<int>(
        Point<int>(min.x, math.max(min.y, minY)),
        Point<int>(max.x, math.min(max.y, maxY)),
      ),
    );
  }

  /// Check if a [Point] is inside of the bounds of the [DiscreteTileRange].
  bool contains(Point<int> point) {
    return _bounds.contains(point);
  }

  /// The minimum [Point] of the [DiscreteTileRange]
  Point<int> get min => _bounds.min;

  /// The maximum [Point] of the [DiscreteTileRange]
  Point<int> get max => _bounds.max;

  /// The center [Point] of the [DiscreteTileRange]
  Point<double> get center => _bounds.center;

  /// Get a list of [TileCoordinates] for the [DiscreteTileRange].
  @override
  Iterable<TileCoordinates> get coordinates sync* {
    for (var j = _bounds.minY; j <= _bounds.maxY; j++) {
      for (var i = _bounds.minX; i <= _bounds.maxX; i++) {
        yield TileCoordinates(i, j, zoom);
      }
    }
  }

  @override
  String toString() => 'DiscreteTileRange($min, $max)';
}
