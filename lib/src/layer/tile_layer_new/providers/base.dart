import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/flutter_map.dart' hide TileLayer;
import 'package:flutter_map/src/layer/tile_layer_new/providers/image_provider/http.dart';
import 'package:flutter_map/src/layer/tile_layer_new/retina_mode.dart';
import 'package:flutter_map/src/layer/tile_layer_new/tile/tile_coordinates.dart';
import 'package:flutter_map/src/layer/tile_layer_new/tile_layer.dart';
import 'package:http/http.dart';
import 'package:http/retry.dart';

part 'asset.dart';
part 'file.dart';
part 'http.dart';
part 'http_wms.dart';
part 'network.dart';
part 'uri.dart';
part 'wms.dart';

/// The base tile provider, extended by other classes with more specialised
/// purposes and/or requirements
///
/// Prefer extending over implementing.
///
/// For more information, see
/// <https://docs.fleaflet.dev/explanation#tile-providers>, and
/// <https://docs.fleaflet.dev/layers/tile-layer/tile-providers>. For an example
/// extension (with custom [ImageProvider]), see [NetworkTileProvider].
abstract class TileProvider {
  /// Whether to ignore exceptions and errors that occur whilst fetching tiles
  /// over the network, and just return a transparent tile
  final bool silenceExceptions;

  const TileProvider({
    this.silenceExceptions = false,
  });

  ImageProvider getImage(
    TileCoordinates coordinates,
    TileLayer layer,
    Future<void> cancelLoading,
  );

  /// Called when the [TileLayer] is disposed
  ///
  /// When disposing resources, ensure that they are not currently being used
  /// by tiles in progress.
  void dispose() {}

  /// [Uint8List] that forms a fully transparent image
  ///
  /// Intended to be used with [getImageWithCancelLoadingSupport], so that a
  /// cancelled tile load returns this. It will not be displayed. An error cannot
  /// be thrown from a custom [ImageProvider].
  static final transparentImage = Uint8List.fromList(const <int>[
    0x89,
    0x50,
    0x4E,
    0x47,
    0x0D,
    0x0A,
    0x1A,
    0x0A,
    0x00,
    0x00,
    0x00,
    0x0D,
    0x49,
    0x48,
    0x44,
    0x52,
    0x00,
    0x00,
    0x00,
    0x01,
    0x00,
    0x00,
    0x00,
    0x01,
    0x08,
    0x06,
    0x00,
    0x00,
    0x00,
    0x1F,
    0x15,
    0xC4,
    0x89,
    0x00,
    0x00,
    0x00,
    0x0A,
    0x49,
    0x44,
    0x41,
    0x54,
    0x78,
    0x9C,
    0x63,
    0x00,
    0x01,
    0x00,
    0x00,
    0x05,
    0x00,
    0x01,
    0x0D,
    0x0A,
    0x2D,
    0xB4,
    0x00,
    0x00,
    0x00,
    0x00,
    0x49,
    0x45,
    0x4E,
    0x44,
    0xAE,
    0x42,
    0x60,
    0x82,
  ]);
}
