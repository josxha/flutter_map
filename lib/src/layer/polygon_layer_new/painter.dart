part of 'polygon_layer.dart';

class _PolygonPainter extends CustomPainter {
  final List<Polygon> polygons;
  final MapCamera camera;

  LatLngBounds get bounds => camera.visibleBounds;

  final _polygonPaint = Paint()
    ..color = Colors.black
    ..strokeWidth = 1
    ..style = PaintingStyle.stroke;

  _PolygonPainter({
    required this.polygons,
    required this.camera,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final origin = (camera.project(camera.center) - camera.size / 2).toOffset();

    final points2 = <Offset>[];
    for (final polygon in polygons) {
      final proj = polygon.points
          .map((e) => camera.crs.projection.projectXY(e))
          .map((e) => DoublePoint(e.$1, e.$2))
          .toList(growable: false);

      final fillOffsets = getOffsetsXY(
        camera: camera,
        origin: origin,
        points: proj,
      );

      final basePoint = fillOffsets.first;
      for (var i = 1; i < proj.length - 1; i++) {
        points2.addAll([
          basePoint,
          fillOffsets[i],
          fillOffsets[i + 1],
        ]);
      }
    }

    final vertices = Vertices(VertexMode.triangles, points2);
    canvas.drawVertices(vertices, BlendMode.dst, _polygonPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
