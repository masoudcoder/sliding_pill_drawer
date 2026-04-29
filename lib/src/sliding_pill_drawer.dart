import 'package:flutter/material.dart';

import 'sliding_pill_drawer_controller.dart';
import 'widgets/default_pill.dart';

/// Builds a custom pill widget. The [animation] value is `0.0` when the
/// drawer is closed and `1.0` when it is fully open — use it to drive label
/// fades, icon rotations, or any other visual state on the pill.
typedef PillBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
);

/// Builds a custom backdrop that sits between the body and the drawer panel.
/// The [animation] value is `0.0` when the drawer is closed and `1.0` when it
/// is fully open — use it to drive fades, blurs, or opacity transitions.
///
/// When a [BackdropBuilder] is provided, tapping the backdrop is still wired
/// to close the drawer; your builder only needs to return the visual layer.
typedef BackdropBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
);

/// A side drawer with a draggable pill button that slides 1:1 with the
/// panel.
///
/// Wraps a [body] and renders a [drawerContent] panel that opens from the
/// leading edge. A pill button is rendered on top and can be dragged to open
/// or close the panel; horizontal drag distance maps directly to panel
/// translation.
///
/// Two placement modes are supported:
///
/// * **Sticky** ([isSticky] = `true`): the pill is pinned at a fixed
///   vertical offset ([stickyTop]) on the screen.
/// * **Follower** ([link] provided): the pill is anchored to a
///   [SlidingPillDrawerTarget] inside the [body] via a [LayerLink] and
///   scrolls with that target.
///
/// Pass a [SlidingPillDrawerController] to drive the drawer
/// imperatively (`open` / `close` / `toggle`) or to read its animation
/// progress.
class SlidingPillDrawer extends StatefulWidget {
  /// Creates a [SlidingPillDrawer].
  ///
  /// Either [isSticky] must be `true` or a [link] must be supplied — without
  /// one, the built-in pill has no anchor and won't be rendered.
  const SlidingPillDrawer({
    super.key,
    required this.body,
    required this.drawerContent,
    required this.controller,
    this.link,
    this.isSticky = false,
    this.stickyTop,
    this.defaultPillText = 'Menu',
    this.pillBuilder,
    this.backdropBuilder,
    this.overlayBuilder,
    this.panelWidthFraction = 0.85,
    this.animationDuration = const Duration(milliseconds: 350),
  });

  /// Page content shown behind the drawer.
  final Widget body;

  /// Panel content that slides in from the trailing edge.
  final Widget drawerContent;

  /// Opens / closes the drawer and exposes the animation.
  final SlidingPillDrawerController controller;

  /// Required in follower mode. Pair with a `SlidingPillDrawerTarget` placed
  /// inside the [body] at the desired pill position.
  final LayerLink? link;

  /// When `true`, the pill stays pinned to a fixed [stickyTop] position.
  final bool isSticky;

  /// Vertical offset of the sticky pill (pixels from the top of the wrapper).
  /// Defaults to 40% of the available height.
  final double? stickyTop;

  /// Fallback text for the default pill.
  final String defaultPillText;

  /// Optional custom pill. The animation drives the pill's open/close state.
  final PillBuilder? pillBuilder;

  /// Optional custom backdrop. When omitted, a plain black overlay fades in
  /// with the drawer. Tapping anywhere on the backdrop closes the drawer
  /// regardless of this builder.
  final BackdropBuilder? backdropBuilder;

  /// Renders extra widgets **above** the backdrop and drawer panel (but
  /// below the optional built-in pill). Use this to place a custom pill
  /// that must sit on top of the backdrop — e.g. an overlay copy of an
  /// in-body pill that needs to survive the backdrop fade-in.
  final Widget Function(BuildContext, Animation<double>)? overlayBuilder;

  /// Fraction of the screen width the drawer occupies when fully open.
  final double panelWidthFraction;

  /// Duration of the open/close animation.
  final Duration animationDuration;

  /// Whether the built-in pill should be rendered inside the drawer's
  /// overlay stack. When `false`, the caller is responsible for placing a
  /// custom pill widget elsewhere in the tree and wiring it to [controller]
  /// (e.g. inside a scrolling body so it participates in scroll clipping).
  bool get _hasInternalPill => isSticky || link != null;

  @override
  State<SlidingPillDrawer> createState() => _SlidingPillDrawerState();
}

