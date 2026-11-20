import 'package:flutter/material.dart';
import 'package:snowfall_or_anythings/snowfall_or_anythings.dart';

class _Element {
  _Element(this.label, this.preview, this.build, this.weight);

  final String label;
  final Widget preview;
  final ParticleVariant Function(double weight) build;
  double weight;
  bool enabled = true;
}

/// Up to 5 elements falling together, with the share of each one.
class MixPage extends StatefulWidget {
  const MixPage({super.key});

  @override
  State<MixPage> createState() => _MixPageState();
}

class _MixPageState extends State<MixPage> {
  double _count = 120;

  final _elements = <_Element>[
    _Element(
      'Snowflake',
      const Icon(Icons.ac_unit, color: Colors.white),
      (w) => ParticleVariant(type: ParticleType.snowflake, size: 6, weight: w),
      50,
    ),
    _Element(
      'Star',
      const Icon(Icons.star, color: Colors.amber),
      (w) => ParticleVariant(
        type: ParticleType.star,
        color: Colors.amber,
        size: 8,
        weight: w,
      ),
      20,
    ),
    _Element(
      'Santa',
      const Text('🎅', style: TextStyle(fontSize: 22)),
      (w) => ParticleVariant(
        widget: const FittedBox(child: Text('🎅')),
        size: 30,
        speed: 1.2,
        weight: w,
      ),
      10,
    ),
    _Element(
      'Tree',
      const Text('🎄', style: TextStyle(fontSize: 22)),
      (w) => ParticleVariant(
        widget: const FittedBox(child: Text('🎄')),
        size: 30,
        speed: 1.2,
        weight: w,
      ),
      10,
    ),
    _Element(
      'Gift',
      const Text('🎁', style: TextStyle(fontSize: 22)),
      (w) => ParticleVariant(
        widget: const FittedBox(child: Text('🎁')),
        size: 24,
        weight: w,
      ),
      10,
    ),
  ];

  Iterable<_Element> get _active =>
      _elements.where((e) => e.enabled && e.weight > 0);

  double get _total => _active.fold(0, (sum, e) => sum + e.weight);

  @override
  Widget build(BuildContext context) {
    final active = _active.toList();
    final wide = MediaQuery.sizeOf(context).width > 800;

    final animation = Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0B1D3A), Color(0xFF3A1C3F)],
        ),
      ),
      child:
          active.isEmpty
              ? const Center(child: Text('Enable at least one element'))
              : SnowfallOrAnythings(
                numberOfParticles: _count.round(),
                particleVariants: [for (final e in active) e.build(e.weight)],
              ),
    );

    final controls = ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'particleVariants: up to ${SnowfallOrAnythings.maxParticleVariants} '
          'elements, weight = share of each',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Row(
          children: [
            const Text('Particles'),
            Expanded(
              child: Slider(
                value: _count,
                min: 10,
                max: 400,
                onChanged: (v) => setState(() => _count = v),
              ),
            ),
            Text('${_count.round()}'),
          ],
        ),
        for (final element in _elements) _elementTile(element),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Christmas mix')),
      body:
          wide
              ? Row(
                children: [
                  Expanded(child: animation),
                  SizedBox(width: 380, child: controls),
                ],
              )
              : Column(
                children: [
                  Expanded(child: animation),
                  SizedBox(height: 330, child: controls),
                ],
              ),
    );
  }

  Widget _elementTile(_Element element) {
    final total = _total;
    final active = element.enabled && element.weight > 0;
    final percent = active && total > 0 ? element.weight / total * 100 : 0.0;
    final count = (_count * percent / 100).round();

    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
        child: Row(
          children: [
            SizedBox(width: 32, child: Center(child: element.preview)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${element.label}  ·  ${percent.toStringAsFixed(0)}% '
                    '(~$count)',
                  ),
                  Slider(
                    value: element.weight,
                    max: 100,
                    onChanged:
                        element.enabled
                            ? (v) => setState(() => element.weight = v)
                            : null,
                  ),
                ],
              ),
            ),
            Switch(
              value: element.enabled,
              onChanged: (v) => setState(() => element.enabled = v),
            ),
          ],
        ),
      ),
    );
  }
}
