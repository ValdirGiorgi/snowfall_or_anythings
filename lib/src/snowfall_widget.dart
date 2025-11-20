import 'package:flutter/material.dart';
import 'particle.dart';

enum ParticleType { circular, snowflake }

/// A widget that creates a snowfall or any kind of falling particle animation.
///
/// This widget can display falling particles using different rendering modes:
/// - Built-in particle types ([ParticleType.circular] or [ParticleType.snowflake])
/// - Custom painter for advanced rendering
/// - Custom widgets as particles
///
/// Example:
/// ```dart
/// SnowfallOrAnythings(
///   numberOfParticles: 200,
///   particleSize: 4.0,
///   particleSpeed: 1.0,
///   particleType: ParticleType.snowflake,
/// )
/// ```
class SnowfallOrAnythings extends StatefulWidget {
  /// Number of particles to display
  final int numberOfParticles;

  /// Color of the particles (used with built-in particle types)
  final Color particleColor;

  /// Maximum size of particles in logical pixels
  final double particleSize;

  /// Maximum falling speed of particles
  final double particleSpeed;

  /// Type of particle to render (circular or snowflake)
  final ParticleType particleType;

  /// Optional custom painter for advanced particle rendering
  final CustomPainter Function({required List<Particle> particles})?
  customPainter;

  /// Optional widget to use as particle (instead of painting)
  final Widget? particleWidget;

  /// Frame rate of the animation in milliseconds per frame.
  /// Default is 16ms (~60 FPS). Lower values = higher FPS, higher values = lower FPS.
  /// For example: 33ms = ~30 FPS, 16ms = ~60 FPS, 8ms = ~120 FPS
  final int frameRateMs;

  const SnowfallOrAnythings({
    super.key,
    this.numberOfParticles = 200,
    this.particleColor = Colors.white,
    this.particleSize = 4.0,
    this.particleSpeed = 1.0,
    this.particleType = ParticleType.snowflake,
    this.customPainter,
    this.particleWidget,
    this.frameRateMs = 16,
  });

  @override
  State<SnowfallOrAnythings> createState() => _SnowfallOrAnythingsState();
}

class _SnowfallOrAnythingsState extends State<SnowfallOrAnythings>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Particle>? _particles;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller with custom frame rate
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.frameRateMs),
    )..addListener(() {
      if (_particles != null) {
        setState(() {
          // Update the position of particles
          final size = MediaQuery.of(context).size;
          for (final particle in _particles!) {
            particle.update(size.width, size.height);
          }
        });
      }
    });

    // Start the animation
    _controller.repeat();
  }

  void _initializeParticles(double width, double height) {
    // Generate particles with correct dimensions
    _particles = List.generate(
      widget.numberOfParticles,
      (_) => Particle.random(
        color: widget.particleColor,
        size: widget.particleSize,
        speed: widget.particleSpeed,
        width: width,
        height: height,
      ),
    );
  }

  @override
  void dispose() {
    // Dispose the animation controller
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Initialize particles with correct dimensions on first build
        if (_particles == null) {
          _initializeParticles(
            constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : MediaQuery.of(context).size.width,
            constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : MediaQuery.of(context).size.height,
          );
        }

        // Wait for particles to be initialized
        if (_particles == null || _particles!.isEmpty) {
          return const SizedBox.shrink();
        }

        // If the user provided a widget for particles, use a Stack to position them
        if (widget.particleWidget != null) {
          return Stack(
            children:
                _particles!.map((particle) {
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
        final defaultPainter =
            widget.particleType == ParticleType.circular
                ? CircularParticlePainter(particles: _particles!)
                : SnowflakeParticlePainter(snowflakes: _particles!);

        return CustomPaint(
          size: Size.infinite,
          // Use customPainter if provided, otherwise use defaultPainter
          painter:
              widget.customPainter != null
                  ? widget.customPainter!(particles: _particles!)
                  : defaultPainter,
        );
      },
    );
  }
}
