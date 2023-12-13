import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/src/gestures/interactive_flag.dart';
import 'package:flutter_map/src/gestures/map_events.dart';
import 'package:flutter_map/src/map/camera/camera.dart';
import 'package:flutter_map/src/map/controller/internal.dart';
import 'package:flutter_map/src/map/options/interaction.dart';
import 'package:flutter_map/src/map/options/options.dart';

typedef InteractiveViewerBuilder = Widget Function(
  BuildContext context,
  MapOptions options,
  MapCamera camera,
);

/// Applies interactions (gestures/scroll/taps etc) to the current [MapCamera]
/// via the internal [controller].
class FlutterMapInteractiveViewer extends StatefulWidget {
  final InteractiveViewerBuilder builder;
  final FlutterMapInternalController controller;

  const FlutterMapInteractiveViewer({
    super.key,
    required this.builder,
    required this.controller,
  });

  @override
  State<FlutterMapInteractiveViewer> createState() =>
      FlutterMapInteractiveViewerState();
}

class FlutterMapInteractiveViewerState
    extends State<FlutterMapInteractiveViewer> with TickerProviderStateMixin {
  late Map<Type, GestureRecognizerFactory> _gestures;

  MapCamera get _camera => widget.controller.camera;

  MapOptions get _options => widget.controller.options;

  InteractionOptions get _interactionOptions => _options.interactionOptions;

  @override
  void initState() {
    super.initState();
    widget.controller.interactiveViewerState = this;
    widget.controller.addListener(onMapStateChange);
  }

  @override
  void didChangeDependencies() {
    // _createGestures uses a MediaQuery to determine gesture settings. This
    // will update those gesture settings if they change.
    _gestures = _createGestures(
      dragEnabled: InteractiveFlag.hasDrag(_interactionOptions.flags),
    );
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    widget.controller.removeListener(onMapStateChange);
    super.dispose();
  }

  void onMapStateChange() => setState(() {});

  void updateGestures(
    InteractionOptions oldOptions,
    InteractionOptions newOptions,
  ) {
    final newHasDrag = InteractiveFlag.hasDrag(newOptions.flags);
    if (newHasDrag != InteractiveFlag.hasDrag(oldOptions.flags)) {
      _gestures = _createGestures(dragEnabled: newHasDrag);
    }

    widget.controller.rotateEnded(MapEventSource.interactiveFlagsChanged);
  }

  Map<Type, GestureRecognizerFactory> _createGestures({
    required bool dragEnabled,
  }) {
    final gestureSettings = MediaQuery.gestureSettingsOf(context);
    return <Type, GestureRecognizerFactory>{
      TapGestureRecognizer:
          GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
        () => TapGestureRecognizer(debugOwner: this),
        (recognizer) {},
      ),
      LongPressGestureRecognizer:
          GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
        () => LongPressGestureRecognizer(debugOwner: this),
        (recognizer) {},
      ),
      if (dragEnabled)
        VerticalDragGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<VerticalDragGestureRecognizer>(
          () => VerticalDragGestureRecognizer(debugOwner: this),
          (recognizer) {},
        ),
      if (dragEnabled)
        HorizontalDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<
                HorizontalDragGestureRecognizer>(
            () => HorizontalDragGestureRecognizer(debugOwner: this),
            (recognizer) {}),
      ScaleGestureRecognizer:
          GestureRecognizerFactoryWithHandlers<ScaleGestureRecognizer>(
        () => ScaleGestureRecognizer(debugOwner: this),
        (recognizer) {},
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      widget.controller.options,
      widget.controller.camera,
    );
  }

  /// Thanks to https://stackoverflow.com/questions/48916517/javascript-click-and-drag-to-rotate
  double getCursorRotationDegrees(Offset offset) {
    const correctionTerm = 180; // North = cursor

    final size = MediaQuery.sizeOf(context);
    return (-math.atan2(
                offset.dx - size.width / 2, offset.dy - size.height / 2) *
            (180 / math.pi)) +
        correctionTerm;
  }
}
