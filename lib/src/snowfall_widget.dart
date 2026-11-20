import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'particle.dart';

/// Types of particles available for rendering
enum ParticleType {
  /// Simple circular particles
  circular,

  /// Snowflake-shaped particles with branches
  snowflake,

  /// Star-shaped particles (5-pointed)
  star,

  /// Heart-shaped particles
  heart,

  /// Leaf-shaped particles with a random tilt
  leaf,

  /// Raindrop/teardrop-shaped particles
  raindrop,
}

/// A widget that creates a snowfall or any kind of falling particle animation.
///
/// This widget can display falling particles using different rendering modes:
/// - Built-in particle types (see [ParticleType])
/// - Custom painter for advanced rendering
/// - Custom widgets as particles
///
/// Particles move based on elapsed time, so the falling speed is the same on
/// 60 Hz and 120 Hz displays. Changing any parameter at runtime is applied
/// automatically, no `Key` is needed.
///
/// When rendering with a painter (built-in types or [customPainter]) the
/// widget ignores pointer events, so it can be placed over other widgets in a
/// [Stack] without blocking taps.
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

  /// Base size of particles in logical pixels.
  ///
  /// Each particle gets a random size between `2` and `particleSize + 2`.
  /// For built-in particle types this is the radius of the shape; for
  /// [particleWidget] it is the width and height of the widget.
  final double particleSize;

  /// Maximum falling speed of particles, in logical pixels per frame at 60 FPS.
  ///
  /// Each particle gets a random speed between `1` and `particleSpeed + 1`.
  final double particleSpeed;

  /// Type of particle to render (circular, snowflake, star, heart, leaf, or raindrop)
  final ParticleType particleType;

  /// Optional custom painter for advanced particle rendering
  final CustomPainter Function({required List<Particle> particles})?
  customPainter;

  /// Optional widget to use as particle (instead of painting)
  final Widget? particleWidget;

  /// Frame duration in milliseconds.
  ///
  /// This parameter never limited the frame rate in previous versions. For
  /// compatibility, a value different from the default `16` is now converted
  /// to a frame-rate cap (`1000 / frameRateMs`) when [maxFps] is not set.
  @Deprecated(
    'frameRateMs never limited the frame rate. Use maxFps instead. '
    'This parameter will be removed in a future major version.',
  )
  final int frameRateMs;

  /// Maximum number of animation updates per second.
  ///
  /// When `null` (default) the animation follows the display refresh rate.
  /// Use lower values (e.g. `30`) to save battery. The falling speed is not
  /// affected, only the smoothness.
  final double? maxFps;

  const SnowfallOrAnythings({
    super.key,
    this.numberOfParticles = 200,
    this.particleColor = Colors.white,
    this.particleSize = 4.0,
    this.particleSpeed = 1.0,
    this.particleType = ParticleType.snowflake,
    this.customPainter,
    this.particleWidget,
    @Deprecated(
      'frameRateMs never limited the frame rate. Use maxFps instead. '
      'This parameter will be removed in a future major version.',
    )
    this.frameRateMs = 16,
    this.maxFps,
  });

  @override
  State<SnowfallOrAnythings> createState() => _SnowfallOrAnythingsState();
}

