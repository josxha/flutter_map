import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

part 'circle_painter.dart';

@immutable
class CircleLayer<R extends Object> extends StatelessWidget {
  /// A notifier to be notified when a hit test occurs on the layer
  ///
  /// If a notifier is not provided, hit testing is not performed.
  ///
  /// Notified with a [LayerHitResult] if any circles are hit, otherwise
  /// notified with `null`.
  ///
  /// See online documentation for more detailed usage instructions. See the
  /// example project for an example implementation.
  final LayerHitNotifier<R>? hitNotifier;

  /// The minimum radius of the hittable area around each [CircleMarker] in
  /// logical pixels.
  ///
  /// The entire visible area is always hittable, but if the visible area is
  /// smaller than this, then this will be the hittable area.
  ///
  /// Defaults to 10.
  final double minimumHitBox;

  final List<CircleMarker<R>> circles;

  const CircleLayer({
    super.key,
    required this.circles,
    this.hitNotifier,
    this.minimumHitBox = 10,
  });

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);
    return MobileLayerTransformer(
      child: CustomPaint(
        painter: CirclePainter<R>(
          circles: circles,
          camera: camera,
          hitNotifier: hitNotifier,
          minimumHitBox: minimumHitBox,
        ),
        size: Size(camera.size.x, camera.size.y),
        isComplex: true,
      ),
    );
  }
}
