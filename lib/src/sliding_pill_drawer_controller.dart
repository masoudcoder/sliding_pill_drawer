import 'package:flutter/widgets.dart';

/// Facade that lets any widget open, close, or observe a [SlidingPillDrawer]
/// without owning the underlying [AnimationController] directly.
///
/// Create one per drawer and pass it to [SlidingPillDrawer.controller]. The wrapper
/// attaches itself in `initState` and detaches in `dispose`, so the same
/// controller can outlive a particular wrapper instance (e.g. across rebuilds).
class SlidingPillDrawerController extends ChangeNotifier {
  AnimationController? _animation;

  /// Called by [SlidingPillDrawer] internally. Not meant for external use.
  void attach(AnimationController controller) {
    _animation?.removeListener(notifyListeners);
    _animation = controller;
    controller.addListener(notifyListeners);
  }

  /// Called by [SlidingPillDrawer] internally. Not meant for external use.
  void detach() {
    _animation?.removeListener(notifyListeners);
    _animation = null;
  }

  /// Current animation progress, in `[0, 1]`. `0` means fully closed.
  double get value => _animation?.value ?? 0.0;

  /// Sets the animation progress directly (clamped to `[0, 1]`) without
  /// animating. Use this when driving the drawer from a custom pill widget's
  /// drag gesture — pair with [settle] on drag end.
  set value(double v) => _animation?.value = v.clamp(0.0, 1.0);

  /// Whether the drawer is past the halfway point (i.e. visible / snapping open).
  bool get isOpen => value > 0.5;

  /// Whether the drawer has finished opening (value == 1.0).
  bool get isFullyOpen => _animation?.isCompleted ?? false;

  /// Plays the open animation forward. No-op until [attach] has been called
  /// by the host [SlidingPillDrawer].
  void open() => _animation?.forward();

  /// Plays the close animation in reverse. No-op until [attach] has been
  /// called by the host [SlidingPillDrawer].
  void close() => _animation?.reverse();

  /// Toggles between [open] and [close] based on the current [isOpen] state.
  void toggle() => isOpen ? close() : open();

  /// Snaps the drawer fully open or fully closed based on the current [value].
  /// Typically invoked at the end of a drag gesture on a custom pill.
  void settle() {
    final a = _animation;
    if (a == null) return;
    if (a.value > 0.5) {
      a.forward();
    } else {
      a.reverse();
    }
  }
}
