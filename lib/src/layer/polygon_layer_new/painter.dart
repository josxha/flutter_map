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

    final amountVertices = polygons.map((e) => e.points.length).sum;

    final floatList = Float32List(amountVertices * 2 * 5);
    int f = 0;
    for (var i = 0; i < polygons.length; i++) {
      final points = polygons[i].points;
      final xyBase = camera.crs.projection.projectXY(points.first);
      final (xBase, yBase) = camera.crs
          .transform(xyBase.$1, xyBase.$2, camera.crs.scale(camera.zoom));
      for (var j = 0; j < points.length - 1; j++) {
        floatList[f++] = xBase - origin.dx;
        floatList[f++] = yBase - origin.dy;

        var xy = camera.crs.projection.projectXY(points[j]);
        var (x, y) =
            camera.crs.transform(xy.$1, xy.$2, camera.crs.scale(camera.zoom));
        floatList[f++] = x - origin.dx;
        floatList[f++] = y - origin.dy;
        xy = camera.crs.projection.projectXY(points[j + 1]);
        (x, y) =
            camera.crs.transform(xy.$1, xy.$2, camera.crs.scale(camera.zoom));
        floatList[f++] = x - origin.dx;
        floatList[f++] = y - origin.dy;
      }
    }

    final vertices = Vertices.raw(VertexMode.triangles, floatList);
    canvas.drawVertices(vertices, BlendMode.dst, _polygonPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
