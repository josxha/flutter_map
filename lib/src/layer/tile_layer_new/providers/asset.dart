part of 'base.dart';

/// Fetch tiles from the app's shipped assets, where the tile URL is a path
/// within the asset store
///
/// Uses [AssetImage] internally.
///
/// All tiles must be listed as assets as normal in the pubspec.yaml config file.
class AssetTileProvider extends UriTileProvider {
  const AssetTileProvider({required super.uriTemplate});

  @override
  ImageProvider<Object> getImage(
    TileCoordinates coordinates,
    TileLayer layer,
    Future<void> cancelLoading,
  ) {
    final assetName = populateUriTemplate(coordinates, layer);
    return AssetImage(assetName);
  }
}
