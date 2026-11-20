import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snowfall_or_anythings/snowfall_or_anythings.dart';

/// Captures the particle list and counts paints.
class _ProbePainter extends CustomPainter {
  _ProbePainter(this.onPaint);

  final VoidCallback onPaint;

  @override
  void paint(Canvas canvas, Size size) => onPaint();

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Particle _particle({double speed = 1, double sway = 0}) => Particle(
  x: 50,
  y: 0,
  size: 4,
  speed: speed,
  sway: sway,
  color: Colors.white,
);

Future<void> _pumpFrames(WidgetTester tester, int frames, int ms) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(Duration(milliseconds: ms));
  }
}

void main() {
  group('Particle', () {
    test('update keeps the per-frame behavior', () {
      final particle = _particle(speed: 2)..update(100, 100);
      expect(particle.y, 2);
    });

    test('advance scales movement by delta', () {
      final particle = _particle(speed: 2, sway: 1)..advance(100, 100, 0.5);
      expect(particle.y, 1);
      expect(particle.x, 50.5);
    });

    test('re-enters above the top after leaving the bottom', () {
      final particle = _particle(speed: 10)..y = 100;
      particle.advance(100, 100, 1);
      expect(particle.y, -particle.size);
    });

    test('wraps horizontally when drifting out of the sides', () {
      final particle = _particle(sway: -1)..x = -4.5;
      particle.advance(100, 1000, 1);
      expect(particle.x, greaterThan(100));
    });
  });

  group('SnowfallOrAnythings', () {
    testWidgets('falling speed does not depend on the refresh rate', (
      tester,
    ) async {
      Future<double> distanceIn1s(int frameMs) async {
        List<Particle>? captured;
        await tester.pumpWidget(
          MaterialApp(
            key: UniqueKey(),
            home: SnowfallOrAnythings(
              numberOfParticles: 1,
              // Every particle gets exactly speed 1.
              particleSpeed: 0,
              customPainter: ({required particles}) {
                captured = particles;
                return _ProbePainter(() {});
              },
            ),
          ),
        );
        await tester.pump();
        final particle =
            captured!.first
              ..y = 0
              ..x = 100;
        var distance = 0.0;
        var last = 0.0;
        for (var i = 0; i < 1000 ~/ frameMs; i++) {
          await tester.pump(Duration(milliseconds: frameMs));
          // Ignore wraps: accumulate only forward movement.
          if (particle.y > last) distance += particle.y - last;
          last = particle.y;
        }
        return distance;
      }

      final at60 = await distanceIn1s(16);
      final at120 = await distanceIn1s(8);
      expect(at120, closeTo(at60, at60 * 0.1));
    });

    testWidgets('maxFps limits the number of updates', (tester) async {
      var builds = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: SnowfallOrAnythings(
            numberOfParticles: 1,
            maxFps: 30,
            customPainter: ({required particles}) {
              builds++;
              return _ProbePainter(() {});
            },
          ),
        ),
      );
      builds = 0;
      await _pumpFrames(tester, 60, 16);
      expect(builds, inInclusiveRange(28, 32));
    });

    testWidgets('deprecated frameRateMs still works as a cap', (tester) async {
      var builds = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: SnowfallOrAnythings(
            numberOfParticles: 1,
            // ignore: deprecated_member_use_from_same_package
            frameRateMs: 33,
            customPainter: ({required particles}) {
              builds++;
              return _ProbePainter(() {});
            },
          ),
        ),
      );
      builds = 0;
      await _pumpFrames(tester, 60, 16);
      expect(builds, inInclusiveRange(28, 32));
    });

    testWidgets('custom painters repaint every frame', (tester) async {
      var paints = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: SnowfallOrAnythings(
            numberOfParticles: 1,
            customPainter:
                ({required particles}) => _ProbePainter(() => paints++),
          ),
        ),
      );
      paints = 0;
      await _pumpFrames(tester, 30, 16);
      expect(paints, greaterThanOrEqualTo(29));
    });

    testWidgets('particles stay inside the widget area', (tester) async {
      List<Particle>? captured;
      await tester.pumpWidget(
        MaterialApp(
          home: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 100,
              height: 100,
              child: SnowfallOrAnythings(
                numberOfParticles: 50,
                customPainter: ({required particles}) {
                  captured = particles;
                  return _ProbePainter(() {});
                },
              ),
            ),
          ),
        ),
      );
      await _pumpFrames(tester, 300, 16);
      for (final particle in captured!) {
        expect(particle.y, lessThanOrEqualTo(100 + particle.size * 2));
      }
    });

    testWidgets('does not block taps on widgets below', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => taps++,
                  child: const ColoredBox(color: Colors.blue),
                ),
              ),
              const Positioned.fill(
                child: SnowfallOrAnythings(numberOfParticles: 5),
              ),
            ],
          ),
        ),
      );
      await tester.tapAt(const Offset(200, 300));
      expect(taps, 1);
    });

    testWidgets('applies parameter changes without a Key', (tester) async {
      List<Particle>? captured;
      Widget build(int count, Color color) => MaterialApp(
        home: SnowfallOrAnythings(
          numberOfParticles: count,
          particleColor: color,
          customPainter: ({required particles}) {
            captured = particles;
            return _ProbePainter(() {});
          },
        ),
      );

      await tester.pumpWidget(build(10, Colors.white));
      expect(captured, hasLength(10));

      await tester.pumpWidget(build(20, Colors.red));
      await tester.pump();
      expect(captured, hasLength(20));
      expect(captured!.every((p) => p.color == Colors.red), isTrue);
    });

    testWidgets('renders one widget per particle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SnowfallOrAnythings(
            numberOfParticles: 7,
            particleWidget: Icon(Icons.star),
          ),
        ),
      );
      await _pumpFrames(tester, 5, 16);
      expect(find.byIcon(Icons.star), findsNWidgets(7));
    });

    testWidgets('renders every built-in particle type', (tester) async {
      for (final type in ParticleType.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: SnowfallOrAnythings(
              numberOfParticles: 10,
              particleType: type,
            ),
          ),
        );
        await _pumpFrames(tester, 3, 16);
        expect(tester.takeException(), isNull);
      }
    });
  });
}
