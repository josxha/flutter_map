part of 'base.dart';

abstract class NetworkTileProvider extends UriTileProvider {
  /// Custom HTTP headers that may be sent with each tile request
  ///
  /// Non-networking implementations may ignore this property.
  ///
  /// [TileLayer] will usually automatically set the 'User-Agent' header, based
  /// on the `userAgentPackageName`, but this can be overridden. On the web, this
  /// header cannot be changed, as specified in [TileLayer.tileProvider]'s
  /// documentation, due to a Dart/browser limitation.
  final Map<String, String> headers;

  const NetworkTileProvider({
    required super.uriTemplate,
    this.headers = const <String, String>{},
    super.additionalUriParameters = const <String, String>{},
    super.subdomains = const <String>[],
  });
}
