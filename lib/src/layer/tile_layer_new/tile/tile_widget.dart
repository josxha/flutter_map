import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/src/layer/tile_layer_new/tile/tile_builders.dart';

/// The widget for a single tile used for the [TileLayer].
@immutable
class TileWidget extends StatelessWidget {
  /// [TileImage] is the model class that contains meta data for the Tile image.
  final TileImage tileImage;

  /// The [TileBuilder] is a reference to the [TileLayer]'s
  /// [TileLayer.tileBuilder].
  final TileBuilder? tileBuilder;

  /// The tile size for the given scale of the map.
  final double scaledTileSize;

  /// Reference to the offset of the top-left corner of the bounding rectangle
  /// of the [MapCamera]. The origin will not equal the offset of the top-left
  /// visible pixel when the map is rotated.
  final Point<double> currentPixelOrigin;

  /// Creates a new instance of [TileWidget].
  const TileWidget({
    super.key,
    required this.scaledTileSize,
    required this.currentPixelOrigin,
    required this.tileImage,
    required this.tileBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: tileImage.coordinates.x * scaledTileSize - currentPixelOrigin.x,
      top: tileImage.coordinates.y * scaledTileSize - currentPixelOrigin.y,
      width: scaledTileSize,
      height: scaledTileSize,
      child: tileBuilder?.call(context, _tileImage, tileImage) ?? _tileImage,
    );
  }

  Widget get _tileImage {
    if (tileImage.loadError && tileImage.errorImage != null) {
      return Image(
        image: tileImage.errorImage!,
        opacity: tileImage.opacity == 1
            ? null
            : AlwaysStoppedAnimation(tileImage.opacity),
      );
    }
    if (tileImage.animation != null) {
      return AnimatedBuilder(
        animation: tileImage.animation!,
        builder: (context, child) => RawImage(
          image: tileImage.imageInfo?.image,
          fit: BoxFit.fill,
          opacity: tileImage.animation,
        ),
      );
    }
    return RawImage(
      image: tileImage.imageInfo?.image,
      fit: BoxFit.fill,
      opacity: tileImage.opacity == 1
          ? null
          : AlwaysStoppedAnimation(tileImage.opacity),
    );
  }
}
