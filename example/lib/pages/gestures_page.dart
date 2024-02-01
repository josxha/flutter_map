import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_example/misc/tile_providers.dart';
import 'package:flutter_map_example/widgets/drawer/menu_drawer.dart';
import 'package:latlong2/latlong.dart';

class GesturesPage extends StatefulWidget {
  static const String route = '/enabled_gestures_page';

  const GesturesPage({super.key});

  @override
  State createState() => _GesturesPageState();
}

class _GesturesPageState extends State<GesturesPage> {
  static const availableFlags = {
    'Movement': {
      InteractiveFlag.drag: 'Drag',
      InteractiveFlag.flingAnimation: 'Fling',
      InteractiveFlag.twoFingerMove: 'Two finger drag',
    },
    'Zooming': {
      InteractiveFlag.twoFingerZoom: 'Pinch',
      InteractiveFlag.scrollWheelZoom: 'Scroll',
      InteractiveFlag.doubleTapZoomIn: 'Double tap',
      InteractiveFlag.doubleTapDragZoom: 'Double tap+drag',
      InteractiveFlag.trackpadZoom: 'Touchpad zoom',
    },
    'Rotation': {
      InteractiveFlag.twoFingerRotate: 'Twist',
      InteractiveFlag.keyTriggerDragRotate: 'CTRL+Drag',
    },
  };

  int flags = InteractiveFlag.drag | InteractiveFlag.twoFingerZoom;

  MapEvent? _latestEvent;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    return Scaffold(
      appBar: AppBar(title: const Text('Input gestures')),
      drawer: const MenuDrawer(GesturesPage.route),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Flex(
              direction: screenWidth >= 750 ? Axis.horizontal : Axis.vertical,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: availableFlags.entries
                  .map<Widget?>(
                    (category) => Column(
                      children: [
                        Text(
                          category.key,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ...category.value.entries.map(
                              (e) => Column(
                                children: [
                                  Checkbox.adaptive(
                                    value:
                                        InteractiveFlag.hasFlag(e.key, flags),
                                    onChanged: (enabled) {
                                      if (!enabled!) {
                                        setState(() => flags &= ~e.key);
                                        return;
                                      }
                                      setState(() => flags |= e.key);
                                    },
                                  ),
                                  Text(e.value, textAlign: TextAlign.center),
                                ],
                              ),
                            ),
                          ].interleave(const SizedBox(width: 12)).toList()
                            ..removeLast(),
                        )
                      ],
                    ),
                  )
                  .interleave(
                    screenWidth >= 600 ? null : const SizedBox(height: 12),
                  )
                  .whereType<Widget>()
                  .toList(),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: Text(
                  'Current event: ${_eventName(_latestEvent)}\n'
                  'Source: ${_latestEvent?.source.name ?? "none"}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  onMapEvent: (evt) {
                    print('event: ${evt.runtimeType}');
                    setState(() => _latestEvent = evt);
                  },
                  initialCenter: const LatLng(51.5, -0.09),
                  initialZoom: 11,
                  interactionOptions: InteractionOptions(
                    gestures: MapGestures.bitfield(flags),
                  ),
                  onTap: (details, point) => print('onTap'),
                  onLongPress: (details, point) => print('onLongPress'),
                  onSecondaryTap: (details, point) => print('onSecondaryTap'),
                  onSecondaryLongPress: (details, point) =>
                      print('onSecondaryLongPress'),
                  onTertiaryTap: (details, point) => print('onTertiaryTap'),
                  onTertiaryLongPress: (details, point) =>
                      print('onTertiaryLongPress'),
                  onMapReady: () => print('onMapReady'),
                  onPointerCancel: (details, point) => print('onPointerCancel'),
                  //onPointerDown: (details, point) => print('onPointerDown'),
                  //onPointerHover: (details, point) => print('onPointerHover'),
                  //onPointerUp: (details, point) => print('onPointerUp'),
                  //onPositionChanged: (details, point) =>
                  //    print('onPositionChanged'),
                ),
                children: [openStreetMapTileLayer],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _eventName(MapEvent? event) {
    switch (event) {
      case MapEventTap():
        return 'MapEventTap';
      case MapEventSecondaryTap():
        return 'MapEventSecondaryTap';
      case MapEventLongPress():
        return 'MapEventLongPress';
      case MapEventMove():
        return 'MapEventMove';
      case MapEventMoveStart():
        return 'MapEventMoveStart';
      case MapEventMoveEnd():
        return 'MapEventMoveEnd';
      case MapEventFlingAnimation():
        return 'MapEventFlingAnimation';
      case MapEventFlingAnimationNotStarted():
        return 'MapEventFlingAnimationNotStarted';
      case MapEventFlingAnimationStart():
        return 'MapEventFlingAnimationStart';
      case MapEventFlingAnimationEnd():
        return 'MapEventFlingAnimationEnd';
      case MapEventDoubleTapZoom():
        return 'MapEventDoubleTapZoom';
      case MapEventScrollWheelZoom():
        return 'MapEventScrollWheelZoom';
      case MapEventDoubleTapZoomStart():
        return 'MapEventDoubleTapZoomStart';
      case MapEventDoubleTapZoomEnd():
        return 'MapEventDoubleTapZoomEnd';
      case MapEventRotate():
        return 'MapEventRotate';
      case MapEventRotateStart():
        return 'MapEventRotateStart';
      case MapEventRotateEnd():
        return 'MapEventRotateEnd';
      case MapEventNonRotatedSizeChange():
        return 'MapEventNonRotatedSizeChange';
      case MapEventSecondaryLongPress():
        return 'MapEventSecondaryLongPress';
      case MapEventTertiaryTap():
        return 'MapEventTertiaryTap';
      case MapEventTertiaryLongPress():
        return 'MapEventTertiaryLongPress';
      case null:
        return 'null';
      default:
        return 'Unknown';
    }
  }
}

extension _IterableExt<E> on Iterable<E> {
  Iterable<E> interleave(E separator) sync* {
    for (int i = 0; i < length; i++) {
      yield elementAt(i);
      if (i < length) yield separator;
    }
  }
}
