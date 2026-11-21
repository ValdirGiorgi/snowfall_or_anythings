import 'dart:math';
import 'package:flutter/widgets.dart';

import 'particle_variant.dart' show ParticleVariant;

/// Represents a single falling particle in the animation.
///
/// Each particle has position ([x], [y]), visual properties ([size], [color]),
/// and movement characteristics ([speed], [sway]).
class Particle {
  /// Current horizontal position in logical pixels
  double x;

  /// Current vertical position in logical pixels
  double y;

  /// Size of the particle in logical pixels
  double size;

  /// Vertical falling speed
  double speed;

  /// Horizontal drift (swaying effect)
  double sway;

  /// Color of the particle
  final Color color;

  /// Index of the [ParticleVariant] this particle belongs to, when
  /// `SnowfallOrAnythings.particleVariants` is used. Always `0` otherwise.
  ///
  /// Useful in a custom painter to draw each variant differently.
  final int variantIndex;

  /// Shared random generator, avoids allocating a new [Random] per particle.
  static final Random _random = Random();

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.sway,
    required this.color,
    this.variantIndex = 0,
  });

  /// Factory constructor to create a particle with random properties.
  ///
  /// Parameters:
  /// - [color]: The color of the particle
  /// - [size]: The maximum size of the particle
  /// - [speed]: The maximum speed of the particle
  /// - [width]: The width of the canvas (defaults to 0, will be repositioned on first update)
  /// - [height]: The height of the canvas (defaults to 0, will be repositioned on first update)
  /// - [variantIndex]: See [Particle.variantIndex]
  factory Particle.random({
    required Color color,
    required double size,
    required double speed,
    double width = 0,
    double height = 0,
    int variantIndex = 0,
  }) {
    final random = _random;
    return Particle(
      x: random.nextDouble() * (width > 0 ? width : 1000),
      y: random.nextDouble() * (height > 0 ? height : 1000),
      size: random.nextDouble() * size + 2,
      speed: random.nextDouble() * speed + 1,
      sway: random.nextDouble() - 0.5,
      color: color,
      variantIndex: variantIndex,
    );
  }

  /// Updates the particle's position for the next frame.
  ///
  /// Same as calling [advance] with a `delta` of `1.0` (one frame at 60 FPS).
  void update(double width, double height) => advance(width, height, 1.0);

  /// Moves the particle by [delta] frames, where `1.0` is one frame at 60 FPS.
  ///
  /// Moves the particle down by `speed * delta` and horizontally by
  /// `sway * delta`. When the particle leaves the bottom of the area
  /// ([height]), it re-enters from just above the top with a new random
  /// horizontal position. Particles drifting out of the sides wrap around
  /// to the opposite side.
  void advance(double width, double height, double delta) {
    y += speed * delta;
    x += sway * delta;
    if (y - size > height) {
      y = -size;
      x = _random.nextDouble() * width;
    } else if (width > 0) {
      if (x < -size) {
        x += width + size * 2;
      } else if (x > width + size) {
        x -= width + size * 2;
      }
    }
  }

  /// Equality is based on the current (mutable) state of the particle.
  /// Avoid using particles as keys in sets or maps.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Particle &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y &&
          size == other.size &&
          speed == other.speed &&
          color == other.color;

  @override
  int get hashCode => Object.hash(x, y, size, speed, color);
}

/// Custom painter to draw circular particles.
class CircularParticlePainter extends CustomPainter {
  final List<Particle> particles;

  /// Creates the painter.
  ///
  /// Pass [repaint] to repaint whenever that [Listenable] notifies, without
  /// creating a new painter on every frame.
  CircularParticlePainter({required this.particles, super.repaint});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (var particle in particles) {
      paint.color = particle.color;
      canvas.drawCircle(Offset(particle.x, particle.y), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CircularParticlePainter oldDelegate) {
    // Particles are mutated in place; movement repaints come from [repaint].
    return !identical(oldDelegate.particles, particles);
  }
}

/// Custom painter to draw particles as circles (alias for [CircularParticlePainter]).
@Deprecated(
  'Use CircularParticlePainter instead. '
  'This alias will be removed in a future major version.',
)
class ParticlePainter extends CircularParticlePainter {
  /// Creates the painter.
  @Deprecated(
    'Use CircularParticlePainter instead. '
    'This alias will be removed in a future major version.',
  )
  ParticlePainter({required super.particles, super.repaint});
}

/// Custom painter to draw snowflake particles
class SnowflakeParticlePainter extends CustomPainter {
  final List<Particle> snowflakes;

