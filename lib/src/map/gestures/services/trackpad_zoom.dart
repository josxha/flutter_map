part of 'base_services.dart';

/// Service to handle the trackpad (aka. touchpad) zoom gesture to zoom
/// the map in or out.
class TrackpadZoomGestureService extends _BaseGestureService {
  TrackpadZoomGestureService({required super.controller});

  /// Trackpad gestures on most platforms since flutter 3.3 use
  /// these onPointerPanZoom* callbacks.
  /// See https://docs.flutter.dev/release/breaking-changes/trackpad-gestures
  void submit(PointerPanZoomUpdateEvent details) {
    print('submit: ${details.scale}');
    if (details.scale == 1) return;
    _zoomMap(details.scale);
  }

  /// Trackpad pinch gesture, in case the pointerPanZoom event
  /// callbacks can't be used and trackpad scrolling must still use
  /// this old PointerScrollSignal system.
  //
  /// This is the case if not enough data is
  /// provided to the Flutter engine by platform APIs:
  /// - On **Windows**, where trackpad gesture support is dependent on
  /// the trackpad’s driver,
  /// - On **Web**, where not enough data is provided by browser APIs.
  //
  /// https://docs.flutter.dev/release/breaking-changes/trackpad-gestures#description-of-change
  void submitFallback(PointerScaleEvent details) {
    print('submitFallback: ${details.scale}');
    if (details.scale == 1) return;
    _zoomMap(details.scale);
  }

  void _zoomMap(double scale) {
    final tmpZoom = _camera.zoom + (math.log(scale) / math.ln2) * 0.05;
    final newZoom = _camera.clampZoom(tmpZoom);

    // TODO: calculate new center

    controller.moveRaw(
      _camera.center,
      newZoom,
      hasGesture: true,
      source: MapEventSource.trackpad,
    );
  }
}
