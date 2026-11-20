import 'package:example/links.dart';
import 'package:example/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:snowfall_or_anythings/snowfall_or_anythings.dart';

/// What the package is, how to install it and who made it.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const _features = [
    (
      '❄️',
      'Snow or anything',
      'Snowflakes, hearts, stars, leaves, raindrops, circles, '
          'or any widget (images, icons, emojis).',
    ),
    (
      '🎄',
      'Mix up to 5 elements',
      'Santa, Christmas trees and stars falling together, with the '
          'percentage of each one.',
    ),
    (
      '⚡',
      'Lightweight',
      'Painted directly on the canvas, no rebuild per frame, same speed '
          'on 60 Hz and 120 Hz screens, optional FPS cap.',
    ),
    (
      '👆',
      'Overlay friendly',
      'Put it on top of your screen: buttons and fields below keep working.',
    ),
    (
      '🧩',
      'Zero dependencies',
      'Pure Flutter: Android, iOS, web, Windows, macOS and Linux.',
    ),
  ];

  static const _code = '''SnowfallOrAnythings(
  numberOfParticles: 150,
  particleVariants: const [
    ParticleVariant(type: ParticleType.snowflake, weight: 60),
    ParticleVariant(type: ParticleType.star, color: Colors.amber, weight: 20),
    ParticleVariant(widget: Text('🎅'), size: 28, weight: 10),
    ParticleVariant(widget: Text('🎄'), size: 28, weight: 10),
  ],
)''';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: Stack(
        children: [
          const Positioned.fill(
            child: SnowfallOrAnythings(
              numberOfParticles: 60,
              particleSize: 3,
              particleSpeed: 0.5,
              particleColor: Colors.white24,
              particleType: ParticleType.circular,
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        'assets/logo.png',
                        width: 120,
                        height: 120,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Snowfall or Anythings',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Make it snow in your Flutter app. Or rain hearts, '
                    'Christmas trees, leaves, stars, confetti... anything. '
                    'One widget, a few lines of code.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 20),
                  const Center(child: InstallCommand()),
                  const SizedBox(height: 24),
                  const ArticleCard(),
                  const SizedBox(height: 24),
                  for (final (emoji, title, text) in _features)
                    ListTile(
                      leading: Text(
                        emoji,
                        style: const TextStyle(fontSize: 28),
                      ),
                      title: Text(title),
                      subtitle: Text(text),
                    ),
                  const SizedBox(height: 16),
                  Text('Quick start', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const SelectableText(
                      _code,
                      style: TextStyle(fontFamily: 'monospace', fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed:
                          () => showLicensePage(
                            context: context,
                            applicationName: 'Snowfall or Anythings',
                            applicationVersion: Links.packageVersion,
                          ),
                      child: const Text('Licenses'),
                    ),
                  ),
                  const CreditsFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