  /// Creates the painter.
  ///
  /// Pass [repaint] to repaint whenever that [Listenable] notifies, without
  /// creating a new painter on every frame.
  SnowflakeParticlePainter({required this.snowflakes, super.repaint});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    for (var snowflake in snowflakes) {
      paint.color = snowflake.color;
      _renderSnowflake(canvas, snowflake, paint);
    }
  }

  // Render a single snowflake
  void _renderSnowflake(Canvas canvas, Particle snowflake, Paint paint) {
    final center = Offset(snowflake.x, snowflake.y);
    final radius = snowflake.size;

    for (int i = 0; i < 6; i++) {
      final angle = i * pi / 3 + snowflake.sway;
      final endPoint = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );

      // Draw main branch
      canvas.drawLine(center, endPoint, paint);

      // Draw small details on each branch
      final midPoint = Offset(
        center.dx + (radius * 0.6) * cos(angle),
        center.dy + (radius * 0.6) * sin(angle),
      );
      final sideOffset1 = Offset(
        midPoint.dx + (radius * 0.3) * cos(angle - pi / 6),
        midPoint.dy + (radius * 0.3) * sin(angle - pi / 6),
      );
      final sideOffset2 = Offset(
        midPoint.dx + (radius * 0.3) * cos(angle + pi / 6),
        midPoint.dy + (radius * 0.3) * sin(angle + pi / 6),
      );

      // Add side branches
      canvas.drawLine(midPoint, sideOffset1, paint);
      canvas.drawLine(midPoint, sideOffset2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant SnowflakeParticlePainter oldDelegate) {
    // Particles are mutated in place; movement repaints come from [repaint].
    return !identical(oldDelegate.snowflakes, snowflakes);
  }
}

/// Custom painter to draw star particles
class StarParticlePainter extends CustomPainter {
  final List<Particle> particles;

  /// Creates the painter.
  ///
  /// Pass [repaint] to repaint whenever that [Listenable] notifies, without
  /// creating a new painter on every frame.
  StarParticlePainter({required this.particles, super.repaint});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var particle in particles) {
      paint.color = particle.color;
      _renderStar(canvas, particle, paint);
    }
  }

  void _renderStar(Canvas canvas, Particle particle, Paint paint) {
    final center = Offset(particle.x, particle.y);
    final outerRadius = particle.size;
    final innerRadius = particle.size * 0.4;
    final path = Path();

    for (int i = 0; i < 5; i++) {
      final outerAngle = (i * 72 - 90) * pi / 180 + particle.sway;
      final innerAngle = ((i * 72) + 36 - 90) * pi / 180 + particle.sway;

      final outerPoint = Offset(
        center.dx + outerRadius * cos(outerAngle),
        center.dy + outerRadius * sin(outerAngle),
      );
      final innerPoint = Offset(
        center.dx + innerRadius * cos(innerAngle),
        center.dy + innerRadius * sin(innerAngle),
      );

      if (i == 0) {
        path.moveTo(outerPoint.dx, outerPoint.dy);
      } else {
        path.lineTo(outerPoint.dx, outerPoint.dy);
      }
      path.lineTo(innerPoint.dx, innerPoint.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant StarParticlePainter oldDelegate) {
    // Particles are mutated in place; movement repaints come from [repaint].
    return !identical(oldDelegate.particles, particles);
  }
}

/// Custom painter to draw heart particles
class HeartParticlePainter extends CustomPainter {
  final List<Particle> particles;

  /// Creates the painter.
  ///
  /// Pass [repaint] to repaint whenever that [Listenable] notifies, without
  /// creating a new painter on every frame.
  HeartParticlePainter({required this.particles, super.repaint});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var particle in particles) {
      paint.color = particle.color;
      _renderHeart(canvas, particle, paint);
    }
  }

  void _renderHeart(Canvas canvas, Particle particle, Paint paint) {
    final center = Offset(particle.x, particle.y);
    final size = particle.size;
    final path = Path();

    // Heart shape using bezier curves
    path.moveTo(center.dx, center.dy + size * 0.3);

    // Left curve
    path.cubicTo(
      center.dx - size,
      center.dy - size * 0.3,
      center.dx - size * 0.5,
      center.dy - size,
      center.dx,
      center.dy - size * 0.4,
    );

    // Right curve
    path.cubicTo(
      center.dx + size * 0.5,
      center.dy - size,
      center.dx + size,
      center.dy - size * 0.3,
      center.dx,
      center.dy + size * 0.3,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant HeartParticlePainter oldDelegate) {
    // Particles are mutated in place; movement repaints come from [repaint].
    return !identical(oldDelegate.particles, particles);
  }
}

