import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sliding_pill_drawer/sliding_pill_drawer.dart';

void main() {
  Widget stickyHarness({
    required SlidingPillDrawerController controller,
    TextDirection direction = TextDirection.ltr,
    double panelWidthFraction = 0.85,
    PillBuilder? pillBuilder,
    BackdropBuilder? backdropBuilder,
    double? stickyTop,
  }) {
    return MaterialApp(
      home: Directionality(
        textDirection: direction,
        child: Scaffold(
          body: SlidingPillDrawer(
            controller: controller,
            isSticky: true,
            stickyTop: stickyTop,
            panelWidthFraction: panelWidthFraction,
            pillBuilder: pillBuilder,
            backdropBuilder: backdropBuilder,
            drawerContent: const SizedBox(
              key: ValueKey('drawer'),
              child: Text('drawer'),
            ),
            body: const Center(child: Text('body')),
          ),
        ),
      ),
    );
  }

  testWidgets('horizontal drag on the pill opens and closes the drawer',
      (tester) async {
    final controller = SlidingPillDrawerController();
    await tester.pumpWidget(stickyHarness(controller: controller));
    await tester.pumpAndSettle();

    final pill = find.byType(DefaultPill);
    expect(pill, findsOneWidget);

    // Drag the pill far enough to cross the snap threshold (>50%).
    await tester.drag(pill, const Offset(500, 0));
    await tester.pumpAndSettle();
    expect(controller.isFullyOpen, isTrue);

    // Drag back the other direction to close.
    await tester.drag(pill, const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(controller.value, 0.0);
  });

  testWidgets('tapping the backdrop closes an open drawer', (tester) async {
    final controller = SlidingPillDrawerController();
    await tester.pumpWidget(stickyHarness(controller: controller));
    controller.open();
    await tester.pumpAndSettle();
    expect(controller.isFullyOpen, isTrue);

    // The backdrop covers the full screen; tap somewhere clearly outside the
    // panel to make sure we hit the backdrop layer, not the panel.
    final size = tester.getSize(find.byType(MaterialApp));
    await tester.tapAt(Offset(size.width - 10, size.height / 2));
    await tester.pumpAndSettle();

    expect(controller.value, 0.0);
  });

  testWidgets('panelWidthFraction sizes the panel relative to screen width',
      (tester) async {
    final controller = SlidingPillDrawerController();
    await tester.pumpWidget(
      stickyHarness(controller: controller, panelWidthFraction: 0.5),
    );
    controller.open();
    await tester.pumpAndSettle();

    final screenWidth = tester.getSize(find.byType(MaterialApp)).width;
    final panelWidth =
        tester.getSize(find.byKey(const ValueKey('drawer'))).width;
    expect(panelWidth, closeTo(screenWidth * 0.5, 0.5));
  });

  testWidgets('custom pillBuilder is rendered instead of DefaultPill',
      (tester) async {
    final controller = SlidingPillDrawerController();
    await tester.pumpWidget(
      stickyHarness(
        controller: controller,
        pillBuilder: (context, animation) => const SizedBox(
          key: ValueKey('custom-pill'),
          width: 80,
          height: 40,
          child: ColoredBox(color: Color(0xFF00FF00)),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('custom-pill')), findsOneWidget);
    expect(find.byType(DefaultPill), findsNothing);
  });

  testWidgets('custom backdropBuilder receives the open animation',
      (tester) async {
    final controller = SlidingPillDrawerController();
    final seenValues = <double>[];

    await tester.pumpWidget(
      stickyHarness(
        controller: controller,
        backdropBuilder: (context, animation) {
          seenValues.add(animation.value);
          return const SizedBox.expand(
            key: ValueKey('custom-backdrop'),
          );
        },
      ),
    );

    controller.open();
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('custom-backdrop')), findsOneWidget);
    expect(seenValues.last, 1.0);
    expect(seenValues.any((v) => v > 0.0 && v < 1.0), isTrue);
  });

  testWidgets('RTL panel translates from the right', (tester) async {
    final controller = SlidingPillDrawerController();
    await tester.pumpWidget(
      stickyHarness(
        controller: controller,
        direction: TextDirection.rtl,
      ),
    );
    await tester.pumpAndSettle();

    final screenWidth = tester.getSize(find.byType(MaterialApp)).width;

    // Closed: panel sits off-screen on the right edge in RTL.
    final closedLeft =
        tester.getTopLeft(find.byKey(const ValueKey('drawer'))).dx;
    expect(closedLeft, greaterThan(screenWidth * 0.9));

    // Open: panel rests against the right edge of the screen.
    controller.open();
    await tester.pumpAndSettle();
    final openRight =
        tester.getTopRight(find.byKey(const ValueKey('drawer'))).dx;
    expect(openRight, closeTo(screenWidth, 1.0));
  });

  testWidgets('stickyTop positions the pill at the requested offset',
      (tester) async {
    final controller = SlidingPillDrawerController();
    const desiredTop = 120.0;

    await tester.pumpWidget(
      stickyHarness(controller: controller, stickyTop: desiredTop),
    );
    await tester.pumpAndSettle();

    final pillTop = tester.getTopLeft(find.byType(DefaultPill)).dy;
    expect(pillTop, closeTo(desiredTop, 1.0));
  });
}
