import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snowfall_or_anythings/snowfall_or_anythings.dart';

class _ProbePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {}

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Map<int, int> _countByVariant(List<Particle> particles) {
  final counts = <int, int>{};
  for (final p in particles) {
    counts[p.variantIndex] = (counts[p.variantIndex] ?? 0) + 1;
  }
  return counts;
}

void main() {
  testWidgets('splits particles exactly by weight', (tester) async {
    List<Particle>? captured;
    await tester.pumpWidget(
      MaterialApp(
        home: SnowfallOrAnythings(
          numberOfParticles: 100,
          customPainter: ({required particles}) {
            captured = particles;
            return _ProbePainter();
          },
          particleVariants: const [
            ParticleVariant(type: ParticleType.snowflake, weight: 60),
            ParticleVariant(type: ParticleType.star, weight: 30),
            ParticleVariant(type: ParticleType.heart, weight: 10),
          ],
        ),
      ),
    );
    expect(captured, hasLength(100));
    expect(_countByVariant(captured!), {0: 60, 1: 30, 2: 10});
  });

  testWidgets('rounding always adds up to numberOfParticles', (tester) async {
    List<Particle>? captured;
    await tester.pumpWidget(
      MaterialApp(
        home: SnowfallOrAnythings(
          numberOfParticles: 7,
          customPainter: ({required particles}) {
            captured = particles;
            return _ProbePainter();
          },
          particleVariants: const [
            ParticleVariant(weight: 1),
            ParticleVariant(weight: 1),
            ParticleVariant(weight: 1),
          ],
        ),
      ),
    );
    expect(captured, hasLength(7));
    final counts = _countByVariant(captured!).values.toList()..sort();
    expect(counts, [2, 2, 3]);
  });

  testWidgets('variant color, size and speed override the defaults', (
    tester,
  ) async {
    List<Particle>? captured;
    await tester.pumpWidget(
      MaterialApp(
        home: SnowfallOrAnythings(
          numberOfParticles: 20,
          particleColor: Colors.white,
          customPainter: ({required particles}) {
            captured = particles;
            return _ProbePainter();
          },
          particleVariants: const [
            ParticleVariant(weight: 1),
            ParticleVariant(color: Colors.red, size: 0, speed: 0, weight: 1),
          ],
        ),
      ),
    );
    final first = captured!.where((p) => p.variantIndex == 0);
    final second = captured!.where((p) => p.variantIndex == 1);
    expect(first.every((p) => p.color == Colors.white), isTrue);
    expect(second.every((p) => p.color == Colors.red), isTrue);
    // size: random * 0 + 2, speed: random * 0 + 1.
    expect(second.every((p) => p.size == 2 && p.speed == 1), isTrue);
  });

  testWidgets('mixes shapes and widgets', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SnowfallOrAnythings(
          numberOfParticles: 10,
          particleVariants: [
            ParticleVariant(type: ParticleType.star, weight: 1),
            ParticleVariant(widget: Icon(Icons.ac_unit), weight: 1),
          ],
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 16));
    expect(find.byIcon(Icons.ac_unit), findsNWidgets(5));
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps particles when only widget instances change', (
    tester,
  ) async {
    List<Particle>? captured;
    Widget build() => MaterialApp(
      home: SnowfallOrAnythings(
        numberOfParticles: 10,
        customPainter: ({required particles}) {
          captured = particles;
          return _ProbePainter();
        },
        // Non-const: a new Text instance on every build.
        particleVariants: [
          ParticleVariant(widget: Text(String.fromCharCode(0x2744)), weight: 1),
        ],
      ),
    );
    await tester.pumpWidget(build());
    final before = captured;
    await tester.pumpWidget(build());
    expect(identical(captured, before), isTrue);
  });

  testWidgets('regenerates when the mix changes', (tester) async {
    List<Particle>? captured;
    Widget build(double weight) => MaterialApp(
      home: SnowfallOrAnythings(
        numberOfParticles: 10,
        customPainter: ({required particles}) {
          captured = particles;
          return _ProbePainter();
        },
        particleVariants: [
          const ParticleVariant(weight: 1),
          ParticleVariant(weight: weight),
        ],
      ),
    );
    await tester.pumpWidget(build(1));
    expect(_countByVariant(captured!), {0: 5, 1: 5});
    await tester.pumpWidget(build(4));
    expect(_countByVariant(captured!), {0: 2, 1: 8});
  });

  testWidgets('uses at most maxParticleVariants entries', (tester) async {
    final errors = <FlutterErrorDetails>[];
    final previous = FlutterError.onError;
    FlutterError.onError = errors.add;
    await tester.pumpWidget(
      MaterialApp(
        home: SnowfallOrAnythings(
          numberOfParticles: 60,
          particleVariants: List.generate(
            6,
            (_) => const ParticleVariant(weight: 1),
          ),
        ),
      ),
    );
    FlutterError.onError = previous;
    // Debug builds report the misuse with an assert.
    expect(errors, isNotEmpty);
  });

  testWidgets('without variants every particle has variantIndex 0', (
    tester,
  ) async {
    List<Particle>? captured;
    await tester.pumpWidget(
      MaterialApp(
        home: SnowfallOrAnythings(
          numberOfParticles: 10,
          customPainter: ({required particles}) {
            captured = particles;
            return _ProbePainter();
          },
        ),
      ),
    );
    expect(captured!.every((p) => p.variantIndex == 0), isTrue);
  });
}
