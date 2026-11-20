import 'package:flutter/widgets.dart';

import 'snowfall_widget.dart' show ParticleType, SnowfallOrAnythings;

/// One kind of particle in a mixed animation, see
/// [SnowfallOrAnythings.particleVariants].
///
/// Each variant is rendered either with a built-in shape ([type]) or with a
/// [widget]. [color], [size] and [speed] are optional and fall back to the
/// values of the [SnowfallOrAnythings] widget.
///
/// [weight] defines the share of particles of this variant. Weights are
/// proportional: `60, 30, 10` and `6, 3, 1` produce the same mix.
///
/// Example:
/// ```dart
/// SnowfallOrAnythings(
///   numberOfParticles: 150,
///   particleVariants: [
///     ParticleVariant(type: ParticleType.snowflake, weight: 60),
///     ParticleVariant(type: ParticleType.star, color: Colors.amber, weight: 25),
///     ParticleVariant(widget: Text('🎅'), size: 28, weight: 15),
///   ],
/// )
/// ```
@immutable
class ParticleVariant {
  /// Creates a particle variant.
  ///
  /// Provide either [type] or [widget], not both. When neither is provided,
  /// [SnowfallOrAnythings.particleType] is used.
  const ParticleVariant({
    this.type,
    this.widget,
    this.color,
    this.size,
    this.speed,
    this.weight = 1,
  }) : assert(
         type == null || widget == null,
         'Provide either type or widget, not both.',
       ),
       assert(weight > 0, 'weight must be greater than zero.');

  /// Built-in shape used to draw the particles of this variant.
  final ParticleType? type;

  /// Widget used as particle for this variant (an image, an icon, an emoji...).
  ///
  /// The widget is sized `particle.size × particle.size` and keeps receiving
  /// pointer events.
  final Widget? widget;

  /// Color of the particles. Defaults to [SnowfallOrAnythings.particleColor].
  /// Only used by built-in shapes.
  final Color? color;

  /// Base size of the particles. Defaults to
  /// [SnowfallOrAnythings.particleSize].
  final double? size;

  /// Falling speed of the particles. Defaults to
  /// [SnowfallOrAnythings.particleSpeed].
  final double? speed;

  /// Proportional share of particles of this variant. Must be greater than
  /// zero.
  final double weight;

  /// Whether [other] produces the same particles (same share, color, size and
  /// speed). The [widget] instance is not compared, only whether it is set.
  bool hasSameLayout(ParticleVariant other) {
    return type == other.type &&
        (widget == null) == (other.widget == null) &&
        color == other.color &&
        size == other.size &&
        speed == other.speed &&
        weight == other.weight;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParticleVariant &&
          hasSameLayout(other) &&
          widget == other.widget;

  @override
  int get hashCode => Object.hash(type, widget, color, size, speed, weight);
}
