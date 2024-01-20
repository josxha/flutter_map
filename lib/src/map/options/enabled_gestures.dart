import 'package:flutter_map/flutter_map.dart';
import 'package:meta/meta.dart';

@immutable
class EnabledGestures {
  /// Use this constructor if you want to set all gestures manually.
  ///
  /// Prefer to use the constructors [InteractiveFlags.all] or
  /// [InteractiveFlags.none] to enable or disable all gestures by default.
  ///
  /// If you want to define your enabled gestures using bitfield operations,
  /// use [InteractiveFlags.bitfield] instead.
  const EnabledGestures({
    required this.drag,
    required this.flingAnimation,
    required this.twoFingerMove,
    required this.twoFingerZoom,
    required this.doubleTapZoomIn,
    required this.doubleTapDragZoom,
    required this.scrollWheelZoom,
    required this.twoFingerRotate,
    required this.keyTriggerDragRotate,
    required this.trackpadZoom,
  });

  /// Shortcut constructor to allow all gestures that don't rotate the map.
  const EnabledGestures.noRotation()
      : this.byGroup(move: true, zoom: true, rotate: false);

  /// This constructor enables all gestures by default. Use this constructor if
  /// you want have all gestures enabled or disable some gestures only.
  ///
  /// In case you want have no or only few gestures enabled use the
  /// [InteractiveFlags.none] constructor instead.
  const EnabledGestures.all({
    this.drag = true,
    this.flingAnimation = true,
    this.twoFingerMove = true,
    this.twoFingerZoom = true,
    this.doubleTapZoomIn = true,
    this.doubleTapDragZoom = true,
    this.scrollWheelZoom = true,
    this.twoFingerRotate = true,
    this.keyTriggerDragRotate = true,
    this.trackpadZoom = true,
  });

  /// This constructor has no enabled gestures by default. Use this constructor
  /// if you want have no gestures enabled or only some specific gestures.
  ///
  /// In case you want have most or all of the gestures enabled use the
  /// [InteractiveFlags.all] constructor instead.
  const EnabledGestures.none({
    this.drag = false,
    this.flingAnimation = false,
    this.twoFingerMove = false,
    this.twoFingerZoom = false,
    this.doubleTapZoomIn = false,
    this.doubleTapDragZoom = false,
    this.scrollWheelZoom = false,
    this.twoFingerRotate = false,
    this.keyTriggerDragRotate = false,
    this.trackpadZoom = false,
  });

  /// This constructor supports bitfield operations on the static fields
  /// from [InteractiveFlag].
  factory EnabledGestures.bitfield(int flags) {
    return EnabledGestures(
      drag: InteractiveFlag.hasFlag(flags, InteractiveFlag.drag),
      flingAnimation:
          InteractiveFlag.hasFlag(flags, InteractiveFlag.flingAnimation),
      twoFingerMove:
          InteractiveFlag.hasFlag(flags, InteractiveFlag.twoFingerMove),
      twoFingerZoom:
          InteractiveFlag.hasFlag(flags, InteractiveFlag.twoFingerZoom),
      doubleTapZoomIn:
          InteractiveFlag.hasFlag(flags, InteractiveFlag.doubleTapZoomIn),
      doubleTapDragZoom:
          InteractiveFlag.hasFlag(flags, InteractiveFlag.doubleTapDragZoom),
      scrollWheelZoom:
          InteractiveFlag.hasFlag(flags, InteractiveFlag.scrollWheelZoom),
      twoFingerRotate:
          InteractiveFlag.hasFlag(flags, InteractiveFlag.twoFingerRotate),
      keyTriggerDragRotate:
          InteractiveFlag.hasFlag(flags, InteractiveFlag.keyTriggerDragRotate),
      trackpadZoom:
          InteractiveFlag.hasFlag(flags, InteractiveFlag.trackpadZoom),
    );
  }

  /// Enable panning with a single finger or cursor
  final bool drag;

  /// Enable fling animation after panning if velocity is great enough.
  final bool flingAnimation;

  /// Enable panning with multiple fingers
  final bool twoFingerMove;

  /// Enable zooming with a multi-finger pinch gesture
  final bool twoFingerZoom;

  /// Enable rotation with two-finger twist gesture
  final bool twoFingerRotate;

  /// Enable zooming with a single-finger double tap gesture
  final bool doubleTapZoomIn;

  /// Enable zooming with a single-finger double-tap-drag gesture
  ///
  /// The associated [MapEventSource] is [MapEventSource.doubleTapHold].
  final bool doubleTapDragZoom;

  /// Enable zooming with a mouse scroll wheel
  final bool scrollWheelZoom;

  /// Enable zooming with the device trackpad / touchpad
  final bool trackpadZoom;

  /// Enable rotation by pressing the defined keyboard key (by default CTRL key)
  /// and dragging with the cursor
  /// or finger.
  final bool keyTriggerDragRotate;

  /// Returns true of any gesture with more than one finger is enabled.
  bool hasMultiFinger() => twoFingerMove || twoFingerZoom || twoFingerRotate;

