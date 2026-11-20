import 'package:example/links.dart';
import 'package:example/pages/about_page.dart';
import 'package:example/pages/custom_paint_page.dart';
import 'package:example/pages/frame_rate_page.dart';
import 'package:example/pages/mix_page.dart';
import 'package:example/pages/overlay_page.dart';
import 'package:example/pages/particle_types_page.dart';
import 'package:example/pages/playground_page.dart';
import 'package:example/pages/presets_page.dart';
import 'package:example/pages/snow_page.dart';
import 'package:example/pages/widget_page.dart';
import 'package:example/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:snowfall_or_anythings/snowfall_or_anythings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snowfall or Anythings',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.lightBlue,
        brightness: Brightness.dark,
      ),
      // No initialRoute: the web URL (/#/mix) or the Android intent decides.
      onGenerateRoute: (settings) {
        final name = settings.name ?? '/';
        final Widget page;
        if (name == '/about') {
          page = const AboutPage();
        } else {
          final demo = _demos.where((d) => d.route == name).firstOrNull;
          page = demo?.page() ?? const MainPage();
        }
        return MaterialPageRoute(settings: settings, builder: (_) => page);
      },
    );
  }
}

class _Demo {
  const _Demo(
    this.title,
    this.subtitle,
    this.icon,
    this.route,
    this.page,
    this.preview,
  );

  final String title;
  final String subtitle;
  final IconData icon;

  /// Also the web URL: snowfall.valdir.dev.br/#/mix
  final String route;
  final Widget Function() page;
  final Widget preview;
}

final _demos = <_Demo>[
  _Demo(
    'Playground',
    'Every parameter, live',
    Icons.tune,
    '/playground',
    () => const PlaygroundPage(),
    const SnowfallOrAnythings(
      numberOfParticles: 30,
      particleSize: 5,
      particleType: ParticleType.snowflake,
    ),
  ),
  _Demo(
    'Christmas mix',
    'Up to 5 elements with % of each',
    Icons.celebration,
    '/mix',
    () => const MixPage(),
    const SnowfallOrAnythings(
      numberOfParticles: 24,
      particleVariants: [
        ParticleVariant(type: ParticleType.snowflake, weight: 50),
        ParticleVariant(
          type: ParticleType.star,
          color: Colors.amber,
          weight: 20,
        ),
        ParticleVariant(widget: Text('🎅'), size: 16, weight: 15),
        ParticleVariant(widget: Text('🎄'), size: 16, weight: 15),
      ],
    ),
  ),
  _Demo(
    'Presets',
    'Winter, autumn, rain, love, party',
    Icons.auto_awesome,
    '/presets',
    () => const PresetsPage(),
    const SnowfallOrAnythings(
      numberOfParticles: 20,
      particleSize: 8,
      particleVariants: [
        ParticleVariant(type: ParticleType.leaf, color: Colors.orange),
        ParticleVariant(type: ParticleType.leaf, color: Colors.redAccent),
        ParticleVariant(type: ParticleType.leaf, color: Colors.amber),
      ],
    ),
  ),
  _Demo(
    'Particle types',
    'All built-in shapes',
    Icons.category,
    '/types',
    () => const ParticleTypesPage(),
    const SnowfallOrAnythings(
      numberOfParticles: 18,
      particleSize: 7,
      particleColor: Colors.pinkAccent,
      particleType: ParticleType.heart,
    ),
  ),
  _Demo(
    'Overlay',
    'Snow on top, taps still work',
    Icons.layers,
    '/overlay',
    () => const OverlayPage(),
    const SnowfallOrAnythings(
      numberOfParticles: 30,
      particleType: ParticleType.circular,
      particleSize: 2,
    ),
  ),
  _Demo(
    'Widget particles',
    'Icons/emojis you can tap',
    Icons.touch_app,
    '/widgets',
    () => const WidgetParticlePage(),
    const SnowfallOrAnythings(
      numberOfParticles: 12,
      particleSize: 18,
      particleWidget: Icon(Icons.star, color: Colors.yellow),
    ),
  ),
  _Demo(
    'Custom painter',
    'Your own shapes + variantIndex',
    Icons.brush,
    '/painter',
    () => const CustomPaintpage(),
    const SnowfallOrAnythings(
      numberOfParticles: 30,
      particleType: ParticleType.raindrop,
      particleColor: Colors.lightBlueAccent,
      particleSize: 5,
      particleSpeed: 3,
    ),
  ),
  _Demo(
    'Frame rate',
    'maxFps: smooth vs battery',
    Icons.speed,
    '/fps',
    () => const FrameRatePage(),
    const SnowfallOrAnythings(
      numberOfParticles: 30,
      particleType: ParticleType.snowflake,
      maxFps: 15,
    ),
  ),
  _Demo(
    'Basic snowfall',
    'The simplest usage',
    Icons.ac_unit,
    '/basic',
    () => const SnowPage(),
    const SnowfallOrAnythings(numberOfParticles: 30, particleSize: 3),
  ),
];

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Snowfall or Anythings'),
        actions: [
          IconButton(
            tooltip: 'About',
            icon: const Icon(Icons.info_outline),
            onPressed: () => Navigator.pushNamed(context, '/about'),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: _Hero()),
          SliverToBoxAdapter(
            child: _Section(
              child: Padding(
                padding: const EdgeInsets.only(top: 24),
                child: const ArticleCard(),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _Section(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 32, 4, 12),
                child: Text(
                  'Live demos',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          SliverLayoutBuilder(
            builder: (context, constraints) {
              final horizontal =
                  ((constraints.crossAxisExtent - _Section.maxWidth) / 2).clamp(
                    16.0,
                    double.infinity,
                  );
              return SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: horizontal),
                sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    // One column on phones, more on tablets/desktop.
                    maxCrossAxisExtent: 480,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: _demos.length,
                  itemBuilder:
                      (context, index) => _DemoCard(demo: _demos[index]),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: CreditsFooter()),
        ],
      ),
    );
  }
}

