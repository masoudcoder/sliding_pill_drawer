import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sliding_pill_drawer/sliding_pill_drawer.dart';

void main() {
  Widget harness({
    required Animation<double> animation,
    required VoidCallback onTap,
    TextDirection direction = TextDirection.ltr,
    String text = 'Menu',
  }) {
    return MaterialApp(
      home: Directionality(
        textDirection: direction,
        child: Scaffold(
          body: Center(
            child: DefaultPill(
              animation: animation,
              text: text,
              onTap: onTap,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('LTR shows the back-arrow chevron', (tester) async {
    await tester.pumpWidget(
      harness(
        animation: const AlwaysStoppedAnimation<double>(0),
        onTap: () {},
      ),
    );

    expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
    expect(find.byIcon(Icons.arrow_forward_ios), findsNothing);
  });

  testWidgets('RTL shows the forward-arrow chevron', (tester) async {
    await tester.pumpWidget(
      harness(
        animation: const AlwaysStoppedAnimation<double>(0),
        onTap: () {},
        direction: TextDirection.rtl,
      ),
    );

    expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_ios_new), findsNothing);
  });

  testWidgets('text is visible at animation value 0', (tester) async {
    await tester.pumpWidget(
      harness(
        animation: const AlwaysStoppedAnimation<double>(0),
        onTap: () {},
        text: 'Menu',
      ),
    );

    expect(find.text('Menu'), findsOneWidget);

    final fade = tester.widget<FadeTransition>(
      find.descendant(
        of: find.byType(DefaultPill),
        matching: find.byType(FadeTransition),
      ),
    );
    expect(fade.opacity.value, 1.0);
  });

  testWidgets('text fades to invisible at animation value 1', (tester) async {
    await tester.pumpWidget(
      harness(
        animation: const AlwaysStoppedAnimation<double>(1),
        onTap: () {},
        text: 'Menu',
      ),
    );

    final fade = tester.widget<FadeTransition>(
      find.descendant(
        of: find.byType(DefaultPill),
        matching: find.byType(FadeTransition),
      ),
    );
    expect(fade.opacity.value, 0.0);
  });

  testWidgets('tapping the pill invokes onTap', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      harness(
        animation: const AlwaysStoppedAnimation<double>(0),
        onTap: () => taps++,
      ),
    );

    await tester.tap(find.byType(DefaultPill));
    await tester.pumpAndSettle();

    expect(taps, 1);
  });
}
