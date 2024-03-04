import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

/// Builder function that returns a [TileBuilder] instance.
typedef TileBuilder = Widget Function(
    BuildContext context, Widget tileWidget, TileImage tile);

const _invertColorsFilter = ColorFilter.matrix(<double>[
  -1,
  0,
  0,
  0,
  255,
  0,
  -1,
  0,
  0,
  255,
  0,
  0,
  -1,
  0,
  255,
  0,
  0,
  0,
  1,
  0,
]);

/// Applies inversion color matrix on Tiles container which may simulate Dark mode.
Widget darkModeTilesContainerBuilder(
  BuildContext context,
  Widget tilesContainer,
) =>
    ColorFiltered(colorFilter: _invertColorsFilter, child: tilesContainer);

/// Applies inversion color matrix on Tiles which may simulate Dark mode.
/// [darkModeTilesContainerBuilder] is better at performance because it applies
/// color matrix on the container instead of on every Tile.
Widget darkModeTileBuilder(
  BuildContext context,
  Widget tileWidget,
  TileImage tile,
) =>
    ColorFiltered(colorFilter: _invertColorsFilter, child: tileWidget);

/// Shows coordinates over Tiles
Widget coordinateDebugTileBuilder(
  BuildContext context,
  Widget tileWidget,
  TileImage tile,
) {
  final coordinates = tile.coordinates;
  final text = '${coordinates.x} : ${coordinates.y} : ${coordinates.z}';
  final textStyle = Theme.of(context).textTheme.headlineSmall;

  return DecoratedBox(
    decoration: BoxDecoration(border: Border.all()),
    child: Stack(
      fit: StackFit.passthrough,
      children: [
        tileWidget,
        Center(child: Text(text, style: textStyle)),
      ],
    ),
  );
}

/// Shows the Tile loading time in ms
Widget loadingTimeDebugTileBuilder(
  BuildContext context,
  Widget tileWidget,
  TileImage tile,
) {
  final loadStarted = tile.loadStarted;
  final loaded = tile.loadFinishedAt;
  final textStyle = Theme.of(context).textTheme.headlineSmall;
  final time = loadStarted == null || loaded == null
      ? 'Loading'
      : '${loaded.difference(loadStarted).inMilliseconds} ms';

  return DecoratedBox(
    decoration: BoxDecoration(border: Border.all()),
    child: Stack(
      fit: StackFit.passthrough,
      children: [
        tileWidget,
        Center(child: Text(time, style: textStyle)),
      ],
    ),
  );
}
