import 'package:flutter/material.dart';
import 'package:snowfall_or_anythings/snowfall_or_anythings.dart';

/// Draws every particle as a square.
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

/// Uses [Particle.variantIndex] to draw a different shape per variant:
/// rotated ribbons, squares and dots.
class ConfettiParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ConfettiParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (final particle in particles) {
      paint.color = particle.color;
      final center = Offset(particle.x, particle.y);
      switch (particle.variantIndex) {
        case 0:
          canvas
            ..save()
            ..translate(center.dx, center.dy)
            // Spins as it falls.
            ..rotate(particle.y / 30 + particle.sway * 6)
            ..drawRect(
              Rect.fromCenter(
                center: Offset.zero,
                width: particle.size * 1.6,
                height: particle.size * 0.5,
              ),
              paint,
            )
            ..restore();
        case 1:
          canvas.drawRect(
            Rect.fromCenter(
              center: center,
              width: particle.size,
              height: particle.size,
            ),
            paint,
          );
        default:
          canvas.drawCircle(center, particle.size / 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
