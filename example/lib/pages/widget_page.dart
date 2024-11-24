import 'package:flutter/material.dart';
import 'package:snowfall_or_anythings/snowfall_or_anythings.dart';

class WidgetParticlePage extends StatelessWidget {
  const WidgetParticlePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Widget Particle Demo'),
      ),
      body: const SnowfallOrAnythings(
        numberOfParticles: 100,
        particleSize: 30.0,
        particleSpeed: 1.0,
        particleWidget: Icon(
          Icons.star,
          color: Colors.yellow,
        ),
      ),
    );
  }
}
