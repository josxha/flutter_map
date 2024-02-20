import 'package:meta/meta.dart';

@immutable
class TileCoordinates {
  /// The x coordinate of the tile coordinates.
  final int x;

  /// The y coordinate of the tile coordinates.
  final int y;

  /// The zoom level of the tile coordinates.
  final int z;

  /// Create a new [TileCoordinates] instance.
  const TileCoordinates(this.x, this.y, this.z);

  @override
  String toString() => 'TileCoordinate($x, $y, $z)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TileCoordinates &&
        other.x == x &&
        other.y == y &&
        other.z == z;
  }

  @override
  int get hashCode {
    // NOTE: the odd numbers are due to JavaScript's integer precision of 53 bits.
    return x ^ y << 24 ^ z << 48;
  }
}