class _SlidingPillDrawerState extends State<SlidingPillDrawer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  double _panelWidthFor(BuildContext context) =>
      MediaQuery.sizeOf(context).width * widget.panelWidthFraction;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    widget.controller.attach(_animController);
  }

  @override
  void didUpdateWidget(covariant SlidingPillDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.detach();
      widget.controller.attach(_animController);
    }
    if (oldWidget.animationDuration != widget.animationDuration) {
      _animController.duration = widget.animationDuration;
    }
  }

  @override
  void dispose() {
    widget.controller.detach();
    _animController.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details, double panelWidth, bool isRTL) {
    final delta = details.primaryDelta! / panelWidth;
    // Drawer sits at the leading edge; opening pulls the pill toward the
    // trailing side. In LTR that's a rightward (positive) drag, in RTL
    // a leftward (negative) drag.
    _animController.value += isRTL ? -delta : delta;
  }

  void _onDragEnd(DragEndDetails details) {
    if (_animController.value > 0.5) {
      _animController.forward();
    } else {
      _animController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final panelWidth = _panelWidthFor(context);
    // Respect the bottom system inset (gesture pill / soft nav keys) so the
    // drawer panel never runs under OS buttons. The backdrop still covers
    // the full screen so the tint reaches edge-to-edge.
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Stack(
      children: [
        widget.body,
        AnimatedBuilder(
          animation: _animController,
          builder: (context, _) {
            if (_animController.value == 0) return const SizedBox.shrink();
            final backdrop =
                widget.backdropBuilder?.call(context, _animController) ??
                    ColoredBox(
                      color: Colors.black
                          .withValues(alpha: _animController.value * 0.5),
                    );
            return Positioned.fill(
              child: GestureDetector(
                onTap: _animController.reverse,
                behavior: HitTestBehavior.opaque,
                child: backdrop,
              ),
            );
          },
        ),
        PositionedDirectional(
          top: 0,
          bottom: bottomInset,
          start: 0,
          width: panelWidth,
          child: AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              // Panel sits at the leading edge; when closed it's translated
              // off-screen toward that edge (left in LTR, right in RTL).
              final hiddenOffset =
                  (1 - _animController.value) * panelWidth * (isRTL ? 1 : -1);
              return Transform.translate(
                offset: Offset(hiddenOffset, 0),
                child: child,
              );
            },
            child: widget.drawerContent,
          ),
        ),
        if (widget.overlayBuilder != null)
          widget.overlayBuilder!(context, _animController),
        if (widget._hasInternalPill) _buildPillPositioner(isRTL, panelWidth),
      ],
    );
  }

  Widget _buildPillPositioner(bool isRTL, double panelWidth) {
    final pill = GestureDetector(
      onHorizontalDragUpdate: (d) => _onDragUpdate(d, panelWidth, isRTL),
      onHorizontalDragEnd: _onDragEnd,
      child: widget.pillBuilder?.call(context, _animController) ??
          DefaultPill(
            animation: _animController,
            text: widget.defaultPillText,
            onTap: widget.controller.toggle,
          ),
    );

    if (widget.isSticky) {
      // Sticky pill: rides the drawer panel's trailing edge as it opens,
      // sliding away from the leading screen edge.
      return AnimatedBuilder(
        animation: _animController,
        builder: (context, _) {
          final top =
              widget.stickyTop ?? MediaQuery.sizeOf(context).height * 0.4;
          return PositionedDirectional(
            top: top,
            start: _animController.value * panelWidth,
            child: pill,
          );
        },
      );
    }

    // Follower pill: at rest it sits on the leading edge (right in RTL,
    // left in LTR) anchored to the target. As the drawer opens (drag or
    // animated), the pill rides on the panel's trailing edge, sliding
    // away from the leading screen edge — leftward in RTL, rightward in
    // LTR.
    //
    // PositionedDirectional(start: 0, top: 0) gives the follower
    // child-sized constraints AND keeps the unlinked fallback on the
    // leading side. CompositedTransformFollower briefly paints at its
    // widget-tree position before the leader's layer is captured. With a
    // literal left:0 we'd see the pill flash on the left edge in RTL —
    // wrong side. showWhenUnlinked: false hides the pill during that one
    // unlinked frame so there's no flicker at all.
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final dragOffset =
            _animController.value * panelWidth * (isRTL ? -1 : 1);
        return PositionedDirectional(
          top: 0,
          start: 0,
          child: CompositedTransformFollower(
            link: widget.link!,
            showWhenUnlinked: false,
            followerAnchor: isRTL ? Alignment.topRight : Alignment.topLeft,
            targetAnchor: isRTL ? Alignment.topRight : Alignment.topLeft,
            offset: Offset(dragOffset, 0),
            child: child,
          ),
        );
      },
      child: pill,
    );
  }
}
