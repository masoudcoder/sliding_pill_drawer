import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sliding_pill_drawer/sliding_pill_drawer.dart';

void main() {
  Widget harness(SlidingPillDrawerController controller, {bool sticky = true}) {
    final link = LayerLink();
    return MaterialApp(
      home: Scaffold(
        body: SlidingPillDrawer(
          controller: controller,
          isSticky: sticky,
          link: sticky ? null : link,
          drawerContent: const SizedBox(child: Text('drawer')),
          body: sticky
              ? const Center(child: Text('body'))
              : ListView(
                  children: [
                    const Text('body'),
                    SlidingPillDrawerTarget(link: link),
                  ],
                ),
        ),
      ),
    );
  }

  testWidgets('starts closed', (tester) async {
    final controller = SlidingPillDrawerController();
    await tester.pumpWidget(harness(controller));
    expect(controller.value, 0.0);
    expect(controller.isOpen, false);
    expect(controller.isFullyOpen, false);
  });

  testWidgets('open() advances the animation to 1.0', (tester) async {
    final controller = SlidingPillDrawerController();
    await tester.pumpWidget(harness(controller));
    controller.open();
    await tester.pumpAndSettle();
    expect(controller.value, 1.0);
    expect(controller.isFullyOpen, true);
  });

  testWidgets('toggle() opens then closes', (tester) async {
    final controller = SlidingPillDrawerController();
    await tester.pumpWidget(harness(controller));
    controller.toggle();
    await tester.pumpAndSettle();
    expect(controller.isOpen, true);
    controller.toggle();
    await tester.pumpAndSettle();
    expect(controller.isOpen, false);
    expect(controller.value, 0.0);
  });

  testWidgets('works in follower mode with a LayerLink', (tester) async {
    final controller = SlidingPillDrawerController();
    await tester.pumpWidget(harness(controller, sticky: false));
    expect(find.text('body'), findsOneWidget);
    controller.open();
    await tester.pumpAndSettle();
    expect(controller.isFullyOpen, true);
  });
}
