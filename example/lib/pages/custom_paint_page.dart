import 'package:example/particles/my_custom_particle.dart';
import 'package:flutter/material.dart';
import 'package:snowfall_or_anythings/snowfall_or_anythings.dart';

class CustomPaintpage extends StatelessWidget {
  const CustomPaintpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom painter')),
      body: Container(
        color: const Color(0xFF1A1A2E),
        // The variants define how many particles of each kind exist and
        // their colors; the painter decides how to draw each variantIndex.
        child: SnowfallOrAnythings(
          numberOfParticles: 160,
          particleSize: 10,
          particleSpeed: 2,
          particleVariants: const [
            ParticleVariant(color: Colors.redAccent, weight: 40),
            ParticleVariant(color: Colors.amber, weight: 40),
            ParticleVariant(color: Colors.cyanAccent, size: 4, weight: 20),
          ],
          customPainter:
              ({required particles}) => ConfettiParticlePainter(particles),
        ),
      ),
    );
  }
}
