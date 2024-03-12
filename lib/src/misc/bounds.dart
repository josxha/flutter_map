import 'dart:math' as math hide Point;
import 'dart:math' show Point;

import 'package:meta/meta.dart';

/// Rectangular bound delimited by orthogonal lines passing through two
/// points.
@immutable
class Bounds<T extends num> {
  /// The minimum x coordinate.
  final T minX;

  /// The maximum x coordinate.
  final T maxX;

  /// The minimum y coordinate.
  final T minY;

  /// The maximum y coordinate.
  final T maxY;

  /// Create a [Bounds] instance in a safe way.
  factory Bounds(Point<T> corner1, Point<T> corner2) {
    final T minX;
    final T maxX;
    if (corner1.x > corner2.x) {
      minX = corner2.x;
      maxX = corner1.x;
    } else {
      minX = corner1.x;
      maxX = corner2.x;
    }
    final T minY;
    final T maxY;
    if (corner1.y > corner2.y) {
      minY = corner2.y;
      maxY = corner1.y;
    } else {
      minY = corner1.y;
      maxY = corner2.y;
    }
    return Bounds.unsafe(minX: minX, maxX: maxX, maxY: maxY, minY: minY);
  }

  /// Create a [Bounds] instance from raw values.
  const Bounds.unsafe({
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
  })  : assert(
          maxY >= minY,
          "The maxY coordinate can't be smaller than the minY coordinate",
        ),
        assert(
          maxX >= minX,
          "The maxX coordinate can't be smaller than the minX coordinate",
        );

  /// Create a [Bounds] as bounding box of a list of points.
  static Bounds<double> containing(Iterable<Point<double>> points) {
    var maxX = double.negativeInfinity;
    var maxY = double.negativeInfinity;
    var minX = double.infinity;
    var minY = double.infinity;

    for (final point in points) {
      maxX = math.max(point.x, maxX);
      minX = math.min(point.x, minX);
      maxY = math.max(point.y, maxY);
      minY = math.min(point.y, minY);
    }

    return Bounds.unsafe(minX: minX, minY: minY, maxX: maxX, maxY: maxY);
  }

  /// Creates a new [Bounds] obtained by expanding the current ones with a new
  /// point.
  Bounds<T> extend(Point<T> point) => Bounds.unsafe(
        minX: math.min(point.x, minX),
        minY: math.min(point.y, minY),
        maxX: math.max(point.x, maxX),
        maxY: math.max(point.y, maxY),
      );

  /// This [Bounds] central point.
  Point<double> get center =>
      Point<double>((minX + maxX) / 2, (minY + maxY) / 2);

  /// Bottom-Left corner's point.
  Point<T> get bottomLeft => Point<T>(minX, maxY);

  /// Top-Right corner's point.
  Point<T> get topRight => Point<T>(maxX, minY);

  /// Top-Left corner's point.
  Point<T> get topLeft => Point<T>(minX, minY);

  /// Bottom-Right corner's point.
  Point<T> get bottomRight => Point<T>(maxX, maxY);

  /// A point that contains the difference between the point's axis projections.
  Point<T> get size => Point<T>((maxX - minX) as T, (maxY - minY) as T);

  /// Check if a [Point] is inside of the bounds.
  bool contains(Point<T> point) {
    return (point.x >= minX) &&
        (point.x <= maxX) &&
        (point.y >= minY) &&
        (point.y <= maxY);
  }

  /// Check if an other [Bounds] object is inside of the bounds.
  bool containsBounds(Bounds<T> b) {
    return (b.minX >= minX) &&
        (b.maxX <= maxX) &&
        (b.minY >= minY) &&
        (b.maxY <= maxY);
  }

  /// Checks if a part of the other [Bounds] is contained in this [Bounds].
  bool containsPartialBounds(Bounds<T> b) {
    return (b.minX <= maxX) &&
        (b.maxX >= minX) &&
        (b.minY <= maxY) &&
        (b.maxY >= minY);
  }

  /// Checks if the line between the two coordinates is contained within the
  /// [Bounds].
  bool aabbContainsLine(double x1, double y1, double x2, double y2) {
    // Completely outside.
    if ((x1 <= minX && x2 <= minX) ||
        (y1 <= minY && y2 <= minY) ||
        (x1 >= maxX && x2 >= maxX) ||
        (y1 >= maxY && y2 >= maxY)) {
      return false;
    }

    final m = (y2 - y1) / (x2 - x1);

    double y = m * (minX - x1) + y1;
    if (y > minY && y < maxY) return true;

    y = m * (maxX - x1) + y1;
    if (y > minY && y < maxY) return true;

    double x = (minY - y1) / m + x1;
    if (x > minX && x < maxX) return true;

    x = (maxY - y1) / m + x1;
    if (x > minX && x < maxX) return true;

    return false;
  }

  /// Calculates the intersection of two Bounds. The return value will be null
  /// if there is no intersection. The returned bounds may be zero size
  /// (bottomLeft == topRight).
  Bounds<T>? intersect(Bounds<T> b) {
    final leftX = math.max(minX, b.minX);
    final rightX = math.min(maxX, b.maxX);
    final topY = math.max(minY, b.minY);
    final bottomY = math.min(maxY, b.maxY);

    if (leftX <= rightX && topY <= bottomY) {
      return Bounds.unsafe(minX: leftX, minY: topY, maxX: rightX, maxY: maxY);
    }

    return null;
  }

  @override
  String toString() =>
      'Bounds(minX: $minX, minY: $minY, maxX: $maxX, maxY: $maxY)';
}
