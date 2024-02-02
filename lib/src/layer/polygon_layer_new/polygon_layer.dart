import 'dart:typed_data';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

part 'painter.dart';

@immutable
class PolygonLayer2 extends StatefulWidget {
  final List<Polygon> polygons;

  const PolygonLayer2({
    super.key,
    required this.polygons,
  });

  @override
  State<PolygonLayer2> createState() => _PolygonLayer2State();
}

class _PolygonLayer2State extends State<PolygonLayer2> {
  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);

    return MobileLayerTransformer(
      child: CustomPaint(
        painter: _PolygonPainter(
          polygons: widget.polygons,
          camera: camera,
        ),
        size: Size(camera.size.x, camera.size.y),
      ),
    );
  }
}