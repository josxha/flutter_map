part of 'base.dart';

/// Fetch tiles from the local filesystem (not asset store), where the tile URL
/// is a path within the filesystem.
///
/// Uses [FileImage] internally.
///
/// If [TileLayer.fallbackUrl] is specified, the [File] must first be
/// synchronously checked for existence - this blocks the main thread, and as
/// such, specifying [TileLayer.fallbackUrl] should be avoided when using this
/// provider.
class FileTileProvider extends UriTileProvider {
  /// Fetch tiles from the local filesystem (not asset store), where the tile URL
  /// is a path within the filesystem.
  ///
  /// Uses [FileImage] internally.
  ///
  /// If [TileLayer.fallbackUrl] is specified, the [File] must first be
  /// synchronously checked for existence - this blocks the main thread, and as
  /// such, specifying [TileLayer.fallbackUrl] should be avoided when using this
  /// provider.
  const FileTileProvider({required super.uriTemplate});

  @override
  ImageProvider getImage(
    TileCoordinates coordinates,
    TileLayer layer,
    Future<void> cancelLoading,
  ) {
    final path = populateUriTemplate(coordinates, layer);
    return FileImage(File(path));
  }
}
