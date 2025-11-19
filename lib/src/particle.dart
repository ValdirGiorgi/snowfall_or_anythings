import 'dart:math';
import 'package:flutter/material.dart';

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

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.sway,
    required this.color,
  });

  /// Factory constructor to create a particle with random properties.
  ///
  /// Parameters:
  /// - [color]: The color of the particle
  /// - [size]: The maximum size of the particle
  /// - [speed]: The maximum speed of the particle
  /// - [width]: The width of the canvas (defaults to 0, will be repositioned on first update)
  /// - [height]: The height of the canvas (defaults to 0, will be repositioned on first update)
  factory Particle.random({
    required Color color,
    required double size,
    required double speed,
    double width = 0,
    double height = 0,
  }) {
    final random = Random();
    return Particle(
      x: random.nextDouble() * (width > 0 ? width : 1000),
      y: random.nextDouble() * (height > 0 ? height : 1000),
      size: random.nextDouble() * size + 2,
      speed: random.nextDouble() * speed + 1,
      sway: random.nextDouble() - 0.5,
      color: color,
    );
  }

  /// Updates the particle's position for the next frame.
  ///
  /// Moves the particle down by [speed] and horizontally by [sway].
  /// When the particle falls below the bottom ([height]), it wraps around
  /// to the top with a new random horizontal position.
  void update(double width, double height) {
    y += speed;
    x += sway;
    if (y > height) {
      y = 0;
      x = Random().nextDouble() * width;
    }
  }
}

/// Custom painter to draw particles as circles.
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (var particle in particles) {
      paint.color = particle.color;
      canvas.drawCircle(Offset(particle.x, particle.y), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

// Custom painter to draw circular particles
class CircularParticlePainter extends CustomPainter {
  final List<Particle> particles;

  CircularParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (var particle in particles) {
      paint.color = particle.color;
      canvas.drawCircle(Offset(particle.x, particle.y), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

/// Custom painter to draw snowflake particles
class SnowflakeParticlePainter extends CustomPainter {
  final List<Particle> snowflakes;
  final Paint snowflakePaint;

  SnowflakeParticlePainter({required this.snowflakes})
      : snowflakePaint = Paint()
          ..color = const Color(0xFFDDDDDD)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    for (var snowflake in snowflakes) {
      _renderSnowflake(canvas, snowflake, snowflakePaint);
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
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
