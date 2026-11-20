import 'package:flutter/material.dart';
import 'package:snowfall_or_anythings/snowfall_or_anythings.dart';

/// Widgets as particles. They keep receiving taps.
class WidgetParticlePage extends StatefulWidget {
  const WidgetParticlePage({super.key});

  @override
  State<WidgetParticlePage> createState() => _WidgetParticlePageState();
}

class _WidgetParticlePageState extends State<WidgetParticlePage> {
  int _caught = 0;

  Widget _catchable(Widget child) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () => setState(() => _caught++),
    child: FittedBox(child: child),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Widget particles · caught: $_caught')),
      body: Container(
        color: const Color(0xFF0B1D3A),
        child: SnowfallOrAnythings(
          numberOfParticles: 40,
          particleSpeed: 0.8,
          particleVariants: [
            ParticleVariant(
              widget: _catchable(const Icon(Icons.star, color: Colors.yellow)),
              size: 30,
            ),
            ParticleVariant(
              widget: _catchable(
                const Icon(Icons.favorite, color: Colors.pinkAccent),
              ),
              size: 26,
            ),
            ParticleVariant(widget: _catchable(const Text('🍪')), size: 32),
          ],
        ),
      ),
    );
  }
}
