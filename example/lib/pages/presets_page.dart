import 'package:flutter/material.dart';
import 'package:snowfall_or_anythings/snowfall_or_anythings.dart';

class _Preset {
  const _Preset({
    required this.name,
    required this.icon,
    required this.background,
    required this.effect,
  });

  final String name;
  final IconData icon;
  final List<Color> background;
  final SnowfallOrAnythings effect;
}

const _presets = [
  _Preset(
    name: 'Winter',
    icon: Icons.ac_unit,
    background: [Color(0xFF0B1D3A), Color(0xFF2B4C7E)],
    effect: SnowfallOrAnythings(
      numberOfParticles: 250,
      particleSpeed: 0.8,
      particleVariants: [
        ParticleVariant(type: ParticleType.snowflake, size: 6, weight: 70),
        ParticleVariant(type: ParticleType.circular, size: 2, weight: 30),
      ],
    ),
  ),
  _Preset(
    name: 'Autumn',
    icon: Icons.eco,
    background: [Color(0xFF3E2723), Color(0xFF795548)],
    effect: SnowfallOrAnythings(
      numberOfParticles: 70,
      particleSize: 14,
      particleSpeed: 1,
      particleVariants: [
        ParticleVariant(type: ParticleType.leaf, color: Colors.orange),
        ParticleVariant(type: ParticleType.leaf, color: Colors.redAccent),
        ParticleVariant(type: ParticleType.leaf, color: Colors.amber),
        ParticleVariant(type: ParticleType.leaf, color: Color(0xFF8D6E63)),
      ],
    ),
  ),
  _Preset(
    name: 'Rain',
    icon: Icons.water_drop,
    background: [Color(0xFF263238), Color(0xFF455A64)],
    effect: SnowfallOrAnythings(
      numberOfParticles: 300,
      particleSpeed: 6,
      maxFps: 60,
      particleVariants: [
        ParticleVariant(
          type: ParticleType.raindrop,
          color: Colors.lightBlueAccent,
          size: 5,
          weight: 80,
        ),
        ParticleVariant(
          type: ParticleType.circular,
          color: Colors.white54,
          size: 1,
          weight: 20,
        ),
      ],
    ),
  ),
  _Preset(
    name: 'Love',
    icon: Icons.favorite,
    background: [Color(0xFF4A148C), Color(0xFF880E4F)],
    effect: SnowfallOrAnythings(
      numberOfParticles: 90,
      particleSize: 10,
      particleVariants: [
        ParticleVariant(
          type: ParticleType.heart,
          color: Colors.redAccent,
          weight: 45,
        ),
        ParticleVariant(
          type: ParticleType.heart,
          color: Colors.pinkAccent,
          weight: 45,
        ),
        ParticleVariant(widget: FittedBox(child: Text('💌')), size: 26),
      ],
    ),
  ),
  _Preset(
    name: 'Party',
    icon: Icons.celebration,
    background: [Color(0xFF1A237E), Color(0xFF311B92)],
    effect: SnowfallOrAnythings(
      numberOfParticles: 160,
      particleSpeed: 2,
      particleVariants: [
        ParticleVariant(
          type: ParticleType.circular,
          color: Colors.yellowAccent,
          size: 4,
        ),
        ParticleVariant(
          type: ParticleType.circular,
          color: Colors.cyanAccent,
          size: 4,
        ),
        ParticleVariant(
          type: ParticleType.star,
          color: Colors.pinkAccent,
          size: 8,
        ),
        ParticleVariant(
          type: ParticleType.star,
          color: Colors.greenAccent,
          size: 8,
        ),
        ParticleVariant(widget: FittedBox(child: Text('🎉')), size: 28),
      ],
    ),
  ),
];

/// Ready-made combinations built with particleVariants.
class PresetsPage extends StatefulWidget {
  const PresetsPage({super.key});

  @override
  State<PresetsPage> createState() => _PresetsPageState();
}

class _PresetsPageState extends State<PresetsPage> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final preset = _presets[_selected];
    return Scaffold(
      appBar: AppBar(title: const Text('Presets')),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: preset.background,
                ),
              ),
            ),
          ),
          Positioned.fill(child: preset.effect),
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (int i = 0; i < _presets.length; i++)
                  ChoiceChip(
                    avatar: Icon(_presets[i].icon, size: 18),
                    label: Text(_presets[i].name),
                    selected: i == _selected,
                    onSelected: (_) => setState(() => _selected = i),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
