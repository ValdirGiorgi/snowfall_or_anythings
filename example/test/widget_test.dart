import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const demos = [
    'Playground',
    'Christmas mix',
    'Presets',
    'Particle types',
    'Overlay',
    'Widget particles',
    'Custom painter',
    'Frame rate',
    'Basic snowfall',
  ];

  for (final demo in demos) {
    testWidgets('opens the "$demo" demo', (tester) async {
      tester.view.physicalSize = const Size(1400, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const MyApp());
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text(demo));
      // Let the route transition and a few animation frames run.
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      expect(tester.takeException(), isNull);
      expect(find.byType(BackButton), findsOneWidget);
    });
  }
}
