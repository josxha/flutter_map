part of 'base.dart';

class HttpTileProvider extends NetworkTileProvider {
  final BaseClient httpClient;

  HttpTileProvider({
    required super.uriTemplate,
    BaseClient? httpClient,
    super.subdomains = const <String>[],
    super.additionalUriParameters = const <String, String>{},
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
