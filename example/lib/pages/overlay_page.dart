import 'package:flutter/material.dart';
import 'package:snowfall_or_anythings/snowfall_or_anythings.dart';

/// The animation placed on top of interactive content: taps go through.
class OverlayPage extends StatefulWidget {
  const OverlayPage({super.key});

  @override
  State<OverlayPage> createState() => _OverlayPageState();
}

class _OverlayPageState extends State<OverlayPage> {
  int _taps = 0;
  bool _showSnow = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Overlay'),
        actions: [
          const Text('Snow'),
          Switch(
            value: _showSnow,
            onChanged: (v) => setState(() => _showSnow = v),
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: ListView(
                padding: const EdgeInsets.all(24),
                shrinkWrap: true,
                children: [
                  Text(
                    'The snow is on top of this content, but buttons, '
                    'fields and lists keep working.',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => setState(() => _taps++),
                    icon: const Icon(Icons.touch_app),
                    label: Text('Tapped $_taps times'),
                  ),
                  const SizedBox(height: 16),
                  const TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Type something',
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (int i = 1; i <= 3; i++)
                    CheckboxListTile(
                      value: i.isOdd,
                      onChanged: (_) {},
                      title: Text('Option $i'),
                    ),
                ],
              ),
            ),
          ),
          if (_showSnow)
            const Positioned.fill(
              child: SnowfallOrAnythings(
                numberOfParticles: 180,
                particleSpeed: 0.8,
                particleVariants: [
                  ParticleVariant(
                    type: ParticleType.snowflake,
                    size: 6,
                    weight: 60,
                  ),
                  ParticleVariant(
                    type: ParticleType.circular,
                    size: 2,
                    weight: 40,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