/// Custom painter to draw leaf particles
class LeafParticlePainter extends CustomPainter {
  final List<Particle> particles;

  /// Creates the painter.
  ///
  /// Pass [repaint] to repaint whenever that [Listenable] notifies, without
  /// creating a new painter on every frame.
  LeafParticlePainter({required this.particles, super.repaint});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final veinPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
    final sideVeinPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    for (var particle in particles) {
      paint.color = particle.color;
      _renderLeaf(canvas, particle, paint, veinPaint, sideVeinPaint);
    }
  }

  void _renderLeaf(
    Canvas canvas,
    Particle particle,
    Paint paint,
    Paint veinPaint,
    Paint sideVeinPaint,
  ) {
    final center = Offset(particle.x, particle.y);
    final size = particle.size;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(particle.sway * 2); // Rotate based on sway

    final path = Path();

    // Realistic leaf shape with pointed tip and curved sides
    path.moveTo(0, -size); // Top point (tip of leaf)

    // Right side curve
    path.cubicTo(
      size * 0.5,
      -size * 0.7, // Control point 1
      size * 0.6,
      -size * 0.2, // Control point 2
      size * 0.5,
      size * 0.2, // End point (widest part)
    );
    path.cubicTo(
      size * 0.4,
      size * 0.5, // Control point 1
      size * 0.2,
      size * 0.8, // Control point 2
      0,
      size, // Bottom point (stem)
    );

    // Left side curve (mirror)
    path.cubicTo(
      -size * 0.2,
      size * 0.8, // Control point 1
      -size * 0.4,
      size * 0.5, // Control point 2
      -size * 0.5,
      size * 0.2, // End point (widest part)
    );
    path.cubicTo(
      -size * 0.6,
      -size * 0.2, // Control point 1
      -size * 0.5,
      -size * 0.7, // Control point 2
      0,
      -size, // Back to top
    );

    path.close();
    canvas.drawPath(path, paint);

    // Draw central vein
    veinPaint
      ..color = particle.color.withValues(alpha: 0.4)
      ..strokeWidth = size * 0.08;
    canvas.drawLine(Offset(0, -size * 0.8), Offset(0, size * 0.7), veinPaint);

    // Draw side veins
    sideVeinPaint
      ..color = particle.color.withValues(alpha: 0.3)
      ..strokeWidth = size * 0.05;

    // Right side veins
    canvas.drawLine(
      Offset(0, -size * 0.4),
      Offset(size * 0.3, -size * 0.1),
      sideVeinPaint,
    );
    canvas.drawLine(
      Offset(0, size * 0.1),
      Offset(size * 0.35, size * 0.25),
      sideVeinPaint,
    );

    // Left side veins
    canvas.drawLine(
      Offset(0, -size * 0.4),
      Offset(-size * 0.3, -size * 0.1),
      sideVeinPaint,
    );
    canvas.drawLine(
      Offset(0, size * 0.1),
      Offset(-size * 0.35, size * 0.25),
      sideVeinPaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant LeafParticlePainter oldDelegate) {
    // Particles are mutated in place; movement repaints come from [repaint].
    return !identical(oldDelegate.particles, particles);
  }
}

/// Custom painter to draw raindrop particles
class RaindropParticlePainter extends CustomPainter {
  final List<Particle> particles;

  /// Creates the painter.
  ///
  /// Pass [repaint] to repaint whenever that [Listenable] notifies, without
  /// creating a new painter on every frame.
  RaindropParticlePainter({required this.particles, super.repaint});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var particle in particles) {
      paint.color = particle.color;
      _renderRaindrop(canvas, particle, paint);
    }
  }

  void _renderRaindrop(Canvas canvas, Particle particle, Paint paint) {
    final center = Offset(particle.x, particle.y);
    final size = particle.size;
    final path = Path();

    // Teardrop/raindrop shape
    path.moveTo(center.dx, center.dy - size);
    path.quadraticBezierTo(
      center.dx + size * 0.6,
      center.dy,
      center.dx,
      center.dy + size * 0.5,
    );
    path.quadraticBezierTo(
      center.dx - size * 0.6,
      center.dy,
      center.dx,
      center.dy - size,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant RaindropParticlePainter oldDelegate) {
    // Particles are mutated in place; movement repaints come from [repaint].
    return !identical(oldDelegate.particles, particles);
  }
}
