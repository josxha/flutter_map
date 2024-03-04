part of 'base.dart';

abstract class UriTileProvider extends TileProvider {
  /// The URL template is a string that contains placeholders, which, when filled
  /// in, create a URL/URI to a specific tile.
  ///
  /// For more information, see <https://docs.fleaflet.dev/layers/tile-layer>.
  final String uriTemplate;

  /// List of subdomains for the URL.
  ///
  /// Example:
  ///
  /// Subdomains = {a,b,c}
  ///
  /// and the URL is as follows:
  ///
  /// https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png
  ///
  /// then:
  ///
  /// https://a.tile.openstreetmap.org/{z}/{x}/{y}.png
  /// https://b.tile.openstreetmap.org/{z}/{x}/{y}.png
  /// https://c.tile.openstreetmap.org/{z}/{x}/{y}.png
  final List<String> subdomains;

  /// Static information that should replace placeholders in the [urlTemplate].
  /// Applying API keys is a good example on how to use this parameter.
  ///
  /// Example:
  ///
  /// ```dart
  ///
  /// TileLayerOptions(
  ///     urlTemplate: "https://api.tiles.mapbox.com/v4/"
  ///                  "{id}/{z}/{x}/{y}{r}.png?access_token={accessToken}",
  ///     additionalOptions: {
  ///         'accessToken': '<PUT_ACCESS_TOKEN_HERE>',
  ///          'id': 'mapbox.streets',
  ///     },
  /// ),
  /// ```
  final Map<String, String> additionalUriParameters;

  /// Regex that describes the format of placeholders in a `urlTemplate`
  ///
  /// Used internally by [populateUriPlaceholders], but may also be used
  /// externally.
  static final templatePlaceholderElement = RegExp('{([^{}]*)}');

  const UriTileProvider({
    required this.uriTemplate,
    this.additionalUriParameters = const <String, String>{},
    this.subdomains = const <String>[],
  });

  String populateUriTemplate(TileCoordinates coordinates, TileLayer layer) {
    final zoom = (layer.zoomOffset +
            (layer.zoomReverse
                ? layer.maxZoom - coordinates.z.toDouble()
                : coordinates.z.toDouble()))
        .round();

    final replacements = {
      'x': coordinates.x.toString(),
      'y': (layer.tms ? ((1 << zoom) - 1) - coordinates.y : coordinates.y)
          .toString(),
      'z': zoom.toString(),
      's': subdomains.isEmpty
          ? ''
          : subdomains[
              (coordinates.x + coordinates.y) % layer.subdomains.length],
      'r': layer.resolvedRetinaMode == RetinaMode.server ? '@2x' : '',
      'd': layer.tileSize.toString(),
      ...additionalUriParameters,
    };

    return uriTemplate.replaceAllMapped(templatePlaceholderElement, (match) {
      final key = match.group(1);
      final value = replacements[key];
      if (value != null) return value;
      throw ArgumentError(
        'Missing value for placeholder "$key" in URI: {${match.group(1)}}',
      );
    });
  }
}
