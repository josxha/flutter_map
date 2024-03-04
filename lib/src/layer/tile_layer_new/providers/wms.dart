part of 'base.dart';

abstract class WmsTileProvider extends NetworkTileProvider {
  /// List of WMS layers to show
  final List<String> layers;

  /// List of WMS styles
  final List<String> styles;

  /// WMS image format (use 'image/png' for layers with transparency)
  final String format;

  /// Version of the WMS service to use
  final String version;

  /// Whether to make tiles transparent
  final bool transparent;

  /// Encode boolean values as uppercase in request
  final bool uppercaseBoolValue;

  /// Sets map projection standard
  final Crs crs;

  /// Other request parameters
  final Map<String, String> otherParameters;

  late final Uri _encodedBaseUri;

  final double _versionNumber;

  WmsTileProvider({
    /// WMS service's URL, for example 'http://ows.mundialis.de/services/service?'
    required String baseUrl,
    this.layers = const <String>[],
    this.styles = const <String>[],
    this.format = 'image/png',
    this.version = '1.1.1',
    this.transparent = true,
    this.uppercaseBoolValue = false,
    this.crs = const Epsg3857(),
    this.otherParameters = const <String, String>{},
    super.headers = const <String, String>{},
  })  : _versionNumber =
            double.tryParse(version.split('.').take(2).join('.')) ?? 0,
        super(uriTemplate: baseUrl) {
    _encodedBaseUri = _buildEncodedBaseUrl();
  }

  Uri _buildEncodedBaseUrl() {
    final uri = Uri.parse(uriTemplate);
    final queryParams = uri.queryParameters;
    queryParams.addAll(<String, String>{
      'service': 'WMS',
      'request': 'GetMap',
      'layers': layers.join(','),
      'styles': styles.join(','),
      'format': format,
      _versionNumber >= 1.3 ? 'crs' : 'srs': crs.code,
      'version': version,
      'transparent': uppercaseBoolValue
          ? transparent.toString().toUpperCase()
          : transparent.toString(),
    });
    queryParams.addAll(otherParameters);
    return uri.replace(queryParameters: queryParams);
  }

  /// Build the URL for a tile
  String getUrl(TileCoordinates coords, int tileSize, bool retinaMode) {
    final nwPoint = coords * tileSize;
    final sePoint = nwPoint + Point<int>(tileSize, tileSize);
    final nwCoords = crs.pointToLatLng(nwPoint, coords.z.toDouble());
    final seCoords = crs.pointToLatLng(sePoint, coords.z.toDouble());
    final nw = crs.projection.project(nwCoords);
    final se = crs.projection.project(seCoords);
    final bounds = Bounds.unsafe(nw, se);
    final bbox = (_versionNumber >= 1.3 && crs is Epsg4326)
        ? [bounds.min.y, bounds.min.x, bounds.max.y, bounds.max.x]
        : [bounds.min.x, bounds.min.y, bounds.max.x, bounds.max.y];

    final buffer = StringBuffer(_encodedBaseUri.toString());
    buffer.write('&width=${retinaMode ? tileSize * 2 : tileSize}');
    buffer.write('&height=${retinaMode ? tileSize * 2 : tileSize}');
    buffer.write('&bbox=${bbox.join(',')}');
    return buffer.toString();
  }
}