  /// Wither to change the value of some gestures. Returns a new
  /// [EnabledGestures] object.
  EnabledGestures copyWith({
    bool? drag,
    bool? flingAnimation,
    bool? twoFingerZoom,
    bool? twoFingerMove,
    bool? doubleTapZoomIn,
    bool? doubleTapDragZoom,
    bool? scrollWheelZoom,
    bool? twoFingerRotate,
    bool? keyTriggerDragRotate,
    bool? trackpadZoom,
  }) =>
      EnabledGestures(
        drag: drag ?? this.drag,
        flingAnimation: flingAnimation ?? this.flingAnimation,
        twoFingerZoom: twoFingerZoom ?? this.twoFingerZoom,
        twoFingerMove: twoFingerMove ?? this.twoFingerMove,
        doubleTapZoomIn: doubleTapZoomIn ?? this.doubleTapZoomIn,
        doubleTapDragZoom: doubleTapDragZoom ?? this.doubleTapDragZoom,
        scrollWheelZoom: scrollWheelZoom ?? this.scrollWheelZoom,
        twoFingerRotate: twoFingerRotate ?? this.twoFingerRotate,
        keyTriggerDragRotate: keyTriggerDragRotate ?? this.keyTriggerDragRotate,
        trackpadZoom: trackpadZoom ?? this.trackpadZoom,
      );

  const EnabledGestures.byGroup({
    required bool move,
    required bool zoom,
    required bool rotate,
  }) : this(
          drag: move,
          twoFingerMove: move,
          flingAnimation: move,
          doubleTapDragZoom: zoom,
          doubleTapZoomIn: zoom,
          scrollWheelZoom: zoom,
          twoFingerZoom: zoom,
          twoFingerRotate: rotate,
          keyTriggerDragRotate: rotate,
          trackpadZoom: zoom,
        );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnabledGestures &&
          runtimeType == other.runtimeType &&
          drag == other.drag &&
          flingAnimation == other.flingAnimation &&
          twoFingerMove == other.twoFingerMove &&
          twoFingerZoom == other.twoFingerZoom &&
          doubleTapZoomIn == other.doubleTapZoomIn &&
          doubleTapDragZoom == other.doubleTapDragZoom &&
          scrollWheelZoom == other.scrollWheelZoom &&
          twoFingerRotate == other.twoFingerRotate &&
          keyTriggerDragRotate == other.keyTriggerDragRotate;

  @override
  int get hashCode => Object.hash(
        drag,
        flingAnimation,
        twoFingerMove,
        twoFingerZoom,
        doubleTapZoomIn,
        doubleTapDragZoom,
        scrollWheelZoom,
        twoFingerRotate,
        keyTriggerDragRotate,
      );
}

/// Use [InteractiveFlag] to disable / enable certain events Use
/// [InteractiveFlag.all] to enable all events, use [InteractiveFlag.none] to
/// disable all events
///
/// If you want mix interactions for example drag and rotate interactions then
/// you have two options:
///   a. Add your own flags:
///      [InteractiveFlag.drag] | [InteractiveFlag.twoFingerRotate]
///   b. Remove unnecessary flags from all:
///     [InteractiveFlag.all] &
///       ~[InteractiveFlag.flingAnimation] &
///       ~[InteractiveFlag.twoFingerMove] &
///       ~[InteractiveFlag.twoFingerZoom] &
///       ~[InteractiveFlag.doubleTapZoomIn]
abstract class InteractiveFlag {
  const InteractiveFlag._();

  static const int all = drag |
      flingAnimation |
      twoFingerMove |
      twoFingerZoom |
      doubleTapZoomIn |
      doubleTapDragZoom |
      scrollWheelZoom |
      twoFingerRotate |
      trackpadZoom |
      keyTriggerDragRotate;

  static const int none = 0;

  /// Enable panning with a single finger or cursor
  static const int drag = 1 << 0;

  /// Enable fling animation after panning if velocity is great enough.
  static const int flingAnimation = 1 << 1;

  /// Enable panning with multiple fingers
  static const int twoFingerMove = 1 << 2;
  @Deprecated('Renamed to twoFingerMove')
  static const int pinchMove = twoFingerMove;

  /// Enable zooming with a multi-finger pinch gesture
  static const int twoFingerZoom = 1 << 3;
  @Deprecated('Renamed to twoFingerZoom')
  static const int pinchZoom = twoFingerZoom;

  /// Enable zooming with a single-finger double tap gesture
  static const int doubleTapZoomIn = 1 << 4;
  @Deprecated('Renamed to doubleTapZoomIn')
  static const int doubleTapZoom = doubleTapZoomIn;

  /// Enable zooming with a single-finger double-tap-drag gesture
  ///
  /// The associated [MapEventSource] is [MapEventSource.doubleTapHold].
  static const int doubleTapDragZoom = 1 << 5;

  /// Enable zooming with a mouse scroll wheel
  static const int scrollWheelZoom = 1 << 6;

  /// Enable rotation with two-finger twist gesture
  ///
  /// For controlling cursor/keyboard rotation, see
  /// [InteractionOptions.cursorKeyboardRotationOptions].
  static const int twoFingerRotate = 1 << 7;
  @Deprecated('Renamed to twoFingerRotate')
  static const int rotate = twoFingerRotate;

  /// Enable rotation by pressing the defined keyboard keys
  /// (by default CTRL Key) and drag the map with the cursor.
  /// To change the key see [InteractionOptions.cursorKeyboardRotationOptions].
  static const int keyTriggerDragRotate = 1 << 8;

  /// Enable zooming by using the trackpad / touchpad of a device.
  static const int trackpadZoom = 1 << 9;

  /// Returns `true` if [leftFlags] has at least one member in [rightFlags]
  /// (intersection) for example
  /// [leftFlags] = [InteractiveFlag.drag] | [InteractiveFlag.twoFingerRotate]
  /// and
  /// [rightFlags] = [InteractiveFlag.twoFingerRotate]
  ///                | [InteractiveFlag.flingAnimation]
  /// returns true because both have the [InteractiveFlag.twoFingerRotate] flag.
  static bool hasFlag(int leftFlags, int rightFlags) {
    return leftFlags & rightFlags != 0;
  }
}
