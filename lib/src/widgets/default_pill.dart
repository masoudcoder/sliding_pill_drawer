import 'package:flutter/material.dart';

/// Default pill button rendered by [SlidingPillDrawer] when no custom
/// `pillBuilder` is provided.
///
/// Displays a label and a chevron icon. As [animation] progresses from `0.0`
/// (closed) to `1.0` (open), the label fades and collapses while the icon
/// rotates 180° to point back toward the closing direction. The chevron
/// orientation follows the ambient [Directionality], so the closed-state
/// arrow always points toward the drag direction that opens the drawer
/// (rightward in LTR, leftward in RTL).
class DefaultPill extends StatelessWidget {
  /// Creates a [DefaultPill] driven by the supplied [animation].
  const DefaultPill({
    super.key,
    required this.animation,
    required this.text,
    required this.onTap,
  });

  /// Drives the pill's open/close visual state. Typically forwarded from
  /// [SlidingPillDrawer]'s internal [AnimationController].
  final Animation<double> animation;

  /// Label rendered next to the chevron when the drawer is closed.
  final String text;

  /// Called when the user taps the pill. Usually wired to
  /// `SlidingPillDrawerController.toggle`.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // The closed-state arrow points toward the drag direction that opens
    // the drawer — rightward in LTR, leftward in RTL. The 180° rotation
    // tween then flips it to the close direction once open.
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final isLTR = Directionality.of(context) == TextDirection.ltr;
    final closedIcon =
        isRTL ? Icons.arrow_forward_ios : Icons.arrow_back_ios_new;
    return Material(
      color: Theme.of(context).primaryColor,
      elevation: 4,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadiusDirectional.horizontal(
          end: Radius.circular(20),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizeTransition(
                sizeFactor:
                    Tween<double>(begin: 1.0, end: 0.0).animate(animation),
                axis: Axis.horizontal,
                child: FadeTransition(
                  opacity:
                      Tween<double>(begin: 1.0, end: 0.0).animate(animation),
                  child: Text(
                    text,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              RotationTransition(
                turns: Tween<double>(begin: 0.0, end: 0.5).animate(animation),
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 8),
                  child: Transform.flip(
                    flipX: isLTR,
                    child: Icon(
                      closedIcon,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
