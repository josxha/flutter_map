import 'package:flutter/widgets.dart';
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
  MapCamera get _camera => widget.controller.camera;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(reload);
  }

  @override
  void dispose() {
    widget.controller.removeListener(reload);
    super.dispose();
  }

  void reload() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      widget.controller.options,
      _camera,
    );
  }

  /// Used by the internal map controller to update interaction gestures
  void updateGestures(InteractionOptions options) {
    print('[MapInteractiveViewer] updateGestures');
    // TODO
  }

  /// Used by the internal map controller
  void interruptAnimatedMovement(MapEventMove event) {
    print('[MapInteractiveViewer] interruptAnimatedMovement');
    // TODO
  }
}
