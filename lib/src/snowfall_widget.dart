import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'particle.dart';
import 'particle_variant.dart';

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

  /// Mix of up to [maxParticleVariants] kinds of particles falling together,
  /// each with its own share of [numberOfParticles].
  ///
  /// When set (and not empty), [particleType] and [particleWidget] are only
  /// used as fallbacks for variants without `type` or `widget`. If
  /// [customPainter] is also set, it draws all particles; use
  /// [Particle.variantIndex] to tell them apart.
  ///
  /// The particles are split exactly according to [ParticleVariant.weight]:
  /// with 100 particles and weights `60, 30, 10` there will be 60, 30 and 10
  /// particles of each variant.
  final List<ParticleVariant>? particleVariants;

  /// Maximum number of entries used from [particleVariants].
  static const int maxParticleVariants = 5;

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
    this.particleVariants,
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

  /// Particles of each variant, sharing the instances of [_particles].
  List<List<Particle>> _variantParticles = const [];
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
        oldWidget.particleSpeed != widget.particleSpeed ||
        !_sameVariantLayout(
          oldWidget.particleVariants,
          widget.particleVariants,
        )) {
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

  /// Active variants, or `null` when [SnowfallOrAnythings.particleVariants]
  /// is not used.
  List<ParticleVariant>? get _variants {
    final variants = widget.particleVariants;
    if (variants == null || variants.isEmpty) return null;
    assert(
      variants.length <= SnowfallOrAnythings.maxParticleVariants,
      'particleVariants supports up to '
      '${SnowfallOrAnythings.maxParticleVariants} entries, '
      'got ${variants.length}. Extra entries are ignored.',
    );
    return variants.length > SnowfallOrAnythings.maxParticleVariants
        ? variants.sublist(0, SnowfallOrAnythings.maxParticleVariants)
        : variants;
  }

  /// Widget instances may be recreated on every parent build; only a change
  /// in the particle mix requires regenerating the particles.
  static bool _sameVariantLayout(
    List<ParticleVariant>? a,
    List<ParticleVariant>? b,
  ) {
    if (identical(a, b)) return true;
    final aEmpty = a == null || a.isEmpty;
    final bEmpty = b == null || b.isEmpty;
    if (aEmpty || bEmpty) return aEmpty == bEmpty;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (!a[i].hasSameLayout(b[i])) return false;
    }
    return true;
  }

  /// Splits [total] proportionally to [weights] using the largest remainder
  /// method, so the counts always add up to [total].
  static List<int> _distribute(int total, List<double> weights) {
    final sum = weights.fold<double>(0, (a, b) => a + b);
    if (total <= 0 || sum <= 0) return List.filled(weights.length, 0);
    final exact = [for (final w in weights) total * w / sum];
    final counts = [for (final e in exact) e.floor()];
    var remaining = total - counts.fold<int>(0, (a, b) => a + b);
    final order = List.generate(weights.length, (i) => i)
      ..sort((a, b) => (exact[b] - counts[b]).compareTo(exact[a] - counts[a]));
    for (final i in order) {
      if (remaining <= 0) break;
      counts[i]++;
      remaining--;
    }
    return counts;
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
    final variants = _variants;
    if (variants != null) {
      final counts = _distribute(widget.numberOfParticles, [
        for (final v in variants) v.weight,
      ]);
      _variantParticles = [
        for (int i = 0; i < variants.length; i++)
          List.generate(
            counts[i],
            (_) => Particle.random(
              color: variants[i].color ?? widget.particleColor,
              size: variants[i].size ?? widget.particleSize,
              speed: variants[i].speed ?? widget.particleSpeed,
              width: size.width,
              height: size.height,
              variantIndex: i,
            ),
          ),
      ];
      return [for (final list in _variantParticles) ...list];
    }

    _variantParticles = const [];
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

  CustomPainter _builtInPainter(
    List<Particle> particles, [
    ParticleType? type,
  ]) {
    return switch (type ?? widget.particleType) {
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
        // The first layout can have an empty size (e.g. Android startup):
        // wait for the real area instead of creating particles for it.
        if (size.isEmpty) return const SizedBox.shrink();
        final particles = _particles ??= _createParticles(size);

        if (particles.isEmpty) {
          return const SizedBox.shrink();
        }

        final customPainter = widget.customPainter;
        final variants = _variants;
        if (variants != null && customPainter == null) {
          return _buildVariants(size, variants);
        }

        // Widget particles: positioned at paint time with a Flow, so no
        // rebuild or relayout happens on each frame.
        final particleWidget = widget.particleWidget;
        if (particleWidget != null && variants == null) {
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

        // Painters don't clip by themselves: keep particles inside the area.
        return IgnorePointer(
          child: RepaintBoundary(child: ClipRect(child: painted)),
        );
      },
    );
  }

  /// Shapes are drawn in a single [CustomPaint] (one painter per variant)
  /// and widgets are positioned in a [Flow] on top of them.
  Widget _buildVariants(Size size, List<ParticleVariant> variants) {
    final painters = <CustomPainter>[];
    final widgetParticles = <Particle>[];
    final widgetChildren = <Widget>[];

    for (int i = 0; i < variants.length && i < _variantParticles.length; i++) {
      final particles = _variantParticles[i];
      if (particles.isEmpty) continue;
      final variant = variants[i];
      final child =
          variant.widget ??
          (variant.type == null ? widget.particleWidget : null);
      if (child != null) {
        widgetParticles.addAll(particles);
        widgetChildren.addAll(List.filled(particles.length, child));
      } else {
        painters.add(_builtInPainter(particles, variant.type));
      }
    }

    return SizedBox.fromSize(
      size: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (painters.isNotEmpty)
            IgnorePointer(
              child: RepaintBoundary(
                child: ClipRect(
                  child: CustomPaint(
                    size: size,
                    painter: _CompositePainter(painters, repaint: _frame),
                  ),
                ),
              ),
            ),
          if (widgetChildren.isNotEmpty)
            RepaintBoundary(
              child: Flow(
                delegate: _ParticleFlowDelegate(
                  particles: widgetParticles,
                  repaint: _frame,
                ),
                children: widgetChildren,
              ),
            ),
        ],
      ),
    );
  }
}

/// Paints several built-in painters in order on the same canvas.
class _CompositePainter extends CustomPainter {
  _CompositePainter(this.painters, {required Listenable repaint})
    : super(repaint: repaint);

  final List<CustomPainter> painters;

  @override
  void paint(Canvas canvas, Size size) {
    for (final painter in painters) {
      painter.paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant _CompositePainter oldDelegate) {
    if (oldDelegate.painters.length != painters.length) return true;
    for (int i = 0; i < painters.length; i++) {
      final oldPainter = oldDelegate.painters[i];
      if (oldPainter.runtimeType != painters[i].runtimeType ||
          painters[i].shouldRepaint(oldPainter)) {
        return true;
      }
    }
    return false;
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
