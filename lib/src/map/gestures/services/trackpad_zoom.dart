part of 'base_services.dart';

/// Service to handle the trackpad (aka. touchpad) zoom gesture to zoom
/// the map in or out.
///
/// Trackpad gestures on most platforms since flutter 3.3 use
/// these onPointerPanZoom* callbacks.
/// See https://docs.flutter.dev/release/breaking-changes/trackpad-gestures
class TrackpadZoomGestureService extends _BaseGestureService {
  double _lastScale = 1;

  TrackpadZoomGestureService({required super.controller});

  double get _velocity => _options.interactionOptions.trackpadZoomVelocity;

  void start(PointerPanZoomStartEvent details) {
    _lastScale = 1;
  }

  void update(PointerPanZoomUpdateEvent details) {
    if (details.scale == _lastScale) return;
    final scaleFactor = (details.scale - _lastScale) * _velocity + 1;
    print(scaleFactor);

    final tmpZoom = _camera.zoom * scaleFactor;
    final newZoom = _camera.clampZoom(tmpZoom);

    // TODO: calculate new center

    _lastScale = details.scale;
    controller.moveRaw(
      _camera.center,
      newZoom,
      hasGesture: true,
      source: MapEventSource.trackpad,
    );
  }

  void end(PointerPanZoomEndEvent details) {}
}