/// Centers content with a max width, matching the demo grid.
class _Section extends StatelessWidget {
  const _Section({required this.child});

  static const double maxWidth = 1100;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: child,
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  static const _themes = [
    '❄️ Snow',
    '❤️ Hearts',
    '🎄 Christmas',
    '🍂 Leaves',
    '💧 Rain',
    '⭐ Stars',
    '🎉 Party',
    '🧩 Any widget',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0B1D3A), Color(0xFF2A2350)],
        ),
      ),
      child: Stack(
        children: [
          const Positioned.fill(
            child: SnowfallOrAnythings(
              numberOfParticles: 90,
              particleSpeed: 0.7,
              particleVariants: [
                ParticleVariant(
                  type: ParticleType.snowflake,
                  size: 6,
                  weight: 55,
                ),
                ParticleVariant(
                  type: ParticleType.star,
                  color: Colors.amber,
                  size: 6,
                  weight: 15,
                ),
                ParticleVariant(
                  type: ParticleType.heart,
                  color: Colors.pinkAccent,
                  size: 6,
                  weight: 10,
                ),
                ParticleVariant(
                  widget: FittedBox(child: Text('🎄')),
                  size: 22,
                  weight: 10,
                ),
                ParticleVariant(
                  widget: FittedBox(child: Text('🎅')),
                  size: 22,
                  weight: 10,
                ),
              ],
            ),
          ),
          _Section(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Image.asset(
                      'assets/logo.png',
                      width: 96,
                      height: 96,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Make it snow in your Flutter app.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Text(
                      'Or hearts, Christmas trees, Santa, leaves, rain, '
                      'confetti... anything. Mix up to 5 elements with the '
                      'percentage of each, in one lightweight widget. '
                      'Everything on this page is running live.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final label in _themes)
                        Chip(
                          label: Text(label),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const InstallCommand(),
                  const SizedBox(height: 20),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () => openLink(context, Links.article),
                        icon: const Icon(Icons.menu_book),
                        label: const Text('Read how it was built'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => openLink(context, Links.pubDev),
                        icon: const Icon(Icons.inventory_2_outlined),
                        label: const Text('View on pub.dev'),
                      ),
                      TextButton.icon(
                        onPressed: () => openLink(context, Links.github),
                        icon: const Icon(Icons.code),
                        label: const Text('GitHub'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoCard extends StatelessWidget {
  const _DemoCard({required this.demo});

  final _Demo demo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, demo.route),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF0B1D3A), Color(0xFF1F3B63)],
                  ),
                ),
                child: demo.preview,
              ),
            ),
            ListTile(
              leading: Icon(demo.icon, color: theme.colorScheme.primary),
              title: Text(demo.title),
              subtitle: Text(demo.subtitle),
            ),
          ],
        ),
      ),
    );
  }
}
