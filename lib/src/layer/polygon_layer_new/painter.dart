part of 'polygon_layer.dart';

class _PolygonPainter extends CustomPainter {
  final List<Polygon> polygons;
  final MapCamera camera;

  LatLngBounds get bounds => camera.visibleBounds;

  final _polygonPaint = Paint()
    ..color = Colors.black
    ..strokeWidth = 1
    ..style = PaintingStyle.stroke;

  final Epsg3857 crs;
  final SphericalMercator projection;
  late final int amountVertices;

  _PolygonPainter({
    required this.polygons,
    required this.camera,
  })  : crs = camera.crs as Epsg3857,
        projection = camera.crs.projection as SphericalMercator {
    amountVertices = polygons.map((e) => e.points.length).sum;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final zoomScale = camera.crs.scale(camera.zoom);
    final centerPointX =
        projectAndTransformLon(camera.center.longitude, zoomScale);
    final centerPointY =
        projectAndTransformLat(camera.center.latitude, zoomScale);
    final originX = centerPointX - camera.size.x / 2;
    final originY = centerPointY - camera.size.y / 2;

    final floatList = Float32List(amountVertices * 6);
    int f = 0;
    for (var i = 0; i < polygons.length; i++) {
      final points = polygons[i].points;
      final baseX = projectAndTransformLon(points.first.longitude, zoomScale);
      final baseY = projectAndTransformLat(points.first.latitude, zoomScale);
      for (var j = 0; j < points.length - 1; j++) {
        floatList[f++] = baseX - originX;
        floatList[f++] = baseY - originY;

        var x = projectAndTransformLon(points[j].longitude, zoomScale);
        var y = projectAndTransformLat(points[j].latitude, zoomScale);
        floatList[f++] = x - originX;
        floatList[f++] = y - originY;
        x = projectAndTransformLon(points[j + 1].longitude, zoomScale);
        y = projectAndTransformLat(points[j + 1].latitude, zoomScale);
        floatList[f++] = x - originX;
        floatList[f++] = y - originY;
      }
    }

    final vertices = Vertices.raw(VertexMode.triangles, floatList);
    canvas.drawVertices(vertices, BlendMode.dst, _polygonPaint);
  }

  double projectAndTransformLon(double lon, double zoomScale) {
    return zoomScale *
        (crs.transformation.a * SphericalMercator.projectLng(lon) +
            crs.transformation.b);
  }

  double projectAndTransformLat(double lat, double zoomScale) {
    return zoomScale *
        (crs.transformation.c * SphericalMercator.projectLat(lat) +
            crs.transformation.d);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
