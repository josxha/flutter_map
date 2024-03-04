part of 'base.dart';

class HttpWmsTileProvider extends WmsTileProvider {
  final BaseClient httpClient;

  HttpWmsTileProvider({
    BaseClient? httpClient,
    required super.baseUrl,
    super.layers = const <String>[],
    super.styles = const <String>[],
    super.format = 'image/png',
    super.version = '1.1.1',
    super.transparent = true,
    super.uppercaseBoolValue = false,
    super.crs = const Epsg3857(),
    super.otherParameters = const <String, String>{},
    super.headers = const <String, String>{},
  }) : httpClient = httpClient ?? RetryClient(Client());

  @override
  ImageProvider<Object> getImage(
    TileCoordinates coordinates,
    TileLayer layer,
    Future<void> cancelLoading,
  ) {
    return HttpImageProvider(
      uri: Uri.parse(getTileUrl(coordinates, layer)),
      headers: headers,
      httpClient: httpClient,
      silenceExceptions: silenceExceptions,
      startedLoading: () => _tilesInProgress[coordinates] = Completer(),
      finishedLoadingBytes: () {
        _tilesInProgress[coordinates]?.complete();
        _tilesInProgress.remove(coordinates);
      },
    );
  }
}
