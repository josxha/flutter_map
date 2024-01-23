part of 'base_services.dart';

/// Service to handle the key-trigger and drag gesture to rotate the map. This
/// is by default a CTRL + drag.
///
/// Can't extend from [_ProgressableGestureService] because of different
/// method signatures.
class KeyTriggerDragRotateGestureService extends _BaseGestureService {
  Size? _screenSize;
  double? _startRotation;

  /// Set to true if the gesture service is marked as active and consumes the
  /// drag updates.
  bool get consumeGesture => _keyPressed;

  /// Getter for the keyboard keys that trigger the drag to rotate gesture.
  List<LogicalKeyboardKey> get keys =>
      _options.interactionOptions.keyTriggerDragRotateKeys;

  /// Checks if one of the specified keys that enable this gesture is pressed.
  bool get _keyPressed => RawKeyboard.instance.keysPressed
      .where((key) => keys.contains(key))
      .isNotEmpty;

  /// Create a new service that rotates the map if the map gets dragged while
  /// a specified key is pressed.
  KeyTriggerDragRotateGestureService({required super.controller});

  /// Called when the gesture is started, stores important values.
  void start(Size screenSize) {
    _screenSize = screenSize;
    _startRotation = _camera.rotation;
    controller.emitMapEvent(
      MapEventRotateStart(
        camera: _camera,
        source: MapEventSource.keyTriggerDragRotateStart,
      ),
    );
  }

  /// Called when the gesture receives an update, updates the [MapCamera].
  void update(ScaleUpdateDetails details) {
    if (_screenSize == null || _startRotation == null) return;

    controller.rotateRaw(
      _getCursorRotationDegrees(
        _screenSize!,
        details.localFocalPoint,
        _startRotation!,
      ),
      hasGesture: true,
      source: MapEventSource.keyTriggerDragRotate,
    );
  }

  /// Called when the gesture ends, cleans up the previously stored values.
  void end() {
    controller.emitMapEvent(
      MapEventRotateEnd(
        camera: _camera,
        source: MapEventSource.keyTriggerDragRotateEnd,
      ),
    );
  }

  /// Get the Rotation in degrees in relation to the cursor position.
  ///
  /// This function is similar to
  /// [KeyTriggerClickRotateGestureService._getCursorRotationDegrees] but has
  /// results that are relative to the start rotation.
  static double _getCursorRotationDegrees(
    Size screenSize,
    Offset cursorOffset,
    double startRotation,
  ) {
    const correctionTerm = 180;

    return (-math.atan2(cursorOffset.dx - screenSize.width / 2,
                cursorOffset.dy - screenSize.height / 2) *
            radians2Degrees) +
        startRotation +
        correctionTerm;
  }
}
