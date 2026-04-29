/// A customizable side drawer with a draggable pill button that slides 1:1
/// with the panel.
///
/// Exposes:
///
/// * [SlidingPillDrawer] — the host widget that wraps your page.
/// * [SlidingPillDrawerController] — imperative open/close control and
///   animation listening.
/// * [SlidingPillDrawerTarget] — anchor widget for follower mode.
/// * [DefaultPill] — the built-in pill widget rendered when no custom
///   [PillBuilder] is supplied.
library;

export 'src/sliding_pill_drawer.dart';
export 'src/sliding_pill_drawer_controller.dart';
export 'src/sliding_pill_drawer_target.dart';
export 'src/widgets/default_pill.dart';
