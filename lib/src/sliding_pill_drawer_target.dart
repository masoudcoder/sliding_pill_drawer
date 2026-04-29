import 'package:flutter/widgets.dart';

/// Marker widget that reserves the slot where the pill button should appear
/// in a scrolling layout. Pair it with a shared [LayerLink] passed to the
/// `SlidingPillDrawer` in follower mode.
///
/// The target auto-aligns to the leading edge of its parent (left in LTR,
/// right in RTL), so the pill always appears flush with the screen edge on
/// the same side the drawer panel slides in from. Drop it directly inside a
/// [ListView] or [Column] at the vertical position where the pill should
/// appear — no outer [Align] or [Padding] needed.
class SlidingPillDrawerTarget extends StatelessWidget {
  /// Creates a [SlidingPillDrawerTarget] linked to [link].
  ///
  /// The [width] and [height] reserve space inside the scrollable so other
  /// content does not overlap the pill at rest.
  const SlidingPillDrawerTarget({
    super.key,
    required this.link,
    this.width = 80,
    this.height = 40,
  });

  /// Shared [LayerLink] also passed to the `SlidingPillDrawer` in follower
  /// mode. The pill renders at this target's position and follows it across
  /// scrolls.
  final LayerLink link;

  /// Reserved width of the slot in the scrollable. Should roughly match the
  /// pill's painted width to avoid overlap with surrounding content.
  final double width;

  /// Reserved height of the slot in the scrollable. Should roughly match the
  /// pill's painted height to avoid overlap with surrounding content.
  final double height;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      heightFactor: 1.0,
      child: CompositedTransformTarget(
        link: link,
        child: SizedBox(width: width, height: height),
      ),
    );
  }
}
