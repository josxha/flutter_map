import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_example/widgets/simplification_tolerance_slider.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';
import 'package:latlong2/latlong.dart';

class PolylineGeoJsonPage extends StatefulWidget {
  static const String route = '/polygon_geojson';

  const PolylineGeoJsonPage({super.key});

  @override
  State<PolylineGeoJsonPage> createState() => _PolylineGeoJsonPageState();
}

class _PolylineGeoJsonPageState extends State<PolylineGeoJsonPage> {
  static const double _initialSimplificationTolerance = 0.5;
  double simplificationTolerance = _initialSimplificationTolerance;

  List<Polyline>? _polylines;

  @override
  void initState() {
    Future.microtask(() async {
      final parser = GeoJsonParser(
        polyLineCreationCallback: (points, properties) => Polyline(
          points: points,
          color: Colors.red,
          strokeWidth: 1,
        ),
      );
      final string =
          await rootBundle.loadString('assets/tiefenlinien-1m.geojson');
      parser.parseGeoJsonAsString(string);
      setState(() {
        _polylines = parser.polylines;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Polygon Stress Test')),
      body: Stack(
        children: [
          FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(47.726313, 9.180082),
              initialZoom: 11,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'dev.fleaflet.flutter_map.example',
              ),
              if (_polylines != null)
                PolylineLayer(
                  simplificationTolerance: simplificationTolerance,
                  polylines: _polylines!,
                ),
            ],
          ),
          Positioned(
            left: 16,
            top: 16,
            right: 16,
            child: SimplificationToleranceSlider(
              initialTolerance: _initialSimplificationTolerance,
              onChangedTolerance: (v) =>
                  setState(() => simplificationTolerance = v),
            ),
          ),
          if (!kIsWeb)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: PerformanceOverlay.allEnabled(),
            ),
        ],
      ),
    );
  }
}
