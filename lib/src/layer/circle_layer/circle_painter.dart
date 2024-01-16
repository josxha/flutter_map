part of 'circle_layer.dart';

@immutable
class CirclePainter<R extends Object> extends CustomPainter {
  final List<CircleMarker<R>> circles;
  final MapCamera camera;
  final LayerHitNotifier<R>? hitNotifier;
  final double minimumHitBox;

  final _hits = <R>[]; // Avoids repetitive memory reallocation

  CirclePainter({
    required this.circles,
    required this.camera,
    required this.hitNotifier,
    required this.minimumHitBox,
  });

  @override
  bool? hitTest(Offset position) {
    if (hitNotifier == null) return null;

    _hits.clear();

    final origin =
        camera.project(camera.center).toOffset() - camera.size.toOffset() / 2;

    for (final circle in circles.reversed) {
      if (circle.hitValue == null) continue;

      // TODO: For efficiency we'd ideally filter by bounding box here. However
      // we'd need to compute an extended bounding box that accounts account for
      // the stroke width.
      // if (!p.boundingBox.contains(touch)) {
      //   continue;
      // }

      final offset = getOffset(origin, circle.point);
      final hittableDistance = math.max(
        circle.borderStrokeWidth / 2 + circle.borderStrokeWidth / 2,
        minimumHitBox,
      );

      final dx = position.dx - offset.dx;
      final dy = position.dy - offset.dy;
      final distance = dx * dx + dy * dy;

      if (distance < hittableDistance) {
        _hits.add(circle.hitValue!);
        break;
      }
    }

    if (_hits.isEmpty) {
      hitNotifier!.value = null;
      return false;
    }

    hitNotifier!.value = LayerHitResult(
      hitValues: _hits,
      point: camera.pointToLatLng(math.Point(position.dx, position.dy)),
    );
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    const distance = Distance();
    final rect = Offset.zero & size;
    canvas.clipRect(rect);

    // Let's calculate all the points grouped by color and radius
    final points = <Color, Map<double, List<Offset>>>{};
    final pointsFilledBorder = <Color, Map<double, List<Offset>>>{};
    final pointsBorder = <Color, Map<double, Map<double, List<Offset>>>>{};
    for (final circle in circles) {
      final offset = camera.getOffsetFromOrigin(circle.point);
      double radius = circle.radius;
      if (circle.useRadiusInMeter) {
        final r = distance.offset(circle.point, circle.radius, 180);
        final delta = offset - camera.getOffsetFromOrigin(r);
        radius = delta.distance;
      }
      points[circle.color] ??= {};
      points[circle.color]![radius] ??= [];
      points[circle.color]![radius]!.add(offset);

      if (circle.borderStrokeWidth > 0) {
        // Check if color have some transparency or not
        // As drawPoints is more efficient than drawCircle
        if (circle.color.alpha == 0xFF) {
          double radiusBorder = circle.radius + circle.borderStrokeWidth;
          if (circle.useRadiusInMeter) {
            final rBorder = distance.offset(circle.point, radiusBorder, 180);
            final deltaBorder = offset - camera.getOffsetFromOrigin(rBorder);
            radiusBorder = deltaBorder.distance;
          }
          pointsFilledBorder[circle.borderColor] ??= {};
          pointsFilledBorder[circle.borderColor]![radiusBorder] ??= [];
          pointsFilledBorder[circle.borderColor]![radiusBorder]!.add(offset);
        } else {
          double realRadius = circle.radius;
          if (circle.useRadiusInMeter) {
            final rBorder = distance.offset(circle.point, realRadius, 180);
            final deltaBorder = offset - camera.getOffsetFromOrigin(rBorder);
            realRadius = deltaBorder.distance;
          }
          pointsBorder[circle.borderColor] ??= {};
          pointsBorder[circle.borderColor]![circle.borderStrokeWidth] ??= {};
          pointsBorder[circle.borderColor]![circle.borderStrokeWidth]![
              realRadius] ??= [];
          pointsBorder[circle.borderColor]![circle.borderStrokeWidth]![
                  realRadius]!
              .add(offset);
        }
      }
    }

    // Now that all the points are grouped, let's draw them
    final paintBorder = Paint()..style = PaintingStyle.stroke;
    for (final color in pointsBorder.keys) {
      final paint = paintBorder..color = color;
      for (final borderWidth in pointsBorder[color]!.keys) {
        final pointsByRadius = pointsBorder[color]![borderWidth]!;
        final radiusPaint = paint..strokeWidth = borderWidth;
        for (final radius in pointsByRadius.keys) {
          final pointsByRadiusColor = pointsByRadius[radius]!;
          for (final offset in pointsByRadiusColor) {
            _paintCircle(canvas, offset, radius, radiusPaint);
          }
        }
      }
    }

    // Then the filled border in order to be under the circle
    final paintPoint = Paint()
      ..isAntiAlias = false
      ..strokeCap = StrokeCap.round;
    for (final color in pointsFilledBorder.keys) {
      final paint = paintPoint..color = color;
      final pointsByRadius = pointsFilledBorder[color]!;
      for (final radius in pointsByRadius.keys) {
        final pointsByRadiusColor = pointsByRadius[radius]!;
        final radiusPaint = paint..strokeWidth = radius * 2;
        _paintPoints(canvas, pointsByRadiusColor, radiusPaint);
      }
    }

    // And then the circle
    for (final color in points.keys) {
      final paint = paintPoint..color = color;
      final pointsByRadius = points[color]!;
      for (final radius in pointsByRadius.keys) {
        final pointsByRadiusColor = pointsByRadius[radius]!;
        final radiusPaint = paint..strokeWidth = radius * 2;
        _paintPoints(canvas, pointsByRadiusColor, radiusPaint);
      }
    }
  }

  void _paintPoints(Canvas canvas, List<Offset> offsets, Paint paint) {
    canvas.drawPoints(PointMode.points, offsets, paint);
  }

  void _paintCircle(Canvas canvas, Offset offset, double radius, Paint paint) {
    canvas.drawCircle(offset, radius, paint);
  }

  @override
  bool shouldRepaint(CirclePainter oldDelegate) =>
      circles != oldDelegate.circles || camera != oldDelegate.camera;

  Offset getOffset(Offset origin, LatLng point) {
    // Critically create as little garbage as possible. This is called on every frame.
    final projected = camera.project(point);
    return Offset(projected.x - origin.dx, projected.y - origin.dy);
  }
}
