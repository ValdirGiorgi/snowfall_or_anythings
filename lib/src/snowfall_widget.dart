import 'package:flutter/material.dart';
import 'particle.dart';

enum ParticleType { circular, snowflake }

class SnowfallOrAnythings extends StatefulWidget {
  final int numberOfParticles;
  final Color particleColor;
  final double particleSize;
  final double particleSpeed;
  final ParticleType particleType; // Added
  final CustomPainter Function({required List<Particle> particles})?
      customPainter; // Added
  final Widget? particleWidget; // New parameter to support widgets

  const SnowfallOrAnythings({
    super.key,
    this.numberOfParticles = 200,
    this.particleColor = Colors.white,
    this.particleSize = 4.0,
    this.particleSpeed = 1.0,
    this.particleType = ParticleType.snowflake, // Default
    this.customPainter,
    this.particleWidget, // New parameter
  });

  @override
  _SnowfallOrAnythingsState createState() => _SnowfallOrAnythingsState();
}

class _SnowfallOrAnythingsState extends State<SnowfallOrAnythings>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(() {
        setState(() {
          // Update the position of particles
          for (final particle in _particles) {
            particle.update(
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height,
            );
          }
        });
      });

    // Generate particles
    _particles = List.generate(
      widget.numberOfParticles,
      (_) => Particle.random(
        color: widget.particleColor,
        size: widget.particleSize,
        speed: widget.particleSpeed,
      ),
    );

    // Start the animation
    _controller.repeat();
  }

  @override
  void dispose() {
    // Dispose the animation controller
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If the user provided a widget for particles, use a Stack to position them
    if (widget.particleWidget != null) {
      return Stack(
        children: _particles.map((particle) {
          return Positioned(
            left: particle.x,
            top: particle.y,
            child: SizedBox(
              width: particle.size,
              height: particle.size,
              child: widget.particleWidget,
            ),
          );
        }).toList(),
      );
    }

    // Otherwise, render with CustomPainter
    final defaultPainter = widget.particleType == ParticleType.circular
        ? CircularParticlePainter(particles: _particles)
        : SnowflakeParticlePainter(snowflakes: _particles);

    return CustomPaint(
      size: Size.infinite,
      // Use customPainter if provided, otherwise use defaultPainter
      painter: widget.customPainter != null
          ? widget.customPainter!(particles: _particles)
          : defaultPainter,
    );
  }
}
