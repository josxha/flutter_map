import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

/// Set interation options for input gestures.
/// Most commonly used is [InteractionOptions.enabledGestures].
@immutable
final class InteractionOptions {
  /// Enable panning with a single finger or cursor
  final DragGesture drag;

  /// Enable fling animation after panning if velocity is great enough.
  final FlingAnimationGesture flingAnimation;

  /// Enable panning with multiple fingers
  final TwoFingerMoveGesture twoFingerMove;

  /// Enable zooming with a multi-finger pinch gesture
  final TwoFingerZoomGesture twoFingerZoom;

  /// Enable rotation with two-finger twist gesture
  final TwoFingerRotateGesture twoFingerRotate;

  /// Enable zooming with a single-finger double tap gesture
  final DoubleTapZoomInGesture doubleTapZoomIn;

  /// Enable zooming with a single-finger double-tap-drag gesture
  ///
  /// The associated [MapEventSource] is [MapEventSource.doubleTapHold].
  final DoubleTapDragZoomGesture doubleTapDragZoom;

  /// Enable zooming with a mouse scroll wheel
  final ScrollWheelZoomGesture scrollWheelZoom;

  /// Enable rotation by pressing the defined keyboard key (by default CTRL key)
  /// and dragging with the cursor
  /// or finger.
  final KeyTriggerDragRotateGesture keyTriggerDragRotate;

  const InteractionOptions.all({
    this.drag = const DragGesture(),
    this.flingAnimation = const FlingAnimationGesture(),
    this.twoFingerMove = const TwoFingerMoveGesture(),
    this.twoFingerZoom = const TwoFingerZoomGesture(),
    this.twoFingerRotate = const TwoFingerRotateGesture(),
    this.doubleTapZoomIn = const DoubleTapZoomInGesture(),
    this.doubleTapDragZoom = const DoubleTapDragZoomGesture(),
    this.scrollWheelZoom = const ScrollWheelZoomGesture(),
    this.keyTriggerDragRotate = const KeyTriggerDragRotateGesture(),
  });

  const InteractionOptions.none({
    this.drag = const DragGesture.disabled(),
    this.flingAnimation = const FlingAnimationGesture.disabled(),
    this.twoFingerMove = const TwoFingerMoveGesture.disabled(),
    this.twoFingerZoom = const TwoFingerZoomGesture.disabled(),
    this.twoFingerRotate = const TwoFingerRotateGesture.disabled(),
    this.doubleTapZoomIn = const DoubleTapZoomInGesture.disabled(),
    this.doubleTapDragZoom = const DoubleTapDragZoomGesture.disabled(),
    this.scrollWheelZoom = const ScrollWheelZoomGesture.disabled(),
    this.keyTriggerDragRotate = const KeyTriggerDragRotateGesture.disabled(),
  });

  InteractionOptions copyWith({
    DragGesture? drag,
    FlingAnimationGesture? flingAnimation,
    TwoFingerMoveGesture? twoFingerMove,
    TwoFingerZoomGesture? twoFingerZoom,
    TwoFingerRotateGesture? twoFingerRotate,
    DoubleTapZoomInGesture? doubleTapZoomIn,
    DoubleTapDragZoomGesture? doubleTapDragZoom,
    ScrollWheelZoomGesture? scrollWheelZoom,
    KeyTriggerDragRotateGesture? keyTriggerDragRotate,
  }) =>
      InteractionOptions.all(
        drag: drag ?? this.drag,
        flingAnimation: flingAnimation ?? this.flingAnimation,
        twoFingerMove: twoFingerMove ?? this.twoFingerMove,
        twoFingerZoom: twoFingerZoom ?? this.twoFingerZoom,
        twoFingerRotate: twoFingerRotate ?? this.twoFingerRotate,
        doubleTapZoomIn: doubleTapZoomIn ?? this.doubleTapZoomIn,
        doubleTapDragZoom: doubleTapDragZoom ?? this.doubleTapDragZoom,
        scrollWheelZoom: scrollWheelZoom ?? this.scrollWheelZoom,
        keyTriggerDragRotate: keyTriggerDragRotate ?? this.keyTriggerDragRotate,
      );

  bool get hasMultiFinger =>
      twoFingerZoom.enabled || twoFingerMove.enabled || twoFingerRotate.enabled;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InteractionOptions &&
          drag == other.drag &&
          flingAnimation == other.flingAnimation &&
          twoFingerMove == other.twoFingerMove &&
          twoFingerZoom == other.twoFingerZoom &&
          twoFingerRotate == other.twoFingerRotate &&
          doubleTapZoomIn == other.doubleTapZoomIn &&
          doubleTapDragZoom == other.doubleTapDragZoom &&
          scrollWheelZoom == other.scrollWheelZoom);

  @override
  int get hashCode => Object.hash(
        drag,
        flingAnimation,
        twoFingerMove,
        twoFingerZoom,
        twoFingerRotate,
        doubleTapZoomIn,
        doubleTapDragZoom,
        scrollWheelZoom,
      );
}

abstract class _BaseGesture {
  final bool enabled;