class _SnowfallOrAnythingsState extends State<SnowfallOrAnythings>
    with SingleTickerProviderStateMixin {
  /// Duration of one frame at 60 FPS, the unit used by [Particle.speed].
  static const double _microsPerReferenceFrame = 1000000 / 60;

  /// Upper bound for a single step, avoids big jumps after the app was paused.
  static const double _maxDelta = 6;

  late final Ticker _ticker;
  final _FrameNotifier _frame = _FrameNotifier();
  List<Particle>? _particles;
  Size _areaSize = Size.zero;
  Duration _lastStep = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void didUpdateWidget(covariant SnowfallOrAnythings oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.numberOfParticles != widget.numberOfParticles ||
        oldWidget.particleColor != widget.particleColor ||
        oldWidget.particleSize != widget.particleSize ||
        oldWidget.particleSpeed != widget.particleSpeed) {
      // Regenerated in the next build with the current area size.
      _particles = null;
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _frame.dispose();
    super.dispose();
  }

  double? get _effectiveMaxFps {
    final maxFps = widget.maxFps;
    if (maxFps != null) return maxFps > 0 ? maxFps : null;
    // ignore: deprecated_member_use_from_same_package
    final frameRateMs = widget.frameRateMs;
    return frameRateMs != 16 && frameRateMs > 0 ? 1000 / frameRateMs : null;
  }

  void _onTick(Duration elapsed) {
    final particles = _particles;
    if (particles == null || _areaSize.isEmpty) {
      _lastStep = elapsed;
      return;
    }

    final elapsedMicros = (elapsed - _lastStep).inMicroseconds;
    final maxFps = _effectiveMaxFps;
    if (maxFps != null) {
      // 10% tolerance absorbs vsync jitter (e.g. 16ms frames at a 60 FPS cap).
      final minIntervalMicros = 1000000 / maxFps * 0.9;
      if (elapsedMicros < minIntervalMicros) return;
    }
    _lastStep = elapsed;

    final delta = math.min(elapsedMicros / _microsPerReferenceFrame, _maxDelta);
    if (delta <= 0) return;

    final width = _areaSize.width;
    final height = _areaSize.height;
    for (final particle in particles) {
      particle.advance(width, height, delta);
    }
    _frame.notify();
  }

  List<Particle> _createParticles(Size size) {
    return List.generate(
      widget.numberOfParticles,
      (_) => Particle.random(
        color: widget.particleColor,
        size: widget.particleSize,
        speed: widget.particleSpeed,
        width: size.width,
        height: size.height,
      ),
    );
  }

  /// Keeps particles proportionally placed when the available area changes
  /// (e.g. device rotation or window resize).
  void _updateAreaSize(Size size) {
    final particles = _particles;
    if (particles != null &&
        !_areaSize.isEmpty &&
        !size.isEmpty &&
        size != _areaSize) {
      final scaleX = size.width / _areaSize.width;
      final scaleY = size.height / _areaSize.height;
      for (final particle in particles) {
        particle
          ..x *= scaleX
          ..y *= scaleY;
      }
    }
    _areaSize = size;
  }

  CustomPainter _builtInPainter(List<Particle> particles) {
    return switch (widget.particleType) {
      ParticleType.circular => CircularParticlePainter(
        particles: particles,
        repaint: _frame,
      ),
      ParticleType.snowflake => SnowflakeParticlePainter(
        snowflakes: particles,
        repaint: _frame,
      ),
      ParticleType.star => StarParticlePainter(
        particles: particles,
        repaint: _frame,
      ),
      ParticleType.heart => HeartParticlePainter(
        particles: particles,
        repaint: _frame,
      ),
      ParticleType.leaf => LeafParticlePainter(
        particles: particles,
        repaint: _frame,
      ),
      ParticleType.raindrop => RaindropParticlePainter(
        particles: particles,
        repaint: _frame,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = MediaQuery.sizeOf(context);
        final size = Size(
          constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : screenSize.width,
          constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : screenSize.height,
        );
        _updateAreaSize(size);
        final particles = _particles ??= _createParticles(size);

        if (particles.isEmpty) {
          return const SizedBox.shrink();
        }

        // Widget particles: positioned at paint time with a Flow, so no
        // rebuild or relayout happens on each frame.
        final particleWidget = widget.particleWidget;
        if (particleWidget != null) {
          return RepaintBoundary(
            child: SizedBox.fromSize(
              size: size,
              child: Flow(
                delegate: _ParticleFlowDelegate(
                  particles: particles,
                  repaint: _frame,
                ),
                children: [for (final _ in particles) particleWidget],
              ),
            ),
          );
        }

        final customPainter = widget.customPainter;
        final Widget painted;
        if (customPainter != null) {
          // The callback is invoked on every frame, as in previous versions.
          painted = ListenableBuilder(
            listenable: _frame,
            builder:
                (context, _) => CustomPaint(
                  size: size,
                  painter: _CustomPainterHost(
                    customPainter(particles: particles),
                    repaint: _frame,
                  ),
                ),
          );
        } else {
          painted = CustomPaint(
            size: size,
            painter: _builtInPainter(particles),
          );
        }

        return IgnorePointer(child: RepaintBoundary(child: painted));
      },
    );
  }
}

/// Notifies listeners once per animation step.
class _FrameNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

/// Wraps a user provided painter so it is repainted on every animation step,
/// regardless of its own `shouldRepaint` implementation.
class _CustomPainterHost extends CustomPainter {
  _CustomPainterHost(this.delegate, {required Listenable repaint})
    : super(repaint: repaint);

  final CustomPainter delegate;

  @override
  void paint(Canvas canvas, Size size) => delegate.paint(canvas, size);

  @override
  bool shouldRepaint(covariant _CustomPainterHost oldDelegate) {
    return oldDelegate.delegate.runtimeType != delegate.runtimeType ||
        delegate.shouldRepaint(oldDelegate.delegate);
  }
}

/// Paints each particle widget at its particle position.
class _ParticleFlowDelegate extends FlowDelegate {
  _ParticleFlowDelegate({required this.particles, required super.repaint});

  final List<Particle> particles;

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
    return BoxConstraints.tight(Size.square(particles[i].size));
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    final count = math.min(context.childCount, particles.length);
    for (int i = 0; i < count; i++) {
      final particle = particles[i];
      context.paintChild(
        i,
        transform: Matrix4.translationValues(particle.x, particle.y, 0),
      );
    }
  }

  @override
  bool shouldRelayout(covariant _ParticleFlowDelegate oldDelegate) {
    return !identical(oldDelegate.particles, particles);
  }

  @override
  bool shouldRepaint(covariant _ParticleFlowDelegate oldDelegate) {
    return !identical(oldDelegate.particles, particles);
  }
}
