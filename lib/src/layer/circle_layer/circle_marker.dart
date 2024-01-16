import 'package:flutter/widgets.dart';
import 'package:latlong2/latlong.dart' hide Path;

/// Immutable marker options for circle markers
@immutable
class CircleMarker<R extends Object> {
  final LatLng point;
  final double radius;
  final Color color;
  final double borderStrokeWidth;
  final Color borderColor;
  final bool useRadiusInMeter;

  /// Value notified in [PolylineLayer.hitNotifier]
  ///
  /// Polylines without a defined [hitValue] are still hit tested, but are not
  /// notified about.
  ///
  /// Should implement an equality operator to avoid breaking [Polyline.==].
  final R? hitValue;

  const CircleMarker({
    required this.point,
    required this.radius,
    this.useRadiusInMeter = false,
    this.color = const Color(0xFF00FF00),
    this.borderStrokeWidth = 0.0,
    this.borderColor = const Color(0xFFFFFF00),
    this.hitValue,
  });
}