  const _BaseGesture({required this.enabled});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _BaseGesture &&
          runtimeType == other.runtimeType &&
          enabled == other.enabled;

  @override
  int get hashCode => enabled.hashCode;
}

class FlingAnimationGesture extends _BaseGesture {
  const FlingAnimationGesture({super.enabled = true});

  const FlingAnimationGesture.disabled() : this(enabled: false);
}

class DragGesture extends _BaseGesture {
  const DragGesture({super.enabled = true});

  const DragGesture.disabled() : this(enabled: false);
}

class TwoFingerMoveGesture extends _BaseGesture {
  const TwoFingerMoveGesture({
    this.threshold = 3.0,
    super.enabled = true,
  }) : assert(
          threshold >= 0.0,
          'pinchMoveThreshold needs to be a positive value',
        );

  const TwoFingerMoveGesture.disabled() : this(enabled: false);

  /// Map starts to move when [threshold] has been achieved or
  /// another multi finger gesture wins. This doesn't take any effect on drag
  /// gestures by a single pointer like a single finger.
  ///
  /// This option gets superseded by [twoFingerZoomThreshold] if
  /// [EnabledGestures.twoFingerMove] and [EnabledGestures.twoFingerZoom] are
  /// both active and the [twoFingerZoomThreshold] is reached.
  ///
  /// Default is 3.0.
  final double threshold;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is TwoFingerMoveGesture &&
          runtimeType == other.runtimeType &&
          threshold == other.threshold;

  @override
  int get hashCode => super.hashCode ^ threshold.hashCode;
}

class TwoFingerZoomGesture extends _BaseGesture {
  const TwoFingerZoomGesture({
    super.enabled = true,
    this.threshold = 0.01,
  }) : assert(
          threshold >= 0.0,
          'pinchZoomThreshold needs to be a positive value',
        );

  const TwoFingerZoomGesture.disabled() : this(enabled: false);

  /// Map starts to zoom when [threshold] has been achieved or
  /// another multi finger gesture wins.
  /// Default is 0.1
  final double threshold;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is TwoFingerZoomGesture &&
          runtimeType == other.runtimeType &&
          threshold == other.threshold;

  @override
  int get hashCode => super.hashCode ^ threshold.hashCode;
}

class TwoFingerRotateGesture extends _BaseGesture {
  const TwoFingerRotateGesture({
    super.enabled = true,
    this.threshold = 0.1,
  }) : assert(
          threshold >= 0.0,
          'rotationThreshold needs to be a positive value',
        );

  const TwoFingerRotateGesture.disabled() : this(enabled: false);

  /// Map starts to rotate when [threshold] has been achieved
  /// or another multi finger gesture wins.
  /// Default is 0.1
  final double threshold;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is TwoFingerRotateGesture &&
          runtimeType == other.runtimeType &&
          threshold == other.threshold;

  @override
  int get hashCode => super.hashCode ^ threshold.hashCode;
}

class DoubleTapZoomInGesture extends _BaseGesture {
  const DoubleTapZoomInGesture({super.enabled = true});

  const DoubleTapZoomInGesture.disabled() : this(enabled: false);
}

class DoubleTapDragZoomGesture extends _BaseGesture {
  const DoubleTapDragZoomGesture({super.enabled = true});

  const DoubleTapDragZoomGesture.disabled() : this(enabled: false);
}

class ScrollWheelZoomGesture extends _BaseGesture {
  const ScrollWheelZoomGesture({
    super.enabled = true,
    this.velocity = 0.01,
  });

  const ScrollWheelZoomGesture.disabled() : this(enabled: false);

  /// The velocity how fast the map should zoom when using the scroll wheel
  /// of the mouse.
  /// Defaults to 0.01.
  final double velocity;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is ScrollWheelZoomGesture &&
          runtimeType == other.runtimeType &&
          velocity == other.velocity;

  @override
  int get hashCode => super.hashCode ^ velocity.hashCode;
}

class KeyTriggerDragRotateGesture extends _BaseGesture {
  const KeyTriggerDragRotateGesture({
    super.enabled = true,
    this.triggerKeys = defaultTriggerKeys,
  });

  const KeyTriggerDragRotateGesture.disabled() : this(enabled: false);

  /// Override this option if you want to use custom keys for the key trigger
  /// drag rotate gesture (aka CTRL+drag rotate gesture).
  /// By default the left and right control key are both used.
  final List<LogicalKeyboardKey> triggerKeys;

  /// Default keys for the key press and drag to rotate gesture.
  static const defaultTriggerKeys = <LogicalKeyboardKey>[
    LogicalKeyboardKey.control,
    LogicalKeyboardKey.controlLeft,
    LogicalKeyboardKey.controlRight,
    LogicalKeyboardKey.shift,
    LogicalKeyboardKey.shiftLeft,
    LogicalKeyboardKey.shiftRight,
  ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is KeyTriggerDragRotateGesture &&
          runtimeType == other.runtimeType &&
          triggerKeys == other.triggerKeys;

  @override
  int get hashCode => super.hashCode ^ triggerKeys.hashCode;
}
