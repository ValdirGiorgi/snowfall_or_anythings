import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snowfall_or_anythings/snowfall_or_anythings.dart';

class _ProbePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {}

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

void main() {
  testWidgets('first layout with an empty size (Android startup) still '
      'spreads particles over the real area', (tester) async {
    List<Particle>? captured;
    addTearDown(tester.view.reset);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = Size.zero;

    await tester.pumpWidget(
      MaterialApp(
        home: SnowfallOrAnythings(
          numberOfParticles: 200,
          customPainter: ({required particles}) {
            captured = particles;
            return _ProbePainter();
          },
        ),
      ),
    );

    tester.view.physicalSize = const Size(400, 300);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));

    expect(captured, hasLength(200));
    for (final p in captured!) {
      expect(p.x, inInclusiveRange(-p.size, 400 + p.size));
      expect(p.y, inInclusiveRange(-p.size, 300 + p.size));
    }
  });
}
