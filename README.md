# Snowfall or Anythings

A Flutter package to create beautiful snowfall or other particle effects in your applications.

## Features

- Easy to use
- Customizable particles
- High performance

## Installation

Add the following to your `pubspec.yaml` file:

```yaml
dependencies:
    snowfall_or_anythings: ^0.0.1
```

Then run `flutter pub get` to install the package.

## Usage

### Basic Example

```dart
class SnowPage extends StatelessWidget {
  const SnowPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Snowfall Demo'),
      ),
      body: const SnowfallOrAnythings(
        numberOfParticles: 200,
        particleSize: 4.0,
        particleSpeed: 0.8,
        particleType: ParticleType.snowflake,
      ),
    );
  }
}
```

### Customizing Particles

```dart
class CustomPaintpage extends StatelessWidget {
  const CustomPaintpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CustomPainter Demo'),
      ),
      body: SnowfallOrAnythings(
        particleColor: Colors.green,
        numberOfParticles: 150,
        particleSize: 10.0,
        particleSpeed: 2.0,
        customPainter: ({required particles}) =>
            CustomParticlePainter(particles),
      ),
    );
  }
}


class CustomParticlePainter extends CustomPainter {
  final List<Particle> particles;

  CustomParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (final particle in particles) {
      paint.color = particle.color;
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(particle.x, particle.y),
          width: particle.size,
          height: particle.size,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
```

## License
MIT License

Copyright (c) [2024] [Valdir Giorgi]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.